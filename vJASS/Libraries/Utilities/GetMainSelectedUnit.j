library GetMainSelectedUnit initializer init_function

    globals
        private framehandle containerFrame
        private framehandle array frames
        private group Group = CreateGroup()
        private unit array units
        private integer unitsCount = 0
        private filterfunc filter
    endglobals
    
    function GetUnitOrderValue takes unit u returns integer
        //heroes use the handleId
        if IsUnitType(u, UNIT_TYPE_HERO) then
            return GetHandleId(u)
        else
        //units use unitCode
            return GetUnitTypeId(u)
        endif
    endfunction
    
    private function FilterFunction takes nothing returns boolean
        local unit u = GetFilterUnit()
        local real prio = BlzGetUnitRealField(u, UNIT_RF_PRIORITY)
        local boolean found = false
        local integer loopA = 1
        local integer loopB = 0
        // compare the current u with allready found, to place it in the right slot
        loop
            exitwhen loopA > unitsCount
            if BlzGetUnitRealField(units[loopA], UNIT_RF_PRIORITY) < prio then
                set unitsCount = unitsCount + 1
                set loopB = unitsCount
                loop
                    exitwhen loopB <= loopA
                    set units[loopB] = units[loopB - 1]
                    set loopB = loopB - 1
                endloop
                set units[loopA] = u
                set found = true
                exitwhen true
            // equal prio and better colisions Value
            elseif BlzGetUnitRealField(units[loopA], UNIT_RF_PRIORITY) == prio and GetUnitOrderValue(units[loopA]) > GetUnitOrderValue(u) then
                set unitsCount = unitsCount + 1
                set loopB = unitsCount
                loop
                    exitwhen loopB <= loopA
                    set units[loopB] = units[loopB - 1]
                    set loopB = loopB - 1
                endloop
                set units[loopA] = u
                set found = true
                exitwhen true
            endif
            set loopA = loopA + 1
        endloop
       
        // not found add it at the end
        if not found then
            set unitsCount = unitsCount + 1
            set units[unitsCount] = u
        endif
    
        set u = null
        return false
    endfunction
    
        function GetSelectedUnitIndex takes nothing returns integer
            local integer i = 0
            // local player is in group selection?
            if BlzFrameIsVisible(containerFrame) then
                // find the first visible yellow Background Frame
                loop
                    exitwhen i > 11
                    if BlzFrameIsVisible(frames[i]) then
                        return i
                    endif
                    set i = i + 1
                endloop
            endif
            return -1
        endfunction  
    
        function GetMainSelectedUnit takes integer index returns unit
            if index >= 0 then
                call GroupEnumUnitsSelected(Group, GetLocalPlayer(), filter)
                set bj_groupRandomCurrentPick = units[index + 1]
                //clear table
                loop
                    exitwhen unitsCount <= 0
                    set units[unitsCount] = null
                    set unitsCount = unitsCount - 1
                endloop
                return bj_groupRandomCurrentPick
            else
                call GroupEnumUnitsSelected(Group, GetLocalPlayer(), null)
                return FirstOfGroup(Group)
            endif
        endfunction
    
        // returns the local current main selected unit, using it in a sync gamestate relevant manner breaks the game.
        function GetMainSelectedUnitEx takes nothing returns unit
            return GetMainSelectedUnit(GetSelectedUnitIndex())
        endfunction
    
        private function init_functionAt0s takes nothing returns nothing
            local integer i = 0
            local framehandle console = BlzGetFrameByName("ConsoleUI", 0)
            local framehandle bottomUI = BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0))
            local framehandle groupframe = BlzFrameGetChild(bottomUI, 5)
            local framehandle buttonContainer
            //globals
            set containerFrame = BlzFrameGetChild(groupframe, 0)
            set Group = CreateGroup()
            // give this frames a handleId
            loop 
                exitwhen i >= BlzFrameGetChildrenCount(containerFrame) - 1
                set buttonContainer = BlzFrameGetChild(containerFrame, i)
                set frames[i] = BlzFrameGetChild(buttonContainer, 0)
                set i = i + 1
            endloop
            call DestroyTimer(GetExpiredTimer())
        endfunction
    
        private function init_function takes nothing returns nothing
            set filter = Filter(function FilterFunction)
            call TimerStart(CreateTimer(), 0, false, function init_functionAt0s)
        endfunction
    endlibrary