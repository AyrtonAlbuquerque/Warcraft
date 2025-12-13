library Fissure requires Spell, Missiles, Utilities, CrowdControl, optional NewBonus
    /* ------------------------ Fissure v1.5 by CHopinski ----------------------- */
    // Credits:
    //     AnsonRuk    - Icon Darky29
    //     Darky29     - Fissure Model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of Fissure ability
        public  constant integer ABILITY     = 'ChnB'
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
        // The Fissure stun model
        private constant string  STUN_MODEL  = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        // The Fissure stun model attach point
        private constant string  STUN_ATTACH = "overhead"
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
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 250. * level + 1.5 * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 250. * level
        endif
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
    private struct Fissure extends Missile
        real face
        real stun
        real time
        real offset = 0

        private method onPeriod takes nothing returns boolean
            local effect e
            
            set offset = offset + speed * Missile.period

            if offset >= 96 then
                set e = AddSpecialEffectEx(MODEL, x, y, 0, SCALE)
                set offset = 0

                call DestroyEffect(AddSpecialEffectEx(BIRTH_MODEL, x, y, 0, BIRTH_SCALE))
                call BlzSetSpecialEffectYaw(e, face)
                call DestroyEffectTimed(e, time - 5)
                call RemoveDestructableTimed(CreateDestructable(BLOCKER, x, y, face*bj_RADTODEG, 1, 0), time)
            endif

            set e = null

            return false
        endmethod

        private method onUnit takes unit hit returns boolean
            if DamageFilter(owner, hit) then
                if UnitDamageTarget(source, hit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call StunUnit(hit, stun, STUN_MODEL, STUN_ATTACH, false)
                endif
            endif

            return false
        endmethod

        private static method onCast takes nothing returns nothing
            local real angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local real distance = GetDistance(Spell.source.unit, Spell.level)
            local thistype this = thistype.create(Spell.source.x, Spell.source.y, 0, Spell.source.x + distance * Cos(angle), Spell.source.y + distance * Sin(angle), 0)

            set face = angle
            set speed = SPEED
            set source = Spell.source.unit
            set owner = Spell.source.player
            set damage = GetDamage(Spell.source.unit, Spell.level)
            set collision = GetAoE(Spell.level)     
            set stun = GetStunTime(Spell.level)
            set time = GetFissureDuration(Spell.level)

            call launch()
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary