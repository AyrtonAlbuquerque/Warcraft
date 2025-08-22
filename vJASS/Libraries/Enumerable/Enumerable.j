library Enumerable requires Table, Modules, RegisterPlayerUnitEvent
    globals
        // The size of each cell in the grid
        private constant integer CELL_SIZE          = 256
        // Item size
        private constant real    ITEM_SIZE          = 16.
        // Destructable size
        private constant real    DESTRUCTABLE_SIZE  = 64.
        // Update period
        private constant real    UPDATE_PERIOD      = 0.2
    endglobals

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    // When you want to set a collision callback function for a object declare a static method or function
    // with these paramenters and set object.onCollide = your_function
    function interface onCollision takes Object colisor, Object collided returns nothing
    
    // When you use the Enum... functions you can declare a static method or function with these parameters
    // and pass the function as a parameter. The data parameter you can use to pass additional information
    // like an struct instance or whatever.
    function interface onEnumeration takes Object object, integer data returns nothing

    /* -------------------------------------- Enumeration -------------------------------------- */
    // Enum functions return a Table which you can loop through. Dont forget to destroy the returned table afterwards
    function EnumObjectsInRange takes real x, real y, real range, integer data, onEnumeration callback returns Table
        return Enumerable.enum(x, y, range, data, callback)
    endfunction

    function EnumUnitsInRange takes real x, real y, real range, integer data, onEnumeration callback returns Table
        return Enumerable.enumUnits(x, y, range, data, callback)
    endfunction

    function EnumItemsInRange takes real x, real y, real range, integer data, onEnumeration callback returns Table
        return Enumerable.enumItems(x, y, range, data, callback)
    endfunction

    function EnumCustomsInRange takes real x, real y, real range, integer data, onEnumeration callback returns Table
        return Enumerable.enumCustoms(x, y, range, data, callback)
    endfunction

    function EnumDestructablesInRange takes real x, real y, real range, integer data, onEnumeration callback returns Table
        return Enumerable.enumDestructables(x, y, range, data, callback)
    endfunction

    function EnumObjectsInRect takes rect r, integer data, onEnumeration callback returns Table
        return Enumerable.enumInRect(r, data, callback)
    endfunction

    function EnumUnitsInRect takes rect r, integer data, onEnumeration callback returns Table
        return Enumerable.enumUnitsInRect(r, data, callback)
    endfunction

    function EnumItemsInRectEx takes rect r, integer data, onEnumeration callback returns Table
        return Enumerable.enumItemsInRect(r, data, callback)
    endfunction

    function EnumCustomsInRect takes rect r, integer data, onEnumeration callback returns Table
        return Enumerable.enumCustomsInRect(r, data, callback)
    endfunction

    function EnumDestructablesInRectEx takes rect r, integer data, onEnumeration callback returns Table
        return Enumerable.enumDestructablesInRect(r, data, callback)
    endfunction

    /* ---------------------------------------- Objects ---------------------------------------- */
    function IsObjectUnit takes Object object returns boolean
        return object.isUnit
    endfunction

    function IsObjectItem takes Object object returns boolean
        return object.isItem
    endfunction

    function IsObjectCustom takes Object object returns boolean
        return object.isCustom
    endfunction

    function IsObjectDestructable takes Object object returns boolean
        return object.isDestructable
    endfunction

    function IsObjectVisible takes Object object returns boolean
        return object.visible
    endfunction

    function IsObjectTrackable takes Object object returns boolean
        return object.trackable
    endfunction

    function GetObjectX takes Object object returns real
        return object.x
    endfunction

    function GetObjectY takes Object object returns real
        return object.y
    endfunction

    function GetObjectZ takes Object object returns real
        return object.z
    endfunction

    function GetObjectData takes Object object returns integer
        return object.data
    endfunction

    function GetObjectUnit takes Object object returns unit
        return object.unit
    endfunction

    function GetObjectItem takes Object object returns item
        return object.item
    endfunction

    function GetObjectDestructable takes Object object returns destructable
        return object.destructable
    endfunction

    function GetObjectCollision takes Object object returns real
        return object.collision
    endfunction

    function GetObjectCollisionCallback takes Object object returns onCollision
        return object.onCollide
    endfunction

    function GetClosestObjectInRange takes real x, real y, real range returns Object
        return Enumerable.closest(x, y, range)
    endfunction

    function GetClosestUnitInRange takes real x, real y, real range returns unit
        return Enumerable.closestUnit(x, y, range)
    endfunction

    function GetClosestItemInRange takes real x, real y, real range returns item
        return Enumerable.closestItem(x, y, range)
    endfunction

    function GetClosestCustomInRange takes real x, real y, real range returns Object
        return Enumerable.closestCustom(x, y, range)
    endfunction

    function GetClosestDestructableInRange takes real x, real y, real range returns destructable
        return Enumerable.closestDestructable(x, y, range)
    endfunction

    function SetObjectX takes Object object, real x returns nothing
        set object.x = x
    endfunction

    function SetObjectY takes Object object, real y returns nothing
        set object.y = y
    endfunction

    function SetObjectZ takes Object object, real z returns nothing
        set object.z = z
    endfunction

    function SetObjectData takes Object object, integer data returns nothing
        set object.data = data
    endfunction

    function SetObjectVisible takes Object object, boolean visible returns nothing
        set object.visible = visible
    endfunction

    function SetObjectTrackable takes Object object, boolean flag returns nothing
        set object.trackable = flag
    endfunction

    function SetObjectCollision takes Object object, real size returns nothing
        set object.collision = size
    endfunction

    function SetObjectCollisionCallback takes Object object, onCollision callback returns nothing
        set object.onCollide = callback
    endfunction

    function TrackObject takes Object object returns nothing
        call Enumerable.track(object)
    endfunction

    function UntrackObject takes Object object returns nothing
        call Enumerable.untrack(object)
    endfunction

    function RemoveObject takes Object object returns nothing
        call Enumerable.remove(object)
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private module Hooks
        static method hookRemove takes agent a returns nothing
            if Object.registered(a) then
                call remove(Object[a])
            endif
        endmethod

        static method hookVisibility takes agent a, boolean visible returns nothing
            local Object object = Object[a]
            
            set object.visible = visible

            if not visible then
                call untrack(object)
            else
                call track(object)
            endif
        endmethod

        static method hookCreate takes integer id, real x, real y returns nothing
            call MoveRectTo(rect, x, y)
            call TimerStart(CreateTimer(), 0.00, false, function thistype.onNewItem)
        endmethod

        static method hookRestore takes destructable d, real life, boolean birth returns nothing
            if not Object.registered(d) and life > 0 then
                call Object.create(d).update()
                call TriggerRegisterDeathEvent(death, d)
            endif
        endmethod

        static method hookCreateLocation takes integer id, location l returns nothing
            call MoveRectTo(rect, GetLocationX(l), GetLocationY(l))
            call TimerStart(CreateTimer(), 0.00, false, function thistype.onNewItem)
        endmethod
        
        static method hookCreateDestructable takes integer id, real x, real y, real face, real scale, integer variation returns nothing
            call MoveRectTo(rect, x, y)
            call TimerStart(CreateTimer(), 0.00, false, function thistype.onNewDestructable)
        endmethod

        static method hookCreateDestructableZ takes integer id, real x, real y, real z, real face, real scale, integer variation returns nothing
            call MoveRectTo(rect, x, y)
            call TimerStart(CreateTimer(), 0.00, false, function thistype.onNewDestructable)
        endmethod 

        static method hookCreateDestructableSkin takes integer id, real x, real y, real face, real scale, integer variation, integer skinId returns nothing
            call MoveRectTo(rect, x, y)
            call TimerStart(CreateTimer(), 0.00, false, function thistype.onNewDestructable)
        endmethod

        static method hookCreateDestructableZSkin takes integer id, real x, real y, real z, real face, real scale, integer variation, integer skinId returns nothing
            call MoveRectTo(rect, x, y)
            call TimerStart(CreateTimer(), 0.00, false, function thistype.onNewDestructable)
        endmethod
    endmodule

    private module Enumerations
        private static integer enums = 1
        private static integer array visited

        static method enum takes real x, real y, real range, integer data, onEnumeration callback returns Table
            local real dx
            local real dy
            local integer i
            local integer j
            local integer k
            local integer l
            local integer minI
            local integer maxI 
            local integer minJ
            local integer maxJ
            local Cell grid
            local real radius
            local Object object
            local Table result = 0
            
            if range > 0 then
                set minI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x - range - Map.minX) * Enumerable.width  / Map.width)))
                set maxI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x + range - Map.minX) * Enumerable.width  / Map.width)))
                set minJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y - range - Map.minY) * Enumerable.height / Map.height)))
                set maxJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y + range - Map.minY) * Enumerable.height / Map.height)))
                set enums = enums + 1
                set i = minI
                set j = minJ
                set l = 0

                if callback == 0 then
                    set result = Table.create()
                endif

                if enums <= 0 then
                    set enums = 1
                endif

                loop
                    exitwhen i > maxI
                        set j = minJ

                        loop
                            exitwhen j > maxJ
                                set k = 0
                                set grid = cell[i][j]

                                loop
                                    exitwhen k >= grid.size
                                        set object = grid[k]

                                        if object != 0 and object.visible and visited[object] != enums then
                                            set dx = object.x - x
                                            set dy = object.y - y
                                            set visited[object] = enums
                                            set radius = range + object.size

                                            if dx*dx + dy*dy <= radius*radius then
                                                if callback != 0 then
                                                    call callback.evaluate(object, data)
                                                else
                                                    set result[l] = object
                                                    set l = l + 1
                                                endif
                                            endif
                                        endif
                                    set k = k + 1
                                endloop
                            set j = j + 1
                        endloop
                    set i = i + 1
                endloop
            endif

            return result
        endmethod

        static method enumUnits takes real x, real y, real range, integer data, onEnumeration callback returns Table
            local real dx
            local real dy
            local integer i
            local integer j
            local integer k
            local integer l
            local integer minI
            local integer maxI 
            local integer minJ
            local integer maxJ
            local Cell grid
            local real radius
            local Object object
            local Table result = 0
            
            if range > 0 then
                set minI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x - range - Map.minX) * Enumerable.width  / Map.width)))
                set maxI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x + range - Map.minX) * Enumerable.width  / Map.width)))
                set minJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y - range - Map.minY) * Enumerable.height / Map.height)))
                set maxJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y + range - Map.minY) * Enumerable.height / Map.height)))
                set enums = enums + 1
                set i = minI
                set j = minJ
                set l = 0

                if callback == 0 then
                    set result = Table.create()
                endif

                if enums <= 0 then
                    set enums = 1
                endif

                loop
                    exitwhen i > maxI
                        set j = minJ

                        loop
                            exitwhen j > maxJ
                                set k = 0
                                set grid = cell[i][j]

                                loop
                                    exitwhen k >= grid.size
                                        set object = grid[k]

                                        if object != 0 and object.isUnit and object.visible and visited[object] != enums then
                                            set dx = object.x - x
                                            set dy = object.y - y
                                            set visited[object] = enums
                                            set radius = range + object.size

                                            if dx*dx + dy*dy <= radius*radius then
                                                if callback != 0 then
                                                    call callback.evaluate(object, data)
                                                else
                                                    set result[l] = object
                                                    set l = l + 1
                                                endif
                                            endif
                                        endif
                                    set k = k + 1
                                endloop
                            set j = j + 1
                        endloop
                    set i = i + 1
                endloop
            endif

            return result
        endmethod

        static method enumItems takes real x, real y, real range, integer data, onEnumeration callback returns Table
            local real dx
            local real dy
            local integer i
            local integer j
            local integer k
            local integer l
            local integer minI
            local integer maxI 
            local integer minJ
            local integer maxJ
            local Cell grid
            local real radius
            local Object object
            local Table result = 0
            
            if range > 0 then
                set minI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x - range - Map.minX) * Enumerable.width  / Map.width)))
                set maxI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x + range - Map.minX) * Enumerable.width  / Map.width)))
                set minJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y - range - Map.minY) * Enumerable.height / Map.height)))
                set maxJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y + range - Map.minY) * Enumerable.height / Map.height)))
                set enums = enums + 1
                set i = minI
                set j = minJ
                set l = 0

                if callback == 0 then
                    set result = Table.create()
                endif

                if enums <= 0 then
                    set enums = 1
                endif

                loop
                    exitwhen i > maxI
                        set j = minJ

                        loop
                            exitwhen j > maxJ
                                set k = 0
                                set grid = cell[i][j]

                                loop
                                    exitwhen k >= grid.size
                                        set object = grid[k]

                                        if object != 0 and object.isItem and object.visible and visited[object] != enums then
                                            set dx = object.x - x
                                            set dy = object.y - y
                                            set visited[object] = enums
                                            set radius = range + object.size

                                            if dx*dx + dy*dy <= radius*radius then
                                                if callback != 0 then
                                                    call callback.evaluate(object, data)
                                                else
                                                    set result[l] = object
                                                    set l = l + 1
                                                endif
                                            endif
                                        endif
                                    set k = k + 1
                                endloop
                            set j = j + 1
                        endloop
                    set i = i + 1
                endloop
            endif

            return result
        endmethod

        static method enumCustoms takes real x, real y, real range, integer data, onEnumeration callback returns Table
            local real dx
            local real dy
            local integer i
            local integer j
            local integer k
            local integer l
            local integer minI
            local integer maxI 
            local integer minJ
            local integer maxJ
            local Cell grid
            local real radius
            local Object object
            local Table result = 0
            
            if range > 0 then
                set minI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x - range - Map.minX) * Enumerable.width  / Map.width)))
                set maxI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x + range - Map.minX) * Enumerable.width  / Map.width)))
                set minJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y - range - Map.minY) * Enumerable.height / Map.height)))
                set maxJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y + range - Map.minY) * Enumerable.height / Map.height)))
                set enums = enums + 1
                set i = minI
                set j = minJ
                set l = 0

                if callback == 0 then
                    set result = Table.create()
                endif

                if enums <= 0 then
                    set enums = 1
                endif

                loop
                    exitwhen i > maxI
                        set j = minJ

                        loop
                            exitwhen j > maxJ
                                set k = 0
                                set grid = cell[i][j]

                                loop
                                    exitwhen k >= grid.size
                                        set object = grid[k]

                                        if object != 0 and object.isCustom and object.visible and visited[object] != enums then
                                            set dx = object.x - x
                                            set dy = object.y - y
                                            set visited[object] = enums
                                            set radius = range + object.size

                                            if dx*dx + dy*dy <= radius*radius then
                                                if callback != 0 then
                                                    call callback.evaluate(object, data)
                                                else
                                                    set result[l] = object
                                                    set l = l + 1
                                                endif
                                            endif
                                        endif
                                    set k = k + 1
                                endloop
                            set j = j + 1
                        endloop
                    set i = i + 1
                endloop
            endif

            return result
        endmethod

        static method enumDestructables takes real x, real y, real range, integer data, onEnumeration callback returns Table
            local real dx
            local real dy
            local integer i
            local integer j
            local integer k
            local integer l
            local integer minI
            local integer maxI 
            local integer minJ
            local integer maxJ
            local Cell grid
            local real radius
            local Object object
            local Table result = 0
            
            if range > 0 then
                set minI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x - range - Map.minX) * Enumerable.width  / Map.width)))
                set maxI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x + range - Map.minX) * Enumerable.width  / Map.width)))
                set minJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y - range - Map.minY) * Enumerable.height / Map.height)))
                set maxJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y + range - Map.minY) * Enumerable.height / Map.height)))
                set enums = enums + 1
                set i = minI
                set j = minJ
                set l = 0

                if callback == 0 then
                    set result = Table.create()
                endif

                if enums <= 0 then
                    set enums = 1
                endif

                loop
                    exitwhen i > maxI
                        set j = minJ

                        loop
                            exitwhen j > maxJ
                                set k = 0
                                set grid = cell[i][j]

                                loop
                                    exitwhen k >= grid.size
                                        set object = grid[k]

                                        if object != 0 and object.isDestructable and object.visible and visited[object] != enums then
                                            set dx = object.x - x
                                            set dy = object.y - y
                                            set visited[object] = enums
                                            set radius = range + object.size

                                            if dx*dx + dy*dy <= radius*radius then
                                                if callback != 0 then
                                                    call callback.evaluate(object, data)
                                                else
                                                    set result[l] = object
                                                    set l = l + 1
                                                endif
                                            endif
                                        endif
                                    set k = k + 1
                                endloop
                            set j = j + 1
                        endloop
                    set i = i + 1
                endloop
            endif

            return result
        endmethod

        static method enumInRect takes rect r, integer data, onEnumeration callback returns Table
            local integer i
            local integer j
            local integer k
            local integer l
            local real minX
            local real maxX
            local real minY
            local real maxY
            local integer minI
            local integer maxI 
            local integer minJ
            local integer maxJ
            local Cell grid
            local Object object
            local Table result = 0

            if r != null then
                set minX = GetRectMinX(r)
                set maxX = GetRectMaxX(r)
                set minY = GetRectMinY(r)
                set maxY = GetRectMaxY(r)
                set minI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((minX - Map.minX) * Enumerable.width  / Map.width)))
                set maxI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((maxX - Map.minX) * Enumerable.width  / Map.width)))
                set minJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((minY - Map.minY) * Enumerable.height / Map.height)))
                set maxJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((maxY - Map.minY) * Enumerable.height / Map.height)))
                set enums = enums + 1
                set i = minI
                set j = minJ
                set l = 0

                if callback == 0 then
                    set result = Table.create()
                endif

                if enums <= 0 then
                    set enums = 1
                endif

                loop
                    exitwhen i > maxI
                        set j = minJ

                        loop
                            exitwhen j > maxJ
                                set k = 0
                                set grid = cell[i][j]

                                loop
                                    exitwhen k >= grid.size
                                        set object = grid[k]

                                        if object != 0 and object.visible and visited[object] != enums then
                                            set visited[object] = enums

                                            if object.x >= minX and object.x <= maxX and object.y >= minY and object.y <= maxY then
                                                if callback != 0 then
                                                    call callback.evaluate(object, data)
                                                else
                                                    set result[l] = object
                                                    set l = l + 1
                                                endif
                                            endif
                                        endif
                                    set k = k + 1
                                endloop
                            set j = j + 1
                        endloop
                    set i = i + 1
                endloop
            endif

            return result
        endmethod

        static method enumUnitsInRect takes rect r, integer data, onEnumeration callback returns Table
            local integer i
            local integer j
            local integer k
            local integer l
            local real minX
            local real maxX
            local real minY
            local real maxY
            local integer minI
            local integer maxI 
            local integer minJ
            local integer maxJ
            local Cell grid
            local Object object
            local Table result = 0

            if r != null then
                set minX = GetRectMinX(r)
                set maxX = GetRectMaxX(r)
                set minY = GetRectMinY(r)
                set maxY = GetRectMaxY(r)
                set minI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((minX - Map.minX) * Enumerable.width  / Map.width)))
                set maxI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((maxX - Map.minX) * Enumerable.width  / Map.width)))
                set minJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((minY - Map.minY) * Enumerable.height / Map.height)))
                set maxJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((maxY - Map.minY) * Enumerable.height / Map.height)))
                set enums = enums + 1
                set i = minI
                set j = minJ
                set l = 0

                if callback == 0 then
                    set result = Table.create()
                endif

                if enums <= 0 then
                    set enums = 1
                endif

                loop
                    exitwhen i > maxI
                        set j = minJ

                        loop
                            exitwhen j > maxJ
                                set k = 0
                                set grid = cell[i][j]

                                loop
                                    exitwhen k >= grid.size
                                        set object = grid[k]

                                        if object != 0 and object.visible and visited[object] != enums then
                                            set visited[object] = enums

                                            if object.isUnit and object.x >= minX and object.x <= maxX and object.y >= minY and object.y <= maxY then
                                                if callback != 0 then
                                                    call callback.evaluate(object, data)
                                                else
                                                    set result[l] = object
                                                    set l = l + 1
                                                endif
                                            endif
                                        endif
                                    set k = k + 1
                                endloop
                            set j = j + 1
                        endloop
                    set i = i + 1
                endloop
            endif

            return result
        endmethod

        static method enumItemsInRect takes rect r, integer data, onEnumeration callback returns Table
            local integer i
            local integer j
            local integer k
            local integer l
            local real minX
            local real maxX
            local real minY
            local real maxY
            local integer minI
            local integer maxI 
            local integer minJ
            local integer maxJ
            local Cell grid
            local Object object
            local Table result = 0

            if r != null then
                set minX = GetRectMinX(r)
                set maxX = GetRectMaxX(r)
                set minY = GetRectMinY(r)
                set maxY = GetRectMaxY(r)
                set minI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((minX - Map.minX) * Enumerable.width  / Map.width)))
                set maxI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((maxX - Map.minX) * Enumerable.width  / Map.width)))
                set minJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((minY - Map.minY) * Enumerable.height / Map.height)))
                set maxJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((maxY - Map.minY) * Enumerable.height / Map.height)))
                set enums = enums + 1
                set i = minI
                set j = minJ
                set l = 0

                if callback == 0 then
                    set result = Table.create()
                endif

                if enums <= 0 then
                    set enums = 1
                endif

                loop
                    exitwhen i > maxI
                        set j = minJ

                        loop
                            exitwhen j > maxJ
                                set k = 0
                                set grid = cell[i][j]

                                loop
                                    exitwhen k >= grid.size
                                        set object = grid[k]

                                        if object != 0 and object.visible and visited[object] != enums then
                                            set visited[object] = enums

                                            if object.isItem and object.x >= minX and object.x <= maxX and object.y >= minY and object.y <= maxY then
                                                if callback != 0 then
                                                    call callback.evaluate(object, data)
                                                else
                                                    set result[l] = object
                                                    set l = l + 1
                                                endif
                                            endif
                                        endif
                                    set k = k + 1
                                endloop
                            set j = j + 1
                        endloop
                    set i = i + 1
                endloop
            endif

            return result
        endmethod

        static method enumCustomsInRect takes rect r, integer data, onEnumeration callback returns Table
            local integer i
            local integer j
            local integer k
            local integer l
            local real minX
            local real maxX
            local real minY
            local real maxY
            local integer minI
            local integer maxI 
            local integer minJ
            local integer maxJ
            local Cell grid
            local Object object
            local Table result = 0

            if r != null then
                set minX = GetRectMinX(r)
                set maxX = GetRectMaxX(r)
                set minY = GetRectMinY(r)
                set maxY = GetRectMaxY(r)
                set minI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((minX - Map.minX) * Enumerable.width  / Map.width)))
                set maxI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((maxX - Map.minX) * Enumerable.width  / Map.width)))
                set minJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((minY - Map.minY) * Enumerable.height / Map.height)))
                set maxJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((maxY - Map.minY) * Enumerable.height / Map.height)))
                set enums = enums + 1
                set i = minI
                set j = minJ
                set l = 0

                if callback == 0 then
                    set result = Table.create()
                endif

                if enums <= 0 then
                    set enums = 1
                endif

                loop
                    exitwhen i > maxI
                        set j = minJ

                        loop
                            exitwhen j > maxJ
                                set k = 0
                                set grid = cell[i][j]

                                loop
                                    exitwhen k >= grid.size
                                        set object = grid[k]

                                        if object != 0 and object.visible and visited[object] != enums then
                                            set visited[object] = enums

                                            if object.isCustom and object.x >= minX and object.x <= maxX and object.y >= minY and object.y <= maxY then
                                                if callback != 0 then
                                                    call callback.evaluate(object, data)
                                                else
                                                    set result[l] = object
                                                    set l = l + 1
                                                endif
                                            endif
                                        endif
                                    set k = k + 1
                                endloop
                            set j = j + 1
                        endloop
                    set i = i + 1
                endloop
            endif

            return result
        endmethod

        static method enumDestructablesInRect takes rect r, integer data, onEnumeration callback returns Table
            local integer i
            local integer j
            local integer k
            local integer l
            local real minX
            local real maxX
            local real minY
            local real maxY
            local integer minI
            local integer maxI 
            local integer minJ
            local integer maxJ
            local Cell grid
            local Object object
            local Table result = 0

            if r != null then
                set minX = GetRectMinX(r)
                set maxX = GetRectMaxX(r)
                set minY = GetRectMinY(r)
                set maxY = GetRectMaxY(r)
                set minI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((minX - Map.minX) * Enumerable.width  / Map.width)))
                set maxI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((maxX - Map.minX) * Enumerable.width  / Map.width)))
                set minJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((minY - Map.minY) * Enumerable.height / Map.height)))
                set maxJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((maxY - Map.minY) * Enumerable.height / Map.height)))
                set enums = enums + 1
                set i = minI
                set j = minJ
                set l = 0

                if callback == 0 then
                    set result = Table.create()
                endif

                if enums <= 0 then
                    set enums = 1
                endif

                loop
                    exitwhen i > maxI
                        set j = minJ

                        loop
                            exitwhen j > maxJ
                                set k = 0
                                set grid = cell[i][j]

                                loop
                                    exitwhen k >= grid.size
                                        set object = grid[k]

                                        if object != 0 and object.visible and visited[object] != enums then
                                            set visited[object] = enums

                                            if object.isDestructable and object.x >= minX and object.x <= maxX and object.y >= minY and object.y <= maxY then
                                                if callback != 0 then
                                                    call callback.evaluate(object, data)
                                                else
                                                    set result[l] = object
                                                    set l = l + 1
                                                endif
                                            endif
                                        endif
                                    set k = k + 1
                                endloop
                            set j = j + 1
                        endloop
                    set i = i + 1
                endloop
            endif

            return result
        endmethod

        static method closest takes real x, real y, real range returns Object
            local real dx
            local real dy
            local integer i
            local integer j
            local integer k
            local integer minI
            local integer maxI 
            local integer minJ
            local integer maxJ
            local Cell grid
            local Object o = 0
            local Object object
            local real distance
            local real closest = range * range
            
            if range > 0 then
                set minI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x - range - Map.minX) * Enumerable.width  / Map.width)))
                set maxI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x + range - Map.minX) * Enumerable.width  / Map.width)))
                set minJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y - range - Map.minY) * Enumerable.height / Map.height)))
                set maxJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y + range - Map.minY) * Enumerable.height / Map.height)))
                set enums = enums + 1
                set i = minI
                set j = minJ

                if enums <= 0 then
                    set enums = 1
                endif

                loop
                    exitwhen i > maxI
                        set j = minJ

                        loop
                            exitwhen j > maxJ
                                set k = 0
                                set grid = cell[i][j]

                                loop
                                    exitwhen k >= grid.size
                                        set object = grid[k]

                                        if object != 0 and object.visible and visited[object] != enums then
                                            set dx = object.x - x
                                            set dy = object.y - y
                                            set visited[object] = enums
                                            set distance = dx*dx + dy*dy

                                            if distance <= closest then
                                                set o = object
                                                set closest = distance
                                            endif
                                        endif
                                    set k = k + 1
                                endloop
                            set j = j + 1
                        endloop
                    set i = i + 1
                endloop
            endif

            return o
        endmethod

        static method closestUnit takes real x, real y, real range returns unit
            local unit u = null
            local real dx
            local real dy
            local integer i
            local integer j
            local integer k
            local integer minI
            local integer maxI 
            local integer minJ
            local integer maxJ
            local Cell grid
            local Object object
            local real distance
            local real closest = range * range
            
            if range > 0 then
                set minI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x - range - Map.minX) * Enumerable.width  / Map.width)))
                set maxI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x + range - Map.minX) * Enumerable.width  / Map.width)))
                set minJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y - range - Map.minY) * Enumerable.height / Map.height)))
                set maxJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y + range - Map.minY) * Enumerable.height / Map.height)))
                set enums = enums + 1
                set i = minI
                set j = minJ

                if enums <= 0 then
                    set enums = 1
                endif

                loop
                    exitwhen i > maxI
                        set j = minJ

                        loop
                            exitwhen j > maxJ
                                set k = 0
                                set grid = cell[i][j]

                                loop
                                    exitwhen k >= grid.size
                                        set object = grid[k]

                                        if object != 0 and object.isUnit and object.visible and visited[object] != enums then
                                            set dx = object.x - x
                                            set dy = object.y - y
                                            set visited[object] = enums
                                            set distance = dx*dx + dy*dy

                                            if distance <= closest then
                                                set u = object.unit
                                                set closest = distance
                                            endif
                                        endif
                                    set k = k + 1
                                endloop
                            set j = j + 1
                        endloop
                    set i = i + 1
                endloop
            endif

            return u
        endmethod

        static method closestItem takes real x, real y, real range returns item
            local item it = null
            local real dx
            local real dy
            local integer i
            local integer j
            local integer k
            local integer minI
            local integer maxI 
            local integer minJ
            local integer maxJ
            local Cell grid
            local Object object
            local real distance
            local real closest = range * range
            
            if range > 0 then
                set minI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x - range - Map.minX) * Enumerable.width  / Map.width)))
                set maxI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x + range - Map.minX) * Enumerable.width  / Map.width)))
                set minJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y - range - Map.minY) * Enumerable.height / Map.height)))
                set maxJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y + range - Map.minY) * Enumerable.height / Map.height)))
                set enums = enums + 1
                set i = minI
                set j = minJ

                if enums <= 0 then
                    set enums = 1
                endif

                loop
                    exitwhen i > maxI
                        set j = minJ

                        loop
                            exitwhen j > maxJ
                                set k = 0
                                set grid = cell[i][j]

                                loop
                                    exitwhen k >= grid.size
                                        set object = grid[k]

                                        if object != 0 and object.isItem and object.visible and visited[object] != enums then
                                            set dx = object.x - x
                                            set dy = object.y - y
                                            set visited[object] = enums
                                            set distance = dx*dx + dy*dy

                                            if distance <= closest then
                                                set it = object.item
                                                set closest = distance
                                            endif
                                        endif
                                    set k = k + 1
                                endloop
                            set j = j + 1
                        endloop
                    set i = i + 1
                endloop
            endif

            return it
        endmethod

        static method closestCustom takes real x, real y, real range returns Object
            local real dx
            local real dy
            local integer i
            local integer j
            local integer k
            local integer minI
            local integer maxI 
            local integer minJ
            local integer maxJ
            local Cell grid
            local Object o = 0
            local Object object
            local real distance
            local real closest = range * range
            
            if range > 0 then
                set minI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x - range - Map.minX) * Enumerable.width  / Map.width)))
                set maxI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x + range - Map.minX) * Enumerable.width  / Map.width)))
                set minJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y - range - Map.minY) * Enumerable.height / Map.height)))
                set maxJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y + range - Map.minY) * Enumerable.height / Map.height)))
                set enums = enums + 1
                set i = minI
                set j = minJ

                if enums <= 0 then
                    set enums = 1
                endif

                loop
                    exitwhen i > maxI
                        set j = minJ

                        loop
                            exitwhen j > maxJ
                                set k = 0
                                set grid = cell[i][j]

                                loop
                                    exitwhen k >= grid.size
                                        set object = grid[k]

                                        if object != 0 and object.isCustom and object.visible and visited[object] != enums then
                                            set dx = object.x - x
                                            set dy = object.y - y
                                            set visited[object] = enums
                                            set distance = dx*dx + dy*dy

                                            if distance <= closest then
                                                set o = object
                                                set closest = distance
                                            endif
                                        endif
                                    set k = k + 1
                                endloop
                            set j = j + 1
                        endloop
                    set i = i + 1
                endloop
            endif

            return o
        endmethod

        static method closestDestructable takes real x, real y, real range returns destructable
            local destructable d = null
            local real dx
            local real dy
            local integer i
            local integer j
            local integer k
            local integer minI
            local integer maxI 
            local integer minJ
            local integer maxJ
            local Cell grid
            local Object object
            local real distance
            local real closest = range * range
            
            if range > 0 then
                set minI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x - range - Map.minX) * Enumerable.width  / Map.width)))
                set maxI = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x + range - Map.minX) * Enumerable.width  / Map.width)))
                set minJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y - range - Map.minY) * Enumerable.height / Map.height)))
                set maxJ = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y + range - Map.minY) * Enumerable.height / Map.height)))
                set enums = enums + 1
                set i = minI
                set j = minJ

                if enums <= 0 then
                    set enums = 1
                endif

                loop
                    exitwhen i > maxI
                        set j = minJ

                        loop
                            exitwhen j > maxJ
                                set k = 0
                                set grid = cell[i][j]

                                loop
                                    exitwhen k >= grid.size
                                        set object = grid[k]

                                        if object != 0 and object.isDestructable and object.visible and visited[object] != enums then
                                            set dx = object.x - x
                                            set dy = object.y - y
                                            set visited[object] = enums
                                            set distance = dx*dx + dy*dy

                                            if distance <= closest then
                                                set d = object.destructable
                                                set closest = distance
                                            endif
                                        endif
                                    set k = k + 1
                                endloop
                            set j = j + 1
                        endloop
                    set i = i + 1
                endloop
            endif

            return d
        endmethod
    endmodule

    struct Map extends array
        readonly static rect rect
        readonly static real minX
        readonly static real minY
        readonly static real maxX
        readonly static real maxY
        readonly static real width
        readonly static real height
        readonly static region region
        readonly static rect playable

        private static method onInit takes nothing returns nothing
            set rect = GetWorldBounds()
            set region = CreateRegion()
            set playable = GetPlayableMapRect()
            set minX = GetRectMinX(rect)
            set minY = GetRectMinY(rect)
            set maxX = GetRectMaxX(rect)
            set maxY = GetRectMaxY(rect)
            set width = maxX - minX
            set height = maxY - minY

            call RegionAddRect(region, rect)
        endmethod
    endstruct

    struct Object extends array
        implement Alloc

        private static HashTable table
        private static integer visit = 0
        private static integer array visited
        
        private integer minI
        private integer minJ
        private integer maxI
        private integer maxJ
        private integer index
        private widget widget
        private Table indexes

        readonly unit unit
        readonly item item
        readonly real size
        readonly integer id
        readonly Table cells
        readonly boolean isUnit
        readonly boolean isItem
        readonly boolean isCustom
        readonly boolean isDestructable
        readonly destructable destructable

        real x
        real y
        real z
        integer data
        boolean visible
        boolean trackable
        onCollision onCollide

        method operator collision= takes real value returns nothing
            set size = value

            call update()
        endmethod

        method operator collision takes nothing returns real
            return size
        endmethod

        method destroy takes nothing returns nothing
            call clear()
            call table[id].flush()
            call indexes.destroy()
            call cells.destroy()
            call deallocate()

            set data = 0
            set unit = null
            set item = null
            set widget = null
            set destructable = null
        endmethod

        method insert takes Cell cell returns nothing
            if cell != 0 and not indexes.has(cell) then
                set cells[index] = cell
                set indexes[cell] = index
                set index = index + 1

                call cell.insert(this)
            endif
        endmethod

        method remove takes Cell cell returns nothing
            if cell != 0 and indexes.has(cell) then
                set index = index - 1
                set cells[indexes[cell]] = cells[index]
                set indexes[cells[index]] = indexes[cell]

                call indexes.remove(cell)
                call cells.remove(index)
                call cell.remove(this)
            endif
        endmethod

        method update takes nothing returns nothing
            local Cell cell
            local real dx
            local real dy
            local integer i
            local integer j
            local integer minX
            local integer maxX 
            local integer minY
            local integer maxY
            local thistype that

            set visit = visit + 1

            if visible then
                if not isCustom then
                    set x = GetWidgetX(widget)
                    set y = GetWidgetY(widget)

                    if isUnit then
                        set z = BlzGetUnitZ(unit)
                    endif
                endif

                set minX = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x - size - Map.minX) * Enumerable.width  / Map.width)))
                set maxX = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x + size - Map.minX) * Enumerable.width  / Map.width)))
                set minY = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y - size - Map.minY) * Enumerable.height / Map.height)))
                set maxY = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y + size - Map.minY) * Enumerable.height / Map.height)))
                set i = minX
                set j = minY

                if minI != minX or minJ != minY or maxI != maxX or maxJ != maxY then
                    loop
                        exitwhen i > maxX
                            set j = minY

                            loop
                                exitwhen j > maxY
                                    call insert(Enumerable.cell[i][j])
                                set j = j + 1
                            endloop
                        set i = i + 1
                    endloop

                    set i = 0

                    loop
                        exitwhen i >= index
                            set cell = cells[i]

                            if cell.i < minX or cell.i > maxX or cell.j < minY or cell.j > maxY then
                                set i = i - 1
                                call remove(cell)
                            endif
                        set i = i + 1
                    endloop

                    set minI = minX
                    set minJ = minY
                    set maxI = maxX
                    set maxJ = maxY
                endif

                if onCollide != 0 and size > 0 then
                    set i = 0

                    loop
                        exitwhen i >= index
                            set j = 0
                            set cell = cells[i]

                            loop
                                exitwhen j >= cell.size
                                    set that = cell[j]
                                            
                                    if that != this and that.visible then
                                        if visited[that] != visit then
                                            set dx = that.x - x
                                            set dy = that.y - y
                                            set visited[that] = visit

                                            if dx*dx + dy*dy <= (that.size + size)*(that.size + size) then
                                                call onCollide.evaluate(this, that)
                                            endif
                                        endif
                                    endif
                                set j = j + 1
                            endloop
                        set i = i + 1
                    endloop
                endif
            endif
        endmethod

        method clear takes nothing returns nothing
            local integer i = 0

            loop
                exitwhen i == index
                    call Cell(cells[i]).remove(this)
                set i = i + 1
            endloop

            call cells.flush()
            call indexes.flush()

            set index = 0
        endmethod

        static method operator [] takes agent a returns thistype
            local integer id = GetHandleId(a)

            if table[id].has(0) then
                return table[id][0]
            endif

            return create(a)
        endmethod

        static method registered takes agent a returns boolean
            return table[GetHandleId(a)].has(0)
        endmethod

        static method create takes agent a returns thistype
            local integer id = GetHandleId(a)
            local thistype this

            if not table[id].has(0) then
                set this = thistype.allocate()
                set x = 0
                set y = 0
                set z = 0
                set minI = 0
                set minJ = 0
                set maxI = 0
                set maxJ = 0
                set index = 0
                set this.id = id
                set onCollide = 0
                set visible = true
                set table[id][0] = this
                set table[id].agent[1] = a
                set unit = table[id].unit[1]
                set item = table[id].item[1]
                set widget = table[id].widget[1]
                set destructable = table[id].destructable[1]
                set isUnit = unit != null
                set isItem = item != null
                set isDestructable = destructable != null
                set cells = Table.create()
                set indexes = Table.create()
                set isCustom = not isUnit and not isItem and not isDestructable
                set trackable = isCustom or (isUnit and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and not IsUnitType(unit, UNIT_TYPE_DEAD))

                if not isCustom then
                    set x = GetWidgetX(widget)
                    set y = GetWidgetY(widget)
                endif

                if isUnit then
                    set z = BlzGetUnitZ(unit)
                    set size = BlzGetUnitCollisionSize(unit)
                elseif isItem then
                    set size = ITEM_SIZE
                elseif isDestructable then
                    set size = DESTRUCTABLE_SIZE
                else
                    set size = 0
                endif

                return this
            else
                return table[id][0]
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set table = HashTable.create()
        endmethod
    endstruct

    struct Cell
        readonly static integer loaded = 0
        readonly static thistype array load

        private Table objects
        private Table indexes
        private integer index
        private boolean indexed

        readonly real x
        readonly real y
        readonly integer i
        readonly integer j
        readonly real minX
        readonly real minY
        readonly real maxX
        readonly real maxY
        readonly integer size

        effect effect

        method operator [] takes integer index returns Object
            return Object(objects[index])
        endmethod

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call objects.destroy()
            call indexes.destroy()
            call deallocate()

            set effect = null
        endmethod

        method insert takes Object object returns nothing
            if object != 0 and not indexes.has(object) then
                set objects[size] = object
                set indexes[object] = size
                set size = size + 1

                if not indexed then
                    set indexed = true
                    set index = loaded
                    set load[index] = this
                    set loaded = loaded + 1
                endif
            endif
        endmethod

        method remove takes Object object returns nothing
            if object != 0 and indexes.has(object) then
                set size = size - 1
                set objects[indexes[object]] = objects[size]
                set indexes[objects[size]] = indexes[object]

                if size <= 0 then
                    set indexed = false
                    set loaded = loaded - 1
                    set load[index] = load[loaded]
                    set load[index].index = index

                    if effect != null then
                        call DestroyEffect(effect)
                        set effect = null
                    endif
                endif

                call indexes.remove(object)
                call objects.remove(size)
            endif
        endmethod

        method contains takes Object object returns boolean
            return indexes.has(object)
        endmethod

        static method create takes integer i, integer j returns thistype
            local thistype this = thistype.allocate()

            set this.i = i
            set this.j = j
            set this.size = 0
            set this.index = 0
            set this.indexed = false
            set this.objects = Table.create()
            set this.indexes = Table.create()
            set this.minX = Map.minX + (i * 1.0) / Enumerable.width * Map.width
            set this.minY = Map.minY + (j * 1.0) / Enumerable.height * Map.height
            set this.maxX = Map.minX + ((i + 1) * 1.0) / Enumerable.width * Map.width
            set this.maxY = Map.minY + ((j + 1) * 1.0) / Enumerable.height * Map.height
            set this.x = (minX + maxX) * 0.5
            set this.y = (minY + maxY) * 0.5

            return this
        endmethod
    endstruct

    struct Enumerable extends array
        private static trigger death = CreateTrigger()
        private static integer array index
        private static boolean array tracked
        private static Object array trackable
        private static integer count
        private static rect rect
        private static item item

        readonly static HashTable cell
        readonly static integer width
        readonly static integer height
        readonly static integer cellSize

        implement Hooks
        implement Enumerations

        static method track takes Object object returns nothing
            if object != 0 then
                call object.update()

                if object.trackable and not tracked[object] then
                    set trackable[count] = object
                    set index[object] = count
                    set count = count + 1
                    set tracked[object] = true
                endif
            endif
        endmethod

        static method untrack takes Object object returns nothing
            if object != 0 then
                call object.clear()

                if object.trackable and tracked[object] and count > 0 then
                    set count = count - 1
                    set tracked[object] = false
                    set trackable[index[object]] = trackable[count]
                    set index[trackable[count]] = index[object]
                endif
            endif
        endmethod

        static method remove takes Object object returns nothing
            if object != 0 then
                call untrack(object)
                call object.destroy()
            endif
        endmethod

        private static method onUnit takes nothing returns nothing
            call track(Object[GetFilterUnit()])
        endmethod

        private static method onItem takes nothing returns nothing
            if not Object.registered(GetEnumItem()) then
                call Object.create(GetEnumItem()).update()
                call TriggerRegisterDeathEvent(death, GetEnumItem())
            endif
        endmethod

        private static method onDestructable takes nothing returns nothing
            if not Object.registered(GetEnumDestructable()) then
                call Object.create(GetEnumDestructable()).update()
                call TriggerRegisterDeathEvent(death, GetEnumDestructable())
            endif
        endmethod

        private static method onDrop takes nothing returns nothing
            set item = GetManipulatedItem()
            call TimerStart(CreateTimer(), 0.00, false, function thistype.onNewItem)
        endmethod

        private static method onPickup takes nothing returns nothing
            call Object[GetManipulatedItem()].clear()
        endmethod

        private static method onSold takes nothing returns nothing
            if Object.registered(GetManipulatedItem()) then
                call remove(Object[GetManipulatedItem()])
            endif
        endmethod

        private static method onDeath takes nothing returns nothing
            if GetDyingUnit() != null then
                if not IsUnitType(GetDyingUnit(), UNIT_TYPE_HERO) then
                    call remove(Object[GetDyingUnit()])
                endif
            elseif GetDyingDestructable() != null then
                call remove(Object[GetDyingDestructable()])
            elseif GetTriggerWidget() != null then
                call remove(Object[GetTriggerWidget()])
            endif
        endmethod

        private static method onNewItem takes nothing returns nothing
            call DestroyTimer(GetExpiredTimer())

            if item != null then
                call Object[item].update()
                set item = null
            else
                call EnumItemsInRect(rect, null, function thistype.onItem)
            endif
        endmethod

        private static method onNewDestructable takes nothing returns nothing
            call DestroyTimer(GetExpiredTimer())
            call EnumDestructablesInRect(rect, null, function thistype.onDestructable)
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0

            loop
                exitwhen i >= count
                    call Object(trackable[i]).update()
                set i = i + 1
            endloop
        endmethod

        private static method onInit takes nothing returns nothing
            local integer i = 0
            local integer j = 0
            local integer minimum = R2I(SquareRoot((Map.width * Map.height) / 8190))

            set count = 0
            set cellSize = CELL_SIZE
            set cell = HashTable.create()
            set width = R2I(Map.width / CELL_SIZE)
            set height = R2I(Map.height / CELL_SIZE)
            set rect = Rect(0, 0, CELL_SIZE, CELL_SIZE)

            if (width * height) > 8190 then
                if ModuloInteger(minimum, 32) != 0 then
                    set minimum = minimum + (32 - ModuloInteger(minimum, 32))
                endif

                set width = R2I(Map.width / minimum)
                set height = R2I(Map.height / minimum)
                set cellSize = minimum
            endif

            loop
                exitwhen i >= width
                    set j = 0

                    loop
                        exitwhen j >= height
                            set cell[i][j] = Cell.create(i, j)
                        set j = j + 1
                    endloop
                set i = i + 1
            endloop

            call EnumItemsInRect(Map.playable, null, function thistype.onItem)
            call GroupEnumUnitsInRect(bj_lastCreatedGroup, Map.playable, Filter(function thistype.onUnit))
            call EnumDestructablesInRect(Map.playable, null, function thistype.onDestructable)
            call TriggerRegisterEnterRegion(CreateTrigger(), Map.region, Filter(function thistype.onUnit))
            call TimerStart(CreateTimer(), UPDATE_PERIOD, true, function thistype.onPeriod)
            call TriggerAddAction(death, function thistype.onDeath)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            // call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_LOADED, function thistype.onLoaded)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, function thistype.onDrop)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PAWN_ITEM, function thistype.onSold)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, function thistype.onPickup)
        endmethod
    endstruct

    hook CreateItem Enumerable.hookCreate
    hook CreateItemLoc Enumerable.hookCreateLocation
    hook CreateDestructable Enumerable.hookCreateDestructable
    hook CreateDestructableZ Enumerable.hookCreateDestructableZ
    hook BlzCreateDestructableWithSkin Enumerable.hookCreateDestructableSkin
    hook BlzCreateDestructableZWithSkin Enumerable.hookCreateDestructableZSkin
    hook DestructableRestoreLife Enumerable.hookRestore
    hook RemoveUnit Enumerable.hookRemove
    hook RemoveItem Enumerable.hookRemove
    hook RemoveDestructable Enumerable.hookRemove
    hook ShowUnit Enumerable.hookVisibility
    hook SetItemVisible Enumerable.hookVisibility
endlibrary