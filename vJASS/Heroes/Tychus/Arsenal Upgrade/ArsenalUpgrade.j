library ArsenalUpgrade requires RegisterPlayerUnitEvent
    /* -------------------- Arsenal Upgrade v1.2 by Chopinski ------------------- */
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
    private struct ArsenalUpgrade extends array
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
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevelUp)
        endmethod
    endstruct
endlibrary