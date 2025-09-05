OnInit("Missiles", function(requires)
    requires "Class"
    requires "Dummy"
    requires "Effect"
    requires "Utilities"

    -- The update period of the system
    local PERIOD = 1. / 30.
    -- The max amount of Missiles processed in a PERIOD
    -- You can play around with both these values to find
    -- your sweet spot. If equal to 0, the system will
    -- process all missiles at once every period.
    local SWEET_SPOT = 500
    -- the avarage collision size compensation when detecting collisions
    local COLLISION_SIZE = 128.
    -- item size used in z collision
    local ITEM_SIZE  = 16.

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
            if Missile.count > -1 then
                if group.size > 0 then
                    group:clear()
                end

                for i = 0, Missile.count do
                    local missile = Missile.collection[i]

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
            if Missile.count > -1 then

                if group.size > 0 then
                    group:clear()
                end

                while i <= Missile.count and j > 0 do
                    local missile = Missile.collection[i]

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
            if Missile.count > -1 then
                if group.size > 0 then
                    group:clear()
                end

                for i = 0, Missile.count do
                    local missile = Missile.collection[i]

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
            if Missile.count > -1 then

                if group.size > 0 then
                    group:clear()
                end

                while i <= Missile.count and j > 0 do
                    local missile = Missile.collection[i]

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
            if Missile.count > -1 then
                local minx = GetRectMinX(rect)
                local miny = GetRectMinY(rect)
                local maxx = GetRectMaxX(rect)
                local maxy = GetRectMaxY(rect)

                if group.size > 0 then
                    group:clear()
                end

                for i = 0, Missile.count do
                    local missile = Missile.collection[i]

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
            if Missile.count > -1 then
                local minx = GetRectMinX(rect)
                local miny = GetRectMinY(rect)
                local maxx = GetRectMaxX(rect)
                local maxy = GetRectMaxY(rect)

                if group.size > 0 then
                    group:clear()
                end

                while i <= Missile.count and j > 0 do
                    local missile = Missile.collection[i]

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
            if Missile.count > -1 then
                local x = GetLocationX(location)
                local y = GetLocationY(location)
                local range = radius * radius

                if group.size > 0 then
                    group:clear()
                end

                for i = 0, Missile.count do
                    local missile = Missile.collection[i]
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
            if Missile.count > -1 then
                local x = GetLocationX(location)
                local y = GetLocationY(location)
                local range = radius * radius

                if group.size > 0 then
                    group:clear()
                end

                while i <= Missile.count and j > 0 do
                    local missile = Missile.collection[i]
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
            if Missile.count > -1 then
                local range = radius * radius

                if group.size > 0 then
                    group:clear()
                end

                for i = 0, Missile.count do
                    local missile = Missile.collection[i]
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
            if Missile.count > -1 then
                local range = radius * radius

                if group.size > 0 then
                    group:clear()
                end

                while i <= Missile.count and j > 0 do
                    local missile = Missile.collection[i]
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

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    Missile = Class()

    Missile.count = -1
    Missile.period = PERIOD
    Missile.collection = {}

    local px = 0
    local py = 0
    local id = -1
    local pid = -1
    local last = 0
    local index = 1
    local dilation = 1
    local keys = {}
    local array = {}
    local frozen = {}
    local missiles = {}
    local timer = CreateTimer()
    local group = CreateGroup()
    local rect = Rect(0, 0, 0, 0)

    Missile:property("arc", {
        get = function(self) return Atan(4 * self.height / self.origin.distance) end,
        set = function(self, value) self.height = Tan(value) * self.origin.distance / 4 end
    })

    Missile:property("curve", {
        get = function(self) return Atan(self.bend / self.origin.distance) end,
        set = function(self, value) self.bend = Tan(value) * self.origin.distance end
    })

    Missile:property("model", {
        get = function(self) return self.effect.model end,
        set = function(self, value) self.effect.model = value end
    })

    Missile:property("scale", {
        get = function(self) return self.effect.scale end,
        set = function(self, value) self.effect.scale = value end
    })

    Missile:property("alpha", {
        get = function(self) return self.effect.alpha end,
        set = function(self, value) self.effect.alpha = value end
    })

    Missile:property("vision", {
        get = function(self) return self.sight end,
        set = function(self, value)
            self.sight = value

            if self.dummy then
                SetUnitOwner(self.dummy, self.owner, false)
                BlzSetUnitRealField(self.dummy, UNIT_RF_SIGHT_RADIUS, value)
            else
                if not self.owner then
                    if self.source then
                        self.dummy = Dummy.retrieve(GetOwningPlayer(self.source), self.x, self.y, self.z, 0)
                        BlzSetUnitRealField(self.dummy, UNIT_RF_SIGHT_RADIUS, value)
                    end
                else
                    self.dummy = Dummy.retrieve(self.owner, self.x, self.y, self.z, 0)
                    BlzSetUnitRealField(self.dummy, UNIT_RF_SIGHT_RADIUS, value)
                end
            end
        end
    })

    Missile:property("duration", {
        get = function(self) return self.time end,
        set = function(self, value)
            self.time = value
            self.speed = RMaxBJ(0.00000001, (self.origin.distance - self.traveled) / RMaxBJ(0.00000001, value))
        end
    })

    Missile:property("animation", {
        get = function(self) return self.effect.animation end,
        set = function(self, value) self.effect.animation = value end
    })

    Missile:property("timeScale", {
        get = function(self) return self.effect.timeScale end,
        set = function(self, value) self.effect.timeScale = value end
    })

    Missile:property("playercolor", {
        get = function(self) return self.effect.playercolor end,
        set = function(self, value) self.effect.playercolor = value end
    })

    function Missile:bounce()
        self.traveled = 0
        self.finished = false

        self.origin:move(self.x, self.y, self.z - GetLocZ(self.x, self.y))
    end

    function Missile:deflect(tx, ty, tz)
        self.toZ = tz
        self.target = nil
        self.traveled = 0
        self.finished = false

        self.impact:move(tx, ty, tz)
        self.origin:move(self.x, self.y, self.z - GetLocZ(self.x, self.y))

    end

    function Missile:deflectTarget(unit)
        self:deflect(GetUnitX(unit), GetUnitY(unit), self.toZ)
        self.target = unit
    end

    function Missile:flushAll()
        array[self] = nil
        array[self] = {}
    end

    function Missile:flush(agent)
        if agent then
            array[self][agent] = nil
        end
    end

    function Missile:hitted(agent)
        return array[self][agent]
    end

    function Missile:attach(model, dx, dy, dz, scale)
        return self.effect:attach(model, dx, dy, dz, scale)
    end

    function Missile:detach(attachment)
        if attachment then
            self.effect:detach(attachment)
            attachment:destroy()
        end
    end

    function Missile:pause(flag)
        local this

        self.paused = flag

        if not self.paused and self.pkey ~= -1 then
            id = id + 1
            missiles[id] = self
            this = frozen[pid]
            this.pkey = self.pkey
            frozen[self.pkey] = frozen[pid]
            pid = pid - 1
            self.pkey = -1

            if id + 1 > SWEET_SPOT and SWEET_SPOT > 0 then
                dilation = (id + 1)/SWEET_SPOT
            else
                dilation = 1.
            end

            if id == 0 then
                TimerStart(timer, PERIOD, true, Missile.__move)
            end

            if self.onResume then
                if self.allocated and self:onResume() then
                    self:terminate()
                else
                    if self.finished then
                        self:terminate()
                    end
                end
            else
                if self.finished then
                    self:terminate()
                end
            end
        end
    end

    function Missile:color(red, green, blue)
        self.effect:color(red, green, blue)
    end

    function Missile:terminate()
        local this

        if self.allocated and self.launched then
            self.allocated = false

            if self.pkey ~= -1 then
                this = frozen[pid]
                this.pkey = self.pkey
                frozen[self.pkey] = frozen[pid]
                pid = pid - 1
                self.pkey = -1
            end

            if self.onRemove then
                self:onRemove()
            end

            if self.dummy then
                Dummy.recycle(self.dummy)
            end

            this = Missile.collection[Missile.count]
            this.index = self.index
            Missile.collection[self.index] = Missile.collection[Missile.count]
            Missile.count = Missile.count - 1
            self.index = -1

            self.origin:destroy()
            self.impact:destroy()
            self.effect:destroy()

            array[self] = nil
        end
    end

    function Missile:launch()
        if not self.launched and self.allocated then
            self.launched = true
            id = id + 1
            missiles[id] = self
            Missile.count = Missile.count + 1
            self.index = Missile.count
            Missile.collection[Missile.count] = self

            if id + 1 > SWEET_SPOT and SWEET_SPOT > 0 then
                dilation = (id + 1) / SWEET_SPOT
            else
                dilation = 1.
            end

            if id == 0 then
                TimerStart(timer, PERIOD, true, Missile.__move)
            end
        end
    end

    function Missile:__reset()
        self.yaw = 0
        self.roll = 0
        self.turn = 0
        self.time = 0
        self.data = 0
        self.type = 0
        self.bend = 0
        self.pitch = 0
        self.sight = 0
        self.speed = 0
        self.pkey = -1
        self.unit = nil
        self.index = -1
        self.height = 0
        self.damage = 0
        self.owner = nil
        self.dummy = nil
        self.tileset = 0
        self.source = nil
        self.target = nil
        self.traveled = 0
        self.collision = 0
        self.paused = false
        self.autoroll = false
        self.launched = false
        self.collideZ = false
        self.finished = false
        self.acceleration = 0
    end

    function Missile:__remove(i)
        if self.paused then
            pid = pid + 1
            self.pkey = pid
            frozen[pid] = self

            if self.onPause then
                if self.allocated and self:onPause() then
                    self:terminate()
                end
            end
        else
            self:terminate()
        end

        missiles[i] = missiles[id]
        id = id - 1

        if id + 1 > SWEET_SPOT and SWEET_SPOT > 0 then
            dilation = (id + 1) / SWEET_SPOT
        else
            dilation = 1
        end

        if id == -1 then
            PauseTimer(timer)
        end

        if not self.allocated then
            table.insert(keys, self.key)
            self = nil
        end

        return i - 1
    end

    function Missile.__onMove(self)
        local dx
        local dy
        local ds
        local angle

        if self.target and GetUnitTypeId(self.target) ~= 0 and UnitAlive(self.target) then
            self.impact:move(GetUnitX(self.target), GetUnitY(self.target), GetUnitFlyHeight(self.target) + self.toZ)

            dx = self.impact.x - self.x
            dy = self.impact.y - self.y
            angle = Atan2(dy, dx)
            self.traveled = self.origin.distance - math.sqrt(dx*dx + dy*dy)
        else
            angle = self.origin.angle
            self.target = nil
        end

        ds = self.speed * PERIOD * dilation
        self.speed = self.speed + self.acceleration
        self.traveled = self.traveled + ds

        if not self.onMove then
            if self.turn ~= 0 and not (math.cos(self.curvature - angle) >= math.cos(self.turn)) then
                if math.sin(angle - self.curvature) >= 0 then
                    self.curvature = self.curvature + self.turn
                else
                    self.curvature = self.curvature - self.turn
                end
            else
                self.curvature = angle
            end

            self.yaw = self.curvature
            self.pitch = self.origin.alpha
            self.x = self.x + ds * math.cos(self.yaw)
            self.y = self.y + ds * math.sin(self.yaw)
            px = self.x
            py = self.y

            if self.height ~= 0 or self.origin.slope ~= 0 then
                self.z = 4 * self.height * self.traveled * (self.origin.distance - self.traveled)/(self.origin.square) + self.origin.slope * self.traveled + self.origin.z
                self.pitch = self.pitch - Atan(((4 * self.height) * (2 * self.traveled - self.origin.distance))/(self.origin.square))
            end

            if self.bend ~= 0 then
                dx = 4 * self.bend * self.traveled * (self.origin.distance - self.traveled)/(self.origin.square)
                angle = self.yaw + bj_PI/2
                self.x = self.x + dx * math.cos(angle)
                self.y = self.y + dx * math.sin(angle)
                self.yaw = self.yaw + Atan(-((4 * self.bend) * (2 * self.traveled - self.origin.distance))/(self.origin.square))
            end
        else
            self:onMove()
        end
    end

    function Missile.__onUnit(self)
        if self.onUnit then
            if self.allocated and self.collision > 0 then
                GroupEnumUnitsInRange(group, self.x, self.y, self.collision + COLLISION_SIZE, nil)

                local unit = FirstOfGroup(group)

                while unit do
                    if array[self][unit] == nil then
                        if IsUnitInRangeXY(unit, self.x, self.y, self.collision) then
                            if self.collideZ then
                                local dx = GetLocZ(GetUnitX(unit), GetUnitY(unit)) + GetUnitFlyHeight(unit)
                                local dy = BlzGetUnitCollisionSize(unit)

                                if dx + dy >= self.z - self.collision and dx <= self.z + self.collision then
                                    array[self][unit] = true

                                    if self.allocated and self:onUnit(unit) then
                                        self:terminate()
                                        break
                                    end
                                end
                            else
                                array[self][unit] = true
                                if self.allocated and self:onUnit(unit) then
                                    self:terminate()
                                    break
                                end
                            end
                        end
                    end

                    GroupRemoveUnit(group, unit)
                    unit = FirstOfGroup(group)
                end
            end
        end
    end

    function Missile.__onItem(self)
        if self.onItem then
            if self.allocated and self.collision > 0 then
                local dx = self.collision

                SetRect(rect, self.x - dx, self.y - dx, self.x + dx, self.y + dx)
                EnumItemsInRect(rect, nil, function()
                    local item = GetEnumItem()

                    if array[self][item] == nil then
                        if self.collideZ then
                            local dz = GetLocZ(GetItemX(item), GetItemY(item))

                            if dz + ITEM_SIZE >= self.z - self.collision and dz <= self.z + self.collision then
                                array[self][item] = true

                                if self.allocated and self:onItem(item) then
                                    self:terminate()
                                    return
                                end
                            end
                        else
                            array[self][item] = true

                            if self.allocated and self:onItem(item) then
                                self:terminate()
                                return
                            end
                        end
                    end
                end)
            end
        end
    end

    function Missile.__onMissile(self)
        if self.onMissile then
            if self.allocated and self.collision > 0 then
                for i = 0, Missile.count do
                    local missile = Missile.collection[i]

                    if missile ~= self then
                        if array[self][missile] == nil then
                            local dx = missile.x - self.x
                            local dy = missile.y - self.y

                            if dx*dx + dy*dy <= self.collision*self.collision then
                                array[self][missile] = true

                                if self.allocated and self:onMissile(missile) then
                                    self:terminate()

                                    if missile.allocated and missile.collision > 0 and missile.onMissile then
                                        if array[missile][self] == nil then
                                            if dx*dx + dy*dy <= missile.collision * missile.collision then
                                                array[missile][self] = true

                                                if missile.allocated and missile:onMissile(self) then
                                                    missile:terminate()
                                                end
                                            end
                                        end
                                    end

                                    break
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    function Missile.__onDestructable(self)
        if self.onDestructable then
            if self.allocated and self.collision > 0 then
                local dx = self.collision

                SetRect(rect, self.x - dx, self.y - dx, self.x + dx, self.y + dx)
                EnumDestructablesInRect(rect, nil, function()
                    local destructable = GetEnumDestructable()

                    if array[self][destructable] == nil then
                        if self.collideZ then
                            local dz = GetLocZ(GetWidgetX(destructable), GetWidgetY(destructable))
                            local tz = GetDestructableOccluderHeight(destructable)

                            if dz + tz >= self.z - self.collision and dz <= self.z + self.collision then
                                array[self][destructable] = true

                                if self.allocated and self:onDestructable(destructable) then
                                    self:terminate()
                                    return
                                end
                            end
                        else
                            array[self][destructable] = true

                            if self.allocated and self:onDestructable(destructable) then
                                self:terminate()
                                return
                            end
                        end
                    end
                end)
            end
        end
    end

    function Missile.__onCliff(self)
        if self.onCliff then
            local k = GetTerrainCliffLevel(self.x, self.y)

            if self.cliff < k and self.z  < (k - GetTerrainCliffLevel(WorldBounds.maxX, WorldBounds.maxY))*bj_CLIFFHEIGHT then
                if self.allocated and self:onCliff() then
                    self:terminate()
                end
            end

            self.cliff = k
        end
    end

    function Missile.__onTerrain(self)
        if self.onTerrain then
            if GetLocZ(self.x, self.y) > self.z then
                if self.allocated and self:onTerrain() then
                    self:terminate()
                end
            end
        end
    end

    function Missile.__onTileset(self)
        if self.onTileset then
            local type = GetTerrainType(self.x, self.y)

            if type ~= self.tileset then
                if self.allocated and self:onTileset(type) then
                    self:terminate()
                end
            end

            self.tileset = type
        end
    end

    function Missile.__onPeriod(self)
        if self.onPeriod then
            if self.allocated and self:onPeriod() then
                self:terminate()
            end
        end
    end

    function Missile.__onFinish(self)
        if self.traveled >= self.origin.distance - 0.0001 then
            self.finished = true

            if self.onFinish then
                if self.allocated and self:onFinish() then
                    self:terminate()
                else
                    if self.traveled > 0 and not self.paused then
                        self:terminate()
                    end
                end
            else
                self:terminate()
            end
        else
            if not self.autoroll then
                self.effect:orient(self.yaw, -self.pitch, self.roll)
            else
                self.effect:orient(self.yaw, -self.pitch, Atan2(self.bend, self.height))
            end
        end
    end

    function Missile.__onBoundaries(self)
        if not self.effect:move(self.x, self.y, self.z) then
            if self.onBoundaries then
                if self.allocated and self:onBoundaries() then
                    self:terminate()
                end
            end
        else
            if self.dummy then
                SetUnitX(self.dummy, self.x)
                SetUnitY(self.dummy, self.y)
            end

            if self.unit then
                SetUnitX(self.unit, self.x)
                SetUnitY(self.unit, self.y)
                SetUnitZ(self.unit, self.z)
                BlzSetUnitFacingEx(self.unit, self.yaw * bj_RADTODEG)
            end
        end
    end

    function Missile.__move()
        local i = 0
        local j = 0

        if SWEET_SPOT > 0 then
            i = last
        end

        while not ((j >= SWEET_SPOT and SWEET_SPOT > 0) or j > id) do
            local this = missiles[i]

            if this.allocated and not this.paused then
                Missile.__onMove(this)
                Missile.__onUnit(this)
                Missile.__onItem(this)
                Missile.__onMissile(this)
                Missile.__onDestructable(this)
                Missile.__onCliff(this)
                Missile.__onTerrain(this)
                Missile.__onTileset(this)
                Missile.__onPeriod(this)
                Missile.__onFinish(this)
                Missile.__onBoundaries(this)

                if not this.onMove then
                    this.x = px
                    this.y = py
                end
            else
                i = this:__remove(i)
                j = j - 1
            end
            i = i + 1
            j = j + 1

            if i > id and SWEET_SPOT > 0 then
                i = 0
            end
        end

        last = i
    end

    function Missile.create(x, y, z, toX, toY, toZ)
        local this = Missile.allocate()

        array[this] = {}

        if #keys > 0 then
            this.key = keys[#keys]
            keys[#keys] = nil
        else
            this.key = index
            index = index + 1
        end

        this:__reset()

        this.allocated = true
        this.origin = Coordinates.create(x, y, z)
        this.impact = Coordinates.create(toX, toY, toZ)
        this.effect = Effect.create("", x, y, this.origin.z, 1)
        this.origin.link = this.impact
        this.curvature = this.origin.angle
        this.x = x
        this.y = y
        this.z = this.impact.z
        this.toZ = toZ
        this.cliff = GetTerrainCliffLevel(x, y)

        return this
    end

    do
        Coordinates = Class()

        Coordinates:property("link", {
            set = function(self, value)
                self.linked = value
                value.linked = self

                self:math(self, value)
            end
        })

        function Coordinates:destroy()
            self.linked = nil
        end

        function Coordinates:move(toX, toY, toZ)
            self.x = toX
            self.y = toY
            self.z = toZ + GetLocZ(toX, toY)

            if self.linked ~= self then
                self:math(self, self.linked)
            end
        end

        function Coordinates:math(a, b)
            local dx
            local dy

            while true do
                dx = b.x - a.x
                dy = b.y - a.y
                dx = dx * dx + dy * dy
                dy = math.sqrt(dx)
                if dx ~= 0. and dy ~= 0. then
                    break
                end
                b.x = b.x + .01
                b.z = b.z - GetLocZ(b.x - .01, b.y) + GetLocZ(b.x, b.y)
            end

            a.square = dx
            a.distance = dy
            a.angle = Atan2(b.y - a.y, b.x - a.x)
            a.slope = (b.z - a.z) / dy
            a.alpha = Atan(a.slope)

            if b.linked == a then
                b.angle = a.angle + bj_PI
                b.distance = dy
                b.slope = -a.slope
                b.alpha = -a.alpha
                b.square = dx
            end
        end

        function Coordinates.create(x, y, z)
            local this = Coordinates.allocate()

            this.linked = this

            this:move(x, y, z)

            return this
        end
    end

    do
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
end)