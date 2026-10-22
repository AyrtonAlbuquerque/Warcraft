library DoubleThunder requires RegisterPlayerUnitEvent, Utilities, Modules optional StormBolt, optional ThunderClap, optional Avatar
    /* ------------------------------------- Double Thunder v1.6 ------------------------------------ */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     Blizzard       - Icon
    /* ---------------------------------------- By Chopinski ---------------------------------------- */
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // The raw code of the Double Thunder ability
        private constant integer ABILITY = 'Mrd0'
        // Enable or disable double storm bolt (use to control behavior in versions v1, v2 ans v3)
        private constant boolean DOUBLE_STORM_BOLT = false
        // Auto level up
        private constant boolean AUTO_LEVEL_UP = true
    endglobals

    // Every 5 levels increase the double thunder level if AUTO_LEVEL_UP is enabled
    private function GetLevel takes nothing returns integer
        return 5
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
    private struct DoubleThunder
        private static boolean array storm
        private static boolean array thunder

        private real x
        private real y
        private unit unit
        private integer id
        private unit target
        private integer mana
        private string order
        private boolean point
        private integer ability

        private method destroy takes nothing returns nothing
            set unit = null
            set target = null

            call deallocate()
        endmethod

        private method onExpire takes nothing returns nothing
            call BlzEndUnitAbilityCooldown(unit, ability)
            call SetUnitState(unit, UNIT_STATE_MANA, (GetUnitState(unit, UNIT_STATE_MANA) + mana))

            if point then
                if target == null then
                    if not IssuePointOrder(unit, order, x, y) then
                        set storm[id] = false
                    endif
                else
                    if not IssueTargetOrder(unit, order, target) then
                        set storm[id] = false
                    endif
                endif
            else
                if not IssueImmediateOrder(unit, order) then
                    set thunder[id] = false
                endif
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local integer skill = GetSpellAbilityId()
            local unit source = GetTriggerUnit()
            local integer id = GetUnitUserData(source)
            local thistype this
        
            static if LIBRARY_StormBolt and DOUBLE_STORM_BOLT then
                if skill == StormBolt_ABILITY then
                    if storm[id] then
                        set storm[id] = false
                    elseif GetRandomInt(1, 100) <= GetDoubleChance(source, GetUnitAbilityLevel(source, ABILITY)) then
                        set this = thistype.allocate()
                        set point = true
                        set x = GetSpellTargetX()
                        set y = GetSpellTargetY()
                        set target = GetSpellTargetUnit()
                        set ability = skill
                        set this.id = id
                        set unit = source
                        set mana = BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(source, skill), ABILITY_ILF_MANA_COST, GetUnitAbilityLevel(source, skill) - 1)
                        set order = BlzGetAbilityStringLevelField(BlzGetUnitAbility(source, skill), ABILITY_SLF_BASE_ORDER_ID_NCL6, GetUnitAbilityLevel(source, skill) - 1)
                        set storm[id] = true

                        call StartTimer(0.1, false, this, 0)
                    endif
                endif
            endif

            static if LIBRARY_ThunderClap then
                if skill == ThunderClap_ABILITY then
                    if thunder[id] then
                        set thunder[id] = false
                    elseif GetRandomInt(1, 100) <= GetDoubleChance(source, GetUnitAbilityLevel(source, ABILITY)) then
                        set this = thistype.allocate()
                        set point = false
                        set ability = skill
                        set this.id = id
                        set unit = source
                        set mana = BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(source, skill), ABILITY_ILF_MANA_COST, GetUnitAbilityLevel(source, skill) - 1)
                        set order = BlzGetAbilityStringLevelField(BlzGetUnitAbility(source, skill), ABILITY_SLF_BASE_ORDER_ID_NCL6, GetUnitAbilityLevel(source, skill) - 1)
                        set thunder[id] = true

                        call StartTimer(0.1, false, this, 0)
                    endif
                endif
            endif
        endmethod

        private static method onLevel takes nothing returns nothing
            local unit source = GetTriggerUnit()
            local integer level = GetUnitAbilityLevel(source, ABILITY)

            if level > 0 and level < BlzGetAbilityIntegerField(BlzGetUnitAbility(source, ABILITY), ABILITY_IF_LEVELS) then
                if ModuloInteger(GetHeroLevel(source), GetLevel()) == 0 and GetHeroLevel(source) >= 10 then
                   call IncUnitAbilityLevel(source, ABILITY)
                endif
            endif
        
            set source = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            static if AUTO_LEVEL_UP then
                call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
            endif

            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
        endmethod
    endstruct
endlibrary