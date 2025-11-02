library Combat requires Indexer, DamageInterface, TimerUtils
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    globals
        // The amount of time before a unit is out of combat
        private constant real COMBAT_TIMEOUT = 5
    endglobals
    
    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function GetCombatSourceUnit takes nothing returns unit
        return Combat.source
    endfunction

    function GetCombatTargetUnit takes nothing returns unit
        return Combat.target
    endfunction
    
    function IsUnitInCombat takes unit u returns boolean
        return Combat.inCombat(u)
    endfunction

    function GetUnitCombatTime takes unit u returns real
        return Combat.time(u)
    endfunction

    function UnitEnterCombat takes unit source, unit target returns nothing
        call Combat.enter(source, target)
    endfunction

    function UnitLeaveCombat takes unit u returns nothing
        call Combat.leave(u)
    endfunction

    function RegisterUnitEnterCombatEvent takes code c returns nothing
        call Combat.registerEnter(c)
    endfunction

    function RegisterUnitLeaveCombatEvent takes code c returns nothing
        call Combat.registerLeave(c)
    endfunction
    
    private function UnitFilter takes unit u returns boolean
        return IsUnitType(u, UNIT_TYPE_HERO) and UnitAlive(u)
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    struct Combat
        private static thistype array array
        private static trigger enters = CreateTrigger()
        private static trigger leaves = CreateTrigger()

        readonly static unit source
        readonly static unit target

        private unit unit
        private timer timer
        private timer reset
        private boolean combat = false

        static method enter takes unit src, unit tgt returns nothing
            local thistype this = array[GetUnitUserData(src)]
            local thistype that = array[GetUnitUserData(tgt)]

            if src != null and UnitFilter(src) then
                if this == 0 then
                    set this = thistype.allocate()
                    set this.timer = NewTimerEx(this)
                    set this.reset = NewTimerEx(this)
                    set array[GetUnitUserData(src)] = this
                endif

                set this.unit = src

                if not this.combat then
                    set this.combat = true
                    set source = src
                    set target = tgt

                    call TriggerEvaluate(enters)
                    call TimerStart(this.timer, 9999999999, true, null)
                endif

                call TimerStart(this.reset, COMBAT_TIMEOUT, false, function thistype.onExpire)
            endif

            if tgt != null and UnitFilter(tgt) then
                if that == 0 then
                    set that = thistype.allocate()
                    set that.timer = NewTimerEx(that)
                    set that.reset = NewTimerEx(that)
                    set array[GetUnitUserData(tgt)] = that
                endif

                set that.unit = tgt

                if not that.combat then
                    set that.combat = true
                    set source = tgt
                    set target = src

                    call TriggerEvaluate(enters)
                    call TimerStart(that.timer, 9999999999, true, null)
                endif

                call TimerStart(that.reset, COMBAT_TIMEOUT, false, function thistype.onExpire)
            endif

            set source = null
            set target = null
        endmethod

        static method leave takes unit u returns nothing
            local thistype this = array[GetUnitUserData(u)]

            if this != 0 then
                if combat then
                    set combat = false
                    set target = null
                    set source = u

                    call PauseTimer(timer)
                    call PauseTimer(reset)
                    call TriggerEvaluate(leaves)

                    set source = null
                endif
            endif
        endmethod

        static method time takes unit u returns real
            local thistype this = array[GetUnitUserData(u)]

            if this != 0 then
                return TimerGetElapsed(timer)
            else
                return 0.
            endif
        endmethod

        static method inCombat takes unit u returns boolean
            local thistype this = array[GetUnitUserData(u)]

            if this != 0 then
                return this.combat
            else
                return false
            endif
        endmethod

        static method registerEnter takes code c returns nothing
            call TriggerAddCondition(enters, Filter(c))
        endmethod

        static method registerLeave takes code c returns nothing
            call TriggerAddCondition(leaves, Filter(c))
        endmethod

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            set combat = false
            set source = unit
            set target = null

            call PauseTimer(timer)
            call TriggerEvaluate(leaves)

            set source = null
        endmethod

        private static method onDamage takes nothing returns nothing
            if Damage.isEnemy then
                call enter(Damage.source.unit, Damage.target.unit)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamagingEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary
