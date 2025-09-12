OnInit("Components", function(requires)
    requires "Class"

    local TOOLTIP_SIZE              = 0.2
    local DOUBLE_CLICK_DELAY        = 0.25
    local HIGHLIGHT                 = "UI\\Widgets\\Glues\\GlueScreen-Button-KeyboardHighlight"
    local CHECKED_BUTTON            = "UI\\Widgets\\EscMenu\\Human\\checkbox-check.blp"
    local UNAVAILABLE_BUTTON        = "ui\\widgets\\battlenet\\chaticons\\bnet-squelch"
    local CLICK_SOUND               = "Sound\\Interface\\MouseClick1.wav"
    local CLICK_SOUND_DURATION      = 239
    local DOUBLE                    = CreateTimer()
    local CONSOLE                   = BlzGetFrameByName("ConsoleUIBackdrop", 0)
    local WORLD                     = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)

    -- --------------------------------------- Operators --------------------------------------- --
    local Operators = Class()

    local sound = CreateSound(CLICK_SOUND, false, false, false, 10, 10, "")

    Operators:property("x", {
        get = function(self) return self._x or 0 end,
        set = function(self, value)
            self._x = value

            if self.parent == CONSOLE or self.parent == WORLD then
                BlzFrameSetAbsPoint(self.frame, self._point, self._x, self._y)
            else
                BlzFrameSetPoint(self.frame, self._point, self.parent, self._relative, self._x, self._y)
            end
        end
    })

    Operators:property("y", {
        get = function(self) return self._y or 0 end,
        set = function(self, value)
            self._y = value

            if self.parent == CONSOLE or self.parent == WORLD then
                BlzFrameSetAbsPoint(self.frame, self._point, self._x, self._y)
            else
                BlzFrameSetPoint(self.frame, self._point, self.parent, self._relative, self._x, self._y)
            end
        end
    })

    Operators:property("point", {
        get = function(self) return self._point or FRAMEPOINT_TOPLEFT end,
        set = function(self, value)
            self._point = value

            BlzFrameClearAllPoints(self.frame)

            if self.parent == CONSOLE or self.parent == WORLD then
                BlzFrameSetAbsPoint(self.frame, self._point, self._x, self._y)
            else
                BlzFrameSetPoint(self.frame, self._point, self.parent, self._relative, self._x, self._y)
            end
        end
    })

    Operators:property("relative", {
        get = function(self) return self._relative or FRAMEPOINT_TOPLEFT end,
        set = function(self, value)
            self._relative = value

            BlzFrameClearAllPoints(self.frame)

            if self.parent == CONSOLE or self.parent == WORLD then
                BlzFrameSetAbsPoint(self.frame, self._point, self._x, self._y)
            else
                BlzFrameSetPoint(self.frame, self._point, self.parent, self._relative, self._x, self._y)
            end
        end
    })

    Operators:property("alpha", {
        get = function(self) return self._alpha or 0 end,
        set = function(self, value)
            self._alpha = value

            BlzFrameSetAlpha(self.frame, value)
        end
    })

    Operators:property("scale", {
        get = function(self) return self._scale or 0 end,
        set = function(self, value)
            self._scale = value

            BlzFrameSetScale(self.frame, value)
        end
    })

    Operators:property("width", {
        get = function(self) return self._width or 0 end,
        set = function(self, value)
            self._width = value

            BlzFrameSetSize(self.frame, value, self._height)
        end
    })

    Operators:property("height", {
        get = function(self) return self._height or 0 end,
        set = function(self, value)
            self._height = value

            BlzFrameSetSize(self.frame, self._width, value)
        end
    })

    Operators:property("enabled", {
        get = function(self) return self._enabled or true end,
        set = function(self, value)
            self._enabled = value

            BlzFrameSetEnable(self.frame, value)
        end
    })

    Operators:property("visible", {
        get = function(self) return self._visible or true end,
        set = function(self, value)
            self._visible = value

            BlzFrameSetVisible(self.frame, value)
        end
    })

    Operators:property("frame", {
        get = function(self) return self._frame end,
        set = function(self, value) self._frame = value end
    })

    Operators:property("set", { set = function(self, value) BlzFrameSetAllPoints(self.frame, value) end })

    function Operators:setPoint(point, relative, x, y)
        self._x = x
        self._y = y
        self._point = point
        self._relative = relative

        BlzFrameClearAllPoints(self.frame)

        if self.parent == CONSOLE or self.parent == WORLD then
            BlzFrameSetAbsPoint(self.frame, point, x, y)
        else
            BlzFrameSetPoint(self.frame, point, self.parent, relative, x, y)
        end
    end

    function Operators.onInit()
        SetSoundDuration(sound, CLICK_SOUND_DURATION)
        BlzLoadTOCFile("Components.toc")
        TimerStart(DOUBLE, 9999999999, false, nil)
    end

    -- ---------------------------------------- Tooltip ---------------------------------------- --
    Tooltip = Class()

    Tooltip:property("parent", { get = function(self) return self.parentFrame end })

    Tooltip:property("text", {
        get = function(self) return BlzFrameGetText(self.tooltip) end,
        set = function(self, value) BlzFrameSetText(self.tooltip, value) end
    })

    Tooltip:property("name", {
        get = function(self) return BlzFrameGetText(self.nameFrame) end,
        set = function(self, value) BlzFrameSetText(self.nameFrame, value) end
    })

    Tooltip:property("icon", {
        get = function(self) return self.texture end,
        set = function(self, value)
            self.texture = value
            BlzFrameSetTexture(self.iconFrame, self.texture, 0, false)
        end
    })

    Tooltip:property("width", {
        get = function(self) return self.widthSize end,
        set = function(self, value)
            self.widthSize = value

            if not self.simple then
                BlzFrameSetSize(self.tooltip, value, 0)
            end
        end
    })

    Tooltip:property("point", {
        get = function(self) return self.pointType end,
        set = function(self, value)
            self.pointType = value

            BlzFrameClearAllPoints(self.tooltip)

            if value == FRAMEPOINT_TOPLEFT then
                BlzFrameSetPoint(self.tooltip, value, self.parent, FRAMEPOINT_TOPRIGHT, 0.005, -0.05)
            elseif value == FRAMEPOINT_TOPRIGHT then
                BlzFrameSetPoint(self.tooltip, value, self.parent, FRAMEPOINT_TOPLEFT, -0.005, -0.05)
            elseif value == FRAMEPOINT_BOTTOMLEFT then
                BlzFrameSetPoint(self.tooltip, value, self.parent, FRAMEPOINT_BOTTOMRIGHT, 0.005, 0.0)
            elseif value == FRAMEPOINT_BOTTOM then
                BlzFrameSetPoint(self.tooltip, value, self.parent, FRAMEPOINT_TOP, 0.0, 0.005)
            elseif value == FRAMEPOINT_TOP then
                BlzFrameSetPoint(self.tooltip, value, self.parent, FRAMEPOINT_BOTTOM, 0.0, -0.05)
            else
                BlzFrameSetPoint(self.tooltip, value, self.parent, FRAMEPOINT_BOTTOMLEFT, -0.005, 0.0)
            end
        end
    })

    Tooltip:property("visible", {
        get = function(self) return self.isVisible end,
        set = function(self, value)
            self.isVisible = value

            BlzFrameSetVisible(self.box, value)
        end
    })

    function Tooltip:destroy()
        BlzDestroyFrame(self.nameFrame)
        BlzDestroyFrame(self.iconFrame)
        BlzDestroyFrame(self.tooltip)
        BlzDestroyFrame(self.line)
        BlzDestroyFrame(self.box)
        BlzDestroyFrame(self.frame)
    end

    function Tooltip:setPoint(point, relative, x, y)
        BlzFrameClearAllPoints(self.tooltip)
        BlzFrameSetPoint(self.tooltip, point, self.parent, relative, x, y)
    end

    function Tooltip.create(owner, width, point, simpleTooltip)
        local this = Tooltip.allocate()

        this.parentFrame = owner
        this.simple = simpleTooltip
        this.widthSize = width
        this.pointType = point
        this.isVisible = true

        if simpleTooltip then
            this.frame = BlzCreateFrameByType("FRAME", "", owner, "", 0)
            this.box = BlzCreateFrame("Leaderboard", this.frame, 0, 0)
            this.tooltip = BlzCreateFrameByType("TEXT", "", this.box, "", 0)

            BlzFrameSetPoint(this.tooltip, FRAMEPOINT_BOTTOM, owner, FRAMEPOINT_TOP, 0, 0.008)
            BlzFrameSetPoint(this.box, FRAMEPOINT_TOPLEFT, this.tooltip, FRAMEPOINT_TOPLEFT, -0.008, 0.008)
            BlzFrameSetPoint(this.box, FRAMEPOINT_BOTTOMRIGHT, this.tooltip, FRAMEPOINT_BOTTOMRIGHT, 0.008, -0.008)
        else
            this.frame = BlzCreateFrame("TooltipBoxFrame", owner, 0, 0)
            this.box = BlzGetFrameByName("TooltipBox", 0)
            this.line = BlzGetFrameByName("TooltipSeperator", 0)
            this.tooltip = BlzGetFrameByName("TooltipText", 0)
            this.iconFrame = BlzGetFrameByName("TooltipIcon", 0)
            this.nameFrame = BlzGetFrameByName("TooltipName", 0)

            if point == FRAMEPOINT_TOPLEFT then
                BlzFrameSetPoint(this.tooltip, point, owner, FRAMEPOINT_TOPRIGHT, 0.005, -0.05)
            elseif point == FRAMEPOINT_TOPRIGHT then
                BlzFrameSetPoint(this.tooltip, point, owner, FRAMEPOINT_TOPLEFT, -0.005, -0.05)
            elseif point == FRAMEPOINT_BOTTOMLEFT then
                BlzFrameSetPoint(this.tooltip, point, owner, FRAMEPOINT_BOTTOMRIGHT, 0.005, 0.0)
            else
                BlzFrameSetPoint(this.tooltip, point, owner, FRAMEPOINT_BOTTOMLEFT, -0.005, 0.0)
            end

            BlzFrameSetPoint(this.box, FRAMEPOINT_TOPLEFT, this.iconFrame, FRAMEPOINT_TOPLEFT, -0.005, 0.005)
            BlzFrameSetPoint(this.box, FRAMEPOINT_BOTTOMRIGHT, this.tooltip, FRAMEPOINT_BOTTOMRIGHT, 0.005, -0.005)
            BlzFrameSetSize(this.tooltip, width, 0)
        end

        return this
    end

    -- ---------------------------------------- Backdrop --------------------------------------- --
    Backdrop = Class(Operators)

    Backdrop:property("texture", {
        get = function(self) return self._path end,
        set = function(self, value)
            self._path = value

            if value ~= "" and value ~= nil then
                BlzFrameSetTexture(self.frame, value, 0, true)
                BlzFrameSetVisible(self.frame, true)
            else
                BlzFrameSetVisible(self.frame, false)
            end

            if self.parent ~= nil and self.parent ~= CONSOLE and self.parent ~= WORLD then
                BlzFrameSetAllPoints(self.frame, self.parent)
            end
        end
    })

    function Backdrop:destroy()
        BlzDestroyFrame(self.frame)
    end

    function Backdrop.create(x, y, width, height, parent, texture)
        local this = Backdrop.allocate()

        if not parent then
            parent = CONSOLE
        end

        this.x = x
        this.y = y
        this.width = width
        this.height = height
        this.parent = parent
        this.texture = texture
        this.frame = BlzCreateFrameByType("BACKDROP", "", parent, "", 0)

        if parent == CONSOLE or parent == WORLD then
            BlzFrameSetAbsPoint(this.frame, this.point, x, y)
        else
            BlzFrameSetPoint(this.frame, this.point, parent, this.relative, x, y)
        end

        BlzFrameSetSize(this.frame, width, height)
        BlzFrameSetTexture(this.frame, texture, 0, true)

        return this
    end

    -- ----------------------------------------- Sprite ---------------------------------------- --
    Sprite = Class(Operators)

    Sprite:property("model", {
        get = function(self) return self._path end,
        set = function(self, value)
            self._path = value

            BlzFrameSetModel(self.frame, value, self.camera)
        end
    })

    Sprite:property("camera", {
        get = function(self) return self._index or 0 end,
        set = function(self, value)
            self._index = value

            BlzFrameSetModel(self.frame, self.model, value)
        end
    })

    Sprite:property("animation", {
        get = function(self) return self._animation or 0 end,
        set = function(self, value)
            self._animation = value

            BlzFrameSetSpriteAnimate(self.frame, value, 0)
        end
    })

    function Sprite:destroy()
        BlzDestroyFrame(self.frame)
    end

    function Sprite.create(x, y, width, height, parent, point, relative)
        local this = Sprite.allocate()

        if not parent then
            parent = CONSOLE
        end

        this.x = x
        this.y = y
        this.point = point
        this.relative = relative
        this.width = width
        this.height = height
        this.parent = parent
        this.frame = BlzCreateFrameByType("SPRITE", "", parent, "", 0)

        if parent == CONSOLE or parent == WORLD then
            BlzFrameSetAbsPoint(this.frame, point, x, y)
        else
            BlzFrameSetPoint(this.frame, point, parent, relative, x, y)
        end

        BlzFrameSetSize(this.frame, width, height)

        return this
    end

    -- ------------------------------------------ Text ----------------------------------------- --
    Text = Class(Operators)

    Text:property("text", {
        get = function(self) return self._text end,
        set = function(self, value)
            self._text = value

            BlzFrameSetText(self.frame, value)
        end
    })

    Text:property("vertical", {
        get = function(self) return self._vertical or TEXT_JUSTIFY_CENTER end,
        set = function(self, value)
            self._vertical = value

            BlzFrameSetTextAlignment(self.frame, value, self.horizontal)
        end
    })

    Text:property("horizontal", {
        get = function(self) return self._horizontal or TEXT_JUSTIFY_CENTER end,
        set = function(self, value)
            self._horizontal = value

            BlzFrameSetTextAlignment(self.frame, self.vertical, value)
        end
    })

    function Text:destroy()
        BlzDestroyFrame(self.frame)
    end

    function Text.create(x, y, width, height, scale, enabled, parent, value, vertical, horizontal)
        local this = Text.allocate()

        if not parent then
            parent = CONSOLE
        end

        if not vertical then
            vertical = TEXT_JUSTIFY_CENTER
        end

        if not horizontal then
            horizontal = TEXT_JUSTIFY_CENTER
        end

        this.x = x
        this.y = y
        this.text = value
        this.scale = scale
        this.width = width
        this.height = height
        this.enabled = enabled
        this.parent = parent
        this.vertical = vertical
        this.horizontal = horizontal
        this.frame = BlzCreateFrameByType("TEXT", "", parent, "", 0)

        if parent == CONSOLE or parent == WORLD then
            BlzFrameSetAbsPoint(this.frame, this.point, x, y)
        else
            BlzFrameSetPoint(this.frame, this.point, parent, this.relative, x, y)
        end

        BlzFrameSetSize(this.frame, width, height)
        BlzFrameSetText(this.frame, value)
        BlzFrameSetEnable(this.frame, enabled)
        BlzFrameSetScale(this.frame, scale)
        BlzFrameSetTextAlignment(this.frame, vertical, horizontal)

        return this
    end

    -- ---------------------------------------- TextArea --------------------------------------- --
    TextArea = Class(Operators)

    TextArea:property("text", {
        get = function(self) return self._text end,
        set = function(self, value)
            self._text = value

            if value then
                BlzFrameSetText(self.frame, value)
            else
                BlzFrameSetText(self.frame, "")
            end
        end
    })

    function TextArea:destroy()
        BlzDestroyFrame(self.frame)
    end

    function TextArea.create(x, y, width, height, parent, template)
        local this = TextArea.allocate()

        if not parent then
            parent = CONSOLE
        end

        if not template or template == "" then
            template = "DescriptionArea"
        end

        this.x = x
        this.y = y
        this.width = width
        this.height = height
        this.parent = parent
        this.frame = BlzCreateFrame(template, parent, 0, 0)

        if parent == CONSOLE or parent == WORLD then
            BlzFrameSetAbsPoint(this.frame, this.point, x, y)
        else
            BlzFrameSetPoint(this.frame, this.point, parent, this.relative, x, y)
        end

        BlzFrameSetSize(this.frame, width, height)

        return this
    end

    -- --------------------------------------- StatusBar --------------------------------------- --
    StatusBar = Class(Operators)

    StatusBar:property("value", {
        get = function(self) return BlzFrameGetValue(self.frame) end,
        set = function(self, value) BlzFrameSetValue(self.frame, value) end
    })

    StatusBar:property("texture", {
        get = function(self) return self._texture end,
        set = function(self, value)
            self._texture = value

            if value ~= "" and value ~= nil then
                BlzFrameSetTexture(self.frame, value, 0, true)
                BlzFrameSetVisible(self.frame, true)
            else
                BlzFrameSetVisible(self.frame, false)
            end
        end
    })

    function StatusBar:destroy()
        BlzDestroyFrame(self.frame)
    end

    function StatusBar.create(x, y, width, height, parent, texture)
        local this = StatusBar.allocate()

        if not parent then
            parent = CONSOLE
        end

        this.x = x
        this.y = y
        this.width = width
        this.height = height
        this.parent = parent
        this.texture = texture
        this.frame = BlzCreateFrameByType("SIMPLESTATUSBAR", "", parent, "", 0)

        if parent == CONSOLE or parent == WORLD then
            BlzFrameSetAbsPoint(this.frame, this.point, x, y)
        else
            BlzFrameSetPoint(this.frame, this.point, parent, this.relative, x, y)
        end

        BlzFrameSetValue(this.frame, 0)
        BlzFrameSetSize(this.frame, width, height)
        BlzFrameSetTexture(this.frame, texture, 0, true)

        return this
    end

    -- --------------------------------------- Component --------------------------------------- --
    Component = Class(Operators)
end)