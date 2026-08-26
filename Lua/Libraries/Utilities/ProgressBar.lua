OnInit("ProgressBar", function (requires)
    requires "Class"
    requires "Dummy"
    requires "Utilities"

    -- Position update period
    local PERIOD = 0.03
    -- ProgressBar unit
    local PROGRESSBAR = S2A('pbar')

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function CreateProgressBar(unit, x, y, z, scale, percent)
        return ProgressBar.create(unit, x, y, z, scale, percent)
    end

    function GetProgressBarX(bar)
        return bar.x
    end

    function GetProgressBarY(bar)
        return bar.y
    end

    function GetProgressBarZ(bar)
        return bar.z
    end

    function SetProgressBarX(bar, newX)
        bar.x = newX
        return bar
    end

    function SetProgressBarY(bar, newY)
        bar.y = newY
        return bar
    end

    function SetProgressBarZ(bar, newZ)
        bar.z = newZ
        return bar
    end

    function GetProgressBarPercentage(bar)
        return bar.percentage
    end

    function SetProgressBarPercentage(bar, newValue, duration)
        bar:setPercentage(newValue, duration)
        return bar
    end

    function SetProgressBarColor(bar, red, green, blue, alpha)
        bar:setColor(red, green, blue, alpha)
        return bar
    end

    function SetProgressBarPlayerColor(bar, color)
        bar.playercolor = color
        return bar
    end

    function SetProgressBarScale(bar, newScale)
        bar.scale = newScale
        return bar
    end

    function ShowProgressBar(bar, flag)
        bar.show = flag
        return bar
    end

    function DestroyProgressBar(bar)
        bar:destroy()
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                         System API                                        --
    -- ----------------------------------------------------------------------------------------- --
    ProgressBar = Class()

    local array = {}
    local location = CreateTimer()

    ProgressBar:property("x", {
        get = function(self)
            if self.unit then
                return self.dx
            else
                return GetUnitX(self.effect)
            end
         end,
        set = function(self, value)
            if self.unit then
                self.dx = value
            else
                SetUnitX(self.effect, value)
            end
        end
    })

    ProgressBar:property("y", {
        get = function(self)
            if self.unit then
                return self.dy
            else
                return GetUnitY(self.effect)
            end
         end,
        set = function(self, value)
            if self.unit then
                self.dy = value
            else
                SetUnitY(self.effect, value)
            end
        end
    })

    ProgressBar:property("z", {
        get = function(self)
            if self.unit then
                return self.dz
            else
                return GetUnitZ(self.effect)
            end
         end,
        set = function(self, value)
            if self.unit then
                self.dz = value
            else
                SetUnitZ(self.effect, value)
            end
        end
    })

    ProgressBar:property("percentage", {
        get = function(self) return self.value end,
        set = function(self, value)
            self:setPercentage(value, 0)
        end
    })

    ProgressBar:property("playercolor", {
        set = function(self, color)
            SetUnitColor(self.effect, GetPlayerColor(Player(color)))
        end
    })

    ProgressBar:property("show", {
        set = function(self, flag)
            self.visible = flag

            ShowUnit(self.effect, flag)
        end
    })

    ProgressBar:property("scale", {
        set = function(self, value)
            SetUnitScale(self.effect, value, value, value)
        end
    })

    function ProgressBar:destroy()
        PauseTimer(self.timer)
        DestroyTimer(self.timer)
        BlzSetUnitSkin(self.effect, Dummy.type)
        DummyRecycle(self.effect)

        self.unit = nil
        self.timer = nil
        self.effect = nil
        self.active = nil
    end

    function ProgressBar:setColor(red, green, blue, alpha)
        SetUnitVertexColor(self.effect, red, green, blue, alpha)

        return self
    end

    function ProgressBar:setPercentage(percent, duration)
        self.target = R2I(percent)
        self.speed = ((self.target - self.value) * 0.1) / RMaxBJ(duration, 0.1)

        if self.value ==self.target then
            return self
        end

        TimerStart(self.timer, 0.1, true, function ()
            self.value = self.value + self.speed

            if (self.speed > 0 and self.value >= self.target) or (self.speed < 0 and self.value <= self.target) then
                self.value = self.target

                PauseTimer(self.timer)
            end

            SetUnitAnimationByIndex(self.effect, R2I(self.value + 0.5))
        end)

        return self
    end

    function ProgressBar.create(unit, x, y, z, scale, percent)
        local self = ProgressBar.allocate()

        self.dx = x
        self.dy = y
        self.dz = z
        self.unit = unit
        self.value = R2I(percent)
        self.visible = true
        self.timer = CreateTimer()
        self.effect = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), x, y, z, 0)

        BlzSetUnitSkin(self.effect, PROGRESSBAR)
        SetUnitScale(self.effect, scale, scale, scale)
        SetUnitAnimationByIndex(self.effect, R2I(self.value))

        if self.unit then
            self.active = true

            table.insert(array, self)

            if #array == 1 then
                TimerStart(location, PERIOD, true, function ()
                    local this

                    for i = #array, 1, -1 do
                        this = array[i]

                        if this.active then
                            SetUnitX(this.effect, GetUnitX(this.unit) + this.dx)
                            SetUnitY(this.effect, GetUnitY(this.unit) + this.dy)
                            SetUnitZ(this.effect, GetUnitZ(this.unit) + this.dz)
                        else
                            table.remove(array, i)

                            if #array == 0 then
                                PauseTimer(location)
                            end
                        end
                    end
                end)
            end
        end

        return self
    end
end)