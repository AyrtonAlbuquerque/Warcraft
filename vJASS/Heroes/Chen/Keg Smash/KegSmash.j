library KegSmash requires Spell, NewBonus, Utilities, Missiles, TimerUtils, CrowdControl
    /* ----------------------- Keg Smash v1.4 by Chopinski ---------------------- */
    // Credits:
    //     Blizzard           - Icon
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
        return 0.2*level
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
    private function GetDamage takes unit source, integer level returns real
        return 75. + 50.*level + (0.6 + 0.1*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
    endfunction

    // The Keg Smash Damage Filter for enemy units
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Ignite
        private static integer array proxy

        private unit unit
        private unit dummy
        private integer id
        private real damage

        method destroy takes nothing returns nothing
            call UnitRemoveAbility(dummy, IGNITE)
            call DummyRecycle(dummy)
            call deallocate()

            set unit = null
            set dummy = null
            set proxy[id] = 0
        endmethod

        static method create takes real x, real y, real dmg, real duration, real aoe, real interval, unit source returns thistype
            local thistype this = thistype.allocate()
            local ability spell

            set unit = source
            set damage = dmg
            set dummy = DummyRetrieve(GetOwningPlayer(source), x, y, 0, 0)
            set id = GetUnitUserData(dummy)
            set proxy[id] = this

            call UnitAddAbility(dummy, IGNITE)
            set spell = BlzGetUnitAbility(dummy, IGNITE)
            call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_FULL_DAMAGE_INTERVAL, 0, duration)
            call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_HALF_DAMAGE_INTERVAL, 0, interval)
            call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_AREA_OF_EFFECT, 0, aoe)
            call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_HALF_DAMAGE_DEALT, 0, dmg)
            call IncUnitAbilityLevel(dummy, IGNITE)
            call DecUnitAbilityLevel(dummy, IGNITE)
            call IssuePointOrder(dummy, "flamestrike", x, y)
            call StartTimer(duration + 0.05, false, this, -1)

            set spell = null

            return this
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this = proxy[Damage.source.id]

            if this != 0 and Damage.amount > 0 then
                set Damage.source = unit
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpellDamageEvent(function thistype.onDamage)
        endmethod 
    endstruct

    struct BrewCloud
        private real x
        private real y
        private real aoe
        private real slow
        private unit unit
        private unit source
        private group group
        private player player
        private effect effect
        private real duration
        private integer level
        private boolean ignited
        private real slowDuration

        method destroy takes nothing returns nothing
            call UnitRemoveAbility(unit, DEBUFF)
            call DestroyGroup(group)
            call DestroyEffect(effect)
            call DummyRecycle(unit)
            call deallocate()

            set unit = null
            set group = null
            set player = null
            set effect = null
            set source = null
        endmethod

        private method onPeriod takes nothing returns boolean
            local unit u

            set duration = duration - PERIOD

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
            endif
            
            return duration > 0
        endmethod

        static method ignite takes unit dummy, real damage, real duration, real interval returns nothing
            local thistype this = GetTimerInstance(GetUnitUserData(dummy))

            if this != 0 then
                if not ignited then
                    set this.duration = 0
                    set this.ignited = true

                    call Ignite.create(x, y, damage, duration, aoe, interval, source)
                endif
            endif
        endmethod

        static method active takes unit dummy returns boolean
            local thistype this = GetTimerInstance(GetUnitUserData(dummy))

            if this != 0 then
                return not ignited
            endif

            return false
        endmethod

        static method create takes player owner, unit source, unit dummy, real x, real y, real aoe, real duration, real slow, real slowDuration, integer level returns thistype
            local thistype this = thistype.allocate()

            set this.x = x 
            set this.y = y
            set this.aoe = aoe
            set this.slow = slow
            set this.unit = dummy
            set this.level = level
            set this.player = owner
            set this.source = source
            set this.ignited = false
            set this.duration = duration
            set this.slowDuration = slowDuration
            set this.group = CreateGroup()
            set this.effect = AddSpecialEffectEx(CLOUD, x, y, 0, CLOUD_SCALE)
            
            call StartTimer(PERIOD, true, this, GetUnitUserData(dummy))

            return this
        endmethod

        private static method onCast takes nothing returns nothing
            if GetUnitAbilityLevel(GetSpellTargetUnit(), BUFF) == 0 then
                call LinkBonusToBuff(GetSpellTargetUnit(), BONUS_MISS_CHANCE, GetChance(GetUnitAbilityLevel(GetTriggerUnit(), DEBUFF)), BUFF)
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(DEBUFF, function thistype.onCast)
        endmethod
    endstruct

    private struct Keg extends Missiles
        real aoe
        real time
        real slow
        unit cloud
        group group
        integer level

        method operator unit takes nothing returns unit
            return cloud
        endmethod

        method operator unit= takes unit u returns nothing
            set cloud = u

            call UnitAddAbility(u, DEBUFF)
            call SetUnitAbilityLevel(u, DEBUFF, level)
        endmethod

        private method onFinish takes nothing returns boolean
            local real d = GetSlowDuration(unit, level)
            local unit u

            call BrewCloud.create(owner, source, unit, x, y, aoe, time, slow, d, level)
            call GroupEnumUnitsInRange(group, x, y, aoe, null)

            loop
                set u = FirstOfGroup(group)
                exitwhen u == null
                    if DamageFilter(owner, u) then
                        if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                            call IssueTargetOrder(unit, "drunkenhaze", u)
                            call SlowUnit(u, slow, d, null, null, false)
                        endif
                    endif
                call GroupRemoveUnit(group, u)
            endloop

            call DestroyGroup(group)

            set unit = null
            set group = null

            return true
        endmethod
    endstruct

    private struct KegSmash extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Chen|r rolls his keg in the targeted direction. Upon arrival the keg explodes, dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r |cff00ffffMagic|r damage, slowing all enemy units within |cffffcc00" + N2S(GetAoE(source, level), 0) + " AoE|r by |cffffcc00" + N2S(GetSlow(source, level), 0) + "%|r and leaving a |cffffcc00Brew Cloud|r. Enemy units that come in contact with the |cffffcc00Brew Cloud|r get soaked with brew and drunk, having their |cffffff00Movement Speed|r reduced by |cffffcc00" + N2S(GetSlow(source, level), 0) + "%|r and when attacking they have |cffffcc00" + N2S(GetChance(level), 0) + "%|r chance of missing their target.\n\nLasts for |cffffcc00" + N2S(GetDuration(source, level), 1) + "|r seconds."
        endmethod

        private method onCast takes nothing returns nothing
            local Keg keg = Keg.create(Spell.source.x, Spell.source.y, 60, Spell.x, Spell.y, 60)

            set keg.model = MODEL
            set keg.scale = SCALE
            set keg.speed = SPEED
            set keg.level = Spell.level
            set keg.source = Spell.source.unit 
            set keg.owner = Spell.source.player
            set keg.group = CreateGroup()
            set keg.damage = GetDamage(Spell.source.unit, Spell.level)
            set keg.aoe = GetAoE(Spell.source.unit, Spell.level)
            set keg.time = GetDuration(Spell.source.unit, Spell.level)
            set keg.slow = GetSlow(Spell.source.unit, Spell.level)
            set keg.unit = DummyRetrieve(Spell.source.player, Spell.x, Spell.y, 0, 0)
            
            call keg.launch()
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary