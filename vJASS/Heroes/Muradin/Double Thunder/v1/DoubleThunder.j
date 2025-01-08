library DoubleThunder requires RegisterPlayerUnitEvent, optional StormBolt, optional ThunderClap, optional Avatar
    /* ------------------------------------- Double Thunder v1.5 ------------------------------------ */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     Blizzard       - Icon
    /* ---------------------------------------- By Chopinski ---------------------------------------- */
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // The raw code of the Double Thunder ability
        private constant integer ABILITY = 'A000'
    endglobals

    // This updates the double thunder level at levels 10, 15 and 20
    private function GetLevel takes integer level returns integer
        if level < 10 then
            return 1
        elseif level >= 10 and level < 15 then
            return 2
        elseif level >= 15 and level < 20 then
            return 3
        else
            return 4
        endif
    endfunction

    // The chance to proc double thunder
    private function GetDoubleChance takes unit source, integer level returns integer
        static if LIBRARY_Avatar then
            if GetUnitAbilityLevel(source, Avatar_BUFF) > 0 then
                return 100
            else
                return 25 * level
            endif
        else
            return 25 * level
        endif
    endfunction

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    private struct DoubleThunder extends array
        private static method onLevel takes nothing returns nothing
            local unit source = GetTriggerUnit()
        
            if GetUnitAbilityLevel(source, ABILITY) > 0 then
                call SetUnitAbilityLevel(source, ABILITY, GetLevel(GetHeroLevel(source)))
            endif
        
            set source = null
        endmethod

        private static method onCast takes nothing returns nothing
            local unit source = GetTriggerUnit()
            local unit target = GetSpellTargetUnit()
            local integer skill = GetSpellAbilityId()
            local integer level = GetUnitAbilityLevel(source, ABILITY)
            local integer chance = GetDoubleChance(source, level)
        
            static if LIBRARY_StormBolt then
                if skill == StormBolt_ABILITY then
                    if GetRandomInt(1, 100) <= chance then
                        call UnitAddAbility(source,  StormBolt_STORM_BOLT_RECAST)
                        call TriggerSleepAction(0.10)
                        call IssueTargetOrder(source, "creepthunderbolt", target)
                        call TriggerSleepAction(0.50)
                        call UnitRemoveAbility(source, StormBolt_STORM_BOLT_RECAST)
                    endif
                endif
            endif

            static if LIBRARY_ThunderClap then
                if skill == ThunderClap_ABILITY then
                    if GetRandomInt(1, 100) <= chance then
                        call UnitAddAbility(source, ThunderClap_THUNDER_CLAP_RECAST)
                        call SetUnitAbilityLevel(source, ThunderClap_THUNDER_CLAP_RECAST, GetUnitAbilityLevel(source, ThunderClap_ABILITY))
                        call IssueImmediateOrder(source, "creepthunderclap")
                        call TriggerSleepAction(0.50)
                        call UnitRemoveAbility(source, ThunderClap_THUNDER_CLAP_RECAST)
                    endif
                endif
            endif
        
            set source = null
            set target = null
        endmethod

        private static method onInit takes nothing returns nothing
            local trigger t = CreateTrigger()

            call TriggerRegisterAnyUnitEventBJ(t, EVENT_PLAYER_UNIT_SPELL_EFFECT)
            call TriggerAddAction(t, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endlibrary