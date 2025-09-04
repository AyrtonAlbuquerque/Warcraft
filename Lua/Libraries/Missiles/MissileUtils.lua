--[[ requires Missiles
    -- ------------------------------------- Missile Utils v2.8 ------------------------------------- --
    -- This is a simple Utils library for the Relativistic Missiles system.
    -- ---------------------------------------- By Chopinski ---------------------------------------- --
]]--

do
    -- ---------------------------------------------------------------------------------------------- --
    --                                             LUA API                                            --
    -- ---------------------------------------------------------------------------------------------- --
    function CreateMissileGroup()
        return MissileGroup.create()
    end

    function DestroyMissileGroup(group)
        if group then
            group:destroy()
        end
    end

    function MissileGroupGetSize(group)
        if group then
            return group.size
        else
            return 0
        end
    end

    function GroupMissileAt(group, position)
        if group then
            return group:missileAt(position)
        else
            return nil
        end
    end

    function ClearMissileGroup(group)
        if group then
            group:clear()
        end
    end

    function IsMissileInGroup(missile, group)
        if group and missile then
            if group.size > 0 then
                return group:contains(missile)
            else
                return false
            end
        else
            return false
        end
    end

    function GroupRemoveMissile(group, missile)
        if group and missile then
            if group.size > 0 then
                group:remove(missile)
            end
        end
    end

    function GroupAddMissile(group, missile)
        if group and missile then
            if not group:contains(missile) then
                group:insert(missile)
            end
        end
    end

    function GroupPickRandomMissile(group)
        if group then
            if group.size > 0 then
                return group:missileAt(GetRandomInt(1, group.size))
            else
                return nil
            end
        else
            return nil
        end
    end

    function FirstOfMissileGroup(group)
        if group then
            if group.size > 0 then
                return group:at(1)
            else
                return nil
            end
        else
            return nil
        end
    end

    function GroupAddMissileGroup(source, target)
        if source and target then
            if source.size > 0 and source ~= target then
                target:addGroup(source)
            end
        end
    end

    function GroupRemoveMissileGroup(source, target)
        if source and target then
            if source == target then
                source:clear()
            elseif source.size > 0 then
                target:removeGroup(source)
            end
        end
    end

    function GroupEnumMissilesOfType(group, type)
        if group then
            if Missiles.count > -1 then
                if group.size > 0 then
                    group:clear()
                end

                for i = 0, Missiles.count do
                    local missile = Missiles.collection[i]

                    if missile.type == type then
                        group:insert(missile)
                    end
                end
            end
        end
    end

    function GroupEnumMissilesOfTypeCounted(group, type, amount)
        local i = 0
        local j = amount

        if group then
            if Missiles.count > -1 then

                if group.size > 0 then
                    group:clear()
                end

                while i <= Missiles.count and j > 0 do
                    local missile = Missiles.collection[i]

                    if missile.type == type then
                        j = j - 1
                        group:insert(missile)
                    end

                    i = i + 1
                end
            end
        end
    end

    function GroupEnumMissilesOfPlayer(group, player)
        if group then
            if Missiles.count > -1 then
                if group.size > 0 then
                    group:clear()
                end

                for i = 0, Missiles.count do
                    local missile = Missiles.collection[i]

                    if missile.owner == player then
                        group:insert(missile)
                    end
                end
            end
        end
    end

    function GroupEnumMissilesOfPlayerCounted(group, player, amount)
        local i = 0
        local j = amount

        if group then
            if Missiles.count > -1 then

                if group.size > 0 then
                    group:clear()
                end

                while i <= Missiles.count and j > 0 do
                    local missile = Missiles.collection[i]

                    if missile.owner == player then
                        j = j - 1
                        group:insert(missile)
                    end

                    i = i + 1
                end
            end
        end
    end

    function GroupEnumMissilesInRect(group, rect)
        if group and rect then
            if Missiles.count > -1 then
                local minx = GetRectMinX(rect)
                local miny = GetRectMinY(rect)
                local maxx = GetRectMaxX(rect)
                local maxy = GetRectMaxY(rect)

                if group.size > 0 then
                    group:clear()
                end

                for i = 0, Missiles.count do
                    local missile = Missiles.collection[i]

                    if minx <= missile.x and missile.x <= maxx and miny <= missile.y and missile.y <= maxy then
                        group:insert(missile)
                    end
                end
            end
        end
    end

    function GroupEnumMissilesInRectCounted(group, rect, amount)
        local i = 0
        local j = amount

        if group and rect then
            if Missiles.count > -1 then
                local minx = GetRectMinX(rect)
                local miny = GetRectMinY(rect)
                local maxx = GetRectMaxX(rect)
                local maxy = GetRectMaxY(rect)

                if group.size > 0 then
                    group:clear()
                end

                while i <= Missiles.count and j > 0 do
                    local missile = Missiles.collection[i]

                    if minx <= missile.x and missile.x <= maxx and miny <= missile.y and missile.y <= maxy then
                        j = j - 1
                        group:insert(missile)
                    end

                    i = i + 1
                end
            end
        end
    end

    function GroupEnumMissilesInRangeOfLoc(group, location, radius)
        if group and location and radius > 0 then
            if Missiles.count > -1 then
                local x = GetLocationX(location)
                local y = GetLocationY(location)
                local range = radius * radius

                if group.size > 0 then
                    group:clear()
                end

                for i = 0, Missiles.count do
                    local missile = Missiles.collection[i]
                    local dx = missile.x - x
                    local dy = missile.y - y

                    if dx*dx + dy*dy <= range then
                        group:insert(missile)
                    end
                end
            end
        end
    end

    function GroupEnumMissilesInRangeOfLocCounted(group, location, radius, amount)
        local i = 0
        local j = amount

        if group and location and radius > 0 then
            if Missiles.count > -1 then
                local x = GetLocationX(location)
                local y = GetLocationY(location)
                local range = radius * radius

                if group.size > 0 then
                    group:clear()
                end

                while i <= Missiles.count and j > 0 do
                    local missile = Missiles.collection[i]
                    local dx = missile.x - x
                    local dy = missile.y - y

                    if dx*dx + dy*dy <= range then
                        j = j - 1
                        group:insert(missile)
                    end

                    i = i + 1
                end
            end
        end
    end

    function GroupEnumMissilesInRange(group, x, y, radius)
        if group and radius > 0 then
            if Missiles.count > -1 then
                local range = radius * radius

                if group.size > 0 then
                    group:clear()
                end

                for i = 0, Missiles.count do
                    local missile = Missiles.collection[i]
                    local dx = missile.x - x
                    local dy = missile.y - y

                    if dx*dx + dy*dy <= range then
                        group:insert(missile)
                    end
                end
            end
        end
    end

    function GroupEnumMissilesInRangeCounted(group, x, y, radius, amount)
        local i = 0
        local j = amount

        if group and radius > 0 then
            if Missiles.count > -1 then
                local range = radius * radius

                if group.size > 0 then
                    group:clear()
                end

                while i <= Missiles.count and j > 0 do
                    local missile = Missiles.collection[i]
                    local dx = missile.x - x
                    local dy = missile.y - y

                    if dx*dx + dy*dy <= range then
                        j = j - 1
                        group:insert(missile)
                    end

                    i = i + 1
                end
            end
        end
    end

    -- ---------------------------------------------------------------------------------------------- --
    --                                             System                                             --
    -- ---------------------------------------------------------------------------------------------- --
    MissileGroup = Class()

    MissileGroup:property("size", { get = function(self) return self.group.size end })

    function MissileGroup:destroy()
        self.group:destroy()
    end

    function MissileGroup:missileAt(i)
        if self.size > 0 and i <= self.size and i > 0 then
            return self.group:at(i)
        else
            return 0
        end
    end

    function MissileGroup:remove(missile)
        self.group:remove(missile)
    end

    function MissileGroup:insert(missile)
        self.group:insert(missile)
    end

    function MissileGroup:clear()
        self.group:clear()
    end

    function MissileGroup:contains(missile)
        return self.group:has(missile)
    end

    function MissileGroup:addGroup(source)
        for _, missile in pairs(source.group) do
            if not self:contains(missile) then
                self:insert(missile)
            end
        end
    end

    function MissileGroup:removeGroup(source)
        for _, missile in pairs(source.group) do
            if self:contains(missile) then
                self:remove(missile)
            end
        end
    end

    function MissileGroup.create()
        local this = MissileGroup.allocate()

        this.group = List.create()

        return this
    end
end