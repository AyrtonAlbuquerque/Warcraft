library Periodic requires Table, TimerUtils
    module Periodic
        private static constant real PERIODIC_THRESHOLD = 5 

		private static Table key
		private static Table table
        private static Table struct
        private static Table timers

        private timer _timer
        private integer _unique
        private boolean _allocated

        private method end takes integer i, integer id returns integer
            if i >= 0 then
                set key[id] = key[id] - 1
                set table[i] = table[key[id]]

                if key[id] == 0 then
                    call PauseTimer(GetExpiredTimer())
                endif
            else
                call ReleaseTimer(GetExpiredTimer())
            endif

            if struct.has(_unique) then
                call struct.remove(_unique)
            endif

            if _allocated then
                set _timer = null
                set _allocated = false

                call destroy()
            endif

            return i - 1
        endmethod

        private static method onTimeout takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            if this != 0 then
                static if thistype.onExpire.exists then
                    call onExpire()
                endif

                call end(-1, 0)
            endif
        endmethod

        private static method onPeriodic takes nothing returns nothing
            local integer i = 0
            local integer id = GetHandleId(GetExpiredTimer())
            local thistype this = GetTimerData(GetExpiredTimer())
            
            if this != 0 then
                static if thistype.onPeriod.exists then
                    if not this.onPeriod() then
                        call end(-1, 0)
                    endif
                endif
            else
                loop
                    exitwhen i == key.integer[id]
                        set this = table[i]

                        if this != 0 then
                            static if thistype.onPeriod.exists then
                                if not this.onPeriod() then
                                    set i = end(i, id)
                                endif
                            endif
                        endif
                    set i = i + 1
                endloop
            endif
        endmethod

        static method HasStartedTimer takes integer id returns boolean
            return struct.has(id)
        endmethod

        static method GetTimerInstance takes integer id returns thistype
            return struct[id]
        endmethod

        static method GetRemainingTime takes thistype this returns real
            return TimerGetRemaining(_timer)
        endmethod

        static method StartTimer takes real timeout, boolean periodic, thistype this, integer uniqueId returns nothing
            local integer index = R2I(timeout * 100000)
            local integer id

            if this != 0 then
                set _unique = uniqueId
                set _allocated = true

                if _unique >= 0 and not struct.has(_unique) then
                    set struct[_unique] = this
                endif

                if periodic then
                    if timeout <= PERIODIC_THRESHOLD then
                        if not timers.timer.has(index) then
                            set timers.timer[index] = CreateTimer()
                        endif

                        set id = GetHandleId(timers.timer[index])
                        set _timer = timers.timer[index]
                        set table[key[id]] = this
                        set key[id] = key[id] + 1
    
                        if key[id] == 1 then
                            call TimerStart(timers.timer[index], timeout, periodic, function thistype.onPeriodic)
                        endif
                    else
                        set _timer = NewTimerEx(this)
                        call TimerStart(_timer, timeout, periodic, function thistype.onPeriodic)
                    endif
                else
                    set _timer = NewTimerEx(this)
                    call TimerStart(_timer, timeout, periodic, function thistype.onTimeout)
                endif
            else
                call BJDebugMsg("Periodic Error: instance not provided")
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set key = Table.create()
            set table = Table.create()
            set struct = Table.create()
            set timers = Table.create()
        endmethod
    endmodule
endlibrary
