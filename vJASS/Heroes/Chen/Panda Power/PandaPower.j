library PandaPower requires RegisterPlayerUnitEvent
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

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct PandaPower extends array
        private static method onLevelUp takes nothing returns nothing
            local unit u = GetTriggerUnit()
        
            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(u) == CHEN_ID and GetHeroLevel(u) == GAIN_AT_LEVEL then
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