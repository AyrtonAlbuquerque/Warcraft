OnInit("Shop", function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"
    requires "Components"
    requires "RegisterPlayerUnitEvent"

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- Main window 
    local X                         = 0.0
    local Y                         = 0.56
    local WIDTH                     = 0.8
    local HEIGHT                    = 0.4
    local TOOLBAR_BUTTON_SIZE       = 0.02
    local ROWS                      = 5
    local COLUMNS                   = 13
    local DETAILED_ROWS             = 5
    local DETAILED_COLUMNS          = 8
    local CLOSE_ICON                = "ui\\widgets\\battlenet\\chaticons\\bnet-squelch"
    local CLEAR_ICON                = "ReplaceableTextures\\CommandButtons\\BTNCancel.blp"
    local HELP_ICON                 = "UI\\Widgets\\EscMenu\\Human\\quest-unknown.blp"
    local LOGIC_ICON                = "ReplaceableTextures\\CommandButtons\\BTNMagicalSentry.blp"
    local UNDO_ICON                 = "ReplaceableTextures\\CommandButtons\\BTNReplay-Loop.blp"
    local DISMANTLE_ICON            = "UI\\Feedback\\Resources\\ResourceUpkeep.blp"

    -- Details window
    local DETAIL_WIDTH              = 0.3125
    local DETAIL_HEIGHT             = HEIGHT
    local DETAIL_USED_COUNT         = 6
    local DETAIL_BUTTON_SIZE        = 0.035
    local DETAIL_BUTTON_GAP         = 0.044
    local DETAIL_CLOSE_BUTTON_SIZE  = 0.02
    local DETAIL_SHIFT_BUTTON_SIZE  = 0.012
    local USED_RIGHT                = "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedDown.blp"
    local USED_LEFT                 = "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedUp.blp"

    -- Side Panels
    local SIDE_WIDTH                = 0.075
    local SIDE_HEIGHT               = HEIGHT
    local EDIT_WIDTH                = 0.15
    local EDIT_HEIGHT               = 0.0285

    local SLOT_WIDTH                = 0.04
    local SLOT_HEIGHT               = 0.05
    local ITEM_SIZE                 = 0.04
    local GOLD_SIZE                 = 0.01
    local COST_WIDTH                = 0.045
    local COST_HEIGHT               = 0.01
    local COST_SCALE                = 0.8
    local SLOT_GAP_X                = 0.018
    local SLOT_GAP_Y                = 0.022
    local GOLD_ICON                 = "UI\\Feedback\\Resources\\ResourceGold.blp"
    local WOOD_ICON                 = "UI\\Feedback\\Resources\\ResourceLumber.blp"

    -- Scroll
    local SCROLL_DELAY              = 0.03

    -- Update time
    local UPDATE_PERIOD             = 0.33

    -- Buy / Sell sound, model and scale
    local SPRITE_MODEL              = "UI\\Feedback\\GoldCredit\\GoldCredit.mdl"
    local SPRITE_SCALE              = 0.0005
    local SUCCESS_SOUND             = "Abilities\\Spells\\Other\\Transmute\\AlchemistTransmuteDeath1.wav"
    local ERROR_SOUND               = "Sound\\Interface\\Error.wav"

    -- Dont touch
    local array = {}

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function ShopFilter(unit, player, shop)
        return IsUnitOwnedByPlayer(unit, player) and UnitInventorySize(unit) > 0 and not IsUnitType(unit, UNIT_TYPE_DEAD) and not IsUnitPaused(unit) and not IsUnitIllusion(unit) and not IsUnitHidden(unit)
    end

    -- ----------------------------------------- Sound ----------------------------------------- --
    local Sound = Class()

    do
        local noGold = {}
        local noWood = {}

        Sound.error_sound = CreateSound(ERROR_SOUND, false, false, false, 10, 10, "")
        Sound.success_sound = CreateSound(SUCCESS_SOUND, false, false, false, 10, 10, "")

        function Sound.gold(player)
            if not GetSoundIsPlaying(noGold[GetHandleId(GetPlayerRace(player))]) then
                StartSoundForPlayerBJ(player, noGold[GetHandleId(GetPlayerRace(player))])
            end
        end

        function Sound.wood(player)
            if not GetSoundIsPlaying(noWood[GetHandleId(GetPlayerRace(player))]) then
                StartSoundForPlayerBJ(player, noWood[GetHandleId(GetPlayerRace(player))])
            end
        end

        function Sound.success(player)
            if not GetSoundIsPlaying(Sound.success_sound) then
                StartSoundForPlayerBJ(player, Sound.success_sound)
            end
        end

        function Sound.error(player)
            if not GetSoundIsPlaying(Sound.error_sound) then
                StartSoundForPlayerBJ(player, Sound.error_sound)
            end
        end

        function Sound.onInit()
            local id

            SetSoundDuration(Sound.success_sound, 1600)
            SetSoundDuration(Sound.error_sound, 614)

            id = GetHandleId(RACE_HUMAN)
            noGold[id] = CreateSound("Sound\\Interface\\Warning\\Human\\KnightNoGold1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noGold[id], "NoGoldHuman")
            SetSoundDuration(noGold[id], 1618)
            noWood[id] = CreateSound("Sound\\Interface\\Warning\\Human\\KnightNoLumber1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noWood[id], "NoLumberHuman")
            SetSoundDuration(noWood[id], 1863)

            id = GetHandleId(RACE_ORC)
            noGold[id] = CreateSound("Sound\\Interface\\Warning\\Orc\\GruntNoGold1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noGold[id], "NoGoldOrc")
            SetSoundDuration(noGold[id], 1450)
            noWood[id] = CreateSound("Sound\\Interface\\Warning\\Orc\\GruntNoLumber1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noWood[id], "NoLumberOrc")
            SetSoundDuration(noWood[id], 1602)

            id = GetHandleId(RACE_NIGHTELF)
            noGold[id] = CreateSound("Sound\\Interface\\Warning\\NightElf\\SentinelNoGold1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noGold[id], "NoGoldNightElf")
            SetSoundDuration(noGold[id], 1229)
            noWood[id] = CreateSound("Sound\\Interface\\Warning\\NightElf\\SentinelNoLumber1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noWood[id], "NoLumberNightElf")
            SetSoundDuration(noWood[id], 1500)

            id = GetHandleId(RACE_UNDEAD)
            noGold[id] = CreateSound("Sound\\Interface\\Warning\\Undead\\NecromancerNoGold1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noGold[id], "NoGoldUndead")
            SetSoundDuration(noGold[id], 2005)
            noWood[id] = CreateSound("Sound\\Interface\\Warning\\Undead\\NecromancerNoLumber1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noWood[id], "NoLumberUndead")
            SetSoundDuration(noWood[id], 1903)

            id = GetHandleId(ConvertRace(11))
            noGold[id] = CreateSound("Sound\\Interface\\Warning\\Naga\\NagaNoGold1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noGold[id], "NoGoldNaga")
            SetSoundDuration(noGold[id], 2690)
            noWood[id] = CreateSound("Sound\\Interface\\Warning\\Naga\\NagaNoLumber1.wav", false, false, false, 10, 10, "")
            SetSoundParamsFromLabel(noWood[id], "NoLumberNaga")
            SetSoundDuration(noWood[id], 1576)
        end
    end

    -- ------------------------------------------ Slot ----------------------------------------- --
    local Slot = Class(Button)

    do
        Slot:property("row", {
            get = function(self) return self._row or 0 end,
            set = function(self, value)
                self._row = value
                self.y = - (0.03 + ((SLOT_HEIGHT + SLOT_GAP_Y) * value))

                self:update()
            end
        })

        Slot:property("column", {
            get = function(self) return self._column or 0 end,
            set = function(self, value)
                self._column = value
                self.x = 0.03 + ((SLOT_WIDTH + SLOT_GAP_X) * value)

                self:update()
            end
        })

        function Slot:destroy()
            self.gold:destroy()
            self.cost:destroy()
            self.wood:destroy()
            self.lumber:destroy()
        end

        function Slot:update()
            if self.column <= (self.shop.columns / 2) and self.row < 3 then
                self.tooltip.point = FRAMEPOINT_TOPLEFT
            elseif self.column >= ((self.shop.columns / 2) + 1) and self.row < 3 then
                self.tooltip.point = FRAMEPOINT_TOPRIGHT
            elseif self.column <= (self.shop.columns / 2) and self.row >= 3 then
                self.tooltip.point = FRAMEPOINT_BOTTOMLEFT
            else
                self.tooltip.point = FRAMEPOINT_BOTTOMRIGHT
            end
        end

        function Slot:move(row, column)
            self.row = row
            self.column = column
        end

        function Slot.create(shop, item, x, y, parent)
            local this = Slot.allocate(x, y, ITEM_SIZE, ITEM_SIZE, parent, false, false)

            this.x = x
            this.y = y
            this.item = item
            this.shop = shop
            this.next = nil
            this.prev = nil
            this.right = nil
            this.left = nil
            this.tooltip.point = FRAMEPOINT_TOPRIGHT
            this.gold = Backdrop.create(0, - 0.04, GOLD_SIZE, GOLD_SIZE, this.frame, GOLD_ICON)
            this.cost = Text.create(0.01325, - 0.00193, COST_WIDTH, COST_HEIGHT, COST_SCALE, false, this.gold.frame, nil, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            this.lumber = Backdrop.create(0, 0, GOLD_SIZE, GOLD_SIZE, this.gold.frame, WOOD_ICON)
            this.wood = Text.create(0, 0, COST_WIDTH, COST_HEIGHT, COST_SCALE, false, this.lumber.frame, nil, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)

            this.lumber:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, 0)
            this.wood:setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, 0, 0)

            if item then
                this.texture = item.icon
                this.tooltip.text = item.tooltip
                this.tooltip.name = item.name
                this.tooltip.icon = item.icon
                this.cost.text = "|cffFFCC00" .. I2S(item.gold) .. "|r"
                this.lumber.visible = item.wood > 0
                this.wood.text = "|cff238b3d" .. I2S(item.wood) .. "|r"
            end

            return this
        end

        function Slot:onScroll()
            if GetLocalPlayer() == GetTriggerPlayer() then
                self.shop:onScroll()
            end
        end

        function Slot:onClick()
            -- self.shop:detail(self.item, GetTriggerPlayer())
        end

        function Slot:onMiddleClick()
            -- if self.shop.favorites:has(self.item.id, GetTriggerPlayer()) then
            --     self.shop.favorites:remove(self.item, GetTriggerPlayer())
            -- else
            --     self.shop.favorites:add(self.item, GetTriggerPlayer())
            -- end
        end

        function Slot:onDoubleClick()
            if self.shop:buy(self.item, GetTriggerPlayer()) then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    self:play(SPRITE_MODEL, SPRITE_SCALE, 0)
                end
            end
        end

        function Slot:onRightClick()
            if self.shop:buy(self.item, GetTriggerPlayer()) then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    self:play(SPRITE_MODEL, SPRITE_SCALE, 0)
                end
            end
        end
    end

    -- ----------------------------------------- Detail ---------------------------------------- --
    local Detail = Class(Panel)

    do
        function Detail:destroy()
            for i = 0, bj_MAX_PLAYER_SLOTS do
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    local j = 0

                    while j < 5 do
                        self.lines[i][j]:destroy()
                        self.components[i][j]:destroy()
                        j = j + 1
                    end

                    j = 0

                    while j < DETAIL_USED_COUNT do
                        self.button[i][j]:destroy()
                        j = j + 1
                    end

                    self.main[i]:destroy()
                end
            end

            self.uses:destroy()
            self.left:destroy()
            self.close:destroy()
            self.right:destroy()
            self.vertical:destroy()
            self.usedText:destroy()
            self.separator:destroy()
            self.horizontal:destroy()
            self.description[0]:destroy()
            self.description[1]:destroy()
            self.description[2]:destroy()
            self.description[3]:destroy()
        end

        function Detail:shift(left, player)
            local id = GetPlayerId(player)

            if left then
                if self.item[id].relation[self.count[id]] and self.count[id] >= DETAIL_USED_COUNT then
                    for j = 0, DETAIL_USED_COUNT - 1 do
                        self.used[id][j] = self.used[id][j + 1]

                        if player == GetLocalPlayer() then
                            self.button[id][j].texture = self.used[id][j].icon
                            self.button[id][j].tooltip.text = self.used[id][j].tooltip
                            self.button[id][j].tooltip.name = self.used[id][j].name
                            self.button[id][j].tooltip.icon = self.used[id][j].icon
                            self.button[id][j].available = shop:has(self.used[id][j].id)
                            self.button[id][j].visible = true
                        end
                    end

                    local j = DETAIL_USED_COUNT - 1
                    local item = Item.get(self.item[id].relation[self.count[id]])

                    if item then
                        self.count[id] = (self.count[id] or 0) - 1
                        self.used[id][j] = item

                        if player == GetLocalPlayer() then
                            self.button[id][j].texture = item.icon
                            self.button[id][j].tooltip.text = item.tooltip
                            self.button[id][j].tooltip.name = item.name
                            self.button[id][j].tooltip.icon = item.icon
                            self.button[id][j].available = shop:has(item.id)
                            self.button[id][j].visible = true
                        end
                    end
                end
            else
                if self.count[id] > DETAIL_USED_COUNT then
                    for j = DETAIL_USED_COUNT - 1, 1, -1 do
                        self.used[id][j] = self.used[id][j - 1]

                        if player == GetLocalPlayer() then
                            self.button[id][j].texture = self.used[id][j].icon
                            self.button[id][j].tooltip.text = self.used[id][j].tooltip
                            self.button[id][j].tooltip.name = self.used[id][j].name
                            self.button[id][j].tooltip.icon = self.used[id][j].icon
                            self.button[id][j].available = shop:has(self.used[id][j].id)
                            self.button[id][j].visible = true
                        end
                    end

                    local j = 0
                    local item = Item.get(self.item[id].relation[self.count[id] - DETAIL_USED_COUNT - 1])

                    if item then
                        self.count[id] = (self.count[id] or 0) + 1
                        self.used[id][j] = item

                        if player == GetLocalPlayer() then
                            self.button[id][j].texture = item.icon
                            self.button[id][j].tooltip.text = item.tooltip
                            self.button[id][j].tooltip.name = item.name
                            self.button[id][j].tooltip.icon = item.icon
                            self.button[id][j].available = shop:has(item.id)
                            self.button[id][j].visible = true
                        end
                    end
                end
            end
        end

        function Detail.create(shop)
            local this = Detail.allocate(WIDTH - DETAIL_WIDTH, 0, DETAIL_WIDTH, DETAIL_HEIGHT, shop.frame, "EscMenuBackdrop", false)

            this.shop = shop
            this.item = {}
            this.main = {}
            this.used = {}
            this.line = {}
            this.count = {}
            this.button = {}
            this.components = {}
            this.description = {}
            this.description[0] = TextArea.create(0.0275, - 0.16, 0.31, 0.16, this.frame, "DescriptionArea")
            this.description[1] = TextArea.create(0.0275, - 0.09, 0.31, 0.23, this.frame, "DescriptionArea")
            this.description[2] = TextArea.create(0.0275, - 0.16, 0.31, 0.22, this.frame, "DescriptionArea")
            this.description[3] = TextArea.create(0.0275, - 0.09, 0.31, 0.29, this.frame, "DescriptionArea")
            this.horizontal = Line.create(0.03725 + ITEM_SIZE/2, - 0.09, 0.05, 0.001, this.frame, "replaceabletextures\\teamcolor\\teamcolor08")
            this.horizontal.visible = false
            this.vertical = Line.create(0.13725 + ITEM_SIZE/2, - 0.08, 0.001, 0.01, this.frame, "replaceabletextures\\teamcolor\\teamcolor08")
            this.vertical.visible = false
            this.uses = Panel.create(0.0225, - 0.3155,  0.2675, 0.061, this.frame, "TransparentBackdrop", false)
            this.uses.OnScroll = Detail.onScrolled
            this.separator = Line.create(0, 0, this.uses.width, 0.001, this.uses.frame, "replaceabletextures\\teamcolor\\teamcolor08")
            this.usedText = Text.create(0.115, - 0.0025, 0.04, 0.012, 1, false, this.uses.frame, "|cffFFCC00 Used in|r", TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
            this.close = Button.create(0.26676, - 0.025, DETAIL_CLOSE_BUTTON_SIZE, DETAIL_CLOSE_BUTTON_SIZE, this.frame, true, false)
            this.close.texture = CLOSE_ICON
            this.close.tooltip.text = "Close"
            this.close.OnClick = Detail.onClicked
            this.left = Button.create(0.005, - 0.0025, DETAIL_SHIFT_BUTTON_SIZE, DETAIL_SHIFT_BUTTON_SIZE, this.uses.frame, true, false)
            this.left.texture = USED_LEFT
            this.left.tooltip.text = "Scroll Left"
            this.left.OnClick = Detail.onClicked
            this.right = Button.create(0.248, - 0.0025, DETAIL_SHIFT_BUTTON_SIZE, DETAIL_SHIFT_BUTTON_SIZE, this.uses.frame, true, false)
            this.right.texture = USED_RIGHT
            this.right.tooltip.text = "Scroll Right"
            this.right.OnClick = Detail.onClicked
            array[this.close] = { this }
            array[this.left] = { this }
            array[this.right] = { this }
            array[this.uses] = { this }

            for i = 0, bj_MAX_PLAYER_SLOTS do
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    local j = 0

                    this.main[i] = Slot.create(shop, 0, 0.13725, - 0.03, this.frame)
                    this.main[i].visible = GetLocalPlayer() == Player(i)
                    array[this.main[i]] = { this }

                    while j < 5 do
                        this.lines[i] = {}
                        this.components[i] = {}
                        this.components[i][j] = Slot.create(shop, 0, 0.03725 + 0.05*j, - 0.1, this.frame)
                        this.lines[i][j] = Line.create(this.components[i][j].width/2, 0.01, 0.001, 0.01, this.components[i][j].frame, "replaceabletextures\\teamcolor\\teamcolor08")
                        this.components[i][j].visible = false
                        array[this.components[i][j]] = { this }
                        j = j + 1
                    end

                    j = 0

                    while j < DETAIL_USED_COUNT do
                        this.button[i] = {}
                        this.button[i][j] = Button.create(0.0050000 + DETAIL_BUTTON_GAP*j, - 0.019500, DETAIL_BUTTON_SIZE, DETAIL_BUTTON_SIZE, this.uses.frame, false, false)
                        this.button[i][j].visible = false
                        this.button[i][j].tooltip.point = FRAMEPOINT_BOTTOMRIGHT
                        this.button[i][j].OnClick = Detail.onClicked
                        this.button[i][j].OnScroll = Detail.onScrolled
                        this.button[i][j].OnRightClick = Detail.onRightClicked
                        this.button[i][j].OnMiddleClick = Detail.onMiddleClicked
                        array[this.button[i][j]] = { this, j }
                        j = j + 1
                    end
                end
            end

            this.visible = false

            return this
        end

        function Detail:onScroll()
            if GetLocalPlayer() == GetTriggerPlayer() then
                self.shop:onScroll()
            end
        end

        function Detail.onClicked()
            local button = GetTriggerComponent()
            local player = GetTriggerPlayer()
            local this = array[button][1]

            if this then
                if button == this.close then
                    -- this.shop:detail(nil, player)
                elseif button == this.left or button == this.right then
                    -- this:shift(button == this.right, player)
                else
                    -- this.shop:detail(this.used[player][array[button][2]], player)
                end
            end
        end

        function Detail.onScrolled()
            local this = array[GetTriggerComponent()][1]

            if this then
                -- this:shift(BlzGetTriggerFrameValue() < 0, GetTriggerPlayer())
            end
        end

        function Detail.onMiddleClicked()
            local button = GetTriggerComponent()
            local player = GetTriggerPlayer()
            local this = array[button][1]

            if this then
                -- if this.shop.favorites:has(this.used[player][array[button][2]].id, player) then
                --     this.shop.favorites:remove(this.used[player][array[button][2]].id, player)
                -- else
                --     this.shop.favorites:add(this.used[player][array[button][2]].id, player)
                -- end
            end
        end

        function Detail.onRightClicked()
            local button = GetTriggerComponent()
            local player = GetTriggerPlayer()
            local id = GetPlayerId(player)
            local this = array[button][1]

            if this then
                -- if this.shop:buy(this.used[player][array[button][2]].id, player) then
                --     if GetLocalPlayer() == GetTriggerPlayer() then
                --         this.button[id][array[button][2]]:play(SPRITE_MODEL, SPRITE_SCALE, 0)
                --     end
                -- end
            end
        end
    end

    -- ------------------------------------------ Shop ----------------------------------------- --
    do
        Shop = Class(Panel)

        Shop.unit = {}
        Shop.group = {}

        local count = 0
        local itempool = {}

        Shop:property("visible", {
            get = function(self) return self.isVisible or true end,
            set = function(self, value)
                self.isVisible = value
                -- self.buyer.visible = value

                if not value then
                    -- self.buyer.index = 0
                else
                    -- if self.details.visible then
                    --     self.details:refresh(GetLocalPlayer())
                    -- end
                end

                BlzFrameSetVisible(self.frame, value)
            end
        })

        function Shop:destroy()
            self.edit:destroy()
            self.close:destroy()
            self.revert:destroy()
            self.breaker:destroy()
        end

        function Shop.create(id, aoe, tax)
            local this

            if not array[id] then
                this = Shop.allocate(X, Y, WIDTH, HEIGHT, BlzGetFrameByName("ConsoleUIBackdrop", 0), "EscMenuBackdrop", false)
                this.id = id
                this.aoe = aoe
                this.tax = tax
                this.first = nil
                this.last = nil
                this.head = nil
                this.tail = nil
                this.size = 0
                this.rows = ROWS
                this.columns = COLUMNS
                this.detailed = false
                this.scrolls = {}
                count = count + 1
                this.edit = EditBox.create(0.021, 0.02, EDIT_WIDTH, EDIT_HEIGHT, this.frame, "EscMenuEditBoxTemplate")
                this.edit.onText = Shop.OnSearch
                this.close = Button.create((WIDTH - 2*TOOLBAR_BUTTON_SIZE), 0.015000, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, this.frame, true, false)
                this.close.texture = CLOSE_ICON
                this.close.tooltip.text = "Close"
                this.close.OnClick = Shop.onClose
                this.breaker = Button.create((WIDTH - 2*TOOLBAR_BUTTON_SIZE - 0.0205), 0.015000, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, this.frame, true, false)
                this.breaker.texture = DISMANTLE_ICON
                this.breaker.tooltip.text = "Dismantle"
                this.breaker.OnClick = Shop.onDismantle
                this.revert = Button.create((WIDTH - 2*TOOLBAR_BUTTON_SIZE - 0.0410), 0.015000, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, this.frame, true, false)
                this.revert.texture = UNDO_ICON
                this.revert.tooltip.text = "Undo"
                this.revert.OnClick = Shop.onUndo
                array[id] = this
                array[this.edit] = this
                array[this.close] = this
                array[this.breaker] = this
                array[this.revert] = this

                for i = 0, bj_MAX_PLAYER_SLOTS do
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                        local player = Player(i)

                        array[player] = {}
                        array[player][id] = this
                        array[player][count] = id
                        this.scrolls[player] = {}
                    end
                end

                this.visible = false
            end

            return this
        end

        function Shop:onScroll()
            local player = GetTriggerPlayer()
            local direction = R2I(BlzGetTriggerFrameValue())

            if (self.scrolls[player][0] or 0) ~= direction then
                self.scrolls[player][0] = direction
                self.scrolls[player][1] = 0
            else
                self.scrolls[player][1] = (self.scrolls[player][1] or 0) + 1
            end

            if GetLocalPlayer() == GetTriggerPlayer() then
                if self.scrolls[player][1] == 1 and SCROLL_DELAY > 0 then
                    -- self:scroll(direction < 0)
                elseif SCROLL_DELAY <= 0 then
                    -- self:scroll(direction < 0)
                end
            end
        end

        function Shop.onExpire()
            local player = GetLocalPlayer()
            local this = array[GetUnitTypeId(Shop.unit[player])]

            if this then
                this.scrolls[player][1] = (this.scrolls[player][1] or 0) - 1

                if this.scrolls[player][1] > 0 then
                    -- this:scroll((this.scrolls[player][0] or 0) < 0)
                else
                    this.scrolls[player][1] = 0
                end
            end
        end

        function Shop.onPeriod()
            for i = 0, bj_MAX_PLAYER_SLOTS do
                local player = Player(i)
                local group = CreateGroup()
                local shop = Shop.unit[player]
                local this = array[shop and GetUnitTypeId(shop)]

                if this then
                    GroupClear(Shop.group[player])
                    GroupEnumUnitsInRange(group, GetUnitX(shop), GetUnitY(shop), this.aoe, nil)

                    local unit = FirstOfGroup(group)

                    while unit do
                        if ShopFilter(unit, Player(i), shop) then
                            GroupAddUnit(Shop.group[player], unit)
                        end

                        GroupRemoveUnit(group, unit)
                        unit = FirstOfGroup(group)
                    end

                    -- this.buyer:update(Shop.group[player], player)
                end

                DestroyGroup(group)
            end
        end

        function Shop.OnSearch()
            local this = array[GetTriggerEditBox()]

            if this and GetLocalPlayer() == GetTriggerPlayer() then
                -- this:filter(this.category.active, this.category.andLogic)
            end
        end

        function Shop.onClose()
            local player = GetTriggerPlayer()
            local this = array[GetTriggerComponent()]

            if this then
                Shop.unit[player] = nil

                if player == GetLocalPlayer() then
                    this.visible = false
                end

                -- Transaction.clear(this, player)
            end
        end

        function Shop.onDismantle()
            local player = GetTriggerPlayer()
            local this = array[GetTriggerComponent()]

            if this then
                if this.buyer.inventory.has(player) then
                    -- this:dismantle(this.buyer.inventory.item[player][this.buyer.inventory[player]], player, this.buyer.inventory[player])
                else
                    Sound.error(player)
                end
            end
        end

        function Shop.onUndo()
            local this = array[GetTriggerComponent()]

            if this then
                -- this:undo(GetTriggerPlayer())
            end
        end

        function Shop.onSelect()
            local player = GetTriggerPlayer()
            local this = array[GetUnitTypeId(GetTriggerUnit())]

            if this then
                if player == GetLocalPlayer() then
                    this.visible = GetTriggerEventId() == EVENT_PLAYER_UNIT_SELECTED
                end

                if GetTriggerEventId() == EVENT_PLAYER_UNIT_SELECTED then
                    Shop.unit[player] = GetTriggerUnit()
                    -- this.buyer.inventory:show(buyer[player])
                else
                    Shop.unit[player] = nil
                    -- Transaction.clear(this, player)
                end
            end
        end

        function Shop.onEsc()
            local player = GetTriggerPlayer()

            for i = 1, count do
                local this = array[player][array[player][i]]

                if this then
                    if player == GetLocalPlayer() then
                        this.visible = false
                    end

                    -- Transaction.clear(this, player)
                end
            end
        end

        function Shop.onInit()
            local trigger = CreateTrigger()

            for i = 0, bj_MAX_PLAYER_SLOTS do
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    Shop.group[Player(i)] = CreateGroup()
                    TriggerRegisterPlayerEventEndCinematic(trigger, Player(i))
                end
            end

            if SCROLL_DELAY > 0 then
                TimerStart(CreateTimer(), SCROLL_DELAY, true, Shop.onExpire)
            end

            TriggerAddCondition(trigger, Condition(Shop.onEsc))
            TimerStart(CreateTimer(), UPDATE_PERIOD, true, Shop.onPeriod)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, Shop.onSelect)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DESELECTED, Shop.onSelect)
        end
    end
end)