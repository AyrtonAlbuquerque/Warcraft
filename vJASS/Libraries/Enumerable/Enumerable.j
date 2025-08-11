



library Enumerable requires Table, Alloc, RegisterPlayerUnitEvent
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

    struct Map
        readonly static rect rect
        readonly static real minX
        readonly static real minY
        readonly static real maxX
        readonly static real maxY
        readonly static real width
        readonly static real height
        readonly static region region

        private static method onInit takes nothing returns nothing
            set rect = GetWorldBounds()
            set region = CreateRegion()
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

        private Table cells
        private Table indexes
        private integer index
        private integer minI
        private integer minJ
        private integer maxI
        private integer maxJ
        private boolean isVisible
        private boolean isTrackable

        readonly integer id
        readonly real size

        method operator x takes nothing returns real
            return GetWidgetX(table[id].widget[1])
        endmethod

        method operator y takes nothing returns real
            return GetWidgetY(table[id].widget[1])
        endmethod

        method operator unit takes nothing returns unit
            return table[id].unit[1]
        endmethod

        method operator item takes nothing returns item
            return table[id].item[1]
        endmethod

        method operator destructable takes nothing returns destructable
            return table[id].destructable[1]
        endmethod

        method operator trackable= takes boolean flag returns nothing
            set isTrackable = flag
        endmethod

        method operator trackable takes nothing returns boolean
            return isTrackable
        endmethod

        method operator visible= takes boolean flag returns nothing
            set isVisible = flag
        endmethod

        method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method operator collision= takes real value returns nothing
            set size = value

            call update()
        endmethod

        method operator collision takes nothing returns real
            return size
        endmethod

        method operator isUnit takes nothing returns boolean
            return unit != null
        endmethod

        method operator isItem takes nothing returns boolean
            return item != null
        endmethod

        method operator isCustom takes nothing returns boolean
            return not isUnit and not isItem and not isDestructable
        endmethod

        method operator isDestructable takes nothing returns boolean
            return destructable != null
        endmethod

        method destroy takes nothing returns nothing
            call clear()
            call table[id].flush()
            call indexes.destroy()
            call cells.destroy()
            call deallocate()
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
            local integer i
            local integer j
            local integer minX
            local integer maxX 
            local integer minY
            local integer maxY

            if visible then
                set minX = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x - size - Map.minX) * Enumerable.width  / Map.width)))
                set maxX = IMaxBJ(0, IMinBJ(Enumerable.width - 1, R2I((x + size - Map.minX) * Enumerable.width  / Map.width)))
                set minY = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y - size - Map.minY) * Enumerable.height / Map.height)))
                set maxY = IMaxBJ(0, IMinBJ(Enumerable.height - 1, R2I((y + size - Map.minY) * Enumerable.height / Map.height)))
                set i = minX
                set j = minY

                if minI == minX and minJ == minY and maxI == maxX and maxJ == maxY then
                    return
                endif

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
                set minI = 0
                set minJ = 0
                set maxI = 0
                set maxJ = 0
                set index = 0
                set this.id = id
                set visible = true
                set table[id][0] = this
                set table[id].agent[1] = a
                set cells = Table.create()
                set indexes = Table.create()
                set trackable = isCustom or (isUnit and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and not IsUnitType(unit, UNIT_TYPE_DEAD))

                if isUnit then
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
        private Table objects
        private Table indexes
        private Table lightning
        private boolean highlighted = false

        readonly integer i
        readonly integer j
        readonly real minX
        readonly real minY
        readonly real maxX
        readonly real maxY
        readonly integer size

        method operator highlight= takes boolean flag returns nothing
            if flag and not highlighted then
                set highlighted = true

                if not lightning.has(0) then
                    set lightning.lightning[0] = AddLightning("DRAM", false, maxX, minY, maxX, maxY)
                    set lightning.lightning[1] = AddLightning("DRAM", false, maxX, maxY, minX, maxY)
                    set lightning.lightning[2] = AddLightning("DRAM", false, minX, maxY, minX, minY)
                    set lightning.lightning[3] = AddLightning("DRAM", false, minX, minY, maxX, minY)
                endif
            elseif not flag and highlighted then
                set highlighted = false

                call DestroyLightning(lightning.lightning[0])
                call DestroyLightning(lightning.lightning[1])
                call DestroyLightning(lightning.lightning[2])
                call DestroyLightning(lightning.lightning[3])
                call lightning.flush()
            endif
        endmethod

        method operator [] takes integer index returns Object
            return Object(objects[index])
        endmethod

        method destroy takes nothing returns nothing
            call objects.destroy()
            call indexes.destroy()
            call deallocate()
        endmethod

        method insert takes Object object returns nothing
            if object != 0 and not indexes.has(object) then
                set objects[size] = object
                set indexes[object] = size
                set size = size + 1
                set highlight = size > 0
            endif
        endmethod

        method remove takes Object object returns nothing
            if object != 0 and indexes.has(object) then
                set size = size - 1
                set objects[indexes[object]] = objects[size]
                set indexes[objects[size]] = indexes[object]

                call indexes.remove(object)
                call objects.remove(size)

                if size == 0 then
                    set highlight = false
                endif
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
            set this.objects = Table.create()
            set this.indexes = Table.create()
            set this.lightning = Table.create()
            set this.minX = Map.minX + (i * 1.0) / Enumerable.width * Map.width
            set this.minY = Map.minY + (j * 1.0) / Enumerable.height * Map.height
            set this.maxX = Map.minX + ((i + 1) * 1.0) / Enumerable.width * Map.width
            set this.maxY = Map.minY + ((j + 1) * 1.0) / Enumerable.height * Map.height

            return this
        endmethod
    endstruct

    struct Enumerable extends array
        private static integer array index
        private static boolean array tracked
        private static Object array trackable
        private static integer count
        private static rect rect

        readonly static HashTable cell
        readonly static integer width
        readonly static integer height

        static method hookX takes agent a, real x returns nothing
            call Object[a].update()
        endmethod

        static method hookY takes agent a, real x returns nothing
            call Object[a].update()
        endmethod

        static method hookRemove takes agent a returns nothing
            if Object.registered(a) then
                call remove(Object[a])
            endif
        endmethod

        static method hookPosition takes agent a, real x, real y returns nothing
            call Object[a].update()
        endmethod

        static method hookLocation takes agent a, location l returns nothing
            call Object[a].update()
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
            endif
        endmethod

        private static method onDestructable takes nothing returns nothing
            if not Object.registered(GetEnumDestructable()) then
                call Object.create(GetEnumDestructable()).update()
            endif
        endmethod

        private static method onDrop takes nothing returns nothing
            call Object[GetManipulatedItem()].update()
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
            endif
        endmethod

        private static method onNewItem takes nothing returns nothing
            call DestroyTimer(GetExpiredTimer())
            call EnumItemsInRect(rect, null, function thistype.onItem)
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
            local trigger tree = CreateTrigger()
            local integer minimum = R2I(SquareRoot((Map.width * Map.height) / 8190))

            set count = 0
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

            call EnumItemsInRect(GetPlayableMapRect(), null, function thistype.onItem)
            call GroupEnumUnitsInRect(bj_lastCreatedGroup, GetPlayableMapRect(), Filter(function thistype.onUnit))
            call EnumDestructablesInRect(GetPlayableMapRect(), null, function thistype.onDestructable)
            call TriggerRegisterEnterRegion(CreateTrigger(), Map.region, Filter(function thistype.onUnit))
            call TimerStart(CreateTimer(), UPDATE_PERIOD, true, function thistype.onPeriod)
            call TriggerRegisterDestDeathInRegionEvent(tree, GetPlayableMapRect())
            call TriggerAddAction(tree, function thistype.onDeath)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            // call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_LOADED, function thistype.onLoaded)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, function thistype.onDrop)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PAWN_ITEM, function thistype.onSold)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, function thistype.onPickup)
        endmethod
    endstruct

    hook SetUnitX Enumerable.hookX
    hook SetUnitY Enumerable.hookY
    hook SetUnitPosition Enumerable.hookPosition
    hook SetItemPosition Enumerable.hookPosition
    hook SetUnitPositionLoc Enumerable.hookLocation
    hook SetItemPositionLoc Enumerable.hookLocation
    hook CreateItem Enumerable.hookCreate
    hook CreateItemLoc Enumerable.hookCreateLocation
    hook CreateDestructable Enumerable.hookCreateDestructable
    hook CreateDestructableZ Enumerable.hookCreateDestructableZ
    hook BlzCreateDestructableWithSkin Enumerable.hookCreateDestructableSkin
    hook BlzCreateDestructableZWithSkin Enumerable.hookCreateDestructableZSkin
    hook RemoveUnit Enumerable.hookRemove
    hook RemoveItem Enumerable.hookRemove
    hook RemoveDestructable Enumerable.hookRemove
    hook ShowUnit Enumerable.hookVisibility
    hook SetItemVisible Enumerable.hookVisibility
endlibrary