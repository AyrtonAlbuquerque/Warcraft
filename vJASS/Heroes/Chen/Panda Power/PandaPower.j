library PandaPower requires RegisterPlayerUnitEvent, NewBonus, Ability
    /* ---------------------- Panda Power v1.2 by Chopinski --------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     NFWar          - Icon
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Panda Power Ability
        private constant integer ABILITY       = 'A00D'
        // The raw code of the Chen unit in the editor
        private constant integer CHEN_ID       = 'N000'
        // The GAIN_AT_LEVEL is greater than 0
        // Chen will gain Panda Power at this level 
        private constant integer GAIN_AT_LEVEL = 20
    endglobals

    private function GetAgilityBonus takes integer level returns real
        return 20 + 0.*level
    endfunction

    private function GetStrengthBonus takes integer level returns real
        return 20 + 0.*level
    endfunction

    private function GetIntelligenceBonus takes integer level returns real
        return 20 + 0.*level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct PandaPower extends Ability
        private static method onLevelUp takes nothing returns nothing
            local unit u = GetTriggerUnit()
        
            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(u) == CHEN_ID and GetHeroLevel(u) == GAIN_AT_LEVEL then
                    call UnitAddAbility(u, ABILITY)
                    call UnitMakeAbilityPermanent(u, true, ABILITY)
                    call AddUnitBonus(u, BONUS_AGILITY, GetAgilityBonus(GetUnitAbilityLevel(u, ABILITY)))
                    call AddUnitBonus(u, BONUS_STRENGTH, GetStrengthBonus(GetUnitAbilityLevel(u, ABILITY)))
                    call AddUnitBonus(u, BONUS_INTELLIGENCE, GetIntelligenceBonus(GetUnitAbilityLevel(u, ABILITY)))
                endif
            endif
        
            set u = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevelUp)
        endmethod
    endstruct
endlibrary