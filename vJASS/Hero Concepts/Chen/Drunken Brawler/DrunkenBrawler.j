library DrunkenBrawler requires RegisterPlayerUnitEvent, NewBonusUtils
    /* -------------------- Drunken Brawler v1.2 by Chopinski ------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Magtheridon96   - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Drunken Brawler ability
        private constant integer ABILITY = 'A006'
    endglobals

    // The Evasion bonus
    private function GetEvasionBonus takes integer level returns real
        return 7. + 0.*level
    endfunction

    // The Critical chance bonus
    private function GetCriticalChanceBonus takes integer level returns real
        if level == 1 then
            return 10. + 0.*level
        else
            return 0.
        endif
    endfunction

    // The Critical damage bonus
    private function GetCriticalDamageBonus takes integer level returns real
        if level == 1 then
            return 1. + 0.*level
        else
            return 0.75
        endif
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct DrunkenBrawler extends array
        private static method onLevel takes nothing returns nothing
            local unit    source = GetTriggerUnit()
            local integer level  = GetUnitAbilityLevel(source, ABILITY)

            if GetLearnedSkill() == ABILITY then
                call AddUnitBonus(source, BONUS_EVASION_CHANCE, GetEvasionBonus(level))
                call AddUnitBonus(source, BONUS_CRITICAL_CHANCE, GetCriticalChanceBonus(level))
                call AddUnitBonus(source, BONUS_CRITICAL_DAMAGE, GetCriticalDamageBonus(level))
            endif

            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.onLevel)
        endmethod
    endstruct
endlibrary