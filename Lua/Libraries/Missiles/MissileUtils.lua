--[[ requires Missiles
    /* -------------------- Missile Utils v2.6 by Chopinski -------------------- */
    // This is a simple Utils library for the Relativistic Missiles system.
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    MissileGroup = setmetatable({}, {})
    local mt = getmetatable(MissileGroup)
    mt.__index = mt
    
    function mt:destroy()
        self.group = nil
        self.set = nil
        self = nil
    end
    
    function mt:missileAt(i)
        if #self.group > 0 and i <= #self.group - 1 then
            return self.group[i + 1]
        else
            return 0
        end
    end
    
    function mt:remove(missile)
        for i = 1, #self.group do
            if self.group[i] == missile then
                self.set[missile] = nil
                table.remove(self.group, i)
                break
            end
        end
    end
    
    function mt:insert(missile)
        table.insert(self.group, missile)
        self.set[missile] = missile
    end
    
    function mt:clear()
        local size = #self.group
        
        for i = 1, size do
            self.set[i] = nil
            self.group[i] = nil
        end
    end
    
    function mt:contains(missile)
        return self.set[missile] ~= nil
    end
    
    function mt:addGroup(this)
        for i = 1, #this.group do
            if not self:contains(this.group[i]) then
                self:insert(this.group[i])
            end
        end
    end
    
    function mt:removeGroup(this)
        for i = 1, #this.group do
            if self:contains(this.group[i]) then
                self:remove(this.group[i])
            end
        end
    end
    
    function mt:create()
        local this = {}
        setmetatable(this, mt)
        
        this.group = {}
        this.set = {}
        
        return this
    end
    
    -- -------------------------------------------------------------------------- --
    --                                   LUA API                                  --
    -- -------------------------------------------------------------------------- --
    function CreateMissileGroup()
        return MissileGroup:create()
    end
    
    function DestroyMissileGroup(group)
        if group then
            group:destroy()
        end
    end
    
    function MissileGroupGetSize(group)
        if group then
            return #group.group
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
            if #group.group > 0 then
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
            if #group.group > 0 then
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
            if #group.group > 0 then
                return group:missileAt(GetRandomInt(0, #group.group - 1))
            else
                return nil
            end
        else
            return nil
        end
    end
    
    function FirstOfMissileGroup(group)
        if group then
            if #group.group > 0 then
                return group.group[1]
            else
                return nil
            end
        else
            return nil
        end
    end
    
    function GroupAddMissileGroup(source, destiny)
        if source and destiny then
            if #source.group > 0 and source ~= destiny then
                destiny:addGroup(source)
            end
        end
    end
    
    function GroupRemoveMissileGroup(source, destiny)
        if source and destiny then
            if source == destiny then
                source:clear()
            elseif #source.group > 0 then
                destiny:removeGroup(source)
            end
        end
    end
    
    function GroupEnumMissilesOfType(group, type)
        if group then
            if Missiles.count > -1 then
                if #group.group > 0 then
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
                
                if #group.group > 0 then
                    group:clear()
                end
                
                while i <= Missiles.count and j > 0 do
                    local missile = Missiles.collection[i]
                    if missile.type == type then
                        group:insert(missile)
                    end
                    
                    j = j - 1
                    i = i + 1
                end
            end
        end
    end
    
    function GroupEnumMissilesOfPlayer(group, player)
        if group then
            if Missiles.count > -1 then
                if #group.group > 0 then
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
                
                if #group.group > 0 then
                    group:clear()
                end
                
                while i <= Missiles.count and j > 0 do
                    local missile = Missiles.collection[i]
                    if missile.owner == player then
                        group:insert(missile)
                    end
                    
                    j = j - 1
                    i = i + 1
                end
            end
        end
    end
    
    function GroupEnumMissilesInRect(group, rect)
        if group and rect then
            if Missiles.count > -1 then
                if #group.group > 0 then
                    group:clear()
                end
                
                for i = 0, Missiles.count do
                    local missile = Missiles.collection[i]
                    if GetRectMinX(rect) <= missile.x and missile.x <= GetRectMaxX(rect) and GetRectMinY(rect) <= missile.y and missile.y <= GetRectMaxY(rect) then
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
                
                if #group.group > 0 then
                    group:clear()
                end
                
                while i <= Missiles.count and j > 0 do
                    local missile = Missiles.collection[i]
                    if GetRectMinX(rect) <= missile.x and missile.x <= GetRectMaxX(rect) and GetRectMinY(rect) <= missile.y and missile.y <= GetRectMaxY(rect) then
                        group:insert(missile)
                    end
                    
                    j = j - 1
                    i = i + 1
                end
            end
        end
    end
    
    function GroupEnumMissilesInRangeOfLoc(group, location, radius)
        if group and location and radius > 0 then
            if Missiles.count > -1 then
                if #group.group > 0 then
                    group:clear()
                end
                
                for i = 0, Missiles.count do
                    local missile = Missiles.collection[i]
                    local dx = missile.x - GetLocationX(location)
                    local dy = missile.y - GetLocationY(location)
                    
                    if SquareRoot(dx*dx + dy*dy) <= radius then
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
                
                if #group.group > 0 then
                    group:clear()
                end
                
                while i <= Missiles.count and j > 0 do
                    local missile = Missiles.collection[i]
                    local dx = missile.x - GetLocationX(location)
                    local dy = missile.y - GetLocationY(location)
                    
                    if SquareRoot(dx*dx + dy*dy) <= radius then
                        group:insert(missile)
                    end
                    
                    j = j - 1
                    i = i + 1
                end
            end
        end
    end
    
    function GroupEnumMissilesInRange(group, x, y, radius)
        if group and radius > 0 then
            if Missiles.count > -1 then
                if #group.group > 0 then
                    group:clear()
                end
                
                for i = 0, Missiles.count do
                    local missile = Missiles.collection[i]
                    local dx = missile.x - x
                    local dy = missile.y - y
                    
                    if SquareRoot(dx*dx + dy*dy) <= radius then
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
                
                if #group.group > 0 then
                    group:clear()
                end
                
                while i <= Missiles.count and j > 0 do
                    local missile = Missiles.collection[i]
                    local dx = missile.x - x
                    local dy = missile.y - x
                    
                    if SquareRoot(dx*dx + dy*dy) <= radius then
                        group:insert(missile)
                    end
                    
                    j = j - 1
                    i = i + 1
                end
            end
        end
    end
end