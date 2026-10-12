library LivingMeteor requires Spell, Missiles, MouseUtils, Utilities, Modules, RegisterPlayerUnitEvent optional Afterburner, NewBonus
    /* --------------------- Living Meteor v1.7 by Chopinski -------------------- */
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
        private constant integer    ABILITY              = 'Rgn2'
        // The landing time of the falling meteor
        private constant real       LANDING_TIME         = 0.75
        // The roll time of the rolling meteor
        private constant real       ROLLING_TIME         = 2.0
        // The damage interval of the rolling interval
        private constant real       DAMAGE_INTERVAL      = 0.1
        // The time the player has to move the mouse before the spell starts
        private constant real       DRAG_AND_DROP_TIME   = 3.
        // The distance from the casting point from where the meteor spawns
        private constant real       LAUNCH_OFFSET         = 3000
        // The starting height fo the meteor
        private constant real       START_HEIGHT         = 2000
        // Meteor Model
        private constant string     METEOR_MODEL         = "LivingMeteor.mdl"
        // Meteor Impact effect model
        private constant string     IMPACT_MODEL         = "LivingMeteor.mdl"
        // Meteor size
        private constant real       METEOR_SCALE         = 0.75
        // The Attack type of the damage dealt (Spell)
        private constant attacktype ATTACK_TYPE          = ATTACK_TYPE_NORMAL
        // The Damage type of the damage dealt
        private constant damagetype DAMAGE_TYPE          = DAMAGE_TYPE_MAGIC
        // If true will damage structures
        private constant boolean    DAMAGE_STRUCTURES    = true
        // If true will damage allies
        private constant boolean    DAMAGE_ALLIES        = false
        // If true will damage magic immune unit if the
        // ATTACK_TYPE is not spell damage
        private constant boolean    DAMAGE_MAGIC_IMMUNE  = false
        // Skill indicator model
        private constant string     INDICATOR_MODEL      = "Skill_Indicator_Move.mdl"
        // Indicator scaling
        private constant real       INDICATOR_SCALE      = 1.5
        // Indicator time scaling
        private constant real       INDICATOR_TIME_SCALE = 1.5
    endglobals

    // The roll distance of the meteor
    private function RollDistance takes integer level returns real
        return 600. + 100.*level
    endfunction

    // The landing damage distance of the meteor
    private function LandingDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 50. + 50.*level + 1 * GetUnitBonus(source, BONUS_SPELL_POWER)
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
    private struct Meteor extends Missile
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

        method destroy takes nothing returns nothing
            if casting then
                call DestroyEffectTimed(effect, 2)
            else
                call DestroyEffect(effect)
            endif

            set unit = null
            set effect = null
            set player = null
            set struct[id] = 0

            call deallocate()
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "Ragnaros summon a meteor at the target area that deals |cff00ffff" + N2S(LandingDamage(source, level), 0) + " Magic|r damage on impact, then rolls in that target direction dealing |cff00ffff" + N2S(RollDamage(source, level), 0) + " Magic|r every |cffffcc00" + N2S(DAMAGE_INTERVAL, 2) + "|r seconds to enemy units within |cffffcc00250 AoE|r until it reaches it's maximum range of |cffffcc00700 AoE|r from the initial impact point."
        endmethod

        private method onPeriod takes nothing returns boolean  
            local boolean down = IsPlayerMouseButtonDown(player, MOUSE_BUTTON_TYPE_LEFT)
            local Meteor meteor

            if down then
                set angle = AngleBetweenCoordinates(x, y, GetPlayerMouseX(player), GetPlayerMouseY(player))
            endif

            if not casting then
                if down and not done then
                    call BlzSetSpecialEffectYaw(effect, angle)
                elseif not down then
                    set done = true
                endif

                return true
            endif

            set timeout = timeout - 0.03

            if not down or timeout <= 0 then
                set meteor = Meteor.create(x + LAUNCH_OFFSET*Cos(angle + bj_PI), y + LAUNCH_OFFSET*Sin(angle + bj_PI), START_HEIGHT, x, y, 0)
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
            endif

            call BlzSetSpecialEffectYaw(effect, angle)

            return timeout > 0 and down
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
                set casting = true
                set level = Spell.level
                set timeout = DRAG_AND_DROP_TIME
            else
                set this = thistype.allocate()
                set x = Spell.x
                set y = Spell.y
                set casting = true
                set level = Spell.level
                set id = Spell.source.id
                set unit = Spell.source.unit
                set player = Spell.source.player
                set timeout = DRAG_AND_DROP_TIME
                set effect = AddSpecialEffectEx(INDICATOR_MODEL, x, y, 0, INDICATOR_SCALE)
                set angle = AngleBetweenCoordinates(x, y, GetPlayerMouseX(player), GetPlayerMouseY(player))

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
                    call destroy()
                elseif BlzGetUnitAbilityCooldownRemaining(source, ABILITY) == 0 and order == base and distance > range then
                    if this != 0 then
                        call destroy()
                    endif

                    set this = thistype.allocate()
                    set done = false
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