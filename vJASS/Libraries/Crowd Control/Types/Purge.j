library Purge requires CrowdControl, Indexer, Dummy, Utilities
    globals
        integer CROWD_CONTROL_PURGE
    endglobals

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function PurgeUnit takes unit source, unit target, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.apply(CROWD_CONTROL_PURGE, source, target, 0, 0, duration, model, point, stack)
    endfunction

    function IsUnitPurged takes unit target returns boolean
        return CrowdControl.applied(target, CROWD_CONTROL_PURGE)
    endfunction
    
    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private struct Purge extends CrowdControl
        private static constant integer buff = 'BU06'
        private static constant integer ability = 'U006'
        private static constant string order = "purge"

        private static unit dummy
        private static ability spell
        private static timer array timer

        method start takes unit source, unit target, real value, real angle, real duration, string model, string point, boolean stack returns boolean
            local integer id = GetUnitUserData(target)
            
            if duration > 0 and target != null then
                if timer[id] == null then
                    set timer[id] = CreateTimer()
                endif

                if stack then
                    set duration = duration + getRemaining(target)
                endif

                call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_HERO, 0, duration)
                call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_NORMAL, 0, duration)
                call IncUnitAbilityLevel(dummy, ability)
                call DecUnitAbilityLevel(dummy, ability)

                if IssueTargetOrder(dummy, order, target) then
                    call UnitRemoveAbility(target, buff)
                    call IssueTargetOrder(dummy, order, target)
                    call TimerStart(timer[id], duration, false, null)

                    if model != null and model != "" then
                        if point != null and point != "" then
                            call LinkEffectToBuff(target, buff, model, point)
                        else
                            call DestroyEffect(AddSpecialEffect(model, GetUnitX(target), GetUnitY(target)))
                        endif
                    endif
                else
                    return false
                endif

                return true
            endif

            return false
        endmethod
        
        method finish takes unit target returns boolean
            local integer id = GetUnitUserData(target)

            if timer[id] != null then
                call DestroyTimer(timer[id])
                set timer[id] = null
            endif

            return UnitRemoveAbility(target, buff)
        endmethod

        method isApplied takes unit target returns boolean
            return GetUnitAbilityLevel(target, buff) > 0
        endmethod

        method getRemaining takes unit target returns real
            local integer id = GetUnitUserData(target)

            if timer[id] != null then
                return TimerGetRemaining(timer[id])
            endif

            return 0.
        endmethod
    
        private static method onInit takes nothing returns nothing
            set CROWD_CONTROL_PURGE = RegisterCrowdControl(thistype.allocate())
            set dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetRectCenterX(GetWorldBounds()), GetRectCenterY(GetWorldBounds()), 0, 0)  

            call UnitAddAbility(dummy, ability)
            call UnitAddAbility(dummy, CrowdControl_TRUE_SIGHT)
            set spell = BlzGetUnitAbility(dummy, ability)
        endmethod
    endstruct
endlibrary