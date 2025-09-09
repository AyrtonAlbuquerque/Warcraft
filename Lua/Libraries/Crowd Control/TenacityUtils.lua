OnInit("TenacityUtils", function(requires)
    requires "Tenacity"

    -- ---------------------------------------------------------------------------------------------- --
    --                                             LUA API                                            --
    -- ---------------------------------------------------------------------------------------------- --
    function UnitAddTenacityTimed(unit, value, duration)
        TenacityUtils:addTimed(unit, value, duration, 0)
    end

    function UnitAddTenacityFlatTimed(unit, value, duration)
        TenacityUtils:addTimed(unit, value, duration, 1)
    end

    function UnitAddTenacityOffsetTimed(unit, value, duration)
        TenacityUtils:addTimed(unit, value, duration, 2)
    end

    -- ---------------------------------------------------------------------------------------------- --
    --                                             System                                             --
    -- ---------------------------------------------------------------------------------------------- --
    TenacityUtils = setmetatable({}, {})
    local mt = getmetatable(TenacityUtils)
    mt.__index = mt

    local key = 0
    local array = {}
    local period = 0.03125
    local timer = CreateTimer()

    function mt:remove(i)
        if self.type == 0 then
            Tenacity:remove(self.unit, self.value)
        else
            Tenacity:add(self.unit, -self.value, self.type)
        end

        array[i] = array[key]
        key = key - 1
        self = nil

        if key == 0 then
            PauseTimer(timer)
        end

        return i - 1
    end

    function mt:addTimed(unit, value, duration, type)
        local this = {}
        setmetatable(this, mt)

        this.unit = unit
        this.value = value
        this.type = type
        this.duration = duration
        key = key + 1
        array[key] = this

        Tenacity:add(unit, value, type)

        if key == 1 then
            TimerStart(timer, period, true, function()
                local i = 1
                local this

                while i <= key do
                    this = array[i]

                    if this.duration <= 0 then
                        i = this:remove(i)
                    end

                    this.duration = this.duration - period
                    i = i + 1
                end
            end)
        end
    end
end)