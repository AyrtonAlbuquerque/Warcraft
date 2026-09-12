OnInit("ProgressBar", function (requires)
    requires "Class"
    requires "Utilities"
    requires "WorldBounds"

    -- Position update period
    local PERIOD = 0.03
    -- Texttag default size
    local TEXTTAG_SIZE = 0.014
    -- ProgressBar unit
    local PROGRESSBAR = S2A('pbar')

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function CreateProgressBar(unit, x, y, z, scale, percent, showText)
        return ProgressBar.create(unit, x, y, z, scale, percent, showText)
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

    function GetProgressBarText(bar)
        return bar.text
    end

    function SetProgressBarText(bar, newText)
        bar.text = newText
        return bar
    end

    function GetProgressBarTextSize(bar)
        return bar.textsize
    end

    function SetProgressBarTextSize(bar, newSize)
        bar.textsize = newSize
        return bar
    end

    function SetProgressBarTextColor(bar, red, green, blue, alpha)
        bar:setTextColor(red, green, blue, alpha)
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
    local group = CreateGroup()
    local location = CreateTimer()
    local position = Location(0, 0)

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

    ProgressBar:property("text", {
        get = function(self) return self.string or "" end,
        set = function(self, value)
            self.string = value

            if self.texttag then
                SetTextTagText(self.texttag, self.string or "", self.size or TEXTTAG_SIZE)
            end
        end
    })

    ProgressBar:property("percentage", {
        get = function(self) return self.value end,
        set = function(self, value)
            self:setPercentage(value, 0)
        end
    })

    ProgressBar:property("textsize", {
        get = function(self) return self.size or TEXTTAG_SIZE end,
        set = function(self, value)
            self.size = value

            if self.texttag then
                SetTextTagText(self.texttag, self.string or "", self.size or TEXTTAG_SIZE)
            end
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

            if self.texttag then
                SetTextTagVisibility(self.texttag, flag)
            end
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
        ProgressBar.recycle(self.effect)

        if self.texttag then
            DestroyTextTag(self.texttag)
        end

        self.unit = nil
        self.timer = nil
        self.effect = nil
        self.active = nil
        self.texttag = nil
    end

    function ProgressBar:setColor(red, green, blue, alpha)
        SetUnitVertexColor(self.effect, red, green, blue, alpha)

        return self
    end

    function ProgressBar:setTextColor(red, green, blue, alpha)
        SetTextTagColor(self.texttag, red, green, blue, alpha)

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

    function ProgressBar.recycle(dummy)
        if GetUnitTypeId(dummy) == PROGRESSBAR then
            GroupAddUnit(group, dummy)
            SetUnitX(dummy, WorldBounds.maxX)
            SetUnitY(dummy, WorldBounds.maxY)
            SetUnitScale(dummy, 1, 1, 1)
            SetUnitTimeScale(dummy, 1)
            SetUnitVertexColor(dummy, 255, 255, 255, 255)
            PauseUnit(dummy, true)
        end
    end

    function ProgressBar.retrieve(x, y, z)
        local dummy

        if BlzGroupGetSize(group) > 0 then
            dummy = FirstOfGroup(group)

            PauseUnit(dummy, false)
            GroupRemoveUnit(group, dummy)
            SetUnitX(dummy, x)
            SetUnitY(dummy, y)
            MoveLocation(position, x, y)
            SetUnitFlyHeight(dummy, z - GetLocationZ(position), 0)
        else
            dummy = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), PROGRESSBAR, x, y, 0)

            MoveLocation(position, x, y)
            SetUnitFlyHeight(dummy, z - GetLocationZ(position), 0)
            UnitRemoveAbility(dummy, S2A('Amrf'))
        end

        return dummy
    end

    function ProgressBar.create(unit, x, y, z, scale, percent, showText)
        local self = ProgressBar.allocate()

        self.dx = x
        self.dy = y
        self.dz = z
        self.unit = unit
        self.string = "0"
        self.visible = true
        self.size = TEXTTAG_SIZE
        self.value = R2I(percent)
        self.timer = CreateTimer()
        self.effect = ProgressBar.retrieve(x, y, z)

        BlzSetUnitSkin(self.effect, PROGRESSBAR)
        SetUnitScale(self.effect, scale, scale, scale)
        SetUnitAnimationByIndex(self.effect, R2I(self.value))

        if showText then
            self.texttag = CreateTextTag()
            
            SetTextTagText(self.texttag, self.string, self.size)
            SetTextTagPos(self.texttag, x, y, z)
            SetTextTagColor(self.texttag, 255, 255, 255, 255)
            SetTextTagPermanent(self.texttag, true)
        end

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

                            if this.texttag then
                                SetTextTagText(this.texttag, this.string, this.size)
                                SetTextTagPos(this.texttag, GetUnitX(this.effect) - 20, GetUnitY(this.effect) - 30, GetUnitFlyHeight(this.effect))
                            end
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

    function ProgressBar.onInit()
        for i = 0, 20 do
            local unit = CreateUnit(Player(PLAYER_NEUTRAL_PASSIVE), PROGRESSBAR, WorldBounds.maxX, WorldBounds.maxY, 0)

            PauseUnit(unit, false)
            GroupAddUnit(group, unit)
            UnitRemoveAbility(unit, S2A('Amrf'))
        end
    end
end)