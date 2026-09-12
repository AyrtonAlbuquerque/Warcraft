library Fear requires CrowdControl, Indexer, Dummy, RegisterPlayerUnitEvent
    globals
        integer CROWD_CONTROL_FEAR
    endglobals

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function FearUnit takes unit source, unit target, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.apply(CROWD_CONTROL_FEAR, source, target, 0, 0, duration, model, point, stack)
    endfunction

    function IsUnitFeared takes unit target returns boolean
        return CrowdControl.applied(target, CROWD_CONTROL_FEAR)
    endfunction 

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private struct Fear extends CrowdControl
        private static constant integer buff = 'BU12'
        private static constant integer ability = 'U012'
        private static constant string order = "drunkenhaze"

        private static constant integer DIRECTION_CHANGE = 5 
        private static constant real MAX_CHANGE = 200
        private static constant real PERIOD = 0.2

        private static timer periodic = CreateTimer()
        private static integer keys = -1
        private static unit dummy
        private static ability spell
        private static real array x
        private static real array y
        private static timer array timer
        private static boolean array flag
        private static thistype array array
        private static integer array struct

        private unit unit
        private effect effect
        private integer id
        private integer change

        method start takes unit source, unit target, real value, real angle, real duration, string model, string point, boolean stack returns boolean
            local integer id = GetUnitUserData(target)
            local thistype self
            
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
                    if struct[id] != 0 then
                        set self = struct[id]
                    else
                        set self = thistype.allocate()
                        set self.id = id
                        set self.unit = target
                        set self.change = 0
                        set keys = keys + 1
                        set array[keys] = self
                        set struct[id] = self
    
                        if model != null and point != null then
                            set self.effect = AddSpecialEffectTarget(model, target, point)
                        endif
    
                        if keys == 0 then
                            call TimerStart(periodic, PERIOD, true, function thistype.onPeriod)
                        endif
                    endif
    
                    set flag[id] = true
                    set x[id] = GetRandomReal(GetUnitX(target) - MAX_CHANGE, GetUnitX(target) + MAX_CHANGE)
                    set y[id] = GetRandomReal(GetUnitY(target) - MAX_CHANGE, GetUnitY(target) + MAX_CHANGE)

                    call IssuePointOrder(target, "move", x[id], y[id])
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
            set flag[id] = true
            call IssueImmediateOrder(unit, "stop")
            call DestroyEffect(effect)

            set struct[id] = 0
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

                    if GetUnitAbilityLevel(unit, buff) > 0 then
                        set change = change + 1

                        if change >= DIRECTION_CHANGE then
                            set change = 0
                            set flag[id] = true
                            set x[id] = GetRandomReal(GetUnitX(unit) - MAX_CHANGE, GetUnitX(unit) + MAX_CHANGE)
                            set y[id] = GetRandomReal(GetUnitY(unit) - MAX_CHANGE, GetUnitY(unit) + MAX_CHANGE)
                            call IssuePointOrder(unit, "move", x[id], y[id])
                        endif
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onOrder takes nothing returns nothing
            local unit source = GetOrderedUnit()
            local integer id

            if GetUnitAbilityLevel(source, buff) > 0 and GetIssuedOrderId() != 851973 then
                set id = GetUnitUserData(source)

                if not flag[id] then
                    set flag[id] = true
                    call IssuePointOrder(source, "move", x[id], y[id])
                else
                    set flag[id] = false
                endif
            endif

            set source = null
        endmethod
    
        private static method onInit takes nothing returns nothing
            set CROWD_CONTROL_FEAR = RegisterCrowdControl(thistype.allocate())
            set dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetRectCenterX(GetWorldBounds()), GetRectCenterY(GetWorldBounds()), 0, 0)  

            call UnitAddAbility(dummy, ability)
            call UnitAddAbility(dummy, CrowdControl_TRUE_SIGHT)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, function thistype.onOrder)
            
            set spell = BlzGetUnitAbility(dummy, ability)
        endmethod
    endstruct
endlibrary