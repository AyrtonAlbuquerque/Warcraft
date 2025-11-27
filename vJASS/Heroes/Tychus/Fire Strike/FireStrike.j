library FireStrike requires Missiles, Spell, Utilities, Modules optional NewBonus
    /* --------------------- Fire Strike v1.0 by Chopinski ---------------------- */
    // Credits:
    //     Panda - icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Fire Strike ability
        public  constant integer ABILITY        = 'Tyc5'
        // The raw code of the Incinerate ability
        private constant integer FLAMES         = 'TycA'
        // The starting height of the missile
        private constant integer START_HEIGHT   = 1500
        // The starting offset of the missile
        private constant integer START_OFFSET   = 3000
        // The Missile model
        private constant string  MODEL          = "Interceptor Shell.mdl"
        // The Missile scale
        private constant real    SCALE          = 0.8
        // The Missile speed
        private constant real    SPEED          = 1500.
    endglobals

    // The amount of damage dealt when the missile lands
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 300 * level + (0.5 + 0.25*level) * GetUnitBonus(source, BONUS_DAMAGE) + (0.2 + 0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 300. * level
        endif
    endfunction

    // The amount of damage Fire deals per second
    private function GetFireDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 50. * level + (0.15*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 50. * level
        endif
    endfunction

    // The max range that a missile can spawn
    // By default it is the ability Area of Effect Field value
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The impact aoe
    private function GetDamageAoE takes unit source, integer level returns real
        return 200. + 0.*level
    endfunction

    // The amount of missiles spawned
    private function GetCount takes unit source, integer level returns integer
        return 60 + 20*level
    endfunction

    // The missile spawn interval
    private function GetInterval takes unit source, integer level returns real
        return 0.1 - 0.*level
    endfunction

    // The Fire damage interval
    private function GetFireInterval takes integer level returns real
        return 1. + 0.*level
    endfunction

    // The fire duration
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The damage filter
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
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
        real burn
        real time
        real interval
        integer level

        private method onFinish takes nothing returns boolean
            local group g = CreateGroup()
            local unit u

            call GroupEnumUnitsInRange(g, x, y, collision, null)
            call Incineration.create(x, y, burn, time, collision, interval, source)

            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if DamageFilter(owner, u) then
                        call UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                    endif
                call GroupRemoveUnit(g, u)
            endloop

            call DestroyGroup(g)

            set g = null

            return true
        endmethod
    endstruct

    private struct FireStrike extends Spell
        private real x
        private real y
        private unit unit
        private real angle
        private real range
        private real count
        private real burn
        private real time
        private real interval
        private integer level

        method destroy takes nothing returns nothing
            set unit = null
            call deallocate()
        endmethod
        
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Tychus|r calls for a |cffffcc00Fire Strike|r in the targeted location. Each missile deals |cff00ffff" + N2S(GetDamage(source, level), 0) + " Magic|r damage to all enemy units within |cffffcc00" + N2S(GetDamageAoE(source, level), 0) + " AoE|r of its impact location and leaves a trail of fire that burns enemy units for |cff00ffff" + N2S(GetFireDamage(source, level), 0) + " Magic|r damage per second for |cffffcc00" + N2S(GetDuration(source, level), 1) + "|r seconds."
        endmethod

        private method onPeriod takes nothing returns boolean
            local real x
            local real y
            local real theta
            local real radius                                              
            local Rocket rocket

            set count = count - 1
            set theta = 2*bj_PI*GetRandomReal(0, 1)
            set radius = GetRandomRange(range)
            set x = .x + radius*Cos(theta)
            set y = .y + radius*Sin(theta)
            set rocket = Rocket.create(x + START_OFFSET*Cos(angle), y + START_OFFSET*Sin(angle), START_HEIGHT, x, y, 0)
            set rocket.source = unit
            set rocket.level = level
            set rocket.model = MODEL
            set rocket.scale = SCALE
            set rocket.speed = SPEED
            set rocket.burn = burn
            set rocket.time = time
            set rocket.interval = interval
            set rocket.arc = GetRandomReal(-45, 45) * bj_DEGTORAD
            set rocket.curve = GetRandomReal(-30, 30) * bj_DEGTORAD
            set rocket.owner = GetOwningPlayer(unit)
            set rocket.damage = GetDamage(unit, level)
            set rocket.collision = GetDamageAoE(unit, level)

            call rocket.launch()
            
            return count > 0
        endmethod

        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set x = Spell.x
            set y = Spell.y
            set level = Spell.level
            set unit = Spell.source.unit
            set angle = AngleBetweenCoordinates(Spell.x, Spell.y, Spell.source.x, Spell.source.y)
            set range = GetAoE(Spell.source.unit, Spell.level)
            set count = GetCount(Spell.source.unit, Spell.level)
            set burn = GetFireDamage(Spell.source.unit, Spell.level)
            set time = GetDuration(Spell.source.unit, Spell.level)
            set interval = GetFireInterval(Spell.level)

            call StartTimer(GetInterval(Spell.source.unit, Spell.level), true, this, -1)
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary
