library WildBond requires RegisterPlayerUnitEvent, TimerUtils, Indexer, NewBonus
    /* ----------------------- Wild Bond v1.0 by Chopinski ---------------------- */
    // Credits:
    //     Nyx-Studio      - Icon
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     Vexorian       - TimerUtils
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Wild Bond Ability
        private constant integer ABILITY       = 'A006'
        // The raw code of the Rexxar unit in the editor
        private constant integer REXXAR_ID     = 'O000'
        // The GAIN_AT_LEVEL is greater than 0
        // Rexxar will gain Wild Bond at this level 
        private constant integer GAIN_AT_LEVEL = 20
        // The updating period
        private constant real    PERIOD        = 1.
    endglobals

    // The bonus damage per unit alive
    private function GetBonusDamage takes integer level returns real
        return 20.*level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct WildBond
        static thistype array struct

        timer timer
        unit unit
        player player
        group group
        real bonus
        
        private method update takes nothing returns nothing
            local unit u

            set bonus = 0
            call GroupEnumUnitsOfPlayer(group, player, null)
            loop
                set u = FirstOfGroup(group)
                exitwhen u == null
                    if UnitAlive(u) and GetUnitAbilityLevel(u, 'Aloc') == 0 and not IsUnitType(u, UNIT_TYPE_HERO) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                        set bonus = bonus + GetBonusDamage(GetUnitAbilityLevel(unit, ABILITY))
                    endif
                call GroupRemoveUnit(group, u)
            endloop
            call AddUnitBonus(unit, BONUS_DAMAGE, bonus)
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            if GetUnitAbilityLevel(unit, ABILITY) > 0 then
                call AddUnitBonus(unit, BONUS_DAMAGE, -bonus)
                call update()
            else
                call ReleaseTimer(timer)
                call DestroyGroup(group)
                call deallocate()
                
                set struct[GetUnitUserData(unit)] = 0
                set timer = null
                set group = null
                set unit = null
                set player  = null
            endif
        endmethod

        private static method onLearn takes nothing returns nothing
            call create(GetLearningUnit(), GetLearnedSkill())
        endmethod

        private static method onLevelUp takes nothing returns nothing
            local unit u = GetTriggerUnit()
        
            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(u) == REXXAR_ID and GetHeroLevel(u) == GAIN_AT_LEVEL then
                    call UnitAddAbility(u, ABILITY)
                    call UnitMakeAbilityPermanent(u, true, ABILITY)
                    call create(u, ABILITY)
                endif
            endif
        
            set u = null
        endmethod

        static method create takes unit source, integer skill returns thistype
            local thistype this
            local integer i = GetUnitUserData(source)

            if skill == ABILITY and struct[i] == 0 then
                set this = thistype.allocate()
                set timer = NewTimerEx(this)
                set unit = source
                set player = GetOwningPlayer(source)
                set group = CreateGroup()
                set struct[i] = this

                call update()
                call TimerStart(timer, PERIOD, true, function thistype.onPeriod)
            endif

            return this
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevelUp)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.onLearn)
        endmethod
    endstruct
endlibrary