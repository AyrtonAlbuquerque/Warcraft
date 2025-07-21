library OdinIncinerate requires Spell, Missiles, Periodic, MouseUtils, DamageInterface, Utilities, optional Newbonus
    /* -------------------- Odin Annihilate v1.3 by Chopinski ------------------- */
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
        public  constant integer ABILITY = 'A009'
        // The raw code of the Incinerate ability
        private constant integer FLAMES  = 'A00A'
        // The Missile model
        private constant string  MODEL   = "Interceptor Shell.mdl"
        // The Missile scale
        private constant real    SCALE   = 0.6
        // The Missile speed
        private constant real    SPEED   = 1000.
        // The Missile arc
        private constant real    ARC     = 45.
        // The Missile height offset
        private constant real    HEIGHT  = 200.
        // The time the player has to move the mouse before the spell starts
        private constant real    DRAG_AND_DROP_TIME  = 0.05
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
    
    private struct Rocket extends Missiles  
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
        private real x
        private real y
        private real aoe
        private integer i
        private unit unit
        private real angle
        private real offset
        private real damage
        private player player
        private integer count
        private integer level
        private real iAoE
        private real iDamage
        private real iInterval
        private real iDuration

        method destroy takes nothing returns nothing
            set unit = null
            set player = null
            
            call deallocate()
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Odin|r fires |cffffcc00" + N2S(GetRocketCount(level), 0) + "|r incendiary rockets towards the desired direction. The rockets explode dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r damage within |cffffcc00" + N2S(GetAoE(source, level), 0) + "|r AoE and leaves a trail of fire that deals |cff00ffff" + N2S(GetIncinerationDamage(source, level), 1) + "|r damage per second to any enemy unit standing in it. Lasts for |cffffcc00" + N2S(GetIncinerationDuration(level), 1) + "|r seconds."
        endmethod

        private method onPeriod takes nothing returns boolean
            local Rocket rocket

            set rocket = Rocket.create(GetUnitX(unit), GetUnitY(unit), HEIGHT, x + offset*i*Cos(angle), y + offset*i*Sin(angle), 50)
            set rocket.model = MODEL
            set rocket.scale = SCALE
            set rocket.speed = SPEED
            set rocket.arc = ARC
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

            return i < count
        endmethod

        private method onExpire takes nothing returns nothing
            set angle = AngleBetweenCoordinates(x, y, GetPlayerMouseX(player), GetPlayerMouseY(player))
            
            call StartTimer(GetInterval(level), true, this, 0)
        endmethod

        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set i = 0
            set x = Spell.x
            set y = Spell.y
            set level = Spell.level
            set unit = Spell.source.unit
            set player = Spell.source.player
            set count = GetRocketCount(Spell.level)
            set offset = GetOffset(Spell.level)
            set damage = GetDamage(Spell.source.unit, Spell.level)
            set aoe = GetAoE(Spell.source.unit, Spell.level)
            set iAoE = GetIncinerationAoE(Spell.source.unit, Spell.level)
            set iDamage = GetIncinerationDamage(Spell.source.unit, Spell.level)
            set iInterval = GetIncinerationInterval(Spell.level)
            set iDuration = GetIncinerationDuration(Spell.level)

            call StartTimer(DRAG_AND_DROP_TIME, false, this, 0)
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary