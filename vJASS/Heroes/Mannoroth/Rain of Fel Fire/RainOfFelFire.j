library RainOfFelFire requires Missiles, Spell, Utilities, Periodic, optional NewBonus
    /* ------------------- Rain of Fel Fire v1.5 by Chopinski ------------------- */
    // Credits:
    //     The Panda - InfernalShower icon
    //     Mythic    - Rain of Fire model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        //the raw code of the Rain of Fel Fire ability
        private constant integer    ABILITY            = 'A000'
        //the starting height of the missile
        private constant integer    START_HEIGHT       = 2000
        // The landing time of the falling misisle
        private constant real       LANDING_TIME       = 1.
        // The impact radius of the missile that will damage units.
        private constant real       IMPACT_RADIUS      = 120.
        //the missile model
        private constant string     MISSILE_MODEL      = "FelRain.mdx"
        //the dot model
        private constant string     DOT_MODEL          = "BurnLarge.mdx"
        //the dot attachment point
        private constant string     DOT_ATTACH         = "origin"
        // The Attack type of the damage dealt on imapact (Spell)
        private constant attacktype IMPACT_ATTACK_TYPE = ATTACK_TYPE_NORMAL
        // The Damage type of the damage dealt on impact
        private constant damagetype IMPACT_DAMAGE_TYPE = DAMAGE_TYPE_MAGIC
        // The Attack type of the damage over time
        private constant attacktype DOT_ATTACK_TYPE    = ATTACK_TYPE_HERO
        // The Damage type of the damage over time
        private constant damagetype DOT_DAMAGE_TYPE    = DAMAGE_TYPE_UNIVERSAL
    endglobals

    // How long the spell will last
    private function GetDuration takes integer level returns real
        return 10. + 0.*level
    endfunction

    // The interval at which the rain of fire meteors spwan
    private function GetInterval takes integer level returns real
        return 0.2 - 0.025 * level
    endfunction

    // The max range that a rain of fel fire missile can spawn
    // By default it is the ability Area of Effect Field value
    private function GetRange takes unit u, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The amount of damage dealt when the missile lands
    private function GetImpactDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 25. * level + (0.8 + 0.05*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 25. * level
        endif
    endfunction

    // The amount of damage over time dealt to units in range of the impact area
    private function GetDoTDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 5. * level + (0.05 + 0.05*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 5. * level
        endif
    endfunction

    // How long the dot will last
    private function GetDoTDuration takes integer level returns real
        return 4. + 0.*level
    endfunction

    // The interval at which the dot effect will do damage
    private function GetDoTInterval takes integer level returns real
        return 1. + 0.*level
    endfunction

    // Filter for the units that will be damaged on impact and get DoT
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct DoT
        private integer id
        private unit source
        private unit target
        private real damage
        private real duration
        private integer level
        private effect effect

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call deallocate()

            set source = null
            set target = null
            set effect = null
        endmethod

        private method onPeriod takes nothing returns boolean
            set duration = duration - GetDoTInterval(level)

            if duration > 0 then
                if UnitAlive(target) then
                    call UnitDamageTarget(source, target, damage, true, false, DOT_ATTACK_TYPE, DOT_DAMAGE_TYPE, null)
                else
                    return false
                endif
            endif
        
            return duration > 0
        endmethod

        static method create takes unit source, unit target, real damage, integer level returns thistype
            local integer id = GetUnitUserData(target)
            local thistype this = GetTimerInstance(id)
            
            if this == 0 then
                set this = thistype.allocate()
                set this.id = id
                set this.level = level
                set this.source = source
                set this.target = target
                set this.damage = damage
                set effect = AddSpecialEffectTarget(DOT_MODEL, target, DOT_ATTACH)

                call StartTimer(GetDoTInterval(level), true, this, id)
            endif

            set this.duration = GetDoTDuration(level)

            return this
        endmethod

        implement Periodic
    endstruct

    private struct Meteor extends Missiles
        integer level

        private method onFinish takes nothing returns boolean
            local unit u
            local group g = CreateGroup()

            call GroupEnumUnitsInRange(g, x, y, IMPACT_RADIUS, null)

            loop
                set u = FirstOfGroup(g)
                exitwhen u == null
                    if DamageFilter(owner, u) then
                        if UnitDamageTarget(source, u, damage, false, false, IMPACT_ATTACK_TYPE, IMPACT_DAMAGE_TYPE, null) then
                            call DoT.create(source, u, GetDoTDamage(source, level), level)
                        endif
                    endif
                call GroupRemoveUnit(g, u)
            endloop

            call DestroyGroup(g)

            set g = null

            return true
        endmethod
    endstruct

    private struct FelFire extends Ability
        private real x
        private real y
        private unit unit
        private real duration
        private integer level

        method destroy takes nothing returns nothing
            set unit = null
            call deallocate()
        endmethod
        
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Mannoroth|r calls fire down from the skies every |cffffcc00" + N2S(GetInterval(level), 3) + "|r seconds, dealing |cff00ffff" + N2S(GetImpactDamage(source, level), 0) + "|r |cff00ffffMagic|r damage on impact and |cffd45e19" + N2S(GetDoTDamage(source, level), 0) + " Pure|r damage per second for |cffffcc00" + N2S(GetDoTDuration(level), 1) + "|r seconds.\n\nLasts |cffffcc00" + N2S(GetDuration(level), 1) + "|r seconds."
        endmethod

        private method onPeriod takes nothing returns boolean
            local real x
            local real y
            local real theta
            local real radius                                              
            local Meteor meteor

            set duration = duration - GetInterval(level)

            if duration > 0 then
                set theta = 2*bj_PI*GetRandomReal(0, 1)
                set radius = GetRandomRange(GetRange(unit, level))
                set x = .x + radius*Cos(theta)
                set y = .y + radius*Sin(theta)  
                set meteor = Meteor.create(x, y, START_HEIGHT, x, y, 20)

                set meteor.source = unit
                set meteor.level = level
                set meteor.model = MISSILE_MODEL
                set meteor.duration = LANDING_TIME
                set meteor.owner = GetOwningPlayer(unit)
                set meteor.damage = GetImpactDamage(unit, level)

                call meteor.launch()
            endif
            
            return duration > 0
        endmethod

        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set x = Spell.x
            set y = Spell.y
            set level = Spell.level
            set unit = Spell.source.unit
            set duration = GetDuration(Spell.level)

            call StartTimer(GetInterval(Spell.level), true, this, -1)
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary