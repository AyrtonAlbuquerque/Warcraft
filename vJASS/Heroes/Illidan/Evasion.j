library Evade requires Ability, NewBonus, Utilities
    /* ------------------------- Evade v1.3 by Chopinski ------------------------ */
    // Credits:
    //     Blizzard - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Evasion ability
        private constant integer ABILITY = 'A001'
        // The raw code of the Evasion buff
        private constant integer BUFF    = 'B001'
    endglobals

    // The Evasion bonus per level
    private function GetPassiveBonus takes integer level returns real
        if level == 1 then
            return 0.1
        else
            return 0.05
        endif
    endfunction

    // The Evasion bonus on cast
    private function GetActiveBonus takes integer level returns real
        return 1.
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Evasion extends Ability
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Illidan|r has |cffffcc00" + N2S(5 + 5 * level, 0) + "%|r passively increased chance to avoid enemy attacks. When activated his |cffffcc00Evasion|r chance is increased by |cffffcc00" + N2S(GetActiveBonus(level) * 100, 0) + "%|r for |cffffcc00" + N2S(BlzGetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_HERO, level - 1), 1) + "|r seconds."
        endmethod

        private method onLearn takes unit source, integer skill, integer level returns nothing
            call AddUnitBonus(source, BONUS_EVASION_CHANCE, GetPassiveBonus(level))
        endmethod

        private method onCast takes nothing returns nothing
            call LinkBonusToBuff(Spell.source.unit, BONUS_EVASION_CHANCE, GetActiveBonus(Spell.level), BUFF)
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary