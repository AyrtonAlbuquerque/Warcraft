--[[ LineSegmentEnumeration v2.2a

    API:

        function LineSegment.EnumUnits(number: ax, number: ay, number: bx, number: by, number: offset, boolean: checkCollision)
        function LineSegment.EnumDestructables(number: ax, number: ay, number: bx, number: by, number: offset)
        function LineSegment.EnumItems(number: ax, number: ay, number: bx, number: by, number: offset)
            - returns the enumerated widgets as a table

]]--
LineSegment = {}
do
    local RECT = Rect(0, 0, 0, 0)
    local GROUP = CreateGroup()

    local ox
    local oy
    local dx
    local dy
    local da
    local db
    local ui
    local uj
    local wdx
    local wdy
    local uui
    local uuj

    local function prepare_rect(ax, ay, bx, by, offset)
        local x_max
        local x_min
        local y_max
        local y_min

        -- get center coordinates of rectangle
        ox, oy = 0.5*(ax + bx), 0.5*(ay + by)

        -- get rectangle major axis as vector
        dx, dy = 0.5*(bx - ax), 0.5*(by - ay)

        -- get half of rectangle length (da) and height (db)
        da, db = math.sqrt(dx*dx + dy*dy), offset

        -- get unit vector of the major axis
        ui, uj = dx/da, dy/da

        -- prepare bounding rect
        if ax > bx then
            x_min, x_max = bx - offset, ax + offset
        else
            x_min, x_max = ax - offset, bx + offset
        end

        if ay > by then
            y_min, y_max = by - offset, ay + offset
        else
            y_min, y_max = ay - offset, by + offset
        end

        SetRect(RECT, x_min, y_min, x_max, y_max)
    end

    local function rect_contains_widget(w, offset)
        wdx, wdy = GetWidgetX(w) - ox, GetWidgetY(w) - oy
        dx, dy = wdx*ui + wdy*uj, wdx*(-uj) + wdy*ui
        da, db = da + offset, db + offset

        return dx*dx <= da*da and dy*dy <= db*db
    end

    local function widget_filter(w, offset)
        if rect_contains_widget(w, offset) then
            table.insert(LineSegment.enumed, w)
        end
    end

    function LineSegment.EnumUnits(ax, ay, bx, by, offset, checkCollision)
        prepare_rect(ax, ay, bx, by, offset)
        GroupEnumUnitsInRect(GROUP, RECT)

        local enumed = {}
        LineSegment.enumed = enumed

        for i = 0, BlzGroupGetSize(GROUP) - 1 do
            local u = BlzGroupUnitAt(GROUP, i)
            widget_filter(u, checkCollision and BlzGetUnitCollisionSize(u) or 0.)
        end

        return enumed
    end

    function LineSegment.EnumDestructables(ax, ay, bx, by, offset)
        prepare_rect(ax, ay, bx, by, offset)

        local enumed = {}
        LineSegment.enumed = enumed

        EnumDestructablesInRect(RECT, Filter(function ()
            widget_filter(GetFilterDestructable(), 0.)
        end))

        return enumed
    end

    function LineSegment.EnumItems(ax, ay, bx, by, offset)
        prepare_rect(ax, ay, bx, by, offset)

        local enumed = {}
        LineSegment.enumed = enumed

        EnumItemsInRect(RECT, Filter(function ()
            widget_filter(GetFilterItem(), 0.)
        end))

        return enumed
    end

end