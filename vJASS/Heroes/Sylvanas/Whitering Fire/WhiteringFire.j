library WitheringFire requires RegisterPlayerUnitEvent, Ability
    /* -------------------- Withering Fire v1.3 by Chopinski -------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     Blizzard       - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Withering Fire Ability
        public  constant integer ABILITY               = 'A00L'
        // The raw code of the Withering Fire Normal Ability
        private constant integer WITHERING_FIRE_NORMAL = 'A00M'
        // The raw code of the Withering Fire Cursed Ability
        private constant integer WITHERING_FIRE_CURSED = 'A00N'
        // The raw code of the Sylvanas unit in the editor
        private constant integer SYLVANAS_ID           = 'H001'
        // The GAIN_AT_LEVEL is greater than 0
        // sylvanas will gain Withering Fire at this level 
        private constant integer GAIN_AT_LEVEL         = 20
    endglobals

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct WitheringFire extends Spell
        static method setMissileArt takes unit source, boolean curse returns nothing
            if curse then
                call UnitRemoveAbility(source, WITHERING_FIRE_NORMAL)
                call UnitAddAbility(source, WITHERING_FIRE_CURSED)
                call UnitMakeAbilityPermanent(source, true, WITHERING_FIRE_CURSED)
            else
                call UnitRemoveAbility(source, WITHERING_FIRE_CURSED)
                call UnitAddAbility(source, WITHERING_FIRE_NORMAL)
                call UnitMakeAbilityPermanent(source, true, WITHERING_FIRE_NORMAL)
            endif
        endmethod

        private static method onLevelUp takes nothing returns nothing
            local unit u = GetTriggerUnit()
        
            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(u) == SYLVANAS_ID and GetHeroLevel(u) == GAIN_AT_LEVEL then
                    call UnitAddAbility(u, ABILITY)
                    call UnitMakeAbilityPermanent(u, true, ABILITY)
                    call IssueImmediateOrderById(u, 852175)
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