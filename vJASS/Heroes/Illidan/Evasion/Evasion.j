library Evade requires RegisterPlayerUnitEvent ,SpellEffectEvent, PluginSpellEffect, NewBonusUtils
    /* ------------------------- Evade v1.2 by Chopinski ------------------------ */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    //     Magtheridon96   - RegisterPlayerUnitEvent
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
            return 10.
        else
            return 5.
        endif
    endfunction

    // The Evasion bonus on cast
    private function GetActiveBonus takes integer level returns real
        return 100.
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Evasion extends array
        private static method onCast takes nothing returns nothing
            call LinkBonusToBuff(Spell.source.unit, BONUS_EVASION_CHANCE, GetActiveBonus(Spell.level), BUFF)
        endmethod

        private static method onLevelUp takes nothing returns nothing
            local unit    source = GetTriggerUnit()
            local integer skill  = GetLearnedSkill()
            local integer level  = GetUnitAbilityLevel(source, skill)
        
            if skill == ABILITY then
                call AddUnitBonus(source, BONUS_EVASION_CHANCE, GetPassiveBonus(level))
            endif
        
            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.onLevelUp)
        endmethod
    endstruct
endlibrary