library ArsenalUpgrade requires RegisterPlayerUnitEvent, Ability
    /* -------------------- Arsenal Upgrade v1.3 by Chopinski ------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Arsenal Upgrade Ability
        public  constant integer ABILITY       = 'A00B'
        // The raw code of the Tychus unit in the editor
        private constant integer TYCHUS_ID     = 'E000'
        // The GAIN_AT_LEVEL is greater than 0
        // Tychus will gain Arsenal Upgrade at this level 
        private constant integer GAIN_AT_LEVEL = 20
    endglobals

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct ArsenalUpgrade extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Tychus|r non ultimate abilities are upgraded.\n\n|cffffcc00Frag Granade|r - Enemy units cought in the explosion radius are stunned for |cffffcc001.5|r seconds.\n\n|cffffcc00Automated Turrent|r - Reduces the number of attacks necessary to the turrents to release a missile by |cffffcc004|r.\n\n|cffffcc00Overkill|r - The mana cost per bullet is halved.\n\n|cffffcc00Run and Gun|r - Doubles the duration of the movement speed bonus."
        endmethod
        
        private static method onLevelUp takes nothing returns nothing
            local unit u = GetTriggerUnit()
        
            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(u) == TYCHUS_ID and GetHeroLevel(u) == GAIN_AT_LEVEL then
                    call UnitAddAbility(u, ABILITY)
                    call UnitMakeAbilityPermanent(u, true, ABILITY)
                endif
            endif
        
            set u = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevelUp)
        endmethod
    endstruct
endlibrary