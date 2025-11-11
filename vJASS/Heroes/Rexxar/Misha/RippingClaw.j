library RippingClaws requires RegisterPlayerUnitEvent, DamageInterface, Utilities
    /* --------------------- Ripping Claws v1.0 by Chopinski -------------------- */
    // Credits:
    //     Nyx-Studio      - Icon
    //     Magtheridon96   - RegisterPlayerUnitEvent
    //     Vinz            - Reaper's claw effect
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY = 'Rex7'
        // The Claw effect
        private constant string  CLAW    = "Reaper's Claws Gold.mdl"
        // The model scale
        private constant real    SCALE   = 1.
        // The effect height offset
        private constant real    HEIGHT  = 90.
    endglobals

    // The arc at which units are damaged
    private function GetArc takes integer level returns real
        return 180. + 0.*level
    endfunction

    // The damage percentage transfered to nearby units (1 = 100%)
    private function GetDamagePercentage takes integer level returns real
        return 1. + 0.*level
    endfunction

    // The AoE
    private function GetAoE takes integer level returns real
        return 300. + 0.*level
    endfunction

    // The claw effect tilt for each attack sequence
    private function GetAngle takes integer sequence returns real
        if sequence == 13 then
            return -45.
        else
            return -135.
        endif
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct RippingClaws extends array
        private static integer array sequence

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if level > 0 then
                call UnitDamageCone(Damage.source.unit, Damage.source.x, Damage.source.y, GetUnitFacing(Damage.source.unit), GetArc(level), GetAoE(level), GetEventDamage()*GetDamagePercentage(level), Damage.attacktype, DAMAGE_TYPE_ENHANCED, false, true, false)
            endif
        endmethod

        private static method onAttack takes nothing returns nothing
            local unit source = GetAttacker()
            local integer level = GetUnitAbilityLevel(source, ABILITY)
            local integer i
            local effect e

            if level > 0 then
                set i = GetUnitUserData(source)

                if sequence[i] == 13 then
                    call SetUnitAnimationByIndex(source, 13)
                    call QueueUnitAnimation(source, "Stand Ready")
                    set e = AddSpecialEffectEx(CLAW, GetUnitX(source), GetUnitY(source), HEIGHT, SCALE)
                    call BlzSetSpecialEffectOrientation(e, Deg2Rad(GetUnitFacing(source)), 0, Deg2Rad(GetAngle(sequence[i])))
                    call DestroyEffect(e)
                    set sequence[i] = 14
                else
                    call SetUnitAnimationByIndex(source, 14)
                    call QueueUnitAnimation(source, "Stand Ready")
                    set e = AddSpecialEffectEx(CLAW, GetUnitX(source), GetUnitY(source), HEIGHT, SCALE)
                    call BlzSetSpecialEffectOrientation(e, Deg2Rad(GetUnitFacing(source)), 0, Deg2Rad(GetAngle(sequence[i])))
                    call DestroyEffect(e)
                    set sequence[i] = 13
                endif
            endif

            set e = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function thistype.onAttack)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary