library DrunkenBrawler requires Spell, NewBonus, Utilities
    /* -------------------- Drunken Brawler v1.3 by Chopinski ------------------- */
    // Credits:
    //     Blizzard        - Icon
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
        return 0.07 + 0.*level
    endfunction

    // The Critical chance bonus
    private function GetCriticalChanceBonus takes integer level returns real
        return 0.05 + 0.*level
    endfunction

    // The Critical damage bonus
    private function GetCriticalDamageBonus takes integer level returns real
        return 0.075 + 0.*level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct DrunkenBrawler extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Chen|r has |cffffcc00" + N2S(GetEvasionBonus(level) * 100 * level, 1) + "%|r chance to dodge attacks and have increased |cffffcc00" + N2S(GetCriticalChanceBonus(level) * 100 * level, 1) + "%|r |cffffcc00Critical Strike Chance|r and |cffffcc00" + N2S(GetCriticalDamageBonus(level) * 100 * level, 1) + "%|r |cffffcc00Critical Strike Damage|r."
        endmethod

        private method onLearn takes unit source, integer skill, integer level returns nothing
            call AddUnitBonus(source, BONUS_EVASION_CHANCE, GetEvasionBonus(level))
            call AddUnitBonus(source, BONUS_CRITICAL_CHANCE, GetCriticalChanceBonus(level))
            call AddUnitBonus(source, BONUS_CRITICAL_DAMAGE, GetCriticalDamageBonus(level))
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary