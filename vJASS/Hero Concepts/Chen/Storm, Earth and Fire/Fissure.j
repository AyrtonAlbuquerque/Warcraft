library Fissure requires SpellEffectEvent, PluginSpellEffect, Missiles, Utilities
    /* ------------------------ Fissure v1.2 by CHopinski ----------------------- */
    // Credits:
    //     AnsonRuk    - Icon Darky29
    //     Darky29     - Fissure Model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of Fissure ability
        public  constant integer ABILITY     = 'A00B'
        // The pathing blocker raw code
        private constant integer BLOCKER     = 'YTpc'
        // The Fissure model
        private constant string  MODEL       = "Fissure.mdl"
        // The Fissure model scale
        private constant real    SCALE       = 1.
        // The Fissure birth model
        private constant string  BIRTH_MODEL = "RockSlam.mdl"
        // The Fissure birth model scale
        private constant real    BIRTH_SCALE = 0.7
        // The Fissure Missile speed
        private constant real    SPEED       = 1500.
    endglobals

    // The Fissure travel distance, by default the ability cast range
    private function GetDistance takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_CAST_RANGE, level - 1)
    endfunction

    // The number of bounces
    private function GetStunTime takes integer level returns real
        return 1. + 0.*level
    endfunction

    // The damage
    private function GetDamage takes integer level returns real
        return 150.*level
    endfunction

    // The Fissure damage aoe
    private function GetAoE takes integer level returns real
        return 200. + 0.*level
    endfunction

    // The Fissure duration
    private function GetFissureDuration takes integer level returns real
        return 10. + 0.*level
    endfunction

    // The Filter Damage Filter for enemy units
    private function DamageFilter takes player owner, unit target returns boolean
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct Fissure extends Missiles
        real offset = 0
        real yaw
        real stun
        real dur

        method onPeriod takes nothing returns boolean
            local effect e
            
            set offset = offset + veloc
            if offset >= 96 then
                set e = AddSpecialEffectEx(MODEL, x, y, 0, SCALE)
                set offset = 0

                call DestroyEffect(AddSpecialEffectEx(BIRTH_MODEL, x, y, 0, BIRTH_SCALE))
                call BlzSetSpecialEffectYaw(e, yaw)
                call DestroyEffectTimed(e, dur - 5)
                call RemoveDestructableTimed(CreateDestructable(BLOCKER, x, y, yaw*bj_RADTODEG, 1, 0), dur)
            endif

            set e = null
            return false
        endmethod

        method onHit takes unit hit returns boolean
            if DamageFilter(owner, hit) then
                if UnitDamageTarget(source, hit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call StunUnit(hit, stun)
                endif
            endif

            return false
        endmethod

        private static method onCast takes nothing returns nothing
            local real a = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local real d = GetDistance(Spell.source.unit, Spell.level)
            local thistype this = thistype.create(Spell.source.x, Spell.source.y, 0, Spell.source.x + d*Cos(a), Spell.source.y + d*Sin(a), 0)

            set speed     = SPEED
            set yaw       = a
            set source    = Spell.source.unit
            set owner     = Spell.source.player
            set damage    = GetDamage(Spell.level)
            set collision = GetAoE(Spell.level)     
            set stun      = GetStunTime(Spell.level)
            set dur       = GetFissureDuration(Spell.level)

            call launch()
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary