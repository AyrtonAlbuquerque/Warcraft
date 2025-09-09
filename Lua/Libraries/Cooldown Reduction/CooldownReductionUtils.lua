OnInit("CDRUtils", function(requires)
    requires "CDR"

    CDRUtils = setmetatable({}, {})
    local mt = getmetatable(CDRUtils)
    mt.__index = mt

    local key = 0
    local array = {}
    local PERIOD = 0.03125
    local timer = CreateTimer()

    function mt:remove(i)
        if self.type == 0 then
            UnitRemoveCooldownReduction(self.unit, self.value)
        elseif self.type == 1 then
            UnitAddCooldownReductionFlat(self.unit, -self.value)
        else
            UnitAddCooldownOffset(self.unit, -self.value)
        end

        array[i] = array[key]
        key      = key - 1
        self     = nil

        if key == 0 then
            PauseTimer(timer)
        end

        return i - 1
    end

    function mt:addTimed(unit, value, duration, type)
        local this = {}
        setmetatable(this, mt)

        this.unit  = unit
        this.value = value
        this.type  = type
        this.ticks = duration/PERIOD
        key        = key + 1
        array[key] = this

        if type == 0 then
            UnitAddCooldownReduction(unit, value)
        elseif type == 1 then
            UnitAddCooldownReductionFlat(unit, value)
        else
            UnitAddCooldownOffset(unit, value)
        end

        if key == 1 then
            TimerStart(timer, PERIOD, true, function()
                local i = 1
                local this

                while i <= key do
                    this = array[i]

                    if this.ticks <= 0 then
                        i = this:remove(i)
                    end
                    this.ticks = this.ticks - 1
                    i = i + 1
                end
            end)
        end
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function UnitAddCooldownReductionTimed(unit, value, duration)
        CDRUtils:addTimed(unit, value, duration, 0)
    end

    function UnitAddCooldownReductionFlatTimed(unit, value, duration)
        CDRUtils:addTimed(unit, value, duration, 1)
    end

    function UnitAddCooldownOffsetTimed(unit, value, duration)
        CDRUtils:addTimed(unit, value, duration, 2)
    end

    function GetUnitCooldownReductionEx(unit)
        return R2SW(CDR:get(unit, 0)*100, 1, 2)
    end

    function GetUnitCooldownReductionFlatEx(unit)
        return R2SW(CDR:get(unit, 1)*100, 1, 2)
    end

    function GetUnitCooldownOffsetEx(unit)
        return R2SW(CDR:get(unit, 2), 1, 2)
    end
end)