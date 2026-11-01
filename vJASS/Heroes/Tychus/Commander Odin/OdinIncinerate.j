library OdinIncinerate requires Spell, Missiles, Modules, MouseUtils, DamageInterface, Utilities, RegisterPlayerUnitEvent optional Newbonus
    /* -------------------- Odin Annihilate v1.4 by Chopinski ------------------- */
    // Credits:
    //     a-ravlik        - Icon
    //     Bribe           - SpellEffectEvent
    //     vexorian        - TimerUtils
    //     MyPad           - MouseUtils
    //     Mythic          - Interceptor Shell model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Odin Incinerate ability
        public  constant integer ABILITY              = 'Tyc9'
        // The raw code of the Incinerate ability
        private constant integer FLAMES               = 'Flam'
        // The Missile model
        private constant string  MODEL                = "Interceptor Shell.mdl"
        // The Missile scale
        private constant real    SCALE                = 0.6
        // The Missile speed
        private constant real    SPEED                = 1000.
        // The Missile arc
        private constant real    ARC                  = 45.
        // The Missile height offset
        private constant real    HEIGHT               = 200.
        // The time the player has to move the mouse before the spell starts
        private constant real    DRAG_AND_DROP_TIME   = 3.
        // Skill indicator model
        private constant string  INDICATOR_MODEL      = "Skill_Indicator_Move.mdl"
        // Indicator scaling
        private constant real    INDICATOR_SCALE      = 2.5
        // Indicator time scaling
        private constant real    INDICATOR_TIME_SCALE = 1.5
    endglobals

    // The distance between rocket explosions that create the flames. Recommended about 50% of the size of the flame strike aoe.
    private function GetOffset takes integer level returns real
        return 100. +0*level
    endfunction

    // The explosion damage
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 50. * level + 0.8 * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 50. * level
        endif
    endfunction

    // The explosion aoe
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The incineration damage per interval
    private function GetIncinerationDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 12.5 * level + 0.2 * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 12.5 * level
        endif
    endfunction

    // The incineration AoE
    private function GetIncinerationAoE takes unit source, integer level returns real
        return GetAoE(source, level)
    endfunction

    // The incineration damage interval
    private function GetIncinerationInterval takes integer level returns real
        return 1. + 0.*level
    endfunction

    // The the incineration duration
    private function GetIncinerationDuration takes integer level returns real
        return 5. + 0.*level
    endfunction

    // The numebr of rockets.
    private function GetRocketCount takes integer level returns integer
        return 3 + 2*level
    endfunction

    // The interval at which rockets are spawnned.
    private function GetInterval takes integer level returns real
        return 0.2 + 0.*level
    endfunction

    // The Damage Filter.
    private function DamageFilter takes player p, unit u returns boolean
        return UnitAlive(u) and IsUnitEnemy(u, p)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Incineration
        private static integer array proxy

        private unit unit
        private unit dummy
        private real damage
        private integer key

        method destroy takes nothing returns nothing
            call UnitRemoveAbility(dummy, FLAMES)
            call DummyRecycle(dummy)
            call deallocate()

            set unit = null
            set dummy = null
            set proxy[key] = 0
        endmethod

        static method create takes real x, real y, real dmg, real duration, real aoe, real interval, unit source returns thistype
            local thistype this = thistype.allocate()
            local ability spell

            set unit = source
            set damage = dmg
            set dummy = DummyRetrieve(GetOwningPlayer(source), x, y, 0, 0)
            set key = GetUnitUserData(dummy)
            set proxy[key] = this

            call UnitAddAbility(dummy, FLAMES)
            set spell = BlzGetUnitAbility(dummy, FLAMES)
            call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_FULL_DAMAGE_INTERVAL, 0, duration)
            call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_HALF_DAMAGE_INTERVAL, 0, interval)
            call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_AREA_OF_EFFECT, 0, aoe)
            call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_HALF_DAMAGE_DEALT, 0, dmg)
            call IncUnitAbilityLevel(dummy, FLAMES)
            call DecUnitAbilityLevel(dummy, FLAMES)
            call IssuePointOrder(dummy, "flamestrike", x, y)
            call StartTimer(duration + 0.05, false, this, 0)

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
    
    private struct Rocket extends Missile
        real aoe
        group group
        real iAoE
        real iDamage
        real iInterval
        real iDuration

        private method onFinish takes nothing returns boolean
            local unit u

            call Incineration.create(x, y, iDamage, iDuration, iAoE, iInterval, source)
            call DestroyEffect(AddSpecialEffect(MODEL, x, y))
            call GroupEnumUnitsInRange(group, x, y, aoe, null)

            loop
                set u = FirstOfGroup(group)
                exitwhen u == null
                    if DamageFilter(owner, u) then
                        call UnitDamageTarget(source, u, damage, true, true, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                    endif
                call GroupRemoveUnit(group, u)
            endloop

            call DestroyGroup(group)

            set group = null

            return true
        endmethod
    endstruct

    private struct OdinIncinerate extends Spell
        private static thistype array struct

        private real x
        private real y
        private unit unit
        private integer id
        private real angle
        private boolean done
        private real timeout
        private effect effect
        private player player
        private integer level
        private boolean casting
        private boolean cancelled
        private real interval
        private real delay
        private boolean firing
        private real aoe
        private integer i
        private real offset
        private real damage
        private integer count
        private real iAoE
        private real iDamage
        private real iInterval
        private real iDuration

        method destroy takes nothing returns nothing
            if casting then
                call DestroyEffectTimed(effect, 2)
            else
                call DestroyEffect(effect)
            endif

            set unit = null
            set effect = null
            set player = null
            
            if struct[id] == this then
                set struct[id] = 0
            endif

            call deallocate()
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Odin|r fires |cffffcc00" + N2S(GetRocketCount(level), 0) + "|r incendiary rockets towards the desired direction. The rockets explode dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r damage within |cffffcc00" + N2S(GetAoE(source, level), 0) + "|r AoE and leaves a trail of fire that deals |cff00ffff" + N2S(GetIncinerationDamage(source, level), 1) + "|r damage per second to any enemy unit standing in it. Lasts for |cffffcc00" + N2S(GetIncinerationDuration(level), 1) + "|r seconds.\n\n|cffffcc00Drag and Drop|r to choose direction."
        endmethod

        private method onPeriod takes nothing returns boolean
            local Rocket rocket
            local boolean down = IsPlayerMouseButtonDown(player, MOUSE_BUTTON_TYPE_LEFT)

            if cancelled then
                return false
            endif

            if down and not firing and (casting or not done) then
                set angle = AngleBetweenCoordinates(x, y, GetPlayerMouseX(player), GetPlayerMouseY(player))
            endif

            if not casting then
                if not UnitAlive(unit) then
                    return false
                endif

                if down and not done then
                    call BlzSetSpecialEffectYaw(effect, angle)
                elseif not down then
                    set done = true
                endif

                return true
            endif

            set timeout = timeout - 0.03
            set delay = delay - 0.03

            if (not down or timeout <= 0) and delay <= 0 then
                set firing = true
                set delay = interval
                set rocket = Rocket.create(GetUnitX(unit), GetUnitY(unit), HEIGHT, x + offset*i*Cos(angle), y + offset*i*Sin(angle), 50)
                set rocket.model = MODEL
                set rocket.scale = SCALE
                set rocket.speed = SPEED
                set rocket.arc = ARC * bj_DEGTORAD
                set rocket.aoe = aoe
                set rocket.source = unit
                set rocket.owner = player
                set rocket.damage = damage
                set rocket.iAoE = iAoE
                set rocket.iDamage = iDamage
                set rocket.iInterval = iInterval
                set rocket.iDuration = iDuration
                set rocket.group = CreateGroup()
                set i = i + 1

                call rocket.launch()
            endif

            if not firing then
                call BlzSetSpecialEffectYaw(effect, angle)
            endif

            return i < count
        endmethod

        private method onCast takes nothing returns nothing
            if struct[Spell.source.id] != 0 then
                set this = struct[Spell.source.id]

                if x != Spell.x or y != Spell.y then
                    call BlzSetSpecialEffectX(effect, Spell.x)
                    call BlzSetSpecialEffectY(effect, Spell.y)
                    call BlzSetSpecialEffectYaw(effect, AngleBetweenCoordinates(Spell.x, Spell.y, GetPlayerMouseX(player), GetPlayerMouseY(player)))
                endif

                set x = Spell.x
                set y = Spell.y
                set i = 0
                set delay = 0
                set firing = false
                set casting = true
                set level = Spell.level
                set timeout = DRAG_AND_DROP_TIME
                set interval = GetInterval(Spell.level)
                set count = GetRocketCount(Spell.level)
                set offset = GetOffset(Spell.level)
                set damage = GetDamage(Spell.source.unit, Spell.level)
                set aoe = GetAoE(Spell.source.unit, Spell.level)
                set iAoE = GetIncinerationAoE(Spell.source.unit, Spell.level)
                set iDamage = GetIncinerationDamage(Spell.source.unit, Spell.level)
                set iInterval = GetIncinerationInterval(Spell.level)
                set iDuration = GetIncinerationDuration(Spell.level)
            else
                set this = thistype.allocate()
                set x = Spell.x
                set y = Spell.y
                set i = 0
                set delay = 0
                set firing = false
                set casting = true
                set cancelled = false
                set level = Spell.level
                set id = Spell.source.id
                set unit = Spell.source.unit
                set player = Spell.source.player
                set timeout = DRAG_AND_DROP_TIME
                set interval = GetInterval(Spell.level)
                set effect = AddSpecialEffectEx(INDICATOR_MODEL, x, y, 0, INDICATOR_SCALE)
                set angle = AngleBetweenCoordinates(x, y, GetPlayerMouseX(player), GetPlayerMouseY(player))
                set count = GetRocketCount(Spell.level)
                set offset = GetOffset(Spell.level)
                set damage = GetDamage(Spell.source.unit, Spell.level)
                set aoe = GetAoE(Spell.source.unit, Spell.level)
                set iAoE = GetIncinerationAoE(Spell.source.unit, Spell.level)
                set iDamage = GetIncinerationDamage(Spell.source.unit, Spell.level)
                set iInterval = GetIncinerationInterval(Spell.level)
                set iDuration = GetIncinerationDuration(Spell.level)

                call BlzSetSpecialEffectYaw(effect, angle)
                call BlzSetSpecialEffectTimeScale(effect, INDICATOR_TIME_SCALE)

                call StartTimer(0.03, true, this, 0)
            endif
        endmethod

        private static method onOrder takes nothing returns nothing
            local unit source = GetOrderedUnit()
            local integer id = GetUnitUserData(source)
            local integer level = GetUnitAbilityLevel(source, ABILITY)
            local thistype this = struct[id]
            local real range
            local string base
            local string order
            local real distance
            local ability skill
            
            if level > 0 then
                set skill = BlzGetUnitAbility(source, ABILITY)
                set order = OrderId2String(GetIssuedOrderId())
                set base = BlzGetAbilityStringLevelField(skill, ABILITY_SLF_BASE_ORDER_ID_NCL6, level - 1)
                set range = BlzGetAbilityRealLevelField(skill, ABILITY_RLF_CAST_RANGE, level - 1)
                set distance = DistanceBetweenCoordinates(GetOrderPointX(), GetOrderPointY(), GetUnitX(source), GetUnitY(source))

                if order != base and this != 0 then
                    if not casting then
                        set cancelled = true
                        set struct[id] = 0
                    endif
                elseif BlzGetUnitAbilityCooldownRemaining(source, ABILITY) == 0 and order == base and distance > range then
                    if this != 0 then
                        set cancelled = true
                        set struct[id] = 0
                    endif

                    set this = thistype.allocate()
                    set i = 0
                    set delay = 0
                    set firing = false
                    set done = false
                    set cancelled = false
                    set x = GetOrderPointX()
                    set y = GetOrderPointY()
                    set this.id = id
                    set casting = false
                    set this.level = level
                    set unit = source
                    set player = GetOwningPlayer(source)
                    set effect = AddSpecialEffectEx(INDICATOR_MODEL, x, y, 0, INDICATOR_SCALE)
                    set angle = AngleBetweenCoordinates(x, y, GetPlayerMouseX(player), GetPlayerMouseY(player))
                    set struct[id] = this

                    call BlzSetSpecialEffectTimeScale(effect, INDICATOR_TIME_SCALE)
                    call BlzSetSpecialEffectYaw(effect, angle)

                    call StartTimer(0.03, true, this, 0)
                endif
            endif

            set skill = null
            set source = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, function thistype.onOrder)
        endmethod
    endstruct
endlibrary