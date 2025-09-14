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

    -- Side Panels
    local SIDE_WIDTH                = 0.075
    local SIDE_HEIGHT               = HEIGHT
    local EDIT_WIDTH                = 0.15
    local EDIT_HEIGHT               = 0.0285

    -- Scroll
    local SCROLL_DELAY              = 0.03

    -- Update time
    local UPDATE_PERIOD             = 0.33

    -- Buy / Sell sound, model and scale
    local SUCCESS_SOUND             = "Abilities\\Spells\\Other\\Transmute\\AlchemistTransmuteDeath1.wav"
    local ERROR_SOUND               = "Sound\\Interface\\Error.wav"

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

    -- ------------------------------------------ Shop ----------------------------------------- --
    do
        Shop = Class(Panel)

        Shop.unit = {}
        Shop.group = {}

        local count = 0
        local array = {}
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