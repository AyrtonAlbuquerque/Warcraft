library KegSmash requires SpellEffectEvent, PluginSpellEffect, NewBonusUtils, Utilities, Missiles, TimerUtils, CrowdControl
    /* ----------------------- Keg Smash v1.3 by Chopinski ---------------------- */
    // Credits:
    //     Blizzard           - Icon
    //     Bribe              - SpellEffectEvent
    //     Vexorian           - TimerUtils
    //     JesusHipster       - Barrel model
    //     EvilCryptLord      - Brew Cloud model (edited by me)
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The Keg Smash Ability
        private constant integer ABILITY      = 'A001'
        // The Keg Smash Ignite ability
        private constant integer IGNITE       = 'A004'
        // The Keg Smash Brew Cloud Ability
        private constant integer DEBUFF       = 'A002'
        // The Keg Smash Brew Cloud debuff
        public  constant integer BUFF         = 'BNdh'
        // The Keg Smash Missile model
        private constant string  MODEL        = "RollingKegMissle.mdl"
        // The Keg Smash Missile scale
        private constant real    SCALE        = 1.25
        // The Keg Smash Missile speed
        private constant real    SPEED        = 1000.
        // The Keg Smash Brew Cloud model
        private constant string  CLOUD        = "BrewCloud.mdl"
        // The Keg Smash Brew Cloud scale
        private constant real    CLOUD_SCALE  = 0.6
        // The Keg Smash Brew Cloud Period
        private constant real    PERIOD       = 0.5
    endglobals

    // The Keg Smash miss chance per level
    private function GetChance takes integer level returns real
        return 20.*level
    endfunction

    // The Keg Smash Brew Cloud duration
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The Keg Smash slow amount
    private function GetSlow takes unit source, integer level returns real
        return 0.4 + 0.*level
    endfunction

    // The Keg Smash slow duration
    private function GetSlowDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, DEBUFF), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The Keg Smash AoE
    public function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The Keg Smash Damage
    private function GetDamage takes integer level returns real
        return 75. + 50.*level
    endfunction

    // The Keg Smash Damage Filter for enemy units
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Ignite
        static integer array proxy

        timer     timer
        unit      unit
        unit      dummy
        real      damage
        integer   index

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call UnitRemoveAbility(dummy, IGNITE)
            call DummyRecycle(dummy)
            call ReleaseTimer(timer)
            call deallocate()

            set unit  = null
            set dummy = null
            set timer = null
            set proxy[index] = 0
        endmethod

        static method create takes real x, real y, real dmg, real duration, real aoe, real interval, unit source returns thistype
            local thistype this = thistype.allocate()
            local ability  abi

            set timer        = NewTimerEx(this)
            set unit         = source
            set damage       = dmg
            set dummy        = DummyRetrieve(GetOwningPlayer(source), x, y, 0, 0)
            set index        = GetUnitUserData(dummy)
            set proxy[index] = this

            call UnitAddAbility(dummy, IGNITE)
            set abi = BlzGetUnitAbility(dummy, IGNITE)
            call BlzSetAbilityRealLevelField(abi, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            call BlzSetAbilityRealLevelField(abi, ABILITY_RLF_FULL_DAMAGE_INTERVAL, 0, duration)
            call BlzSetAbilityRealLevelField(abi, ABILITY_RLF_HALF_DAMAGE_INTERVAL, 0, interval)
            call BlzSetAbilityRealLevelField(abi, ABILITY_RLF_AREA_OF_EFFECT, 0, aoe)
            call BlzSetAbilityRealLevelField(abi, ABILITY_RLF_HALF_DAMAGE_DEALT, 0, dmg)
            call IncUnitAbilityLevel(dummy, IGNITE)
            call DecUnitAbilityLevel(dummy, IGNITE)
            call IssuePointOrder(dummy, "flamestrike", x, y)
            call TimerStart(timer, duration + 0.05, false, function thistype.onExpire)

            set abi = null
            return this
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this

            if proxy[Damage.source.id] != 0 and GetEventDamage() > 0 then
                set this = proxy[Damage.source.id]
                call BlzSetEventDamage(0)
                call UnitDamageTarget(unit, Damage.target.unit, damage, false, false, Damage.attacktype, Damage.damagetype, null)
            endif
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterSpellDamageEvent(function thistype.onDamage)
        endmethod 
    endstruct

    struct BrewCloud
        private static thistype array n
        private static thistype array data
		private static integer didx  = -1
        private static timer timer = CreateTimer()

        private unit source
        private unit unit
        private group group
        private player player
        private effect effect
        private boolean ignited
        private integer duration
        private integer level
        private integer index
        private real slow
        private real slowDuration
        private real aoe
        private real x
        private real y

        private method remove takes integer i returns integer
            call UnitRemoveAbility(unit, DEBUFF)
            call DestroyGroup(group)
            call DestroyEffect(effect)
            call DummyRecycle(unit)

            set unit = null
            set group = null
            set player = null
            set effect = null
            set source = null
            set n[index] = 0
			set data[i] = data[didx]
			set didx = didx - 1

			if didx == -1 then
				call PauseTimer(timer)
			endif

			call deallocate()

			return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local thistype this
            local unit u
	
			loop
				exitwhen i > didx
					set this = data[i]

                    if duration > 0 then
                        if not ignited then
                            call GroupEnumUnitsInRange(group, x, y, aoe, null)
                            loop
                                set u = FirstOfGroup(group)
                                exitwhen u == null
                                    if UnitAlive(u) and IsUnitEnemy(u, player) and GetUnitAbilityLevel(u, BUFF) == 0 then
                                        if not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) then
                                            call IssueTargetOrder(unit, "drunkenhaze", u)
                                            call SlowUnit(u, slow, slowDuration, null, null, false)
                                        endif
                                    endif
                                call GroupRemoveUnit(group, u)
                            endloop
                        else
                            call DestroyEffect(effect)
                        endif
					else
						set i = remove(i)
                    endif
                    set duration = duration - 1
				set i = i + 1
			endloop
        endmethod

        static method ignite takes unit dummy, real damage, real duration, real interval returns nothing
            local integer  i = GetUnitUserData(dummy)
            local thistype this

            if n[i] != 0 then
                set this = n[i]
                if not ignited then
                    set .ignited  = true
                    set .duration = 0
                    call Ignite.create(x, y, damage, duration, aoe, interval, source)
                endif
            endif
        endmethod

        static method active takes unit dummy returns boolean
            local thistype this = n[GetUnitUserData(dummy)]

            if this != 0 then
                return not ignited
            endif

            return false
        endmethod

        static method create takes player owner, unit source, unit dummy, real x, real y, real aoe, real dur, real slow, real slowDuration, integer level returns thistype
            local thistype this = thistype.allocate()

            set .x = x 
            set .y = y
            set .aoe = aoe
            set .slow = slow
            set .slowDuration = slowDuration
            set .level = level
            set .source = source
            set player = owner
            set unit = dummy
            set ignited = false
            set index = GetUnitUserData(dummy)
            set group = CreateGroup()
            set effect = AddSpecialEffectEx(CLOUD, x, y, 0, CLOUD_SCALE)
            set duration = R2I(dur/PERIOD)
            set didx = didx + 1
            set data[didx] = this
            set n[index] = this
            

            if didx == 0 then
                call TimerStart(timer, PERIOD, true, function thistype.onPeriod)
            endif

            return this
        endmethod

        private static method onCast takes nothing returns nothing
            if GetUnitAbilityLevel(GetSpellTargetUnit(), BUFF) == 0 then
                call LinkBonusToBuff(GetSpellTargetUnit(), BONUS_MISS_CHANCE, GetChance(GetUnitAbilityLevel(GetTriggerUnit(), DEBUFF)), BUFF)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(DEBUFF, function thistype.onCast)
        endmethod
    endstruct

    private struct KegSmash extends Missiles
        unit unit
        group group
        integer level
        real aoe
        real dur
        real slow
        real slowDuration

        method onFinish takes nothing returns boolean
            local unit u

            call BrewCloud.create(owner, source, unit, x, y, aoe, dur, slow, slowDuration, level)
            call GroupEnumUnitsInRange(group, x, y, aoe, null)
            loop
                set u = FirstOfGroup(group)
                exitwhen u == null
                    if DamageFilter(owner, u) then
                        if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                            call IssueTargetOrder(unit, "drunkenhaze", u)
                            call SlowUnit(u, slow, slowDuration, null, null, false)
                        endif
                    endif
                call GroupRemoveUnit(group, u)
            endloop
            call DestroyGroup(group)

            set unit = null
            set group = null
            return true
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.create(Spell.source.x, Spell.source.y, 60, Spell.x, Spell.y, 60)

            set unit = DummyRetrieve(Spell.source.player, Spell.x, Spell.y, 0, 0)
            call UnitAddAbility(unit, DEBUFF)
            call SetUnitAbilityLevel(unit, DEBUFF, Spell.level)

            set model = MODEL
            set scale = SCALE
            set speed = SPEED
            set source = Spell.source.unit 
            set owner = Spell.source.player
            set level = Spell.level
            set group = CreateGroup()
            set damage = GetDamage(Spell.level)
            set aoe = GetAoE(Spell.source.unit, Spell.level)
            set dur = GetDuration(Spell.source.unit, Spell.level)
            set slow = GetSlow(Spell.source.unit, Spell.level)
            set slowDuration = GetSlowDuration(unit, Spell.level)

            call launch()
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary