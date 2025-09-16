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

    -- Buyer Panel
    local BUYER_WIDTH               = WIDTH/2
    local BUYER_HEIGHT              = 0.08
    local BUYER_SIZE                = 0.032
    local BUYER_GAP                 = 0.04
    local BUYER_SHIFT_BUTTON_SIZE   = 0.012
    local BUYER_COUNT               = 8
    local BUYER_RIGHT               = "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedDown.blp"
    local BUYER_LEFT                = "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedUp.blp"

    -- Inventory Panel
    local INVENTORY_WIDTH           = 0.23780
    local INVENTORY_HEIGHT          = 0.03740
    local INVENTORY_SIZE            = 0.031
    local INVENTORY_GAP             = 0.04
    local INVENTORY_COUNT           = 6
    local INVENTORY_TEXTURE         = "Inventory.blp"

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

    -- Category and Favorite buttons
    local CATEGORY_COUNT            = 13
    local CATEGORY_SIZE             = 0.02750
    local CATEGORY_GAP              = 0.0

    -- ItemTable slots
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

    -- Selected item highlight
    local ITEM_HIGHLIGHT            = "neon_sprite.mdx"
    local HIGHLIGHT_SCALE           = 0.75
    local HIGHLIGHT_XOFFSET         = -0.0052
    local HIGHLIGHT_YOFFSET         = -0.0048

    -- Tagged item highlight
    local TAG_MODEL                 = "crystallid_sprite.mdx"
    local TAG_SCALE                 = 0.75
    local TAG_XOFFSET               = -0.0052
    local TAG_YOFFSET               = -0.0048

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

    -- -------------------------------------- Transaction -------------------------------------- --
    local Transaction = Class()

    do
        local counter = {}
        local transactions = {}

        function Transaction:rollback()
            if IsUnitInGroup(self.unit, self.shop.group[self.id]) then
                if self.type == "buy" then
                    if UnitHasItemOfType(self.unit, self.item.id) then
                        for i = 0, UnitInventorySize(self.unit) - 1 do
                            if GetItemTypeId(UnitItemInSlot(self.unit, i)) == self.item.id then
                                RemoveItem(UnitItemInSlot(self.unit, i))
                                break
                            end
                        end

                        for i = 0, self.index - 1 do
                            UnitAddItemById(self.unit, self.component[i].id)
                        end

                        SetPlayerState(self.player, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(self.player, PLAYER_STATE_RESOURCE_GOLD) + self.gold)
                        SetPlayerState(self.player, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(self.player, PLAYER_STATE_RESOURCE_LUMBER) + self.wood)
                        Sound.success(self.player)
                    else
                        Sound.error(self.player)
                    end
                elseif self.type == "sell" then
                    UnitAddItemById(self.unit, self.item.id)
                    SetPlayerState(self.player, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(self.player, PLAYER_STATE_RESOURCE_GOLD) - self.gold)
                    SetPlayerState(self.player, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(self.player, PLAYER_STATE_RESOURCE_LUMBER) - self.wood)
                    Sound.success(self.player)
                else
                    for i = 1, self.components do
                        for j = 0, UnitInventorySize(self.unit) - 1 do
                            if GetItemTypeId(UnitItemInSlot(self.unit, j)) == self.component[i].id then
                                RemoveItem(UnitItemInSlot(self.unit, j))
                                break
                            end
                        end
                    end

                    UnitAddItemById(self.unit, self.item.id)
                    Sound.success(self.player)
                end
            else
                Sound.error(self.player)
            end

            counter[self.shop][self.id] = counter[self.shop][self.id] - 1
            transactions[self.shop][self.id][counter[self.shop][self.id]] = nil
        end

        function Transaction:add(item)
            if item then
                self.component[self.index] = item
                self.index = self.index + 1
            end
        end

        function Transaction.last(shop, id)
            if counter[shop][id] > 0 then
                return transactions[shop][id][counter[shop][id] - 1]
            end

            return nil
        end

        function Transaction.count(shop, id)
            return counter[shop][id] or 0
        end

        function Transaction.clear(shop, id)
            counter[shop][id] = 0
            transactions[shop][id] = {}
        end

        function Transaction.create(shop, unit, item, gold, wood, transaction)
            local this = Transaction.allocate()

            this.shop = shop
            this.unit = unit
            this.item = item
            this.gold = gold
            this.wood = wood
            this.index = 0
            this.component = {}
            this.type = transaction
            this.player = GetOwningPlayer(unit)
            this.id = GetPlayerId(this.player)

            if not transactions[shop] then
                counter[shop] = {}
                transactions[shop] = {}
                counter[shop][this.id] = 0
                transactions[shop][this.id] = {}
            end

            transactions[shop][this.id][counter[shop][this.id]] = this
            counter[shop][this.id] = counter[shop][this.id] + 1

            return this
        end
    end

    -- --------------------------------------- Inventory --------------------------------------- --
    local Inventory = Class()

    do
        Inventory:property("visible", {
            get = function(self) return self.isVisible or true end,
            set = function(self, value)
                self.isVisible = value
                BlzFrameSetVisible(self.frame, value)
            end
        })

        function Inventory:destroy()
            for i = 0, bj_MAX_PLAYER_SLOTS do
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    for j = 0, INVENTORY_COUNT - 1 do
                        self.button[i][j]:destroy()
                    end
                end
            end

            BlzDestroyFrame(self.frame)
        end

        function Inventory:get(id)
            return self.selected[id]
        end

        function Inventory:has(id)
            return self.selected[id] ~= nil
        end

        function Inventory:move(point, relative, relativePoint)
            BlzFrameClearAllPoints(self.frame)
            BlzFrameSetPoint(self.frame, point, relative, relativePoint, 0, 0)
        end

        function Inventory:show(unit)
            local id = GetPlayerId(GetOwningPlayer(unit))

            if unit then
                for i = 0, INVENTORY_COUNT - 1 do
                    local item = UnitItemInSlot(unit, i)

                    if item then
                        self.item[id][i] = Item.get(GetItemTypeId(item))

                        if GetLocalPlayer() == GetOwningPlayer(unit) then
                            self.button[id][i].texture = self.item[id][i].icon
                            self.button[id][i].tooltip.text = self.item[id][i].tooltip
                            self.button[id][i].tooltip.name = self.item[id][i].name
                            self.button[id][i].tooltip.icon = self.item[id][i].icon
                            self.button[id][i].visible = true
                            self.button[id][i].highlighted = false
                        end
                    else
                        self.item[id][i] = nil

                        if GetLocalPlayer() == GetOwningPlayer(unit) then
                            self.button[id][i].visible = false
                            self.button[id][i].highlighted = false
                        end
                    end
                end
            else
                for i = 0, INVENTORY_COUNT - 1 do
                    self.item[id][i] = nil

                    if GetLocalPlayer() == GetOwningPlayer(unit) then
                        self.button[id][i].visible = false
                        self.button[id][i].highlighted = false
                    end
                end
            end
        end

        function Inventory:remove(id)
            self.selected[id] = nil
        end

        function Inventory:removeComponents(item, transaction)
            for i = 1, item.components do
                local component = Item.get(item.components[i])

                if UnitHasItemOfType(transaction.unit, component.id) then
                    for j = 0, UnitInventorySize(transaction.unit) - 1 do
                        if GetItemTypeId(UnitItemInSlot(transaction.unit, j) ) == component.id then
                            RemoveItem(UnitItemInSlot(transaction.unit, j) )
                            break
                        end
                    end

                    transaction:add(component)
                else
                    self:removeComponents(component, transaction)
                end
            end
        end

        function Inventory.create(shop, buyer)
            local this = Inventory.allocate()

            this.shop = shop
            this.item = {}
            this.button = {}
            this.selected = {}
            this.isVisible = false
            this.frame = BlzCreateFrameByType("BACKDROP", "", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)

            BlzFrameSetPoint(this.frame, FRAMEPOINT_TOPLEFT, buyer.frame, FRAMEPOINT_TOPLEFT, 0, 0)
            BlzFrameSetSize(this.frame, INVENTORY_WIDTH, INVENTORY_HEIGHT)
            BlzFrameSetTexture(this.frame, INVENTORY_TEXTURE, 0, false)

            for i = 0, bj_MAX_PLAYER_SLOTS do
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    this.item[i] = {}
                    this.button[i] = {}

                    for j = 0, INVENTORY_COUNT - 1 do
                        this.button[i][j] = Button.create(0.0033700 + INVENTORY_GAP*j, - 0.0037500, INVENTORY_SIZE, INVENTORY_SIZE, this.frame, false, false)
                        this.button[i][j].tooltip.point = FRAMEPOINT_BOTTOM
                        this.button[i][j].OnClick = Inventory.onClick
                        this.button[i][j].OnDoubleClick = Inventory.onDoubleClick
                        this.button[i][j].OnRightClick = Inventory.onRightClick
                        this.button[i][j].visible = false
                        array[this.button[i][j]] = { this, j }
                    end
                end
            end

            return this
        end

        function Inventory.onClick()
            local player = GetTriggerPlayer()
            local button = GetTriggerComponent()
            local id = GetPlayerId(player)
            local this = array[button][1]
            local i = array[button][2]

            if this then
                if GetLocalPlayer() == player and this.selected[id] then
                    this.button[id][this.selected[id]].highlighted = false
                    this.button[id][i].highlighted = true
                end

                this.selected[id] = i
            end
        end

        function Inventory.onDoubleClick()
            local player = GetTriggerPlayer()
            local button = GetTriggerComponent()
            local id = GetPlayerId(player)
            local this = array[button][1]
            local i = array[button][2]

            if this then
                if this.shop:sell(this.item[id][i], player, i) then
                    this:show(this.shop.buyer:get(id))
                end
            end
        end

        function Inventory.onRightClick()
            local player = GetTriggerPlayer()
            local button = GetTriggerComponent()
            local id = GetPlayerId(player)
            local this = array[button][1]
            local i = array[button][2]

            if this then
                if this.shop:sell(this.item[id][i], player, i) then
                    this:show(this.shop.buyer:get(id))
                end
            end
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
            self.shop:detail(self.item, GetTriggerPlayer())
        end

        function Slot:onMiddleClick()
            if self.shop.favorites:has(self.item.id, GetTriggerPlayer()) then
                self.shop.favorites:remove(self.item, GetTriggerPlayer())
            else
                self.shop.favorites:add(self.item, GetTriggerPlayer())
            end
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
                            self.button[id][j].available = self.shop:has(self.used[id][j].id)
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
                            self.button[id][j].available = self.shop:has(item.id)
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
                            self.button[id][j].available = self.shop:has(self.used[id][j].id)
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
                            self.button[id][j].available = self.shop:has(item.id)
                            self.button[id][j].visible = true
                        end
                    end
                end
            end
        end

        function Detail:showUsed(player)
            local id = GetPlayerId(player)

            for i = 0, DETAIL_USED_COUNT do
                local item = Item.get(self.item[id].relation[i])

                if item and i < DETAIL_USED_COUNT then
                    self.used[id][i] = item

                    if player == GetLocalPlayer() then
                        self.button[id][self.count[id]].texture = item.icon
                        self.button[id][self.count[id]].tooltip.text = item.tooltip
                        self.button[id][self.count[id]].tooltip.name = item.name
                        self.button[id][self.count[id]].tooltip.icon = item.icon
                        self.button[id][self.count[id]].available = self.shop:has(item.id)
                        self.button[id][self.count[id]].visible = true
                    end

                    self.count[id] = self.count[id] + 1
                else
                    self.button[id][i].visible = false
                end
            end
        end

        function Detail:refresh(player)
            local id = GetPlayerId(player)

            if self.visible and self.item[id] then
                self:show(self.item[id], player)
            end
        end

        function Detail:show(item, player)
            local counter = {}
            local id = GetPlayerId(player)

            if item then
                local cost = item.cost
                local wood = item.wood
                self.main[id].item = item
                self.main[id].texture = item.icon
                self.main[id].tooltip.text = item.tooltip
                self.main[id].tooltip.name = item.name
                self.main[id].tooltip.icon = item.icon
                self.main[id].available = self.shop:has(item.id)

                if item ~= self.item[id] then
                    self.item[id] = item
                    self.count[id] = 0

                    self:showUsed(player)
                end

                if player == GetLocalPlayer() then
                    self.visible = true
                    self.uses.visible = self.count[id] > 0
                    self.vertical.visible = item.components > 0
                    self.horizontal.visible = item.components > 1
                    self.description[0].text = item.tooltip
                    self.description[1].text = item.tooltip
                    self.description[2].text = item.tooltip
                    self.description[3].text = item.tooltip
                    self.description[0].visible = self.uses.visible and item.components > 0
                    self.description[1].visible = self.uses.visible and item.components == 0
                    self.description[2].visible = not self.uses.visible and item.components > 0
                    self.description[3].visible = not self.uses.visible and item.components == 0
                    self.main[id].lumber.visible = item.wood > 0
                    self.main[id].cost.text = "|cffFFCC00" .. I2S(item:cost(self.shop.buyer:get(id), false)) .. "|r"
                    self.main[id].wood.text = "|cff238b3d" .. I2S(item:cost(self.shop.buyer:get(id), true)) .. "|r"
                end

                if item.components > 0 then
                    for i = 0, 5 do
                        local component = Item.get(item.components[i + 1])

                        if component then
                            local slot = self.components[id][i]

                            if player == GetLocalPlayer() then
                                if item.components == 1 then
                                    slot.x = 0.13725
                                elseif item.components == 2 then
                                    slot.x = 0.08725 + 0.1*i
                                elseif item.components == 3 then
                                    slot.x = 0.03725 + 0.1*i
                                elseif item.components == 4 then
                                    slot.x = 0.03725 + 0.06525*i
                                else
                                    slot.x = 0.03725 + 0.05*i
                                end

                                slot.visible = true
                            end

                            slot.item = component
                            slot.texture = component.icon
                            slot.tooltip.text = component.tooltip
                            slot.tooltip.name = component.name
                            slot.tooltip.icon = component.icon
                            slot.available = self.shop:has(component.id)
                            slot.lumber.visible = component.wood > 0
                            slot.cost.text = "|cffFFCC00" .. I2S(component:cost(self.shop.buyer:get(id), false)) .. "|r"
                            slot.wood.text = "|cff238b3d" .. I2S(component:cost(self.shop.buyer:get(id), true)) .. "|r"

                            if self.shop.buyer:get(id) then
                                if UnitHasItemOfType(self.shop.buyer:get(id), component.id) then
                                    if UnitCountItemOfType(self.shop.buyer:get(id), component.id) >= item:count(component.id) then
                                        slot.checked = true
                                    else
                                        counter[component.id] = (counter[component.id] or 0) + 1
                                        slot.checked = counter[component.id] <= UnitCountItemOfType(self.shop.buyer:get(id), component.id)
                                    end
                                else
                                    slot.checked = false
                                end
                            else
                                slot.checked = false
                            end

                            if slot.checked then
                                cost = cost - component.gold
                                wood = wood - component.wood
                            end
                        else
                            if player == GetLocalPlayer() then
                                self.components[id][i].visible = false
                            end
                        end
                    end

                    if player == GetLocalPlayer() then
                        self.horizontal.width = 0.2
                        self.horizontal.x = self.components[id][0].x + ITEM_SIZE/2

                        if item.components == 2 then
                            self.horizontal.width = 0.1
                        elseif item.components == 4 then
                            self.horizontal.width = 0.19575
                        end
                    end
                else
                    for i = 0, 5 do
                        if player == GetLocalPlayer() then
                            self.components[id][i].visible = false
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
            this.lines = {}
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

                    this.used[i] = {}
                    this.count[i] = 0
                    this.lines[i] = {}
                    this.components[i] = {}
                    this.main[i] = Slot.create(shop, nil, 0.13725, - 0.03, this.frame)
                    this.main[i].visible = GetLocalPlayer() == Player(i)
                    array[this.main[i]] = { this }

                    while j < 5 do
                        this.components[i][j] = Slot.create(shop, nil, 0.03725 + 0.05*j, - 0.1, this.frame)
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
            local id = GetPlayerId(player)
            local this = array[button][1]

            if this then
                if button == this.close then
                    this.shop:detail(nil, player)
                elseif button == this.left or button == this.right then
                    this:shift(button == this.right, player)
                else
                    this.shop:detail(this.used[id][array[button][2]], player)
                end
            end
        end

        function Detail.onScrolled()
            local this = array[GetTriggerComponent()][1]

            if this then
                this:shift(BlzGetTriggerFrameValue() < 0, GetTriggerPlayer())
            end
        end

        function Detail.onMiddleClicked()
            local button = GetTriggerComponent()
            local player = GetTriggerPlayer()
            local id = GetPlayerId(player)
            local this = array[button][1]

            if this then
                if this.shop.favorites:has(this.used[id][array[button][2]].id, player) then
                    this.shop.favorites:remove(this.used[id][array[button][2]].id, player)
                else
                    this.shop.favorites:add(this.used[id][array[button][2]].id, player)
                end
            end
        end

        function Detail.onRightClicked()
            local button = GetTriggerComponent()
            local player = GetTriggerPlayer()
            local id = GetPlayerId(player)
            local this = array[button][1]

            if this then
                if this.shop:buy(this.used[id][array[button][2]].id, player) then
                    if GetLocalPlayer() == GetTriggerPlayer() then
                        this.button[id][array[button][2]]:play(SPRITE_MODEL, SPRITE_SCALE, 0)
                    end
                end
            end
        end
    end

    -- ----------------------------------------- Buyer ----------------------------------------- --
    local Buyer = Class(Panel)

    do
        local current = {}

        Buyer:property("visible", {
            get = function(self) return self.isVisible or true end,
            set = function(self, value)
                self.isVisible = value
                self.inventory.visible = value

                if value then
                    local id = GetPlayerId(GetLocalPlayer())

                    for i = 0, BUYER_COUNT - 1 do
                        if self.unit[id][i] == self.selected[id] then
                            self.inventory:move(FRAMEPOINT_TOP, self.button[id][i].frame, FRAMEPOINT_BOTTOM)
                            break
                        end
                    end
                end

                BlzFrameSetVisible(self.frame, value)
            end
        })

        function Buyer:get(id)
            return self.selected[id]
        end

        function Buyer:destroy()
            for i = 0, bj_MAX_PLAYER_SLOTS do
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    for j = 0, BUYER_COUNT - 1 do
                        self.button[i][j]:destroy()
                    end
                end
            end

            self.left:destroy()
            self.right:destroy()
            self.inventory:destroy()
        end

        function Buyer:shift(left, player)
            local flag = false
            local id = GetPlayerId(player)

            if left then
                if ((self.index[id] or 0) + 1 + BUYER_COUNT) <= (self.size[id] or 0) and (self.size[id] or 0) > 0 then
                    local i  = 0

                    self.index[id] = (self.index[id] or 0) + 1

                    while i < BUYER_COUNT - 1 do
                        self.unit[id][i] = self.unit[id][i + 1]

                        if player == GetLocalPlayer() then
                            self.button[id][i].texture = self.button[id][i + 1].texture
                            self.button[id][i].tooltip.text = self.button[id][i + 1].tooltip.text
                            self.button[id][i].highlighted = self.selected[id] == self.unit[id][i]
                            self.button[id][i].visible = true

                            if self.button[id][i].highlighted then
                                flag = true
                                self.inventory:move(FRAMEPOINT_TOP, self.button[id][i].frame, FRAMEPOINT_BOTTOM)
                            end
                        end

                        i = i + 1
                    end

                    local unit = BlzGroupUnitAt(self.shop.group[id], self.index[id] + BUYER_COUNT)

                    if unit then
                        self.unit[id][BUYER_COUNT - 1] = unit

                        if player == GetLocalPlayer() then
                            self.button[id][BUYER_COUNT - 1].texture = BlzGetAbilityIcon(GetUnitTypeId(unit))
                            self.button[id][BUYER_COUNT - 1].tooltip.text = GetUnitName(unit)
                            self.button[id][BUYER_COUNT - 1].highlighted = self.selected[id] == unit
                            self.button[id][BUYER_COUNT - 1].visible = true

                            if self.button[id][BUYER_COUNT - 1].highlighted then
                                flag = true
                                self.inventory:move(FRAMEPOINT_TOP, self.button[id][BUYER_COUNT - 1].frame, FRAMEPOINT_BOTTOM)
                            end
                        end
                    end

                    if player == GetLocalPlayer() then
                        self.inventory.visible = flag
                    end
                end
            else
                if (self.index[id] or 0) - 1 >= 0 and (self.size[id] or 0) > 0 then
                    local i = BUYER_COUNT - 1

                    self.index[id] = (self.index[id] or 0) - 1

                    while i > 0 do
                        self.unit[id][i] = self.unit[id][i - 1]

                        if player == GetLocalPlayer() then
                            self.button[id][i].texture = self.button[id][i - 1].texture
                            self.button[id][i].tooltip.text = self.button[id][i - 1].tooltip.text
                            self.button[id][i].highlighted = self.selected[id] == self.unit[id][i]
                            self.button[id][i].visible = true

                            if self.button[id][i].highlighted then
                                flag = true
                                self.inventory:move(FRAMEPOINT_TOP, self.button[id][i].frame, FRAMEPOINT_BOTTOM)
                            end
                        end

                        i = i - 1
                    end

                    local unit = BlzGroupUnitAt(self.shop.group[id], self.index[id])

                    if unit then
                        self.unit[id][0] = unit

                        if player == GetLocalPlayer() then
                            self.button[id][0].texture = BlzGetAbilityIcon(GetUnitTypeId(unit))
                            self.button[id][0].tooltip.text = GetUnitName(unit)
                            self.button[id][0].highlighted = self.selected[id] == unit
                            self.button[id][0].visible = true

                            if self.button[id][0].highlighted then
                                flag = true
                                self.inventory:move(FRAMEPOINT_TOP, self.button[id][0].frame, FRAMEPOINT_BOTTOM)
                            end
                        end
                    end

                    if player == GetLocalPlayer() then
                        self.inventory.visible = flag
                    end
                end
            end
        end

        function Buyer:update(group, id)
            self.size[id] = BlzGroupGetSize(group)

            if self.size[id] > 0 then
                if ((self.index[id] or 0) + BUYER_COUNT) > self.size[id] then
                    self.index[id] = 0
                end

                if not IsUnitInGroup(self.selected[id], group) then
                    self.index[id] = 0
                    current[self.selected[id]] = nil
                    self.selected[id] = FirstOfGroup(group)
                    current[self.selected[id]] = self
                    IssueNeutralTargetOrder(Player(id), self.shop.unit[id], "smart", self.selected[id])
                    self.inventory:show(self.selected[id])

                    if Player(id) == GetLocalPlayer() then
                        self.inventory:move(FRAMEPOINT_TOP, self.button[id][0].frame, FRAMEPOINT_BOTTOM)
                        self.shop.details:refresh(Player(id))
                    end
                end

                local j = self.index[id]

                for i = 1, BUYER_COUNT - 1 do
                    if j >= self.size[id] then
                        self.unit[id][i] = nil

                        if Player(id) == GetLocalPlayer() then
                            self.button[id][i].visible = false
                        end
                    else
                        local unit = BlzGroupUnitAt(group, j)

                        self.unit[id][i] = unit

                        if self.selected[id] == unit then
                            self.last[id] = self.button[id][i]
                        end

                        if Player(id) == GetLocalPlayer() then
                            self.button[id][i].texture = BlzGetAbilityIcon(GetUnitTypeId(unit))
                            self.button[id][i].tooltip.text = GetUnitName(unit)
                            self.button[id][i].highlighted = self.selected[id] == unit
                            self.button[id][i].visible = true

                            if self.button[id][i].highlighted then
                                self.inventory.visible = true
                                self.inventory:move(FRAMEPOINT_TOP, self.button[id][i].frame, FRAMEPOINT_BOTTOM)
                            end
                        end

                        j = j + 1
                    end
                end
            else
                current[self.selected[id]] = nil
                self.index[id] = 0
                self.selected[id] = nil

                if Player(id) == GetLocalPlayer() then
                    self.inventory.visible = false

                    for i = 0, BUYER_COUNT - 1 do
                        self.unit[id][i] = nil
                        self.button[id][i].visible = false
                        self.button[id][i].highlighted = false
                    end

                    self.shop.details:refresh(Player(id))
                end
            end
        end

        function Buyer.create(shop)
            local this = Buyer.allocate(WIDTH/2 - BUYER_WIDTH/2, HEIGHT/2 - 0.015, BUYER_WIDTH, BUYER_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "EscMenuBackdrop", false)

            this.shop = shop
            this.last = {}
            this.size = {}
            this.index = {}
            this.unit = {}
            this.button = {}
            this.selected = {}
            this.inventory = Inventory.create(shop, this)
            this.left = Button.create(0.027500, - 0.032500, BUYER_SHIFT_BUTTON_SIZE, BUYER_SHIFT_BUTTON_SIZE, this.frame, true, false)
            this.left.texture = BUYER_LEFT
            this.left.tooltip.text = "Scroll Left"
            this.left.OnClick = Buyer.onClicked
            this.right = Button.create(0.36350, - 0.032500, BUYER_SHIFT_BUTTON_SIZE, BUYER_SHIFT_BUTTON_SIZE, this.frame, true, false)
            this.right.texture = BUYER_RIGHT
            this.right.tooltip.text = "Scroll Right"
            this.right.OnClick = Buyer.onClicked
            array[this.left] = { this }
            array[this.right] = { this }

            for i = 0, bj_MAX_PLAYER_SLOTS do
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    this.unit[i] = {}
                    this.button[i] = {}

                    for j = 0, BUYER_COUNT - 1 do
                        this.button[i][j] = Button.create(0.045000 + BUYER_GAP*j, - 0.023000, BUYER_SIZE, BUYER_SIZE, this.frame, true, false)
                        this.button[i][j].visible = false
                        this.button[i][j].OnClick = Buyer.onClicked
                        this.button[i][j].OnScroll = Buyer.onScrolled
                        array[this.button[i][j]] = { this, j }

                    end
                end
            end

            this.visible = false

            return this
        end

        function Buyer:onScroll()
            self:shift(BlzGetTriggerFrameValue() < 0, GetTriggerPlayer())
        end

        function Buyer.onScrolled()
            local this = array[GetTriggerComponent()][1]

            if this then
                this:shift(BlzGetTriggerFrameValue() < 0, GetTriggerPlayer())
            end
        end

        function Buyer.onClicked()
            local button = GetTriggerComponent()
            local player = GetTriggerPlayer()
            local id = GetPlayerId(player)
            local this = array[button][1]

            if this then
                if button == this.left then
                    this:shift(false, player)
                elseif button == this.right then
                    this:shift(true, player)
                else
                    current[this.selected[id]] = nil
                    this.selected[id] = this.unit[id][array[button][2]]
                    current[this.selected[id]] = this
                    IssueNeutralTargetOrder(player, this.shop.unit[id], "smart", this.selected[id])
                    this.inventory:show(this.selected[id])
                    this.inventory:remove(id)

                    if player == GetLocalPlayer() then
                        this.last[id].highlighted = false
                        this.button[id][array[button][2]].highlighted = true
                        this.last[id] = this.button[id][array[button][2]]

                        this.inventory:move(FRAMEPOINT_TOP, this.button[id][array[button][2]].frame, FRAMEPOINT_BOTTOM)
                        this.shop.details:refresh(player)
                    end
                end
            end
        end

        function Buyer.onPickup()
            local unit = GetManipulatingUnit()
            local id = GetPlayerId(GetOwningPlayer(unit))
            local this = current[unit]

            if this then
                if this.shop.unit[id] then
                    if this.selected[id] == unit and IsUnitInRange(unit, this.shop.unit[id], this.shop.aoe) then
                        this.inventory:show(unit)
                        this.shop.details:refresh(GetOwningPlayer(unit))
                    end
                end
            end
        end

        function Buyer.onDrop()
            local unit = GetManipulatingUnit()
            local id = GetPlayerId(GetOwningPlayer(unit))
            local this = current[unit]

            if this then
                if this.shop.unit[id] then
                    if this.selected[id] == unit and IsUnitInRange(unit, this.shop.unit[id], this.shop.aoe) then
                        this.shop.details:refresh(GetOwningPlayer(unit))
                    end
                end
            end
        end

        function Buyer.onInit()
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, Buyer.onPickup)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, Buyer.onDrop)
        end
    end

    -- --------------------------------------- Favorites --------------------------------------- --
    local Favorites = Class(Panel)

    do
        function Favorites:destroy()
            for i = 0, bj_MAX_PLAYER_SLOTS do
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    for j = 0, CATEGORY_COUNT - 1 do
                        self.button[i][j]:destroy()
                    end
                end
            end

            self.clear:destroy()
        end

        function Favorites:has(id, player)
            local pid = GetPlayerId(player)

            for i = 0, self.count[pid] do
                if self.item[pid][i] and self.item[pid][i].id == id then
                    return true
                end
            end

            return false
        end

        function Favorites:reset(player)
            local id = GetPlayerId(player)

            while self.count[id] > -1 do
                if player == GetLocalPlayer() then
                    self.button[id][self.count[id]].visible = false
                    array[self.shop][self.item[id][self.count[id]].id]:tag(nil, 0, 0, 0)
                end

                self.count[id] = self.count[id] - 1
            end
        end

        function Favorites:remove(item, player)
            local id = GetPlayerId(player)

            if self:has(item.id, player) then
                for i = 0, self.count[id] do
                    if self.item[id][i] and self.item[id][i].id == item.id then
                        local j = i

                        if player == GetLocalPlayer() then
                            array[self.shop][item.id]:tag(nil, 0, 0, 0)
                        end

                        while j < self.count[id] do
                            self.item[id][j] = self.item[id][j + 1]

                            if player == GetLocalPlayer() then
                                self.button[id][j].texture = self.item[id][j].icon
                                self.button[id][j].tooltip.text = self.item[id][j].tooltip
                                self.button[id][j].tooltip.name = self.item[id][j].name
                                self.button[id][j].tooltip.icon = self.item[id][j].icon
                            end

                            j = j + 1
                        end

                        if player == GetLocalPlayer() then
                            self.button[id][self.count[id]].visible = false
                        end

                        self.count[id] = self.count[id] - 1
                        break
                    end
                end
            end
        end

        function Favorites:add(item, player)
            local id = GetPlayerId(player)

            if self.count[id] < (CATEGORY_COUNT - 1) then
                if not self:has(item.id, player) then
                    self.count[id] = self.count[id] + 1
                    self.item[id][self.count[id]] = item

                    if player == GetLocalPlayer() then
                        self.button[id][self.count[id]].texture = item.icon
                        self.button[id][self.count[id]].tooltip.text = item.tooltip
                        self.button[id][self.count[id]].tooltip.name = item.name
                        self.button[id][self.count[id]].tooltip.icon = item.icon
                        self.button[id][self.count[id]].visible = true
                        array[self.shop][item.id]:tag(TAG_MODEL, TAG_SCALE, TAG_XOFFSET, TAG_YOFFSET)
                    end
                end
            end
        end

        function Favorites.create(shop)
            local this = Favorites.allocate(X + (WIDTH - 0.027), 0, SIDE_WIDTH, SIDE_HEIGHT, shop.frame, "EscMenuBackdrop", false)

            this.shop = shop
            this.count = {}
            this.item = {}
            this.button = {}
            this.clear = Button.create(0.027, 0.015, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, this.frame, true, false)
            this.clear.texture = CLEAR_ICON
            this.clear.tooltip.text = "Clear"
            this.clear.OnClick = Favorites.onClear
            array[this.clear] = { this }

            for i = 0, bj_MAX_PLAYER_SLOTS do
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    this.count[i] = -1
                    this.button[i] = {}

                    for j = 0, CATEGORY_COUNT - 1 do
                        this.button[i][j] = Button.create(0.023750, - (0.021500 + CATEGORY_SIZE*j + CATEGORY_GAP), CATEGORY_SIZE, CATEGORY_SIZE, this.frame, false, false)
                        this.button[i][j].visible = false
                        this.button[i][j].tooltip.point = FRAMEPOINT_TOPRIGHT
                        this.button[i][j].OnClick = Favorites.onClicked
                        this.button[i][j].OnRightClick = Favorites.onRightClicked
                        this.button[i][j].OnMiddleClick = Favorites.onMiddleClicked
                        this.button[i][j].OnDoubleClick = Favorites.onDoubleClicked
                        array[this.button[i][j]] = { this, j }

                        if j > 6 then
                            this.button[i][j].tooltip.point = FRAMEPOINT_BOTTOMRIGHT
                        end
                    end
                end
            end

            return this
        end

        function Favorites.onClear()
            local this = array[GetTriggerComponent()][1]

            if this then
                this:reset(GetTriggerPlayer())
            end
        end

        function Favorites.onClicked()
            local this = array[GetTriggerComponent()][1]

            if this then
                this.shop:detail(this.item[GetPlayerId(GetTriggerPlayer())][array[GetTriggerComponent()][2]], GetTriggerPlayer())
            end
        end

        function Favorites.onMiddleClicked()
            local this = array[GetTriggerComponent()][1]

            if this then
                this:remove(this.item[GetPlayerId(GetTriggerPlayer())][array[GetTriggerComponent()][2]], GetTriggerPlayer())
            end
        end

        function Favorites.onDoubleClicked()
            local this = array[GetTriggerComponent()][1]

            if this then
                if this.shop:buy(this.item[GetPlayerId(GetTriggerPlayer())][array[GetTriggerComponent()][2]].id, GetTriggerPlayer()) then
                    if GetLocalPlayer() == GetTriggerPlayer() then
                        this.button[GetPlayerId(GetTriggerPlayer())][array[GetTriggerComponent()][2]]:play(SPRITE_MODEL, SPRITE_SCALE, 0)
                    end
                end
            end
        end

        function Favorites.onRightClicked()
            local this = array[GetTriggerComponent()][1]

            if this then
                if this.shop:buy(this.item[GetPlayerId(GetTriggerPlayer())][array[GetTriggerComponent()][2]].id, GetTriggerPlayer()) then
                    if GetLocalPlayer() == GetTriggerPlayer() then
                        this.button[GetPlayerId(GetTriggerPlayer())][array[GetTriggerComponent()][2]]:play(SPRITE_MODEL, SPRITE_SCALE, 0)
                    end
                end
            end
        end
    end

    -- ---------------------------------------- Category --------------------------------------- --
    local Category = Class(Panel)

    do
        function Category:destroy()
            for i = 0, CATEGORY_COUNT - 1 do
                if self.button[i] then
                    self.button[i]:destroy()
                end
            end

            self.clear:destroy()
            self.logic:destroy()
        end

        function Category:reset()
            self.active = 0

            for i = 0, CATEGORY_COUNT - 1 do
                self.button[i].active = false
            end

            self.shop:filter(self.active, self.andLogic)
        end

        function Category:add(icon, description)
            if self.count < CATEGORY_COUNT then
                self.count = self.count + 1
                self.value[self.count] = R2I(Pow(2, self.count))
                self.button[self.count] = Button.create(0.023750, - (0.021500 + CATEGORY_SIZE*self.count + CATEGORY_GAP), CATEGORY_SIZE, CATEGORY_SIZE, self.frame, true, false)
                self.button[self.count].texture = icon
                self.button[self.count].active = false
                self.button[self.count].tooltip.text = description
                self.button[self.count].OnClick = Category.onClicked
                array[self.button[self.count]] = { self, self.count }

                return self.value[self.count]
            else
                print("Maximum number of categories reached.")
            end

            return 0
        end

        function Category.create(shop)
            local this = Category.allocate(X - 0.048, 0, SIDE_WIDTH, SIDE_HEIGHT, shop.frame, "EscMenuBackdrop", false)

            this.count = -1
            this.active = 0
            this.value = {}
            this.button = {}
            this.shop = shop
            this.andLogic = true
            this.clear = Button.create(0.028, 0.015, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, this.frame, true, false)
            this.clear.texture = CLEAR_ICON
            this.clear.tooltip.text = "Clear"
            this.clear.OnClick = Category.onClear
            this.logic = Button.create(X + 0.048, 0.015, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, this.frame, true, false)
            this.logic.texture = LOGIC_ICON
            this.logic.active = false
            this.logic.tooltip.text = "AND"
            this.logic.OnClick = Category.onLogic
            array[this.clear] = { this }
            array[this.logic] = { this }

            return this
        end

        function Category.onClicked()
            local category = GetTriggerComponent()
            local this = array[category][1]

            if this and GetLocalPlayer() == GetTriggerPlayer() then
                category.active = not category.active

                if category.active then
                    this.active = this.active + this.value[array[category][2]]
                else
                    this.active = this.active - this.value[array[category][2]]
                end

                this.shop:filter(this.active, this.andLogic)
            end
        end

        function Category.onClear()
            local this = array[GetTriggerComponent()][1]

            if this and GetLocalPlayer() == GetTriggerPlayer() then
                this:reset()
            end
        end

        function Category.onLogic()
            local this = array[GetTriggerComponent()][1]

            if this and GetLocalPlayer() == GetTriggerPlayer() then
                this.logic.active = not this.logic.active
                this.andLogic = not this.andLogic

                if this.andLogic then
                    this.logic.tooltip.text = "AND"
                else
                    this.logic.tooltip.text = "OR"
                end

                this.shop:filter(this.active, this.andLogic)
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
                self.buyer.visible = value

                if not value then
                    self.buyer.index = 0
                else
                    if self.details.visible then
                        self.details:refresh(GetLocalPlayer())
                    end
                end

                BlzFrameSetVisible(self.frame, value)
            end
        })

        function Shop:destroy()
            local slot = itempool[self][0]

            for i = 0, bj_MAX_PLAYER_SLOTS do
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    Transaction.clear(self, i)
                end
            end

            while slot do
                slot:destroy()
                slot = slot.next
            end

            self.edit:destroy()
            self.close:destroy()
            self.revert:destroy()
            self.breaker:destroy()
            self.category:destroy()
            self.favorites:destroy()
            self.details:destroy()
            self.buyer:destroy()
        end

        function Shop:canBuy(item, player)
            local flag = true
            local i = 1

            if item and self:has(item.id) and self.buyer.get(GetPlayerId(player)) then
                if item.components > 0 then
                    while i <= item.components and flag do
                        flag = self:canBuy(Item.get(item.component[i]), player)

                        i = i + 1
                    end
                end

                return flag
            end

            return false
        end

        function Shop:buy(item, player)
            local id = GetPlayerId(player)
            local cost = item:cost(self.buyer.get(id), false)
            local wood = item:cost(self.buyer.get(id), true)

            if self:canBuy(item, player) and cost <= GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD) and wood <= GetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER) then
                local new = CreateItem(item.id, GetUnitX(self.buyer.get(id)), GetUnitY(self.buyer.get(id)))

                self.buyer.inventory:removeComponents(item, Transaction.create(self, self.buyer.get(id), item, cost, wood, "buy"))

                if not UnitAddItem(self.buyer.get(id), new) then
                    IssueTargetItemOrder(self.buyer.get(id), "smart", new)
                end

                self.buyer.inventory:show(self.buyer.get(id))
                self.details:refresh(player)
                SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD) - cost)
                SetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER, GetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER) - wood)
                Sound.success(player)

                return true
            else
                if cost > GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD) then
                    Sound.gold(player)
                elseif wood > GetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER) then
                    Sound.wood(player)
                else
                    Sound.error(player)
                end

                return false
            end

            return false
        end

        function Shop:sell(item, player, slot)
            local sold = false
            local id = GetPlayerId(player)

            if item and self.buyer.get(id) then
                local charges = GetItemCharges(UnitItemInSlot(self.buyer.get(id), slot))

                if charges == 0 then
                    charges = 1
                end

                local gold = GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD)
                local lumber = GetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER)
                local cost = R2I(R2I(item.gold / item.charges) * charges * self.tax)
                local wood = R2I(R2I(item.wood / item.charges) * charges * self.tax)

                if GetItemTypeId(UnitItemInSlot(self.buyer.get(id), slot)) == item.id then
                    sold = true

                    Transaction.create(self, self.buyer.get(id), item, cost, wood, "sell")
                    RemoveItem(UnitItemInSlot(self.buyer.get(id), slot))
                    SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, gold + cost)
                    SetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER, lumber + wood)
                    self.buyer.inventory:show(self.buyer.get(id))
                    self.details:refresh(player)
                end

                Sound.success(player)
            else
                Sound.error(player)
            end

            return sold
        end

        function Shop:dismantle(item, player, slot)
            local slots = 0
            local id = GetPlayerId(player)

            if item and self.buyer.get(id) then
                if item.components > 0 then
                    for i = 0, UnitInventorySize(self.buyer.get(id)) -1 do
                        if UnitItemInSlot(self.buyer.get(id), i) ~= nil then
                            slots = slots + 1
                        end
                    end

                    if (slots + 1) >= item.components then
                        Transaction.create(self, self.buyer.get(id), item, 0, 0, "dismantle")
                        RemoveItem(UnitItemInSlot(self.buyer.get(id), slot))

                        for i = 1, item.components do
                            UnitAddItemById(self.buyer.get(id), Item.get(item.component[i]).id)
                        end

                        Sound.success(player)
                        self.buyer.inventory:show(self.buyer.get(id))
                        self.details:refresh(player)
                    else
                        Sound.error(player)
                    end
                else
                    Sound.error(player)
                end
            else
                Sound.error(player)
            end
        end

        function Shop:undo(player)
            local id = GetPlayerId(player)

            if Transaction.count(self, id) > 0 then
                Transaction.last(self, id):rollback()
                self.buyer.inventory:show(self.buyer.get(id))
                self.details:refresh(player)
            else
                Sound.error(player)
            end
        end

        function Shop:scroll(down)
            local slot = self.first

            if (down and self.tail ~= self.last) or (not down and self.head ~= self.first) then
                while slot do
                    if down then
                        slot:move(slot.row - 1, slot.column)
                    else
                        slot:move(slot.row + 1, slot.column)
                    end

                    slot.visible = slot.row >= 0 and slot.row <= self.rows - 1 and slot.column >= 0 and slot.column <= self.columns - 1

                    if slot.row == 0 and slot.column == 0 then
                        self.head = slot
                    end

                    if (slot.row == self.rows - 1 and slot.column == self.columns - 1) or (slot == self.last and slot.visible) then
                        self.tail = slot
                    end

                    slot = slot.right
                end

                return true
            end

            return false
        end

        function Shop:scrollTo(item, player)
            if item and player == GetLocalPlayer() then
                local slot = array[self][item.id]

                repeat until slot.visible or not self:scroll(true)
            end
        end

        function Shop:filter(categories, andLogic)
            local slot = itempool[self][0]
            local process
            local i = -1

            self.size = 0
            self.first = nil
            self.last = nil
            self.head = nil
            self.tail = nil

            while slot do
                if andLogic then
                    process = categories == 0 or BlzBitAnd(slot.item.categories, categories) >= categories
                else
                    process = categories == 0 or BlzBitAnd(slot.item.categories, categories) > 0
                end

                if self.edit.text ~= "" and self.edit.text ~= nil then
                    process = process and self:find(StringCase(slot.item.name, false), StringCase(self.edit.text, false))
                end

                if process then
                    i = i + 1
                    self.size = self.size + 1
                    slot:move(R2I(i/self.columns), ModuloInteger(i, self.columns))
                    slot.visible = slot.row >= 0 and slot.row <= self.rows - 1 and slot.column >= 0 and slot.column <= self.columns - 1

                    if i > 0 then
                        slot.left = self.last
                        self.last.right = slot
                    else
                        self.first = slot
                        self.head = self.first
                    end

                    if slot.visible then
                        self.tail = slot
                    end

                    self.last = slot
                else
                    slot.visible = false
                end

                slot = slot.next
            end
        end

        function Shop:select(item, player)
            local id = GetPlayerId(player)

            if item and player == GetLocalPlayer() then
                if array[self][id] then
                    array[self][id]:display(nil, 0, 0, 0)
                end

                array[self][id] = array[self][item.id]
                array[self][id]:display(ITEM_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
            end
        end

        function Shop:detail(item, player)
            if item then
                if GetLocalPlayer() == player then
                    self.rows = DETAILED_ROWS
                    self.columns = DETAILED_COLUMNS

                    if not self.detailed then
                        self.detailed = true
                        self.details:filter(self.category.active, self.category.andLogic)
                    end
                end

                if not self.details.visible then
                    self:scrollTo(item, player)
                end

                self:select(item, player)
                self.details:show(item, player)
            else
                if GetLocalPlayer() == player then
                    self.rows = ROWS
                    self.columns = COLUMNS
                    self.detailed = false
                    self.details.visible = false
                    self.details:filter(self.category.active, self.category.andLogic)
                    self:scrollTo(array[self][GetPlayerId(player)].item, player)
                end
            end
        end

        function Shop:has(id)
            return array[self][id] ~= nil
        end

        function Shop:find(source, target)
            local sourceLength = StringLength(source)
            local targetLength = StringLength(target)
            local i = 0

            if targetLength <= sourceLength then
                while i <= sourceLength - targetLength do
                    if SubString(source, i, i + targetLength) == target then
                        return true
                    end

                    i = i + 1
                end
            end

            return false
        end

        function Shop.addCategory(id, icon, description)
            local this = array[id]

            if this then
                return this.category:add(icon, description)
            end

            return 0
        end

        function Shop.addItem(id, itemId, categories)
            local this = array[id]
            local slot

            if this then
                if not array[this][itemId] then
                    local item = Item.get(itemId)

                    if item then
                        this.size = this.size + 1
                        this.index = this.index + 1
                        item.categories = categories or 0
                        slot = Slot.create(this, item, 0, 0, this.frame)
                        slot.row = R2I(this.index/COLUMNS)
                        slot.column = ModuloInteger(this.index, COLUMNS)
                        slot.visible = slot.row >= 0 and slot.row <= ROWS - 1 and slot.column >= 0 and slot.column <= COLUMNS - 1

                        if this.index > 0 then
                            slot.prev = this.last
                            slot.left = this.last
                            this.last.next = slot
                            this.last.right = slot
                        else
                            this.first = slot
                            this.head = slot
                        end

                        if slot.visible then
                            this.tail = slot
                        end

                        this.last = slot
                        array[this][itemId] = slot
                        itempool[this][this.index] = slot
                    else
                        print("Invalid item code: " .. A2S(itemId))
                    end
                else
                    print("The item " .. GetObjectName(itemId) .. " is already registered for the shop " .. GetObjectName(id))
                end
            end
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
                this.index = -1
                this.rows = ROWS
                this.columns = COLUMNS
                this.detailed = false
                this.scrolls = {}
                count = count + 1
                this.buyer = Buyer.create(this)
                this.details = Detail.create(this)
                this.category = Category.create(this)
                this.favorites = Favorites.create(this)
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
                array[this] = {}
                itempool[this] = {}
                array[this.edit] = this
                array[this.close] = this
                array[this.breaker] = this
                array[this.revert] = this

                for i = 0, bj_MAX_PLAYER_SLOTS do
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                        array[i] = {}
                        array[i][id] = this
                        array[i][count] = id
                        this.scrolls[i] = {}
                    end
                end

                this.visible = false
            end

            return this
        end

        function Shop:onScroll()
            local id = GetPlayerId(GetTriggerPlayer())
            local direction = R2I(BlzGetTriggerFrameValue())

            if (self.scrolls[id][0] or 0) ~= direction then
                self.scrolls[id][0] = direction
                self.scrolls[id][1] = 0
            else
                self.scrolls[id][1] = (self.scrolls[id][1] or 0) + 1
            end

            if GetLocalPlayer() == GetTriggerPlayer() then
                if self.scrolls[id][1] == 1 and SCROLL_DELAY > 0 then
                    self:scroll(direction < 0)
                elseif SCROLL_DELAY <= 0 then
                    self:scroll(direction < 0)
                end
            end
        end

        function Shop.onExpire()
            local id = GetPlayerId(GetTriggerPlayer())
            local this = array[GetUnitTypeId(Shop.unit[id])]

            if this then
                this.scrolls[id][1] = (this.scrolls[id][1] or 0) - 1

                if this.scrolls[id][1] > 0 then
                    this:scroll((this.scrolls[id][0] or 0) < 0)
                else
                    this.scrolls[id][1] = 0
                end
            end
        end

        function Shop.onPeriod()
            for i = 0, bj_MAX_PLAYER_SLOTS do
                local player = Player(i)
                local id = GetPlayerId(player)
                local group = CreateGroup()
                local shop = Shop.unit[id]
                local this = array[shop and GetUnitTypeId(shop)]

                if this then
                    GroupClear(Shop.group[id])
                    GroupEnumUnitsInRange(group, GetUnitX(shop), GetUnitY(shop), this.aoe, nil)

                    local unit = FirstOfGroup(group)

                    while unit do
                        if ShopFilter(unit, Player(i), shop) then
                            GroupAddUnit(Shop.group[id], unit)
                        end

                        GroupRemoveUnit(group, unit)
                        unit = FirstOfGroup(group)
                    end

                    this.buyer:update(Shop.group[id], player)
                end

                DestroyGroup(group)
            end
        end

        function Shop.OnSearch()
            local this = array[GetTriggerEditBox()]

            if this and GetLocalPlayer() == GetTriggerPlayer() then
                this:filter(this.category.active, this.category.andLogic)
            end
        end

        function Shop.onClose()
            local player = GetTriggerPlayer()
            local id = GetPlayerId(player)
            local this = array[GetTriggerComponent()]

            if this then
                Shop.unit[id] = nil

                if player == GetLocalPlayer() then
                    this.visible = false
                end

                Transaction.clear(this, player)
            end
        end

        function Shop.onDismantle()
            local player = GetTriggerPlayer()
            local id = GetPlayerId(player)
            local this = array[GetTriggerComponent()]

            if this then
                if this.buyer.inventory.has(player) then
                    this:dismantle(this.buyer.inventory.item[id][this.buyer.inventory:get(id)], player, this.buyer.inventory:get(id))
                else
                    Sound.error(player)
                end
            end
        end

        function Shop.onUndo()
            local this = array[GetTriggerComponent()]

            if this then
                this:undo(GetTriggerPlayer())
            end
        end

        function Shop.onSelect()
            local player = GetTriggerPlayer()
            local id = GetPlayerId(player)
            local this = array[GetUnitTypeId(GetTriggerUnit())]

            if this then
                if player == GetLocalPlayer() then
                    this.visible = GetTriggerEventId() == EVENT_PLAYER_UNIT_SELECTED
                end

                if GetTriggerEventId() == EVENT_PLAYER_UNIT_SELECTED then
                    Shop.unit[id] = GetTriggerUnit()
                    this.buyer.inventory:show(this.buyer:get(id))
                else
                    Shop.unit[id] = nil
                    Transaction.clear(this, player)
                end
            end
        end

        function Shop.onEsc()
            local player = GetTriggerPlayer()
            local id = GetPlayerId(player)

            for i = 1, count do
                local this = array[id][array[id][i]]

                if this then
                    if player == GetLocalPlayer() then
                        this.visible = false
                    end

                    Transaction.clear(this, player)
                end
            end
        end

        function Shop.onInit()
            local trigger = CreateTrigger()

            for i = 0, bj_MAX_PLAYER_SLOTS do
                if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                    Shop.group[i] = CreateGroup()
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