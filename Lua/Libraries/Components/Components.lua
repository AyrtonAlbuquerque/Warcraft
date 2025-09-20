---@beginFile Components
---@debug
---@diagnostic disable: need-check-nil
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
    local SOUND                     = CreateSound(CLICK_SOUND, false, false, false, 10, 10, "")

    -- --------------------------------------- Operators --------------------------------------- --
    local Operators = Class()

    Operators:property("x", {
        get = function(self) return self._x or 0 end,
        set = function(self, value)
            self._x = value

            if self.parent == CONSOLE or self.parent == WORLD then
                BlzFrameSetAbsPoint(self.frame, self.point, value, self.y)
            else
                BlzFrameSetPoint(self.frame, self.point, self.parent, self.relative, value, self.y)
            end
        end
    })

    Operators:property("y", {
        get = function(self) return self._y or 0 end,
        set = function(self, value)
            self._y = value

            if self.parent == CONSOLE or self.parent == WORLD then
                BlzFrameSetAbsPoint(self.frame, self.point, self.x, value)
            else
                BlzFrameSetPoint(self.frame, self.point, self.parent, self.relative, self.x, value)
            end
        end
    })

    Operators:property("point", {
        get = function(self) return self._point or FRAMEPOINT_TOPLEFT end,
        set = function(self, value)
            self._point = value

            BlzFrameClearAllPoints(self.frame)

            if self.parent == CONSOLE or self.parent == WORLD then
                BlzFrameSetAbsPoint(self.frame, value, self.x, self.y)
            else
                BlzFrameSetPoint(self.frame, value, self.parent, self.relative, self.x, self.y)
            end
        end
    })

    Operators:property("relative", {
        get = function(self) return self._relative or FRAMEPOINT_TOPLEFT end,
        set = function(self, value)
            self._relative = value

            BlzFrameClearAllPoints(self.frame)

            if self.parent == CONSOLE or self.parent == WORLD then
                BlzFrameSetAbsPoint(self.frame, self.point, self.x, self.y)
            else
                BlzFrameSetPoint(self.frame, self.point, self.parent, value, self.x, self.y)
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

            BlzFrameSetSize(self.frame, value, self.height)
        end
    })

    Operators:property("height", {
        get = function(self) return self._height or 0 end,
        set = function(self, value)
            self._height = value

            BlzFrameSetSize(self.frame, self.width, value)
        end
    })

    Operators:property("enabled", {
        get = function(self) return self._enabled end,
        set = function(self, value)
            self._enabled = value

            BlzFrameSetEnable(self.frame, value)
        end
    })

    Operators:property("visible", {
        get = function(self) return self._visible end,
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
        SetSoundDuration(SOUND, CLICK_SOUND_DURATION)
        BlzLoadTOCFile("Components.toc")
        TimerStart(DOUBLE, 9999999999, false, nil)
    end

    -- ---------------------------------------- Tooltip ---------------------------------------- --
    do
        Tooltip = Class()

        Tooltip:property("parent", { get = function(self) return self.parentFrame end })

        Tooltip:property("text", {
            get = function(self) return BlzFrameGetText(self.tooltip) end,
            set = function(self, value) BlzFrameSetText(self.tooltip, value or "") end
        })

        Tooltip:property("name", {
            get = function(self) return BlzFrameGetText(self.nameFrame) end,
            set = function(self, value) BlzFrameSetText(self.nameFrame, value or "") end
        })

        Tooltip:property("icon", {
            get = function(self) return self.texture or "" end,
            set = function(self, value)
                self.texture = value or ""

                BlzFrameSetTexture(self.iconFrame, self.texture, 0, false)
            end
        })

        Tooltip:property("width", {
            get = function(self) return self.widthSize or 0 end,
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
    end

    -- ---------------------------------------- Backdrop --------------------------------------- --
    do
        Backdrop = Class(Operators)

        Backdrop:property("texture", {
            get = function(self) return self._path or "" end,
            set = function(self, value)
                self._path = value or ""

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
            BlzFrameSetTexture(this.frame, texture or "", 0, true)

            return this
        end
    end

    -- ----------------------------------------- Sprite ---------------------------------------- --
    do
        Sprite = Class(Operators)

        Sprite:property("model", {
            get = function(self) return self._path or "" end,
            set = function(self, value)
                self._path = value or ""

                BlzFrameSetModel(self.frame, self._path, self.camera)
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
    end

    -- ------------------------------------------ Text ----------------------------------------- --
    do
        Text = Class(Operators)

        Text:property("text", {
            get = function(self) return self._text or "" end,
            set = function(self, value)
                self._text = value or ""

                BlzFrameSetText(self.frame, self._text)
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
            BlzFrameSetText(this.frame, value or "")
            BlzFrameSetEnable(this.frame, enabled)
            BlzFrameSetScale(this.frame, scale)
            BlzFrameSetTextAlignment(this.frame, vertical, horizontal)

            return this
        end
    end

    -- ---------------------------------------- TextArea --------------------------------------- --
    do
        TextArea = Class(Operators)

        TextArea:property("text", {
            get = function(self) return self._text or "" end,
            set = function(self, value)
                self._text = value or ""

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
    end

    -- --------------------------------------- StatusBar --------------------------------------- --
    do
        StatusBar = Class(Operators)

        StatusBar:property("value", {
            get = function(self) return BlzFrameGetValue(self.frame) end,
            set = function(self, value) BlzFrameSetValue(self.frame, value) end
        })

        StatusBar:property("texture", {
            get = function(self) return self._texture or "" end,
            set = function(self, value)
                self._texture = value or ""

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
            BlzFrameSetTexture(this.frame, texture or "", 0, true)

            return this
        end
    end

    -- --------------------------------------- Component --------------------------------------- --
    do
        Component = Class(Operators)

        local time = {}
        local array = {}
        local current = {}
        local doubleTime = {}
        local click = CreateTrigger()
        local enter = CreateTrigger()
        local leave = CreateTrigger()
        local scroll = CreateTrigger()

        Component:property("texture", {
            get = function(self) return self.image.texture end,
            set = function(self, value) self.image.texture = value end
        })

        Component:property("active", {
            get = function(self) return self.isActive end,
            set = function(self, value)
                self.isActive = value

                if not self.isActive then
                    if SubString(self.image.texture, 34, 35) == "\\" then
                        self.image.texture = SubString(self.image.texture, 0, 34) .. "Disabled\\DIS" .. SubString(self.image.texture, 35, StringLength(self.image.texture))
                    end
                else
                    if SubString(self.image.texture, 34, 46) == "Disabled\\DIS" then
                        self.image.texture = SubString(self.image.texture, 0, 34) .. "\\" .. SubString(self.image.texture, 46, StringLength(self.image.texture))
                    end
                end
            end
        })

        Component:property("actor", { get = function(self) return self.listener end })

        Component:property("OnEnter", {
            set = function(self, value)
                if type(value) == "function" then
                    self.entered = {}
                    table.insert(self.entered, value)
                end
            end
        })

        Component:property("OnLeave", {
            set = function(self, value)
                if type(value) == "function" then
                    self.exited = {}
                    table.insert(self.exited, value)
                end
            end
        })

        Component:property("OnClick", {
            set = function(self, value)
                if type(value) == "function" then
                    self.clicked = {}
                    table.insert(self.clicked, value)
                end
            end
        })

        Component:property("OnScroll", {
            set = function(self, value)
                if type(value) == "function" then
                    self.scrolled = {}
                    table.insert(self.scrolled, value)
                end
            end
        })

        Component:property("OnRightClick", {
            set = function(self, value)
                if type(value) == "function" then
                    self.rightClicked = {}
                    table.insert(self.rightClicked, value)
                end
            end
        })

        Component:property("OnDoubleClick", {
            set = function(self, value)
                if type(value) == "function" then
                    self.doubleClicked = {}
                    table.insert(self.doubleClicked, value)
                end
            end
        })

        Component:property("OnMiddleClick", {
            set = function(self, value)
                if type(value) == "function" then
                    self.middleClicked = {}
                    table.insert(self.middleClicked, value)
                end
            end
        })

        function Component:destroy()
            self.image:destroy()
            array[self.listener] = nil
            array[self.button] = nil
            BlzDestroyFrame(self.frame)
            BlzDestroyFrame(self.listener)
        end

        function Component.get()
            return current[GetTriggerPlayer()]
        end

        function Component.create(x, y, width, height, parent, frameType, template, inheritEvents)
            local this = Component.allocate()

            if not parent then
                parent = CONSOLE
            end

            if template == "" or template == nil then
                template = "TransparentBackdrop"
            end

            this.x = x
            this.y = y
            this.width = width
            this.height = height
            this.parent = parent
            this.isActive = true
            this.inherit = inheritEvents
            this.frame = BlzCreateFrame(template, parent, 0, 0)
            this.listener = BlzCreateFrame(frameType, this.frame, 0, 0)
            this.button = BlzFrameGetChild(this.listener, 0)
            this.image = Backdrop.create(0, 0, width, height, this.listener, nil)
            this.image.visible = false
            array[this.frame] = this
            array[this.listener] = this
            array[this.button] = this

            if parent == CONSOLE or parent == WORLD then
                BlzFrameSetAbsPoint(this.frame, this.point, x, y)
            else
                BlzFrameSetPoint(this.frame, this.point, parent, this.relative, x, y)
            end

            BlzFrameSetSize(this.frame, width, height)
            BlzFrameSetAllPoints(this.listener, this.frame)
            BlzTriggerRegisterFrameEvent(enter, this.listener, FRAMEEVENT_MOUSE_ENTER)
            BlzTriggerRegisterFrameEvent(leave, this.listener, FRAMEEVENT_MOUSE_LEAVE)
            BlzTriggerRegisterFrameEvent(scroll, this.button, FRAMEEVENT_MOUSE_WHEEL)

            return this
        end

        function Component.onScrolled()
            local this = array[BlzGetTriggerFrame()]

            if this then
                local owner = array[this.parent]

                if this.onScroll then
                    this:onScroll()
                end

                if owner then
                    if owner.onScroll and this.inherit then
                        owner:onScroll()
                    end
                end

                if this.scrolled then
                    for i = 1, #this.scrolled do
                        this.scrolled[i]()
                    end
                end
            end
        end

        function Component.onClicked()
            local player = GetTriggerPlayer()
            local this = current[player]

            if this then
                local owner = array[this.parent]

                if not time[player] then time[player] = {} end
                if not doubleTime[player] then doubleTime[player] = {} end

                StartSoundForPlayerBJ(player, SOUND)

                if BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_LEFT then
                    time[player][this] = TimerGetElapsed(DOUBLE)

                    BlzFrameSetEnable(this.listener, false)
                    BlzFrameSetEnable(this.listener, true)

                    if this.onClick then
                        this:onClick()
                    end

                    if owner then
                        if owner.onClick and this.inherit then
                            owner:onClick()
                        end
                    end

                    if this.clicked then
                        for i = 1, #this.clicked do
                            this.clicked[i]()
                        end
                    end

                    if time[player][this] - (doubleTime[player][this] or 0) <= DOUBLE_CLICK_DELAY then
                        doubleTime[player][this] = 0

                        if this.onDoubleClick then
                            this:onDoubleClick()
                        end

                        if owner then
                            if owner.onDoubleClick and this.inherit then
                                owner:onDoubleClick()
                            end
                        end

                        if this.doubleClicked then
                            for i = 1, #this.doubleClicked do
                                this.doubleClicked[i]()
                            end
                        end
                    else
                        doubleTime[player][this] = time[player][this] or 0
                    end
                end

                if BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT then
                    if this.onRightClick then
                        this:onRightClick()
                    end

                    if owner then
                        if owner.onRightClick and this.inherit then
                            owner:onRightClick()
                        end
                    end

                    if this.rightClicked then
                        for i = 1, #this.rightClicked do
                            this.rightClicked[i]()
                        end
                    end
                end

                if BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_MIDDLE then
                    if this.onMiddleClick then
                        this:onMiddleClick()
                    end

                    if owner then
                        if owner.onMiddleClick and this.inherit then
                            owner:onMiddleClick()
                        end
                    end

                    if this.middleClicked then
                        for i = 1, #this.middleClicked do
                            this.middleClicked[i]()
                        end
                    end
                end
            end
        end

        function Component.onEntered()
            local this = array[BlzGetTriggerFrame()]

            current[GetTriggerPlayer()] = this

            if this then
                local owner = array[this.parent]

                if this.onEnter then
                    this:onEnter()
                end

                if owner then
                    if owner.onEnter and this.inherit then
                        owner:onEnter()
                    end
                end

                if this.entered then
                    for i = 1, #this.entered do
                        this.entered[i]()
                    end
                end
            end
        end

        function Component.onExited()
            local this = array[BlzGetTriggerFrame()]

            current[GetTriggerPlayer()] = nil

            if this then
                local owner = array[this.parent]

                if this.onLeave then
                    this:onLeave()
                end

                if owner then
                    if owner.onLeave and this.inherit then
                        owner:onLeave()
                    end
                end

                if this.exited then
                    for i = 1, #this.exited do
                        this.exited[i]()
                    end
                end
            end
        end

        function Component.onInit()
            TriggerAddAction(leave, Component.onExited)
            TriggerAddAction(enter, Component.onEntered)
            TriggerAddAction(click, Component.onClicked)
            TriggerAddAction(scroll, Component.onScrolled)

            for i = 0, bj_MAX_PLAYER_SLOTS do
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    TriggerRegisterPlayerEvent(click, Player(i), EVENT_PLAYER_MOUSE_UP)
                end
            end
        end
    end

    -- ---------------------------------------- EditBox ---------------------------------------- --
    do
        EditBox = Class(Operators)

        local array = {}
        local enter = CreateTrigger()
        local typing = CreateTrigger()

        EditBox:property("limit", {
            get = function(self) return self.length end,
            set = function(self, value)
                self.length = value

                BlzFrameSetTextSizeLimit(self.frame, value)
            end
        })

        EditBox:property("text", {
            get = function(self)
                self._text = BlzFrameGetText(self.frame)
                return self._text
            end,
            set = function(self, value)
                self._text = value or ""

                BlzFrameSetText(self.frame, self._text)
            end
        })

        EditBox:property("OnEnter", {
            set = function(self, value)
                if type(value) == "function" then
                    self.entered = {}
                    table.insert(self.entered, value)
                end
            end
        })

        EditBox:property("OnText", {
            set = function(self, value)
                if type(value) == "function" then
                    self.typed = {}
                    table.insert(self.typed, value)
                end
            end
        })

        function EditBox:destroy()
            BlzDestroyFrame(self.frame)
        end

        function EditBox.get()
            return array[BlzGetTriggerFrame()]
        end

        function EditBox.create(x, y, width, height, parent, template)
            local this = EditBox.allocate()

            if not parent then
                parent = CONSOLE
            end

            if template == "" or template == nil then
                template = "EscMenuEditBoxTemplate"
            end

            this.x = x
            this.y = y
            this.width = width
            this.height = height
            this.parent = parent
            this.frame = BlzCreateFrame(template, parent, 0, 0)
            array[this.frame] = this

            if parent == CONSOLE or parent == WORLD then
                BlzFrameSetAbsPoint(this.frame, this.point, x, y)
            else
                BlzFrameSetPoint(this.frame, this.point, parent, this.relative, x, y)
            end

            BlzFrameSetSize(this.frame, width, height)
            BlzTriggerRegisterFrameEvent(enter, this.frame, FRAMEEVENT_EDITBOX_ENTER)
            BlzTriggerRegisterFrameEvent(typing, this.frame, FRAMEEVENT_EDITBOX_TEXT_CHANGED)

            return this
        end

        function EditBox.onTyping()
            local this = array[BlzGetTriggerFrame()]

            if this then
                this._text = BlzGetTriggerFrameText()

                if this.onText then
                    this:onText()
                end

                if this.typed then
                    for i = 1, #this.typed do
                        this.typed[i]()
                    end
                end
            end
        end

        function EditBox.onEntered()
            local this = array[BlzGetTriggerFrame()]

            if this then
                if this.onEnter then
                    this:onEnter()
                end

                if this.entered then
                    for i = 1, #this.entered do
                        this.entered[i]()
                    end
                end
            end
        end

        function EditBox.onInit()
            TriggerAddAction(typing, EditBox.onTyping)
            TriggerAddAction(enter, EditBox.onEntered)
        end
    end

    -- ---------------------------------------- CheckBox --------------------------------------- --
    do
        CheckBox = Class(Operators)

        local array = {}
        local event = CreateTrigger()

        CheckBox:property("checked", { get = function(self) return (self.isChecked and self.isChecked[GetLocalPlayer()]) or false end })

        CheckBox:property("OnCheck", {
            set = function(self, value)
                if type(value) == "function" then
                    self.check = {}
                    table.insert(self.check, value)
                end
            end
        })

        CheckBox:property("OnUncheck", {
            set = function(self, value)
                if type(value) == "function" then
                    self.uncheck = {}
                    table.insert(self.uncheck, value)
                end
            end
        })

        function CheckBox:destroy()
            BlzDestroyFrame(self.frame)
        end

        function CheckBox.get()
            return array[BlzGetTriggerFrame()]
        end

        function CheckBox.create(x, y, width, height, parent, template)
            local this = CheckBox.allocate()

            if not parent then
                parent = CONSOLE
            end

            if template == "" or template == nil then
                template = "QuestCheckBox"
            end

            this.x = x
            this.y = y
            this.width = width
            this.height = height
            this.parent = parent
            this.frame = BlzCreateFrame(template, parent, 0, 0)
            array[this.frame] = this

            if parent == CONSOLE or parent == WORLD then
                BlzFrameSetAbsPoint(this.frame, this.point, x, y)
            else
                BlzFrameSetPoint(this.frame, this.point, parent, this.relative, x, y)
            end

            BlzFrameSetSize(this.frame, width, height)
            BlzTriggerRegisterFrameEvent(event, this.frame, FRAMEEVENT_CHECKBOX_CHECKED)
            BlzTriggerRegisterFrameEvent(event, this.frame, FRAMEEVENT_CHECKBOX_UNCHECKED)

            return this
        end

        function CheckBox.onChecked()
            local this = array[BlzGetTriggerFrame()]

            if this then
                if not this.isChecked then this.isChecked = {} end

                this.isChecked[GetTriggerPlayer()] = BlzGetTriggerFrameEvent() == FRAMEEVENT_CHECKBOX_CHECKED

                if BlzGetTriggerFrameEvent() == FRAMEEVENT_CHECKBOX_CHECKED then
                    if this.onCheck then
                        this:onCheck()
                    end

                    if this.check then
                        for i = 1, #this.check do
                            this.check[i]()
                        end
                    end
                else
                    if this.onUncheck then
                        this:onUncheck()
                    end

                    if this.uncheck then
                        for i = 1, #this.uncheck do
                            this.uncheck[i]()
                        end
                    end
                end
            end
        end

        function CheckBox.onInit()
            TriggerAddAction(event, CheckBox.onChecked)
        end
    end

    -- ----------------------------------------- Slider ---------------------------------------- --
    do
        Slider = Class(Operators)

        local array = {}
        local event = CreateTrigger()

        Slider:property("min", {
            get = function(self) return self.minimum or 0 end,
            set = function(self, value)
                self.minimum = value

                BlzFrameSetMinMaxValue(self.frame, value, self.maximum)
            end
        })

        Slider:property("max", {
            get = function(self) return self.maximum or 100 end,
            set = function(self, value)
                self.maximum = value

                BlzFrameSetMinMaxValue(self.frame, self.minimum, value)
            end
        })

        Slider:property("step", {
            get = function(self) return self.stepping or 1 end,
            set = function(self, value)
                self.stepping = value

                BlzFrameSetStepSize(self.frame, value)
            end
        })

        Slider:property("value", {
            get = function(self) return BlzFrameGetValue(self.frame) end,
            set = function(self, val) BlzFrameSetValue(self.frame, val) end
        })

        Slider:property("OnSlide", {
            set = function(self, value)
                if type(value) == "function" then
                    self.slided = {}
                    table.insert(self.slided, value)
                end
            end
        })

        function Slider:destroy()
            BlzDestroyFrame(self.frame)
        end

        function Slider.get()
            return array[BlzGetTriggerFrame()]
        end

        function Slider.create(x, y, width, height, parent, template)
            local this = CheckBox.allocate()

            if not parent then
                parent = CONSOLE
            end

            if template == "" or template == nil then
                template = "EscMenuSliderTemplate"
            end

            this.x = x
            this.y = y
            this.width = width
            this.height = height
            this.parent = parent
            this.frame = BlzCreateFrame(template, parent, 0, 0)
            array[this.frame] = this

            if parent == CONSOLE or parent == WORLD then
                BlzFrameSetAbsPoint(this.frame, this.point, x, y)
            else
                BlzFrameSetPoint(this.frame, this.point, parent, this.relative, x, y)
            end

            BlzFrameSetSize(this.frame, width, height)
            BlzFrameSetStepSize(this.frame, this.step)
            BlzFrameSetMinMaxValue(this.frame, this.min, this.max)
            BlzTriggerRegisterFrameEvent(event, this.frame, FRAMEEVENT_SLIDER_VALUE_CHANGED)

            return this
        end

        function Slider.onSlided()
            local this = array[BlzGetTriggerFrame()]

            if this then
                if this.onSlide then
                    this:onSlide()
                end

                if this.slided then
                    for i = 1, #this.slided do
                        this.slided[i]()
                    end
                end
            end
        end

        function Slider.onInit()
            TriggerAddAction(event, Slider.onSlided)
        end
    end

    -- ----------------------------------------- Button ---------------------------------------- --
    do
        Button = Class(Component)

        Button:property("available", {
            get = function(self) return not self.block.visible end,
            set = function(self, value) self.block.visible = not value end
        })

        Button:property("checked", {
            get = function(self) return self.check.visible end,
            set = function(self, value) self.check.visible = value end
        })

        Button:property("highlighted", {
            get = function(self) return self.isHighlighted or false end,
            set = function(self, value)
                self.isHighlighted = value

                BlzFrameSetVisible(self.highlight, value)
            end
        })

        Button:property("tagged", { get = function(self) return self.tagger.visible end })

        function Button:destroy()
            self.check:destroy()
            self.block:destroy()
            self.tagger:destroy()
            self.sprite:destroy()
            self.player:destroy()
            self.tooltip:destroy()

            BlzDestroyFrame(self.highlight)
        end

        function Button:play(model, scale, animation)
            if model ~= "" and model ~= nil then
                self.sprite.scale = scale
                self.sprite.model = model
                self.sprite.animation = animation
            end
        end

        function Button:display(model, scale, offsetX, offsetY)
            self.player.visible = model ~= "" and model ~= nil

            if self.player.visible then
                self.player.x = offsetX
                self.player.y = offsetY
                self.player.scale = scale
                self.player.model = model
            end
        end

        function Button:tag(model, scale, offsetX, offsetY)
            self.tagger.visible = model ~= "" and model ~= nil

            if self.tagger.visible then
                self.tagger.x = offsetX
                self.tagger.y = offsetY
                self.tagger.scale = scale
                self.tagger.model = model
            end
        end

        function Button.create(x, y, width, height, parent, simpleTooltip, inheritEvents)
            local this = Button.allocate(x, y, width, height, parent, "ComponentFrame", nil, inheritEvents)

            this.check = Backdrop.create(0, 0, width, height, this.frame, CHECKED_BUTTON)
            this.block = Backdrop.create(0, 0, width, height, this.frame, UNAVAILABLE_BUTTON)
            this.sprite = Sprite.create(0, 0, width, height, this.frame, FRAMEPOINT_CENTER, FRAMEPOINT_CENTER)
            this.tagger = Sprite.create(0, 0, 0.00001, 0.00001, this.frame, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT)
            this.player = Sprite.create(0, 0, 0.00001, 0.00001, this.frame, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT)
            this.tooltip = Tooltip.create(this.frame, TOOLTIP_SIZE, FRAMEPOINT_TOPLEFT, simpleTooltip)
            this.highlight = BlzCreateFrame("HighlightFrame", this.frame, 0, 0)
            this.checked = false
            this.available = true
            this.highlighted = false
            this.tagger.visible = false

            BlzFrameSetTooltip(this.actor, this.tooltip.frame)
            BlzFrameSetPoint(this.highlight, FRAMEPOINT_TOPLEFT, this.frame, FRAMEPOINT_TOPLEFT, - 0.004, 0.0045)
            BlzFrameSetSize(this.highlight, width + 0.0085, height + 0.0085)
            BlzFrameSetTexture(this.highlight, HIGHLIGHT, 0, true)

            return this
        end
    end

    -- ----------------------------------------- Panel ----------------------------------------- --
    do
        Panel = Class(Component)

        function Panel.create(x, y, width, height, parent, template, inheritEvents)
            return Panel.allocate(x, y, width, height, parent, "PanelFrame", template, inheritEvents)
        end
    end

    -- ------------------------------------------ Line ----------------------------------------- --
    do
        Line = Class(Backdrop)

        function Line.create(x, y, width, height, parent, texture)
            return Line.allocate(x, y, width, height, parent, texture)
        end
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function GetTriggerComponent()
        return Component.get()
    end

    function GetTriggerEditBox()
        return EditBox.get()
    end

    function GetTriggerCheckBox()
        return CheckBox.get()
    end

    function GetTriggerSlider()
        return Slider.get()
    end
end)