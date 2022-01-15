library AdaptedWarrior requires Evasion, NewBonusUtils
    /* -------------------- Adapted Warrior v1.2 by Chopinski ------------------- */
    // Credits:
    //     FrIkY          - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Adapted Warrior ability
        private constant integer ABILITY = 'A000'
    endglobals

    // The Attack Speed bonus amount
    private function GetAttackSpeedBonus takes integer level returns real
        return 0.05 + 0.*level
    endfunction

    // The Attack Speed bonus duration
    private function GetAttackSpeedDuration takes integer level returns real
        return 10. + 0.*level
    endfunction

    // The Movement Speed bonus amount
    private function GetMovementSpeedBonus takes integer level returns integer
        return 5 + 0*level
    endfunction

    // The Movement Speed bonus duration
    private function GetMovementSpeedDuration takes integer level returns real
        return 10. + 0.*level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct AdaptedWarrior extends array
        private static method onEvade takes nothing returns nothing
            local unit    source = GetMissingUnit()
            local unit    target = GetEvadingUnit()
            local integer level  = GetUnitAbilityLevel(target, ABILITY)
            local boolean enemy  = IsUnitEnemy(target, GetOwningPlayer(source))
        
            if level > 0 and enemy then
                call AddUnitBonusTimed(target, BONUS_ATTACK_SPEED, GetAttackSpeedBonus(level), GetAttackSpeedDuration(level))
                call AddUnitBonusTimed(target, BONUS_MOVEMENT_SPEED, GetMovementSpeedBonus(level), GetMovementSpeedDuration(level))
            endif
        
            set source = null
            set target = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterEvasionEvent(function thistype.onEvade)
        endmethod
    endstruct
endlibrary