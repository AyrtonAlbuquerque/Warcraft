library Modules requires Table, TimerUtils
    module Alloc
        private static integer instanceCount = 0
        private thistype recycle
   
        static method allocate takes nothing returns thistype
            local thistype this
   
            if (thistype(0).recycle == 0) then
                debug if (instanceCount == JASS_MAX_ARRAY_SIZE) then
                    debug call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Alloc ERROR: Attempted to allocate too many instances!")
                    debug return 0
                debug endif
                set instanceCount = instanceCount + 1
                set this = instanceCount
            else
                set this = thistype(0).recycle
                set thistype(0).recycle = thistype(0).recycle.recycle
            endif

            debug set this.recycle = -1
   
            return this
        endmethod
   
        method deallocate takes nothing returns nothing
            debug if (this.recycle != -1) then
                debug call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Alloc ERROR: Attempted to deallocate an invalid instance at [" + I2S(this) + "]!")
                debug return
            debug endif

            set this.recycle = thistype(0).recycle
            set thistype(0).recycle = this
        endmethod
    endmodule

    module LinkedList
        readonly thistype next
        readonly thistype prev

        method initialize takes nothing returns thistype
            set next = this
            set prev = this

            return this
        endmethod

        method push takes thistype node returns thistype
            set node.prev = prev
            set node.next = this
            set prev.next = node
            set prev = node

            return node
        endmethod

        method pop takes nothing returns nothing
            set prev.next = next
            set next.prev = prev
        endmethod
    endmodule

    module Periodic
        private static constant real PERIODIC_THRESHOLD = 5 

		private static Table key
		private static Table table
        private static Table struct
        private static Table timers

        private timer _timer
        private integer _unique
        private integer _calls = 0
        private boolean _allocated

        private method end takes integer i, integer id returns integer
            set _calls = _calls - 1

            if i >= 0 then
                set key[id] = key[id] - 1
                set table[i] = table[key[id]]

                if key[id] == 0 then
                    call PauseTimer(GetExpiredTimer())
                endif
            else
                call ReleaseTimer(GetExpiredTimer())
            endif

            if _calls <= 0 then
                if struct.has(_unique) then
                    call struct.remove(_unique)
                endif

                if _allocated then
                    set _calls = 0
                    set _timer = null
                    set _allocated = false

                    call destroy()
                endif
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

        static method SetTimerPeriod takes thistype this, real timeout returns nothing
            if _timer != null and timeout >= 0 then
                call TimerStart(_timer, timeout, true, function thistype.onPeriodic)
            endif
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
                set _calls = _calls + 1

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
                        if _timer == null then
                            set _timer = NewTimerEx(this)
                        endif

                        call TimerStart(_timer, timeout, periodic, function thistype.onPeriodic)
                    endif
                else
                    call TimerStart(NewTimerEx(this), timeout, periodic, function thistype.onTimeout)
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

    struct List extends array
        implement LinkedList
        implement Alloc
        
        private Table table

        readonly integer data
        readonly integer size
        
        method destroy takes nothing returns nothing
            local thistype node = next
            
            loop
                exitwhen node == this
                    call node.pop()
                    call node.deallocate()
                set node = node.next
            endloop

            call table.destroy()
            call deallocate()

            set size = 0
        endmethod

        method remove takes integer data returns nothing
            local thistype node

            if has(data) then
                set node = table[data]
                set node.data = 0
                set size = size - 1

                call node.pop()
                call node.deallocate()
                call table.remove(data)
            endif
        endmethod

        method insert takes integer data returns thistype
            local thistype node = 0

            if not has(data) then
                set node = push(allocate())
                set node.data = data
                set table[data] = node
                set size = size + 1
            endif

            return node
        endmethod

        method clear takes nothing returns nothing
            local thistype node = next
            
            loop
                exitwhen node == this
                    call node.pop()
                    call node.deallocate()
                set node = node.next
            endloop

            call table.flush()

            set size = 0
        endmethod

        method has takes integer data returns boolean
            return table.has(data)
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = thistype(allocate()).initialize()
            
            set size = 0
            set table = Table.create()
            
            return this
        endmethod
    endstruct
endlibrary