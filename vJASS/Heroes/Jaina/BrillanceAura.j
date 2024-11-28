library BrillanceAura requires RegisterPlayerUnitEvent, TimerUtils
    /* -------------------- Brilliance Aure v1.1 by Chopinski ------------------- */
    // Credits
    //      Vexorian         - TimerUtils
    //      Magtheridon96    - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY    = 'A003'
        // If true the bonus regen will stack with each cast
        private constant boolean STACK      = false
    endglobals

    // The bonus mana regen when an ability is cast
    private function GetBonusManaRegen takes unit source, integer level returns real
        return 1.5 * level
    endfunction

    // The duration of the bonus regen
    private function GetDuration takes unit source, integer level returns real
        return 2.5 * level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct BrillianceAura
        static thistype array struct

        timer timer
        unit unit
        ability ability
        integer id
        integer levels
        real bonus
        abilityreallevelfield field

        static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local integer i = 0

            loop
                exitwhen i == levels
                    call BlzSetAbilityRealLevelField(ability, field, i, BlzGetAbilityRealLevelField(ability, field, i) - bonus)
                    call IncUnitAbilityLevel(unit, ABILITY)
                    call DecUnitAbilityLevel(unit, ABILITY)
                set i = i + 1
            endloop
            
            call ReleaseTimer(timer)
            call deallocate()

            set struct[id] = 0
            set bonus = 0
            set field = null
            set timer = null
            set unit = null
            set ability = null
        endmethod

        static method onCast takes nothing returns nothing
            local unit source = GetTriggerUnit()
            local integer level = GetUnitAbilityLevel(source, ABILITY)
            local integer i = 0
            local thistype this

            if level > 0 then
                static if STACK then
                    set this = thistype.allocate()
                    set timer = NewTimerEx(this)
                    set id = GetUnitUserData(source)
                    set unit = source
                    set field = ABILITY_RLF_MANA_REGENERATION_INCREASE
                    set ability = BlzGetUnitAbility(source, ABILITY)
                    set levels = BlzGetAbilityIntegerField(ability, ABILITY_IF_LEVELS)
                    set bonus = GetBonusManaRegen(source, level)

                    loop
                        exitwhen i == levels
                            call BlzSetAbilityRealLevelField(ability, field, i, BlzGetAbilityRealLevelField(ability, field, i) + bonus)
                            call IncUnitAbilityLevel(source, ABILITY)
                            call DecUnitAbilityLevel(source, ABILITY)
                        set i = i + 1
                    endloop
                else
                    if struct[GetUnitUserData(source)] != 0 then
                        set this = struct[GetUnitUserData(source)]
                    else
                        set this = thistype.allocate()
                        set timer = NewTimerEx(this)
                        set id = GetUnitUserData(source)
                        set unit = source
                        set field = ABILITY_RLF_MANA_REGENERATION_INCREASE
                        set ability = BlzGetUnitAbility(source, ABILITY)
                        set levels = BlzGetAbilityIntegerField(ability, ABILITY_IF_LEVELS)
                        set bonus = 0
                        set struct[id] = this
                    endif
                    
                    if bonus == 0 then
                        set bonus = GetBonusManaRegen(source, level)

                        loop
                            exitwhen i == levels
                                call BlzSetAbilityRealLevelField(ability, field, i, BlzGetAbilityRealLevelField(ability, field, i) + bonus)
                                call IncUnitAbilityLevel(source, ABILITY)
                                call DecUnitAbilityLevel(source, ABILITY)
                            set i = i + 1
                        endloop
                    endif
                endif

                call TimerStart(timer, GetDuration(source, level), false, function thistype.onExpire)
            endif

            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
        endmethod
    endstruct
endlibrary