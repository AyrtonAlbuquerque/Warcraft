library Knockback requires CrowdControl, Indexer, WorldBounds
    globals
        integer CROWD_CONTROL_KNOCKBACK
    endglobals
    
    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function KnockbackUnit takes unit source, unit target, real angle, real distance, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.apply(CROWD_CONTROL_KNOCKBACK, source, target, distance, angle, duration, model, point, stack)
    endfunction
    
    function IsUnitKnockedBack takes unit target returns boolean
        return CrowdControl.applied(target, CROWD_CONTROL_KNOCKBACK)
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private struct Knockback extends CrowdControl
        private static timer array timer
        private static timer periodic = CreateTimer()
        private static rect rect = Rect(0, 0, 0, 0)
        private static constant real period = 0.03125
        private static thistype array array
        private static integer array struct
        private static integer keys = -1
        private static thistype temp

        private unit unit
        private real theta
        private real offset
        private real distance
        private real timeout
        private real collision
        private integer id
        private effect effect

        method start takes unit source, unit target, real value, real angle, real duration, string model, string point, boolean stack returns boolean
            local integer id = GetUnitUserData(target)
            local thistype self
            
            if duration > 0 and UnitAlive(target) then
                if timer[id] == null then
                    set timer[id] = CreateTimer()
                endif

                if stack then
                    set duration = duration + getRemaining(target)
                endif

                if struct[id] != 0 then
                    set self = struct[id]
                else
                    set self = thistype.allocate()
                    set self.id = id
                    set self.unit = target
                    set self.collision = 2*BlzGetUnitCollisionSize(target)
                    set keys = keys + 1
                    set array[keys] = self
                    set struct[self.id] = self

                    call BlzPauseUnitEx(target, true)

                    if model != null and point != null then
                        set self.effect = AddSpecialEffectTarget(model, target, point)
                    endif

                    if keys == 0 then
                        call TimerStart(periodic, period, true, function thistype.onPeriod)
                    endif
                endif

                set self.theta = angle
                set self.distance = value
                set self.timeout = duration
                set self.offset = RMaxBJ(0.00000001, self.distance*period/RMaxBJ(0.00000001, duration))

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
            return struct[GetUnitUserData(target)] != 0
        endmethod

        method getRemaining takes unit target returns real
            local integer id = GetUnitUserData(target)

            if timer[id] != null then
                return TimerGetRemaining(timer[id])
            endif

            return 0.
        endmethod

        private method remove takes integer i returns integer
            call DestroyEffect(effect)
            call BlzPauseUnitEx(unit, false)

            set unit = null
            set effect = null
            set struct[id] = 0
            set array[i] = array[keys]
            set keys = keys - 1

            call deallocate()

            if keys == -1 then
                call PauseTimer(periodic)
            endif

            return i - 1
        endmethod

        private static method onDestructable takes nothing returns nothing
            local thistype this = temp

            if GetDestructableLife(GetEnumDestructable()) > 0 then
                set timeout = 0
                return
            endif
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local thistype this
            local real x
            local real y
            local unit u

            loop
                exitwhen i > keys
                    set this = array[i]

                    if timeout > 0 and UnitAlive(unit) then
                        set timeout = timeout - period
                        set x = GetUnitX(unit) + offset*Cos(theta)
                        set y = GetUnitY(unit) + offset*Sin(theta)

                        if timeout > 0 and collision > 0 then
                            set temp = this
                            call SetRect(rect, x - collision, y - collision, x + collision, y + collision)
                            call EnumDestructablesInRect(rect, null, function thistype.onDestructable)
                        endif

                        if timeout > 0 then
                            if GetTerrainCliffLevel(GetUnitX(unit), GetUnitY(unit)) < GetTerrainCliffLevel(x, y) and GetUnitZ(unit) < (GetTerrainCliffLevel(x, y) - GetTerrainCliffLevel(WorldBounds.maxX, WorldBounds.maxY))*bj_CLIFFHEIGHT then
                                set timeout = 0
                            endif
                        endif

                        if timeout > 0 then
                            call SetUnitX(unit, x)
                            call SetUnitY(unit, y)
                        endif
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod
    
        private static method onInit takes nothing returns nothing
            set CROWD_CONTROL_KNOCKBACK = RegisterCrowdControl(thistype.allocate())
        endmethod
    endstruct
endlibrary