library Knockup requires CrowdControl, Indexer, TimerUtils
    globals
        integer CROWD_CONTROL_KNOCKUP
    endglobals
    
    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function KnockupUnit takes unit source, unit target, real maxHeight, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.apply(CROWD_CONTROL_KNOCKUP, source, target, maxHeight, 0, duration, model, point, stack)
    endfunction

    function IsUnitKnockedUp takes unit target returns boolean
        return CrowdControl.applied(target, CROWD_CONTROL_KNOCKUP)
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private struct Knockup extends CrowdControl
        private static timer array timer
        private static integer array knocked

        private timer periodic 
        private unit unit
        private effect effect
        private integer keys
        private boolean up
        private real rate
        private real airTime

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

                set self = thistype.allocate()
                set self.periodic = NewTimerEx(self)
                set self.unit = target
                set self.rate = value/duration
                set self.airTime = duration
                set self.up = true
                set self.keys = id
                set knocked[self.keys] = knocked[self.keys] + 1

                if model != null and point != null then
                    set self.effect = AddSpecialEffectTarget(model, self.unit, point)
                endif

                if knocked[self.keys] == 1 then
                    call BlzPauseUnitEx(self.unit, true)
                endif

                call UnitAddAbility(self.unit, 'Amrf')
                call UnitRemoveAbility(self.unit, 'Amrf')
                call SetUnitFlyHeight(self.unit, (GetUnitDefaultFlyHeight(self.unit) + value), self.rate)
                call TimerStart(self.periodic, duration/2, false, function thistype.onPeriod)
                call TimerStart(timer[id], duration, false, null)

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

            return false
        endmethod

        method isApplied takes unit target returns boolean
            return knocked[GetUnitUserData(target)] > 0
        endmethod

        method getRemaining takes unit target returns real
            local integer id = GetUnitUserData(target)

            if timer[id] != null then
                return TimerGetRemaining(timer[id])
            endif

            return 0.
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            if up then
                set up = false
                call SetUnitFlyHeight(unit, GetUnitDefaultFlyHeight(unit), rate)
                call TimerStart(periodic, airTime/2, false, function thistype.onPeriod)
            else
                call DestroyEffect(effect)
                call ReleaseTimer(periodic)
                call deallocate()

                set knocked[keys] = knocked[keys] - 1

                if knocked[keys] == 0 then
                    call BlzPauseUnitEx(unit, false)
                endif

                set periodic = null
                set unit = null
                set effect = null
            endif
        endmethod
    
        private static method onInit takes nothing returns nothing
            set CROWD_CONTROL_KNOCKUP = RegisterCrowdControl(thistype.allocate())
        endmethod
    endstruct
endlibrary