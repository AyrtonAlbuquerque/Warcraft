library RangerPrecision requires DamageInterface, RegisterPlayerUnitEvent, NewBonusUtils
    /* ------------------- Ranger Precision v1.2 by Chopinski ------------------- */
    // Credits:
    //     Magtheridon96 - RegisterPlayerUnitEvent
    //     The Panda     - Dark Bow icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Ranger Precision ability
        private constant integer ABILITY     = 'A00E'
        // The bonus type gained
        private constant integer BONUS_TYPE  = BONUS_AGILITY
    endglobals

    // The bonus duration
    private function GetBonusDuration takes integer level returns real
        return 10. + 0*level
    endfunction

    // The amount of agility gained
    private function GetBonusAmount takes integer level returns integer
        return 2 + 0*level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct RangerPrecision extends array
        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if level > 0 and Damage.target.isHero then
                call AddUnitBonusTimed(Damage.source.unit, BONUS_TYPE, GetBonusAmount(level), GetBonusDuration(level))
            endif
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit    killer = GetKillingUnit()
            local integer level  = GetUnitAbilityLevel(killer, ABILITY)

            if level > 0 then
                call AddUnitBonusTimed(killer, BONUS_TYPE, GetBonusAmount(level), GetBonusDuration(level))
            endif

            set killer = null
        endmethod   

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endlibrary