library Taunt requires CrowdControl, Indexer, RegisterPlayerUnitEvent
    globals
        integer CROWD_CONTROL_TAUNT
    endglobals
    
    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function TauntUnit takes unit source, unit target, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.apply(CROWD_CONTROL_TAUNT, source, target, 0, 0, duration, model, point, stack)
    endfunction

    function IsUnitTaunted takes unit target returns boolean
        return CrowdControl.applied(target, CROWD_CONTROL_TAUNT)
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private struct Taunt extends CrowdControl
        private static constant integer buff = 'BU13'
        private static constant integer ability = 'U013'
        private static constant string order = "drunkenhaze"

        private static constant real PERIOD = 0.2

        private static unit dummy
        private static ability spell
        private static timer array timer
        private static integer keys = -1
        private static unit array sources
        private static thistype array array
        private static integer array struct
        private static timer periodic = CreateTimer()

        private unit unit
        private integer id
        private effect effect
        private boolean selected

        method start takes unit source, unit target, real value, real angle, real duration, string model, string point, boolean stack returns boolean
            local integer id = GetUnitUserData(target)
            local thistype self
            
            if duration > 0 and UnitAlive(source) and UnitAlive(target) then
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
                    if struct[id] != 0 then
                        set self = struct[id]
                    else
                        set self = thistype.allocate()
                        set self.id = id
                        set self.unit = target
                        set self.selected = IsUnitSelected(target, GetOwningPlayer(target))
                        set keys = keys + 1
                        set array[keys] = self
                        set struct[id] = self
    
                        if self.selected then
                            call SelectUnit(target, false)
                        endif

                        if model != null and point != null then
                            set self.effect = AddSpecialEffectTarget(model, target, point)
                        endif
    
                        if keys == 0 then
                            call TimerStart(periodic, PERIOD, true, function thistype.onPeriod)
                        endif
                    endif

                    set sources[id] = source
                    
                    if IsUnitVisible(source, GetOwningPlayer(target)) then
                        call IssueTargetOrderById(target, 851983, source)
                    else
                        call IssuePointOrderById(target, 851986, GetUnitX(source), GetUnitY(source))
                    endif

                    call TimerStart(timer[id], duration, false, null)
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

        private method remove takes integer i returns integer
            call finish(unit)
            call IssueImmediateOrder(unit, "stop")
            call DestroyEffect(effect)

            if selected and UnitAlive(unit) then
                call SelectUnitAddForPlayer(unit, GetOwningPlayer(unit))
            endif

            set struct[id] = 0
            set sources[id] = null
            set unit = null
            set effect = null
            set array[i] = array[keys]
            set keys = keys - 1

            call deallocate()

            if keys == -1 then
                call PauseTimer(periodic)
            endif

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local thistype this

            loop
                exitwhen i > keys
                    set this = array[i]

                    if GetUnitAbilityLevel(unit, buff) > 0 and UnitAlive(sources[id]) and UnitAlive(unit) then
                        if IsUnitVisible(sources[id],  GetOwningPlayer(unit)) then
                            call IssueTargetOrderById(unit, 851983, sources[id])
                        else
                            call IssuePointOrderById(unit, 851986, GetUnitX(sources[id]), GetUnitY(sources[id]))
                        endif
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onOrder takes nothing returns nothing
            local unit target = GetOrderedUnit()
            local integer order = GetIssuedOrderId()
            local integer id
            
            if GetUnitAbilityLevel(target, buff) > 0 and order != 851973 then
                set id = GetUnitUserData(target)

                if order != 851983 and order != 851986 then
                    if IsUnitVisible(sources[id],  GetOwningPlayer(target)) then
                        call IssueTargetOrderById(target, 851983, sources[id])
                    else 
                        call IssuePointOrderById(target, 851986, GetUnitX(sources[id]), GetUnitY(sources[id]))
                    endif
                else
                    if GetOrderTargetUnit() != sources[id] and GetOrderTargetUnit() != null then
                        if IsUnitVisible(sources[id],  GetOwningPlayer(target)) then
                            call IssueTargetOrderById(target, 851983, sources[id])
                        else 
                            call IssuePointOrderById(target, 851986, GetUnitX(sources[id]), GetUnitY(sources[id]))
                        endif
                    endif
                endif
            endif

            set target = null
        endmethod

        private static method onSelect takes nothing returns nothing
            local unit target = GetTriggerUnit()
            
            if GetUnitAbilityLevel(target, buff) > 0 then
                if IsUnitSelected(target, GetOwningPlayer(target)) then
                    call SelectUnit(target, false)
                endif
            endif
            
            set target = null
        endmethod
    
        private static method onInit takes nothing returns nothing
            set CROWD_CONTROL_TAUNT = RegisterCrowdControl(thistype.allocate())
            set dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetRectCenterX(GetWorldBounds()), GetRectCenterY(GetWorldBounds()), 0, 0)  

            call UnitAddAbility(dummy, ability)
            call UnitAddAbility(dummy, CrowdControl_TRUE_SIGHT)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, function thistype.onSelect)

            set spell = BlzGetUnitAbility(dummy, ability)
        endmethod
    endstruct
endlibrary