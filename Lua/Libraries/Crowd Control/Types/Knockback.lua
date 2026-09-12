OnInit("Knockback", function(requires)
    requires "Class"
    requires "WorldBounds"
    requires "CrowdControl"

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function KnockbackUnit(source, target, angle, distance, duration, model, point, stack)
        CrowdControl.apply(CROWD_CONTROL_KNOCKBACK, source, target, distance, angle, duration, model, point, stack)
    end

    function IsUnitKnockedBack(target)
        return CrowdControl.applied(target, CROWD_CONTROL_KNOCKBACK)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    local Knockback = Class(CrowdControl)

    local timer = {}

    local key = 0
    local period = 0.03125
    local array = {}
    local struct = {}
    local rect = Rect(0, 0, 0, 0)
    local periodic = CreateTimer()

    function Knockback:start(source, target, value, angle, duration, model, point, stack)
        if duration > 0 and UnitAlive(target) then
            local this

            if not timer[target] then
                timer[target] = CreateTimer()
            end

            if stack then
                duration = duration + self:getRemaining(target)
            end

            if struct[target] then
                this = struct[target]
            else
                this = {
                    unit = target,
                    collision = 2*BlzGetUnitCollisionSize(target),
                    group = CreateGroup(),
                    remove = Knockback.remove
                }

                key = key + 1
                array[key] = this
                struct[target] = this

                BlzPauseUnitEx(target, true)

                if model and point then
                    this.effect = AddSpecialEffectTarget(model, target, point)
                end

                if key == 1 then
                    TimerStart(periodic, period, true, function()
                        local i = 1
                        local this

                        while i <= key do
                            this = array[i]

                            if this.duration > 0 and UnitAlive(this.unit) then
                                local x = GetUnitX(this.unit) + this.offset*Cos(this.angle)
                                local y = GetUnitY(this.unit) + this.offset*Sin(this.angle)

                                this.duration = this.duration - period

                                if this.duration > 0 and this.collision > 0 then
                                    SetRect(rect, x - this.collision, y - this.collision, x + this.collision, y + this.collision)
                                    EnumDestructablesInRect(rect, nil, function()
                                        if GetDestructableLife(GetEnumDestructable()) > 0 then
                                            this.duration = 0
                                            return
                                        end
                                    end)
                                end

                                if this.duration > 0 then
                                    if GetTerrainCliffLevel(GetUnitX(this.unit), GetUnitY(this.unit)) < GetTerrainCliffLevel(x, y) and GetUnitZ(this.unit) < (GetTerrainCliffLevel(x, y) - GetTerrainCliffLevel(WorldBounds.maxX, WorldBounds.maxY))*bj_CLIFFHEIGHT then
                                        this.duration = 0
                                    end
                                end

                                if this.duration > 0 then
                                    SetUnitX(this.unit, x)
                                    SetUnitY(this.unit, y)
                                end
                            else
                                i = this:remove(i)
                            end

                            i = i + 1
                        end
                    end)
                end
            end

            this.angle = angle
            this.distance = value
            this.duration = duration
            this.offset = RMaxBJ(0.00000001, value*period/RMaxBJ(0.00000001, duration))

            TimerStart(timer[target], duration, false, nil)

            return true
        end

        return false
    end

    function Knockback:finish(unit)
        if timer[unit] then
            DestroyTimer(timer[unit])
            timer[unit] = nil
        end

        return false
    end

    function Knockback:isApplied(unit)
        return struct[unit] ~= nil
    end

    function Knockback:getRemaining(unit)
        if timer[unit] then
            return TimerGetRemaining(timer[unit])
        end

        return 0
    end

    function Knockback:remove(i)
        DestroyGroup(self.group)
        DestroyEffect(self.effect)
        BlzPauseUnitEx(self.unit, false)

        struct[self.unit] = nil
        array[i] = array[key]
        key = key - 1
        self = nil

        if key == 0 then
            PauseTimer(periodic)
        end

        return i - 1
    end

    CROWD_CONTROL_KNOCKBACK = RegisterCrowdControl(Knockback.allocate())
end)