library LivingMeteor requires Spell, Missiles, MouseUtils, Utilities, Periodic optional Afterburner, NewBonus
    /* --------------------- Living Meteor v1.6 by Chopinski -------------------- */
    // Credits:
    //     Blizzard         - icon (Edited by me)
    //     AZ               - Meteor model
    //     MyPad            - MouseUtils
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Living Meteor ability
        private constant integer    ABILITY             = 'A002'
        // The landing time of the falling meteor
        private constant real       LANDING_TIME        = 0.75
        // The roll time of the rolling meteor
        private constant real       ROLLING_TIME        = 2.0
        // The damage interval of the rolling interval
        private constant real       DAMAGE_INTERVAL     = 0.1
        // The time the player has to move the mouse before the spell starts
        private constant real       DRAG_AND_DROP_TIME  = 0.05
        // The distance from the casting point from where the meteor spawns
        private constant real       LAUNCH_OFFSET       = 3000
        // The starting height fo the meteor
        private constant real       START_HEIGHT        = 2000
        // Meteor Model
        private constant string     METEOR_MODEL        = "LivingMeteor.mdl"
        // Meteor Impact effect model
        private constant string     IMPACT_MODEL        = "LivingMeteor.mdl"
        // Meteor size
        private constant real       METEOR_SCALE        = 0.75
        // The Attack type of the damage dealt (Spell)
        private constant attacktype ATTACK_TYPE         = ATTACK_TYPE_NORMAL
        // The Damage type of the damage dealt
        private constant damagetype DAMAGE_TYPE         = DAMAGE_TYPE_MAGIC
        // If true will damage structures
        private constant boolean    DAMAGE_STRUCTURES   = true
        // If true will damage allies
        private constant boolean    DAMAGE_ALLIES       = false
        // If true will damage magic immune unit if the
        // ATTACK_TYPE is not spell damage
        private constant boolean    DAMAGE_MAGIC_IMMUNE = false
    endglobals

    // The roll distance of the meteor
    private function RollDistance takes integer level returns real
        return 600. + 100.*level
    endfunction

    // The landing damage distance of the meteor
    private function LandingDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 50. + 50.*level + 1*GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 50. + 50.*level
        endif
    endfunction

    // The roll damage distance of the meteor.
    //will do this damage every DAMAGE_INTERVAL
    private function RollDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 100. * level * DAMAGE_INTERVAL + (1 + 0.25*level) * GetUnitBonus(source, BONUS_SPELL_POWER) * DAMAGE_INTERVAL
        else
            return 100. * level * DAMAGE_INTERVAL
        endif
    endfunction

    // The size of the area around the impact point where units will be damaged
    // By default it is the Living Meteor ability field Area of Effect
    private function GetImpactAoE takes unit u, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The size of the area of the roll meteor that will damage units
    // every DAMAGE_INTERVAL. by default it is the same as the impact AoE
    private function GetRollAoE takes unit u, integer level returns real
        return GetImpactAoE(u, level)
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Meteor extends Missiles
        private static integer ticks = R2I(DAMAGE_INTERVAL/Missiles_PERIOD)

        real aoe
        real angle
        real distance
        integer i = 0
        integer j = 0
        integer level
        boolean rolling

        private method onPeriod takes nothing returns boolean
            if rolling then
                set i = i + 1
                set j = j + 1

                if j == 15 then
                    set j = 0

                    static if LIBRARY_Afterburner then
                        call Afterburn(x, y, source)
                    endif
                endif

                if i == ticks then
                    set i = 0
                    call UnitDamageArea(source, x, y, aoe, damage, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_STRUCTURES, DAMAGE_ALLIES, DAMAGE_MAGIC_IMMUNE)
                endif
            endif

            return false
        endmethod

        private method onFinish takes nothing returns boolean
            if not rolling then
                call DestroyEffect(AddSpecialEffect(IMPACT_MODEL, x, y))
                call UnitDamageArea(source, x, y, GetImpactAoE(source, level), damage, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_STRUCTURES, DAMAGE_ALLIES, DAMAGE_MAGIC_IMMUNE)
                call deflect(x + distance*Cos(angle), y + distance*Sin(angle), 0)
                
                static if LIBRARY_Afterburner then
                    call Afterburn(x, y, source)
                endif

                set rolling = true
                set damage = RollDamage(source, level)
                set duration = ROLLING_TIME
            endif

            return false
        endmethod
    endstruct
    
    private struct LivingMeteor extends Spell
        private real x
        private real y
        private unit unit
        private player player
        private integer level
        private ability ability

        method destroy takes nothing returns nothing
            set unit = null
            set player = null 
            set ability = null

            call deallocate()
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "Ragnaros summon a meteor at the target area that deals |cff00ffff" + N2S(LandingDamage(source, level), 0) + " Magic|r damage on impact, then rolls in that target direction dealing |cff00ffff" + N2S(RollDamage(source, level), 0) + " Magic|r every |cffffcc00" + N2S(DAMAGE_INTERVAL, 2) + "|r seconds to enemy units within |cffffcc00250 AoE|r until it reaches it's maximum range of |cffffcc00700 AoE|r from the initial impact point."
        endmethod

        private method onExpire takes nothing returns nothing
            local real angle = AngleBetweenCoordinates(x, y, GetPlayerMouseX(player), GetPlayerMouseY(player))
            local Meteor meteor = Meteor.create(x + LAUNCH_OFFSET*Cos(angle + bj_PI), y + LAUNCH_OFFSET*Sin(angle + bj_PI), START_HEIGHT, x, y, 0)
            
            set meteor.source = unit
            set meteor.owner = player
            set meteor.model = METEOR_MODEL
            set meteor.scale = METEOR_SCALE
            set meteor.duration = LANDING_TIME
            set meteor.angle = angle
            set meteor.level = level
            set meteor.rolling  = false
            set meteor.aoe = GetRollAoE(unit, level)
            set meteor.damage = LandingDamage(unit, level)
            set meteor.distance = RollDistance(level)

            call meteor.launch()
        endmethod

        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set x = Spell.x
            set y = Spell.y
            set level = Spell.level
            set unit = Spell.source.unit
            set player = Spell.source.player

            call StartTimer(DRAG_AND_DROP_TIME, false, this, -1)
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary