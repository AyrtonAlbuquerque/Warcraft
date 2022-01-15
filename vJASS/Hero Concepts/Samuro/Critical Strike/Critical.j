library Critical requires RegisterPlayerUnitEvent, NewBonusUtils
    /* ----------------------- Critical v1.2 by Chopinski ----------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     Blizzard       - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Critical Strike ability
        private constant integer ABILITY  = 'A003'
    endglobals

    // The the critical strike chance increament
    private function GetBonusChance takes integer level returns real
        if level == 1 then
            return 10.
        else
            return 5.
        endif
    endfunction

    // The the critical strike multiplier increament
    private function GetBonusMultiplier takes integer level returns real
        if level == 1 then
            return 1.
        else
            return 0.5
        endif
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct CriticalStrike extends array
        static method onLevelUp takes nothing returns nothing
            local unit    source = GetTriggerUnit()
            local integer level  = GetUnitAbilityLevel(source, ABILITY)
            local integer skill  = GetLearnedSkill()
        
            if skill == ABILITY then
                call AddUnitBonus(source, BONUS_CRITICAL_CHANCE, GetBonusChance(level))
                call AddUnitBonus(source, BONUS_CRITICAL_DAMAGE, GetBonusMultiplier(level))
            endif
        
            set source = null
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.onLevelUp)
        endmethod
    endstruct
endlibrary