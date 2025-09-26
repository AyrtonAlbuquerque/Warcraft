OnInit("Interface", function(requires)
    requires "Class"
    requires "Components"
    requires "GetMainSelectedUnit"
    requires "RegisterPlayerUnitEvent"

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- --------------------------------------- Info Panel -------------------------------------- --
    -- The initial position of the info panel
    local INFO_X = 0.34
    local INFO_Y = 0.11
    -- The size of the info panel
    local INFO_WIDTH = 0.12
    local INFO_HEIGHT = 0.15
    -- ---------------------------------------- Portrait --------------------------------------- --
    -- The initial position of the portrait (relative to the info panel)
    local PORTRAIT_X = 0.017
    local PORTRAIT_Y = -0.017
    -- Size of the portrait
    local PORTRAIT_WIDTH = 0.085
    local PORTRAIT_HEIGHT = 0.09
    -- Portrait darkness level (0 -> Normal, > 0 -> Darker)
    local PORTRAIT_DARKNESS = 104
    -- --------------------------------------- Health Bar -------------------------------------- --
    -- The initial position of the health bar (relative to the info panel)
    local HEALTH_X = 0.017
    local HEALTH_Y = -0.092
    -- Size of the health bar
    local HEALTH_WIDTH = 0.085
    local HEALTH_HEIGHT = 0.0075
    -- The health bar texture
    local HEALTH_TEXTURE = "replaceabletextures\\teamcolor\\teamcolor00"
    -- The size of the health text
    local HEALTH_TEXT_SCALE = 0.65
    -- The transparency of the health bar (0 -> 100%, 255 -> 0%)
    local HEALTH_TRANSPARENCY = 128
    -- ---------------------------------------- Mana Bar --------------------------------------- --
    -- The initial position of the mana bar (relative to the info panel)
    local MANA_X = 0.017
    local MANA_Y = -0.0995
    -- Size of the mana bar
    local MANA_WIDTH = 0.085
    local MANA_HEIGHT = 0.0075
    -- The mana bar texture
    local MANA_TEXTURE = "replaceabletextures\\teamcolor\\teamcolor01"
    -- The size of the mana text
    local MANA_TEXT_SCALE = 0.65
    -- The transparency of the mana bar (0 -> 100%, 255 -> 0%)
    local MANA_TRANSPARENCY = 128
    -- -------------------------------------- Progress Bar ------------------------------------- --
    -- The initial position of the xp/timed life/progess bar (relative to the info panel)
    local PROGRESS_X = 0.017
    local PROGRESS_Y = -0.107
    -- Size of the progress bar
    local PROGRESS_WIDTH = 0.085
    local PROGRESS_HEIGHT = 0.003
    -- The initial position of the buffs bar (relative to the info panel)
    -- ---------------------------------------- Buff Bar --------------------------------------- --
    local BUFF_X = 0.006
    local BUFF_Y = 0.012
    -- Size of the buffs bar
    local BUFF_WIDTH = 0.1235
    local BUFF_HEIGHT = 0.015
    -- --------------------------------------- Attributes -------------------------------------- --
    -- The Initial position of the attributes buttons (relative to the info panel)
    local ATTRIBUTES_X = 0.017
    local ATTRIBUTES_Y = -0.02
    -- The gap between each button
    local ATTRIBUTES_GAP = 0.014
    -- The size of the attributes buttons
    local ATTRIBUTES_WIDTH = 0.0125
    local ATTRIBUTES_HEIGHT = 0.0125
    -- The position of the attributes text (relative to the attributes buttons)
    local ATTRIBUTES_TEXT_X = 0.02
    local ATTRIBUTES_TEXT_Y = -0.0025
    -- The size of the attributes text
    local ATTRIBUTES_TEXT_WIDTH = 0.15
    local ATTRIBUTES_TEXT_HEIGHT = 0.0125
    local ATTRIBUTES_TEXT_SCALE = 0.65
    -- ------------------------------------ Attributes Panel ----------------------------------- --
    -- The size of the attributes toggle button
    local ATTRIBUTES_TOGGLE_WIDTH = 0.0125
    local ATTRIBUTES_TOGGLE_HEIGHT = 0.0125
    -- The attributes toggle button textures
    local ATTRIBUTES_TOGGLE_OPEN = "UI\\Minimap\\minimap-gold.blp"
    local ATTRIBUTES_TOGGLE_CLOSE = "UI\\Widgets\\EscMenu\\Human\\radiobutton-button.blp"
    -- The initial offsets of the buttons (relative to the panel)
    local ATTRIBUTES_BUTTON_X = 0.005
    local ATTRIBUTES_BUTTON_Y = 0.005
    -- The width and height of the attributes buttons
    local ATTRIBUTES_BUTTON_WIDTH = 0.02
    local ATTRIBUTES_BUTTON_HEIGHT = 0.02
    -- The gap between each button
    local ATTRIBUTES_BUTTON_GAP = 0.001
    -- The panel maximum columns
    local ATTRIBUTES_COLUMNS = 5
    -- ----------------------------------------- Damage ---------------------------------------- --
    -- The damage button texture
    local DAMAGE_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNAttack.blp"
    -- ----------------------------------------- Armor ----------------------------------------- --
    -- The armor button texture
    local ARMOR_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpOne.blp"
    -- ---------------------------------------- Strenght --------------------------------------- --
    -- The strength button texture
    local STRENGTH_TEXTURE = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-str.blp"
    -- ---------------------------------------- Agility ---------------------------------------- --
    -- The agility button texture
    local AGILITY_TEXTURE = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-agi.blp"
    -- -------------------------------------- Intelligence ------------------------------------- --
    -- The intelligence button texture
    local INTELLIGENCE_TEXTURE = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-int.blp"
    -- ---------------------------------- Attribute Highlight ---------------------------------- --
    -- Main attribute highlight
    local ATTRIBUTE_HIGHLIGHT = "goldenbrown.mdx"
    local HIGHLIGHT_SCALE = 0.125
    local HIGHLIGHT_XOFFSET = 0.052
    local HIGHLIGHT_YOFFSET = 0.048
    -- ------------------------------------- Ability Panel ------------------------------------- --
    -- The initial position of the abilities panel
    local ABILITY_PANEL_X = 0.105
    local ABILITY_PANEL_Y = 0.055
    -- Size of the ability slots
    local ABILITY_SLOT_WIDTH = 0.038
    local ABILITY_SLOT_HEIGHT = 0.038
    -- The initial position of the abilities slot inside the panel (relative to the panel)
    local ABILITY_SLOT_X = 0.017
    local ABILITY_SLOT_Y = -0.017
    -- The initial position of the ability icon inside the slot (relative to the slot)
    local ABILITY_ICON_X = 0.02
    local ABILITY_ICON_Y = -0.02
    -- Size of the ability icons
    local ABILITY_ICON_WIDTH = 0.032
    local ABILITY_ICON_HEIGHT = 0.032
    -- Gap between each slot
    local ABILITY_SLOT_GAP = 0.0375
    -- Numbers of slots
    local ABILITY_SLOT_COUNT = 6
    -- Set this to a texture to replace the default gold icon
    local ABILITY_SLOT_TEXTURE = "SpellSlot.blp"
    -- --------------------------------------- Item Panel -------------------------------------- --
    -- The initial position of the item panel
    local ITEM_PANEL_X = 0.435
    local ITEM_PANEL_Y = 0.055
    -- Size of the item slots
    local ITEM_SLOT_WIDTH = 0.038
    local ITEM_SLOT_HEIGHT = 0.038
    -- The initial position of the item slot inside the panel (relative to the panel)
    local ITEM_SLOT_X = 0.017
    local ITEM_SLOT_Y = -0.017
    -- The initial position of the item icon inside the slot (relative to the slot)
    local ITEM_ICON_X = 0.02
    local ITEM_ICON_Y = -0.02
    -- Size of the item icons
    local ITEM_ICON_WIDTH = 0.032
    local ITEM_ICON_HEIGHT = 0.032
    -- Gap between each slot
    local ITEM_SLOT_GAP = 0.0375
    -- Numbers of slots
    local ITEM_SLOT_COUNT = 6
    -- Set this to a texture to replace the default gold icon
    local ITEM_SLOT_TEXTURE = "ItemSlot.blp"
    -- --------------------------------------- Hero List --------------------------------------- --
    -- The initial position of the first hero icon
    local HERO_LIST_X = -0.128
    local HERO_LIST_Y = 0.573
    -- Size of the hero icon
    local HERO_LIST_WIDTH = 0.038
    local HERO_LIST_HEIGHT = 0.038
    -- The gap between each icon
    local HERO_LIST_GAP = 0.0505
    -- ------------------------------------------ Chat ----------------------------------------- --
    -- The initial position of the chat
    local CHAT_X = 0.00
    local CHAT_Y = 0.35
    -- The size of the chat
    local CHAT_WIDTH = 0.35
    local CHAT_HEIGHT = 0.2
    -- ------------------------------------ Group Selection ------------------------------------ --
    -- The initial position of the first group buttons (relative to the abilities and item panels)
    local GROUP_X = 0.0235
    local GROUP_Y = 0.04
    -- Size of the group buttons
    local GROUP_WIDTH = 0.025
    local GROUP_HEIGHT = 0.025
    -- Gap between each button
    local GROUP_GAP = 0.0375
    -- ------------------------------------------ Menu ----------------------------------------- --
    -- The initial position of the menu button
    local MENU_X = 0.39
    local MENU_Y = 0.60
    -- The size of the menu button
    local MENU_WIDTH = 0.02
    local MENU_HEIGHT = 0.02
    -- The menu button texture
    local OPEN_MENU_TEXTURE = "UI\\Widgets\\Glues\\Gluescreen-Scrollbar-DownArrow.blp"
    local CLOSE_MENU_TEXTURE = "UI\\Widgets\\Glues\\Gluescreen-Scrollbar-UpArrow.blp"
    -- The initial position of the menu frame
    local MENU_FRAME_X = -0.19
    local MENU_FRAME_Y = -0.02
    -- The size of the menu frame
    local MENU_FRAME_WIDTH = 0.40
    local MENU_FRAME_HEIGHT = 0.23
    -- -------------------------------------- Menu Options ------------------------------------- --
    local MENU_X_OFFSET = 0.04
    local MENU_Y_OFFSET = -0.025
    local MENU_Y_GAP = -0.005
    local CHECK_WIDTH = 0.015
    local CHECK_HEIGHT = 0.015
    local CHECK_TEXT_X = 0.002
    local CHECK_TEXT_Y = 0.0
    local CHECK_TEXT_WIDTH = 0.2
    local CHECK_TEXT_HEIGHT = 0.015
    local CHECK_TEXT_SCALE = 1
    local SLIDER_WIDTH = 0.30
    local SLIDER_HEIGHT = 0.015
    local SLIDER_TEXT_WIDTH = 0.15
    local SLIDER_TEXT_HEIGHT = 0.015
    -- ------------------------------------------ Gold ----------------------------------------- --
    -- The initial position of the gold background (relative to the menu button)
    local GOLD_BACKGROUND_X = 0.0165
    local GOLD_BACKGROUND_Y = 0.0025
    -- The size of the gold background
    local GOLD_BACKGROUND_WIDTH = 0.07
    local GOLD_BACKGROUND_HEIGHT = 0.0225
    -- The initial position of the gold icon (relative to the gold background)
    local GOLD_ICON_X = 0.005
    local GOLD_ICON_Y = -0.005
    -- The size of the gold icon
    local GOLD_ICON_WIDTH = 0.0125
    local GOLD_ICON_HEIGHT = 0.0125
    -- The gold icon texture
    local GOLD_ICON_TEXTURE = "UI\\Feedback\\Resources\\ResourceGold.blp"
    -- The initial position of the gold text (relative to the gold icon)
    local GOLD_TEXT_X = 0.013
    local GOLD_TEXT_Y = 0.0
    -- The size of the gold text
    local GOLD_TEXT_WIDTH = 0.0575
    local GOLD_TEXT_HEIGHT = 0.0125
    local GOLD_TEXT_SCALE = 1.0
    -- ----------------------------------------- Lumber ---------------------------------------- --
    -- The initial position of the lumber background (relative to the menu button)
    local LUMBER_BACKGROUND_X = -0.067
    local LUMBER_BACKGROUND_Y = 0.0025
    -- The size of the lumber background
    local LUMBER_BACKGROUND_WIDTH = 0.07
    local LUMBER_BACKGROUND_HEIGHT = 0.0225
    -- The initial position of the lumber icon (relative to the lumber background)
    local LUMBER_ICON_X = 0.0525
    local LUMBER_ICON_Y = -0.005
    -- The size of the lumber icon
    local LUMBER_ICON_WIDTH = 0.0125
    local LUMBER_ICON_HEIGHT = 0.0125
    -- The lumber icon texture
    local LUMBER_ICON_TEXTURE = "UI\\Feedback\\Resources\\ResourceLumber.blp"
    -- The initial position of the lumber text (relative to the lumber icon)
    local LUMBER_TEXT_X = -0.06
    local LUMBER_TEXT_Y = 0.0
    -- The size of the lumber text
    local LUMBER_TEXT_WIDTH = 0.0575
    local LUMBER_TEXT_HEIGHT = 0.0125
    local LUMBER_TEXT_SCALE = 1.0
    -- ---------------------------------------- Minimap ---------------------------------------- --
    -- The initial position of the minimap on the right side of the screen
    local MINIMAP_RIGHT_X = 0.785
    local MINIMAP_RIGHT_Y = 0.15
    -- The initial position of the minimap on the left side of the screen
    local MINIMAP_LEFT_X = -0.13365
    local MINIMAP_LEFT_Y = 0.15
    -- The size of the minimap
    local MINIMAP_WIDTH = 0.15
    local MINIMAP_HEIGHT = 0.15
    -- Minimap initial transparency (0 -> 100%, 255 -> 0%)
    local MAP_TRANSPARENCY = 57
    -- The minimap toggle key
    local MINIMAP_TOGGLE_KEY = OSKEY_TAB
    -- ------------------------------------------ Shop ----------------------------------------- --
    -- The initial position of the shop panel
    local SHOP_PANEL_X = 0.308
    local SHOP_PANEL_Y = 0.25
    -- The initial position of the first shop slot inside the panel (relative to the panel)
    local SHOP_SLOT_X = 0.017
    local SHOP_SLOT_Y = -0.017
    -- Size of the shop slots
    local SHOP_SLOT_WIDTH = 0.038
    local SHOP_SLOT_HEIGHT = 0.038
    -- The shop slot texture
    local SHOP_SLOT_TEXTURE = "SpellSlot.blp"
    -- The initial position of the shop icon inside the slot (relative to the slot)
    local SHOP_ICON_X = 0.02
    local SHOP_ICON_Y = -0.02
    -- Size of the shop icons
    local SHOP_ICON_WIDTH = 0.032
    local SHOP_ICON_HEIGHT = 0.032
    -- Number of columns
    local SHOP_COLUMNS = 4
    -- Number of rows
    local SHOP_ROWS = 3
    -- Total count
    local SHOP_COUNT = SHOP_ROWS * SHOP_COLUMNS
    -- Gap between each slot
    local SHOP_SLOT_GAP = 0.0375
    -- When true and a unit that has "Select Unit" or "Select Hero" or "Shop Purchase Item" 
    -- abilities is selected a panel above the portrait is created to show the items/units
    local DISPLAY_SHOP = true
    -- ----------------------------------- Hero skill button ----------------------------------- --
    -- If true, the + icon will be displayed on top of all abilities when the hero has a skill point
    local SEPARATE_LEVELUP = true
    -- The size of the + icon
    local SEPARATE_LEVELUP_WIDTH = 0.0125
    local SEPARATE_LEVELUP_HEIGHT = 0.0125
    -- The + icon texture
    local SEPARATE_LEVELUP_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNSkillz.blp"
    -- -------------------------------------- Damage Value ------------------------------------- --
    -- If true the damage value will be trimmed to show only the last value (xx - xx + yy) => (xx + yy)
    local TRIM_DAMAGE = true

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function IsUnitShop(unit, player)
        return (GetUnitAbilityLevel(unit, FourCC('Aneu')) > 0 or GetUnitAbilityLevel(unit, FourCC('Ane2')) > 0 or GetUnitAbilityLevel(unit, FourCC('Apit')) > 0) and not IsUnitEnemy(unit, player)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    -- ---------------------------------------- Resource --------------------------------------- --
    local Resource = Class(Panel)

    do
        Resource:property("text", {
            get = function (self) return self.value.text end,
            set = function (self, value) self.value.text = value end
        })

        Resource:property("icon", {
            get = function (self) return self.image.texture end,
            set = function (self, value) self.image.texture = value end
        })

        function Resource:destroy()
            self.value:destroy()
            self.image:destroy()
        end

        function Resource.create(x, y, width, height, parent, gold)
            local this = Resource.allocate(x, y, width, height, parent, "Leaderboard", false)

            if gold then
                this.image = Backdrop.create(GOLD_ICON_X, GOLD_ICON_Y, GOLD_ICON_WIDTH, GOLD_ICON_HEIGHT, this.frame, GOLD_ICON_TEXTURE)
                this.value = Text.create(GOLD_TEXT_X, GOLD_TEXT_Y, GOLD_TEXT_WIDTH, GOLD_TEXT_HEIGHT, GOLD_TEXT_SCALE, false, this.image.frame, nil, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            else
                this.image = Backdrop.create(LUMBER_ICON_X, LUMBER_ICON_Y, LUMBER_ICON_WIDTH, LUMBER_ICON_HEIGHT, this.frame, LUMBER_ICON_TEXTURE)
                this.value = Text.create(LUMBER_TEXT_X, LUMBER_TEXT_Y, LUMBER_TEXT_WIDTH, LUMBER_TEXT_HEIGHT, LUMBER_TEXT_SCALE, false, this.image.frame, nil, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_RIGHT)
            end

            return this
        end
    end

    -- ---------------------------------------- Options ---------------------------------------- --
    local Options = Class(Panel)

    do
        local array = {}

        function Options:destroy()
            self.right:destroy()
            self.toggle:destroy()
            self.heroes:destroy()
            self.slider:destroy()
            self.shader:destroy()
            self.default:destroy()
            self.rightText:destroy()
            self.toggleText:destroy()
            self.heroesText:destroy()
            self.defaultText:destroy()
            self.sliderText:destroy()
            self.shaderText:destroy()
        end

        function Options.create(x, y, width, height, parent)
            local this = Options.allocate(x, y, width, height, parent, "EscMenuBackdrop", false)

            this.right = CheckBox.create(MENU_X_OFFSET, MENU_Y_OFFSET, CHECK_WIDTH, CHECK_HEIGHT, this.frame, "QuestCheckBox")
            this.right.onCheck = Options.onChecked
            this.right.onUncheck = Options.onUnchecked
            this.rightText = Text.create(0, 0, CHECK_TEXT_WIDTH, CHECK_TEXT_HEIGHT, CHECK_TEXT_SCALE, false, this.right.frame, "|cffffffffShow Minimap on the Right|r", TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            this.toggle = CheckBox.create(0, 0, CHECK_WIDTH, CHECK_HEIGHT, this.right.frame, "QuestCheckBox")
            this.toggle.onCheck = Options.onChecked
            this.toggle.onUncheck = Options.onUnchecked
            this.toggleText = Text.create(0, 0, CHECK_TEXT_WIDTH, CHECK_TEXT_HEIGHT, CHECK_TEXT_SCALE, false, this.toggle.frame, "|cffffffffEnable Minimap Toggle (Hold Tab)|r", TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            this.heroes = CheckBox.create(0, 0, CHECK_WIDTH, CHECK_HEIGHT, this.toggle.frame, "QuestCheckBox")
            this.heroes.onCheck = Options.onChecked
            this.heroes.onUncheck = Options.onUnchecked
            this.heroesText = Text.create(0, 0, CHECK_TEXT_WIDTH, CHECK_TEXT_HEIGHT, CHECK_TEXT_SCALE, false, this.heroes.frame, "|cffffffffShow Heroes Bar|r", TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            this.default = CheckBox.create(0, 0, CHECK_WIDTH, CHECK_HEIGHT, this.heroes.frame, "QuestCheckBox")
            this.default.onCheck = Options.onChecked
            this.default.onUncheck = Options.onUnchecked
            this.defaultText = Text.create(0, 0, CHECK_TEXT_WIDTH, CHECK_TEXT_HEIGHT, CHECK_TEXT_SCALE, false, this.default.frame, "|cffffffffShow Default Menu|r", TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            this.sliderText = Text.create(0, 0, SLIDER_TEXT_WIDTH, SLIDER_TEXT_HEIGHT, CHECK_TEXT_SCALE, false, this.default.frame, "|cffffffffMinimap Opacity: " .. I2S(R2I((MAP_TRANSPARENCY*100)/255)) .. "%|r", TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
            this.slider = Slider.create(0, 0, SLIDER_WIDTH, SLIDER_HEIGHT, this.sliderText.frame, "EscMenuSliderTemplate")
            this.slider.max = 255
            this.slider.value = MAP_TRANSPARENCY
            this.slider.onSlide = Options.onSlider
            this.shaderText = Text.create(0, 0, SLIDER_TEXT_WIDTH, SLIDER_TEXT_HEIGHT, CHECK_TEXT_SCALE, false, this.slider.frame, "|cffffffffPortrait Opacity: " .. I2S(R2I((PORTRAIT_DARKNESS*100)/255)) .. "%|r", TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
            this.shader = Slider.create(0, 0, SLIDER_WIDTH, SLIDER_HEIGHT, this.shaderText.frame, "EscMenuSliderTemplate")
            this.shader.max = 255
            this.shader.value = PORTRAIT_DARKNESS
            this.shader.onSlide = Options.onSlider
            array[this.right] = this
            array[this.toggle] = this
            array[this.heroes] = this
            array[this.shader] = this
            array[this.slider] = this
            array[this.default] = this

            this.right:setPoint(FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, MENU_X_OFFSET, MENU_Y_OFFSET)
            this.rightText:setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, CHECK_TEXT_X, CHECK_TEXT_Y)
            this.toggle:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, MENU_Y_GAP)
            this.toggleText:setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, CHECK_TEXT_X, CHECK_TEXT_Y)
            this.heroes:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, MENU_Y_GAP)
            this.heroesText:setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, CHECK_TEXT_X, CHECK_TEXT_Y)
            this.default:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, MENU_Y_GAP)
            this.defaultText:setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, CHECK_TEXT_X, CHECK_TEXT_Y)
            this.sliderText:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, width/2 - MENU_X_OFFSET - 0.0075, MENU_Y_GAP)
            this.slider:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, MENU_Y_GAP)
            this.shaderText:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, MENU_Y_GAP)
            this.shader:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, MENU_Y_GAP)

            for i = 0, bj_MAX_PLAYER_SLOTS do
                array[GetHandleId(Player(i))] = this
            end

            return this
        end

        function Options.onKey()
            local this = array[GetHandleId(GetTriggerPlayer())]

            if this and GetLocalPlayer() == GetTriggerPlayer() then
                if this.toggle.checked then
                    if BlzGetTriggerPlayerIsKeyDown() then
                        if this.right.checked then
                            Interface.map.x = MINIMAP_RIGHT_X
                            Interface.map.y = MINIMAP_RIGHT_Y
                            Interface.map.visible = true
                        else
                            Interface.map.x = MINIMAP_LEFT_X
                            Interface.map.y = MINIMAP_LEFT_Y
                            Interface.map.visible = true
                        end
                    else
                        Interface.map.visible = false
                    end
                end
            end
        end

        function Options.onSlider()
            local slide = GetTriggerSlider()
            local this = array[slide]

            if this and GetLocalPlayer() == GetTriggerPlayer() then
                if slide == this.slider then
                    this.sliderText.text = "|cffffffffMinimap Opacity: " .. I2S(R2I((this.slider.value*100)/255)) .. "%|r"
                    Interface.map.opacity = R2I(this.slider.value)
                elseif slide == this.shader then
                    this.shaderText.text = "|cffffffffPortrait Opacity: " .. I2S(R2I((this.shader.value*100)/255)) .. "%|r"
                    Interface.portrait.opacity = R2I(this.shader.value)
                end
            end
        end

        function Options.onChecked()
            local check = GetTriggerCheckBox()
            local this = array[check]

            if this and GetLocalPlayer() == GetTriggerPlayer() then
                if check == this.right and not this.toggle.checked then
                    Interface.map.x = MINIMAP_RIGHT_X
                    Interface.map.y = MINIMAP_RIGHT_Y
                    Interface.map.visible = true
                elseif check == this.toggle then
                    Interface.map.visible = false
                elseif check == this.heroes then
                    Interface.heroes= true
                elseif check == this.default then
                    BlzFrameSetVisible(Interface.default, true)
                end
            end
        end

        function Options.onUnchecked()
            local check = GetTriggerCheckBox()
            local this = array[check]

            if this and GetLocalPlayer() == GetTriggerPlayer() then
                if check == this.right then
                    if not this.toggle.checked then
                        Interface.map.x = MINIMAP_LEFT_X
                        Interface.map.y = MINIMAP_LEFT_Y
                        Interface.map.visible = true
                    else
                        Interface.map.visible = false
                    end
                elseif check == this.toggle then
                    if this.right.checked then
                        Interface.map.x = MINIMAP_RIGHT_X
                        Interface.map.y = MINIMAP_RIGHT_Y
                        Interface.map.visible = true
                    else
                        Interface.map.x = MINIMAP_LEFT_X
                        Interface.map.y = MINIMAP_LEFT_Y
                        Interface.map.visible = true
                    end
                elseif check == this.heroes then
                    Interface.heroes = false
                elseif check == this.default then
                    BlzFrameSetVisible(Interface.default, false)
                end
            end
        end

        function Options.onInit()
            local trigger = CreateTrigger()

            for i = 0, bj_MAX_PLAYER_SLOTS do
                BlzTriggerRegisterPlayerKeyEvent(trigger, Player(i), MINIMAP_TOGGLE_KEY, 0, true)
                BlzTriggerRegisterPlayerKeyEvent(trigger, Player(i), MINIMAP_TOGGLE_KEY, 0, false)
            end

            TriggerAddAction(trigger, Options.onKey)
        end
    end

    -- ------------------------------------------ Menu ----------------------------------------- --
    local Menu = Class(Button)

    do
        function Menu:destroy()
            this.panel:destroy()
        end

        function Menu.create(x, y, width, height, parent)
            local this = Menu.allocate(x, y, width, height, parent, true, false)

            this.texture = OPEN_MENU_TEXTURE
            this.tooltip.text = "Open Menu"
            this.panel = Options.create(MENU_FRAME_X, MENU_FRAME_Y, MENU_FRAME_WIDTH, MENU_FRAME_HEIGHT, this.frame)
            this.panel.visible = false
            this.tooltip:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, -0.008)

            return this
        end

        function Menu:onClick()
            if GetLocalPlayer() == GetTriggerPlayer() then
                self.panel.visible = not self.panel.visible

                if self.panel.visible then
                    self.texture = CLOSE_MENU_TEXTURE
                    self.tooltip.text = "Close Menu"
                else
                    self.texture = OPEN_MENU_TEXTURE
                    self.tooltip.text = "Open Menu"
                end
            end
        end
    end

    -- ------------------------------------------ Grid ----------------------------------------- --
    local Grid = Class(Panel)

    do
        local slot = {}
        local button = {}

        Grid:property("visible", {
            get = function (self) return self.isVisible end,
            set = function (self, value)
                self.isVisible = value

                if value then
                    local k = 0

                    for i = 0, SHOP_ROWS - 1 do
                        for j = 0, SHOP_COLUMNS - 1 do
                            if k < 12 then
                                BlzFrameSetAbsPoint(button[k], FRAMEPOINT_TOPLEFT, self.x + (SHOP_ICON_X + (j*SHOP_SLOT_GAP)), self.y + SHOP_ICON_Y - (i*SHOP_SLOT_GAP))
                                BlzFrameSetScale(button[k], SHOP_ICON_WIDTH/0.04)
                            end

                            k = k + 1
                        end
                    end
                end

                BlzFrameSetVisible(self.frame, value)
            end
        })

        function Grid:destroy()
            local k = 0

            for i = 0, SHOP_ROWS - 1 do
                for j = 0, SHOP_COLUMNS - 1 do
                    slot[k]:destroy()
                    k = k + 1
                end
            end
        end

        function Grid.create(x, y, width, height, parent)
            local this = Grid.allocate(x, y, width, height, parent, "EscMenuBackdrop", false)
            local k = 0

            for i = 0, SHOP_ROWS - 1 do
                for j = 0, SHOP_COLUMNS - 1 do
                    slot[k] = Backdrop.create(SHOP_SLOT_X + (j*SHOP_SLOT_GAP), SHOP_SLOT_Y - (i*SHOP_SLOT_GAP), SHOP_SLOT_WIDTH, SHOP_SLOT_HEIGHT, this.frame, SHOP_SLOT_TEXTURE)
                    k = k + 1
                end
            end

            this.visible = false

            return this
        end

        function Grid.onInit()
            for i = 0, 11 do
                button[i] = BlzGetFrameByName("CommandButton_" .. I2S(i), 0)
            end
        end
    end

    -- ---------------------------------------- Portrait --------------------------------------- --
    local Portrait = Class(Panel)

    do
        local shades = {}
        local attribute = {}

        Portrait:property("opacity", {
            set = function (self, value)
                for i = 0, 4 do
                    BlzFrameSetAlpha(shades[i], value)
                end
            end
        })

        function Portrait:destroy()
            for i = 0, 4 do
                BlzDestroyFrame(shades[i])
            end

            self.mana:destroy()
            self.manaText:destroy()
            self.health:destroy()
            self.healthText:destroy()
            self.damage:destroy()
            self.armor:destroy()
            self.strength:destroy()
            self.agility:destroy()
            self.intelligence:destroy()
        end

        function Portrait:trim(text, flag)
            if flag and text ~= nil then
                local length = StringLength(text)
                local i = 0

                while i < length - 1 do
                    if SubString(text, i, i + 1) == "-" then
                        return SubString(text, i + 2, length)
                    end

                    i = i + 1
                end
            end

            return text
        end

        function Portrait:update(unit, player)
            local group = CreateGroup()
            local visible = IsUnitVisible(unit, player)
            local hero = IsUnitType(unit, UNIT_TYPE_HERO)
            local id = GetPlayerId(player)
            local primary = BlzGetUnitIntegerField(unit, UNIT_IF_PRIMARY_ATTRIBUTE)

            GroupEnumUnitsSelected(group, player, nil)
            local count = CountUnitsInGroup(group)

            self.mana.value = GetUnitManaPercent(unit)
            self.health.value = GetUnitLifePercent(unit)
            self.manaText.visible = BlzGetUnitMaxMana(unit) > 0
            self.healthText.visible = BlzGetUnitMaxHP(unit) > 0
            self.manaText.text = "|cffFFFFFF" .. I2S(R2I(GetUnitState(unit,  UNIT_STATE_MANA))) .. " / " .. I2S(BlzGetUnitMaxMana(unit)) .. "|r"
            self.healthText.text = "|cffFFFFFF" .. I2S(R2I(GetWidgetLife(unit))) .. " / " .. I2S(BlzGetUnitMaxHP(unit)) .. "|r"
            self.damage.value.text = self:trim(BlzFrameGetText(Portrait.attack), TRIM_DAMAGE)
            self.damage.tooltip.text = "Damage: " .. self.damage.value.text
            self.damage.visible = BlzGetUnitWeaponBooleanField(unit, UNIT_WEAPON_BF_ATTACKS_ENABLED, 0) and visible and count == 1
            self.armor.value.text = BlzFrameGetText(Portrait.defense)
            self.armor.tooltip.text = "Armor: " .. self.armor.value.text
            self.armor.visible = self.armor.value.text ~= nil and visible and count == 1
            self.strength.value.text = BlzFrameGetText(Portrait.str)
            self.strength.tooltip.text = "Strength: " .. self.strength.value.text
            self.strength.visible = hero and visible and count == 1
            self.agility.value.text = BlzFrameGetText(Portrait.agi)
            self.agility.tooltip.text = "Agility: " .. self.agility.value.text
            self.agility.visible = hero and visible and count == 1
            self.intelligence.value.text = BlzFrameGetText(Portrait.int)
            self.intelligence.tooltip.text = "Intelligence: " .. self.intelligence.value.text
            self.intelligence.visible = hero and visible and count == 1

            if hero then
                if primary == 3 and attribute[id] ~= primary then
                    attribute[id] = primary
                    self.agility:display(ATTRIBUTE_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
                    self.intelligence:display(nil, 0, 0, 0)
                    self.strength:display(nil, 0, 0, 0)
                elseif primary == 2 and attribute[id] ~= primary then
                    attribute[id] = primary
                    self.agility:display(nil, 0, 0, 0)
                    self.intelligence:display(ATTRIBUTE_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
                    self.strength:display(nil, 0, 0, 0)
                elseif primary == 1 and attribute[id] ~= primary then
                    attribute[id] = primary
                    self.agility:display(nil, 0, 0, 0)
                    self.intelligence:display(nil, 0, 0, 0)
                    self.strength:display(ATTRIBUTE_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
                end
            end

            if BlzGetUnitMaxMana(unit) <= 0 then
                BlzFrameSetAllPoints(self.health.frame, self.mana.frame)
                BlzFrameSetAllPoints(self.healthText.frame, self.health.frame)
            else
                BlzFrameSetAbsPoint(self.health.frame, FRAMEPOINT_TOPLEFT, self.x + HEALTH_X, self.y + HEALTH_Y)
                BlzFrameSetAbsPoint(self.health.frame, FRAMEPOINT_BOTTOMRIGHT, self.x + HEALTH_X + HEALTH_WIDTH, self.y + HEALTH_Y - HEALTH_HEIGHT)
                BlzFrameSetAllPoints(self.healthText.frame, self.health.frame)
            end

            DestroyGroup(group)
        end

        function Portrait.create(x, y, width, height, parent)
            local this = Portrait.allocate(x, y, width, height, parent, "EscMenuBackdrop", false)

            this.mana = StatusBar.create(MANA_X, MANA_Y, MANA_WIDTH, MANA_HEIGHT, this.frame, MANA_TEXTURE)
            this.mana.alpha = MANA_TRANSPARENCY
            this.manaText = Text.create(0, 0, this.mana.width, this.mana.height, MANA_TEXT_SCALE, false, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), nil, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
            this.health = StatusBar.create(HEALTH_X, HEALTH_Y, HEALTH_WIDTH, HEALTH_HEIGHT, this.frame, HEALTH_TEXTURE)
            this.health.alpha = HEALTH_TRANSPARENCY
            this.healthText = Text.create(0, 0, this.health.width, this.health.height, HEALTH_TEXT_SCALE, false, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), nil, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
            this.damage = Attribute.create(x + ATTRIBUTES_X, y + ATTRIBUTES_Y - (0*ATTRIBUTES_GAP), ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), DAMAGE_TEXTURE, "Damage", nil)
            this.armor = Attribute.create(x + ATTRIBUTES_X, y + ATTRIBUTES_Y - (1*ATTRIBUTES_GAP), ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), ARMOR_TEXTURE, "Armor", nil)
            this.strength = Attribute.create(x + ATTRIBUTES_X, y + ATTRIBUTES_Y - (2*ATTRIBUTES_GAP), ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), STRENGTH_TEXTURE, "Strength", nil)
            this.agility = Attribute.create(x + ATTRIBUTES_X, y + ATTRIBUTES_Y - (3*ATTRIBUTES_GAP), ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), AGILITY_TEXTURE, "Agility", nil)
            this.intelligence = Attribute.create(x + ATTRIBUTES_X, y + ATTRIBUTES_Y - (4*ATTRIBUTES_GAP), ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), INTELLIGENCE_TEXTURE, "Intelligence", nil)

            BlzFrameSetVisible(Portrait.portrait, true)
            BlzFrameClearAllPoints(Portrait.portrait)
            BlzFrameSetAbsPoint(Portrait.portrait, FRAMEPOINT_TOPLEFT, x + PORTRAIT_X + 0.01, y + PORTRAIT_Y)
            BlzFrameSetAbsPoint(Portrait.portrait, FRAMEPOINT_BOTTOMRIGHT, x + PORTRAIT_X + PORTRAIT_WIDTH - 0.01, y + PORTRAIT_Y - PORTRAIT_HEIGHT)
            BlzFrameSetAllPoints(this.manaText.frame, this.mana.frame)
            BlzFrameSetAllPoints(this.healthText.frame, this.health.frame)

            for i = 0, 4 do
                shades[i] = BlzCreateFrame("SemiTransparentBackdrop", Portrait.portrait, 0, 0)
                BlzFrameSetAllPoints(shades[i], this.frame)
                BlzFrameSetAlpha(shades[i], PORTRAIT_DARKNESS)
            end

            return this
        end

        function Portrait.onInit()
            Portrait.agi = BlzGetFrameByName("InfoPanelIconHeroAgilityValue", 6)
            Portrait.str = BlzGetFrameByName("InfoPanelIconHeroStrengthValue", 6)
            Portrait.int = BlzGetFrameByName("InfoPanelIconHeroIntellectValue", 6)
            Portrait.attack = BlzGetFrameByName("InfoPanelIconValue", 0)
            Portrait.defense = BlzGetFrameByName("InfoPanelIconValue", 2)
            Portrait.portrait = BlzGetOriginFrame(ORIGIN_FRAME_PORTRAIT, 0)
        end
    end

    -- --------------------------------------- Abilities --------------------------------------- --
    local Abilities = Class(Panel)

    do
        local slot = {}
        local button = {}

        Abilities.levelup = {}

        Abilities:property("visible", {
            get = function (self) return self.isVisible end,
            set = function (self, value)
                if not self.isVisible and value then
                    for i = 0, 11 do
                        if i < ABILITY_SLOT_COUNT then
                            BlzFrameSetAbsPoint(button[i], FRAMEPOINT_TOPLEFT, self.x + (ABILITY_ICON_X + (i*ABILITY_SLOT_GAP)), self.y + ABILITY_ICON_Y)
                            BlzFrameSetScale(button[i], ABILITY_ICON_WIDTH/0.04)
                        else
                            BlzFrameSetAbsPoint(button[i], FRAMEPOINT_TOPLEFT, 999, 999)
                            BlzFrameSetAbsPoint(button[i], FRAMEPOINT_BOTTOMRIGHT, 999, 999)
                        end
                    end
                end

                self.isVisible = value
            end
        })

        function Abilities:destroy()
            for i = 0, ABILITY_SLOT_COUNT - 1 do
                slot[i]:destroy()

                if SEPARATE_LEVELUP then
                    Abilities.levelup[i]:destroy()
                end
            end
        end

        function Abilities.create(x, y, width, height, parent)
            local this = Abilities.allocate(x, y, width, height, parent, "EscMenuBackdrop", false)

            for i = 0, ABILITY_SLOT_COUNT - 1 do
                slot[i] = Backdrop.create(ABILITY_SLOT_X + (i*ABILITY_SLOT_GAP), ABILITY_SLOT_Y, ABILITY_SLOT_WIDTH, ABILITY_SLOT_HEIGHT, this.frame, ABILITY_SLOT_TEXTURE)

                if SEPARATE_LEVELUP then
                    Abilities.levelup[i] = Button.create(slot[i].width/2 - SEPARATE_LEVELUP_WIDTH/2, slot[i].y + 2*SEPARATE_LEVELUP_HEIGHT, SEPARATE_LEVELUP_WIDTH, SEPARATE_LEVELUP_HEIGHT, slot[i].frame, true, false)
                    Abilities.levelup[i].texture = SEPARATE_LEVELUP_TEXTURE
                    Abilities.levelup[i].tooltip.visible = false
                    Abilities.levelup[i].onEnter = Abilities.onHover
                    Abilities.levelup[i].visible = false
                    Abilities.levelup[i]:setPoint(FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0, 0)
                end
            end

            this.visible = true

            return this
        end

        function Abilities.onHover()
            local b = GetTriggerComponent()
            local unit = GetMainSelectedUnitEx()

            if GetLocalPlayer() == GetTriggerPlayer() then
                if GetHeroSkillPoints(unit) > 0 then
                    BlzFrameSetAllPoints(Abilities.level, b.frame)
                    BlzFrameSetScale(Abilities.level, b.width/0.04)
                else
                    BlzFrameSetAbsPoint(Abilities.level, FRAMEPOINT_TOPLEFT, 999, 999)
                    BlzFrameSetAbsPoint(Abilities.level, FRAMEPOINT_BOTTOMRIGHT, 999, 999)
                end
            end
        end

        function Abilities.onInit()
            Abilities.level = BlzGetFrameByName("CommandButton_7", 0)
            button[0] = BlzGetFrameByName("CommandButton_8", 0)
            button[1] = BlzGetFrameByName("CommandButton_9", 0)
            button[2] = BlzGetFrameByName("CommandButton_10", 0)
            button[3] = BlzGetFrameByName("CommandButton_11", 0)
            button[4] = BlzGetFrameByName("CommandButton_5", 0)
            button[5] = BlzGetFrameByName("CommandButton_6", 0)
            button[6] = BlzGetFrameByName("CommandButton_7", 0)
            button[7] = BlzGetFrameByName("CommandButton_0", 0)
            button[8] = BlzGetFrameByName("CommandButton_1", 0)
            button[9] = BlzGetFrameByName("CommandButton_2", 0)
            button[10] = BlzGetFrameByName("CommandButton_3", 0)
            button[11] = BlzGetFrameByName("CommandButton_4", 0)
        end
    end

    -- --------------------------------------- Inventory --------------------------------------- --
    local Inventory = Class(Panel)

    do
        local slot = {}

        function Inventory:destroy()
            for i = 0, ITEM_SLOT_COUNT - 1 do
                slot[i]:destroy()
            end
        end

        function Inventory.create(x, y, width, height, parent)
            local this = Inventory.allocate(x, y, width, height, parent, "EscMenuBackdrop", false)

            for i = 0, ITEM_SLOT_COUNT - 1 do
                slot[i] = Backdrop.create(ITEM_SLOT_X + (i*ITEM_SLOT_GAP), ITEM_SLOT_Y, ITEM_SLOT_WIDTH, ITEM_SLOT_HEIGHT, this.frame, ITEM_SLOT_TEXTURE)

                BlzFrameSetAbsPoint(BlzGetFrameByName("InventoryButton_" .. I2S(i), 0), FRAMEPOINT_TOPLEFT, x + (ITEM_ICON_X + (i*ITEM_SLOT_GAP)), y + ITEM_ICON_Y)
                BlzFrameSetScale(BlzGetFrameByName("InventoryButton_" .. I2S(i), 0), ITEM_ICON_WIDTH/0.032)
            end

            return this
        end
    end

    -- ---------------------------------------- Minimap ---------------------------------------- --
    local Minimap = Class(Panel)

    do
        Minimap:property("opacity", {
            set = function (self, value)
                BlzFrameSetAlpha(Minimap.minimap, value)
            end
        })

        function Minimap:destroy()
            BlzFrameSetParent(Minimap.minimap, self.parent)
            self.helper.destroy()
        end

        function Minimap.create(x, y, width, height, parent)
            local this = Minimap.allocate(x, y, width, height, parent, "Leaderboard", false)

            this.helper = Panel.create(x, y, width - 0.01, height - 0.01, this.frame, "TransparentBackdrop", false)

            this.helper:setPoint(FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, 0, 0)

            BlzFrameSetParent(Minimap.minimap, this.helper.frame)
            BlzFrameSetAlpha(Minimap.minimap, R2I(MAP_TRANSPARENCY))
            BlzFrameSetAllPoints(Minimap.minimap, this.helper.frame)
            BlzFrameSetVisible(Minimap.minimap, true)

            return this
        end

        function Minimap.onInit()
            Minimap.minimap = BlzGetFrameByName("MiniMapFrame", 0)
        end
    end

    -- --------------------------------------- Attribute --------------------------------------- --
    do
        Attribute = Class(Button)

        local menu
        local panel
        local array = {}
        local attributes = {}
        local timer = CreateTimer()

        Attribute:property("visible", {
            get = function (self) return self.isVisible end,
            set = function (self, value)
                self.isVisible = value
                BlzFrameSetVisible(self.frame, value and self.button.available)
            end
        })

        function Attribute:destroy()
            self.button:destroy()
            self.value:destroy()

            for  i = #attributes, 1, -1 do
                if attributes[i] == self then
                    table.remove(attributes, i)
                end
            end

            if #attributes == 0 then
                PauseTimer(timer)
            end
        end

        function Attribute:update(unit)
        end

        function Attribute.create(x, y, width, height, parent, texture, tooltip, point)
            if parent == nil then
                parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
            end

            if point == nil then
                point = FRAMEPOINT_TOPRIGHT
            end

            local this = Attribute.allocate(x, y, width, height, parent, true, false)

            table.insert(attributes, this)

            this.texture = texture
            this.tooltip.text = tooltip
            this.value = Text.create(ATTRIBUTES_TEXT_X, ATTRIBUTES_TEXT_Y, ATTRIBUTES_TEXT_WIDTH, ATTRIBUTES_TEXT_HEIGHT, ATTRIBUTES_TEXT_SCALE, false, this.frame, nil, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            this.button = Button.create(ATTRIBUTES_BUTTON_X + ((ATTRIBUTES_BUTTON_WIDTH + ATTRIBUTES_BUTTON_GAP) * ModuloInteger(#attributes - 1, ATTRIBUTES_COLUMNS)), - (ATTRIBUTES_BUTTON_Y + ((ATTRIBUTES_BUTTON_HEIGHT + ATTRIBUTES_BUTTON_GAP) * R2I((#attributes - 1)/ATTRIBUTES_COLUMNS))), ATTRIBUTES_BUTTON_WIDTH, ATTRIBUTES_BUTTON_HEIGHT, panel.frame, true, false)
            this.button.texture = texture
            this.button.tooltip.text = tooltip
            this.button.onClick = Attribute.onClicked
            array[this.button] = this
            panel.width = RMaxBJ(panel.width, (ATTRIBUTES_BUTTON_WIDTH * (ModuloInteger(#attributes - 1, ATTRIBUTES_COLUMNS) + 1)) + (2 * ATTRIBUTES_BUTTON_X) + (ATTRIBUTES_BUTTON_GAP * ModuloInteger(#attributes - 1, ATTRIBUTES_COLUMNS)))
            panel.height = RMaxBJ(panel.height, (ATTRIBUTES_BUTTON_HEIGHT * (R2I((#attributes - 1)/ATTRIBUTES_COLUMNS) + 1)) + (2 * ATTRIBUTES_BUTTON_Y) + (ATTRIBUTES_BUTTON_GAP * R2I((#attributes - 1)/ATTRIBUTES_COLUMNS)))

            if point == FRAMEPOINT_LEFT or point == FRAMEPOINT_TOPLEFT or point == FRAMEPOINT_BOTTOMLEFT then
                this.value.horizontal = TEXT_JUSTIFY_RIGHT
                this.value:setPoint(FRAMEPOINT_TOPRIGHT, FRAMEPOINT_TOPLEFT, -ATTRIBUTES_TEXT_X + ATTRIBUTES_WIDTH + 0.005, ATTRIBUTES_TEXT_Y)
            elseif point == FRAMEPOINT_TOP then
                this.value.horizontal = TEXT_JUSTIFY_CENTER
                this.value:setPoint(FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0, ATTRIBUTES_TEXT_Y + 0.005)
            elseif point == FRAMEPOINT_BOTTOM then
                this.value.horizontal = TEXT_JUSTIFY_CENTER
                this.value:setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, -ATTRIBUTES_TEXT_Y - 0.005)
            end

            if #attributes == 1 then
                TimerStart(timer, 0.2, true, Attribute.onUpdate)
            end

            return this
        end

        function Attribute.onClicked()
            local button = GetTriggerComponent()
            local this = array[button]

            if GetLocalPlayer() == GetTriggerPlayer() then
                if button == menu then
                    panel.visible = not panel.visible

                    if panel.visible then
                        button.texture = ATTRIBUTES_TOGGLE_CLOSE
                        button.tooltip.text = "Close Attribute Menu"
                    else
                        button.texture = ATTRIBUTES_TOGGLE_OPEN
                        button.tooltip.text = "Open Attribute Menu"
                    end
                else
                    this.button.available = not this.button.available
                    this.visible = this.visible
                end
            end
        end

        function Attribute.onUpdate()
            local unit = GetMainSelectedUnitEx()

            for  i = #attributes, 1, -1 do
                attributes[i]:update(unit)
            end
        end

        function Attribute.onInit()
            menu = Button.create(INFO_X + INFO_WIDTH/2 - ATTRIBUTES_TOGGLE_WIDTH/2, INFO_Y - 0.004, ATTRIBUTES_TOGGLE_WIDTH, ATTRIBUTES_TOGGLE_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), true, false)
            menu.texture = ATTRIBUTES_TOGGLE_OPEN
            menu.tooltip.text = "Open Attribute Menu"
            menu.onClick = Attribute.onClicked
            panel = Panel.create(0, 0, 0.03, 0.03, menu.frame, "Leaderboard", false)
            panel.visible = false

            panel:setPoint(FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0, BUFF_Y)
        end
    end

    -- --------------------------------------- Interface --------------------------------------- --
    do
        Interface = Class()

        local hero = {}
        local highlight = {}

        Interface:property("heroes", {
            set = function (self, value)
                if value then
                    for i = 0, 6 do
                        BlzFrameSetAbsPoint(hero[i], FRAMEPOINT_TOPLEFT, HERO_LIST_X, HERO_LIST_Y - (i*HERO_LIST_GAP))
                        BlzFrameSetScale(hero[i], HERO_LIST_WIDTH/0.038)
                        BlzFrameSetScale(highlight[i], HERO_LIST_WIDTH/0.038)
                    end
                else
                    for i = 0, 6 do
                        BlzFrameSetAbsPoint(hero[i], FRAMEPOINT_TOPLEFT, 999, 999)
                    end
                end
            end
        })

        function Interface.onPeriod()
            local player = GetLocalPlayer()
            local unit = GetMainSelectedUnitEx()
            local shop = IsUnitShop(unit, player)
            local points = GetHeroSkillPoints(unit)

            if not IsUnitVisible(unit, player) then
                unit = nil
            end

            Interface.portrait:update(unit, player)

            Interface.gold.text = BlzFrameGetText(Interface.coin)
            Interface.lumber.text = BlzFrameGetText(Interface.wood)

            if DISPLAY_SHOP then
                Interface.grid.visible = shop
                Interface.abilities.visible = not Interface.grid.visible

                if Interface.grid.visible then
                    BlzFrameSetPoint(Interface.tooltip, FRAMEPOINT_BOTTOM, Interface.grid.frame, FRAMEPOINT_TOP, 0, 0)
                else
                    BlzFrameSetPoint(Interface.tooltip, FRAMEPOINT_BOTTOM, Interface.portrait.frame, FRAMEPOINT_TOP, 0, BUFF_Y)
                end
            end

            if SEPARATE_LEVELUP then
                for i = 0, ABILITY_SLOT_COUNT - 1 do
                    Interface.abilities.levelup[i].visible = points > 0 and not Interface.grid.visible and GetOwningPlayer(unit) == player
                end

                if (not shop and points <= 0) or (shop and not DISPLAY_SHOP) then
                    BlzFrameSetAbsPoint(Interface.abilities.level, FRAMEPOINT_TOPLEFT, 999, 999)
                    BlzFrameSetAbsPoint(Interface.abilities.level, FRAMEPOINT_BOTTOMRIGHT, 999, 999)
                end
            end
        end

        function Interface.onInit()
            if BlzGetLocalClientWidth() > 1920 then
                HERO_LIST_X = -0.315
                MINIMAP_LEFT_X = -0.32
                MINIMAP_RIGHT_X = 0.97
                PORTRAIT_X = PORTRAIT_X + 0.01
                PORTRAIT_WIDTH = PORTRAIT_WIDTH - 0.02
            end

            Interface.coin = BlzGetFrameByName("ResourceBarGoldText" , 0)
            Interface.wood = BlzGetFrameByName("ResourceBarLumberText" , 0)
            Interface.default = BlzGetFrameByName("UpperButtonBarFrame", 0)
            Interface.tooltip = BlzGetOriginFrame(ORIGIN_FRAME_UBERTOOLTIP , 0)
            Interface.map = Minimap.create(MINIMAP_LEFT_X, MINIMAP_LEFT_Y, MINIMAP_WIDTH, MINIMAP_HEIGHT, BlzGetFrameByName("ConsoleUIBackdrop", 0))
            Interface.menu = Menu.create(MENU_X, MENU_Y, MENU_WIDTH, MENU_HEIGHT, nil)
            Interface.portrait = Portrait.create(INFO_X, INFO_Y, INFO_WIDTH, INFO_HEIGHT, nil)
            Interface.grid = Grid.create(SHOP_PANEL_X, SHOP_PANEL_Y, SHOP_COLUMNS*SHOP_SLOT_WIDTH + 0.032, SHOP_SLOT_HEIGHT*SHOP_ROWS + 0.034, nil)
            Interface.gold = Resource.create(GOLD_BACKGROUND_X, GOLD_BACKGROUND_Y, GOLD_BACKGROUND_WIDTH, GOLD_BACKGROUND_HEIGHT, Interface.menu.frame, true)
            Interface.lumber = Resource.create(LUMBER_BACKGROUND_X, LUMBER_BACKGROUND_Y, LUMBER_BACKGROUND_WIDTH, LUMBER_BACKGROUND_HEIGHT, Interface.menu.frame, false)
            Interface.abilities = Abilities.create(ABILITY_PANEL_X, ABILITY_PANEL_Y, ABILITY_SLOT_COUNT*ABILITY_SLOT_WIDTH + 0.032, ABILITY_SLOT_HEIGHT + 0.034, nil)
            Interface.inventory = Inventory.create(ITEM_PANEL_X, ITEM_PANEL_Y, ITEM_SLOT_COUNT*ITEM_SLOT_WIDTH + 0.032, ITEM_SLOT_HEIGHT + 0.034, nil)

            for i = 0, 6 do
                hero[i] = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, i)
                highlight[i] = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, i)
            end

            for i = 0, 11 do
                local frame = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), i), 1)

                if i >= 6 then
                    BlzFrameSetAbsPoint(frame, FRAMEPOINT_TOPLEFT, ITEM_PANEL_X + (GROUP_X + ((i - 6)*GROUP_GAP)), ITEM_PANEL_Y + GROUP_Y)
                    BlzFrameSetAbsPoint(frame, FRAMEPOINT_BOTTOMRIGHT, ITEM_PANEL_X + (GROUP_X + ((i - 6)*GROUP_GAP)) + GROUP_WIDTH, ITEM_PANEL_Y + GROUP_Y - GROUP_HEIGHT)
                else
                    BlzFrameSetAbsPoint(frame, FRAMEPOINT_TOPLEFT, ABILITY_PANEL_X + (GROUP_X + (i*GROUP_GAP)), ABILITY_PANEL_Y + GROUP_Y)
                    BlzFrameSetAbsPoint(frame, FRAMEPOINT_BOTTOMRIGHT, ABILITY_PANEL_X + (GROUP_X + (i*GROUP_GAP)) + GROUP_WIDTH, ABILITY_PANEL_Y + GROUP_Y - GROUP_HEIGHT)
                end
            end

            BlzEnableUIAutoPosition(false)
            BlzFrameSetParent(Interface.tooltip, BlzGetFrameByName("ConsoleUI", 0))
            BlzFrameSetAlpha(BlzGetFrameByName("SimpleInventoryCover", 0), 0)
            BlzFrameSetScale(BlzGetFrameByName("InventoryText", 0), 0.0001)
            BlzFrameSetScale(BlzGetFrameByName("SimpleNameValue", 0), 0.00001)
            BlzFrameSetScale(BlzGetFrameByName("SimpleClassValue", 0), 0.00001)
            BlzFrameSetScale(BlzGetFrameByName("SimpleBuildingNameValue", 1), 0.00001)
            BlzFrameSetScale(BlzGetFrameByName("SimpleBuildingActionLabel", 1), 0.00001)
            BlzFrameSetScale(BlzGetFrameByName("SimpleHoldNameValue", 2), 0.00001)
            BlzFrameSetScale(BlzGetFrameByName("SimpleHoldDescriptionNameValue", 2), 0.00001)
            BlzFrameSetScale(BlzGetFrameByName("SimpleItemNameValue", 3), 0.00001)
            BlzFrameSetScale(BlzGetFrameByName("SimpleItemDescriptionValue", 3), 0.00001)
            BlzFrameSetScale(BlzGetFrameByName("SimpleDestructableNameValue", 4), 0.00001)
            BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR_LABEL, 0), 0.00001)
            BlzFrameSetVisible(Interface.default, false)
            BlzFrameSetVisible(BlzFrameGetChild(BlzGetFrameByName("ConsoleBottomBar", 0), 3), false)
            BlzFrameSetVisible(BlzFrameGetChild(BlzFrameGetChild(BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 5),0), false)
            BlzFrameSetPoint(Interface.tooltip, FRAMEPOINT_BOTTOM, Interface.portrait.frame, FRAMEPOINT_TOP, 0, BUFF_Y)
            BlzFrameSetAbsPoint(BlzGetFrameByName("ConsoleUI", 0), FRAMEPOINT_TOPLEFT, 0.0, 0.633)
            BlzFrameSetAbsPoint(BlzGetFrameByName("ResourceBarFrame", 0), FRAMEPOINT_TOPLEFT, 999, 999)
            BlzFrameSetAbsPoint(BlzGetFrameByName("ResourceBarFrame", 0), FRAMEPOINT_BOTTOMRIGHT, 999, 999)
            BlzFrameSetAbsPoint(BlzGetFrameByName("SimpleProgressIndicator", 0), FRAMEPOINT_TOPLEFT, INFO_X + PROGRESS_X, INFO_Y + PROGRESS_Y)
            BlzFrameSetAbsPoint(BlzGetFrameByName("SimpleProgressIndicator", 0), FRAMEPOINT_BOTTOMRIGHT, INFO_X + PROGRESS_X + PROGRESS_WIDTH, INFO_Y + PROGRESS_Y - PROGRESS_HEIGHT)
            BlzFrameSetAbsPoint(BlzGetFrameByName("SimpleHeroLevelBar", 0), FRAMEPOINT_TOPLEFT, INFO_X + PROGRESS_X, INFO_Y + PROGRESS_Y)
            BlzFrameSetAbsPoint(BlzGetFrameByName("SimpleHeroLevelBar", 0), FRAMEPOINT_BOTTOMRIGHT, INFO_X + PROGRESS_X + PROGRESS_WIDTH, INFO_Y + PROGRESS_Y - PROGRESS_HEIGHT)
            BlzFrameSetAbsPoint(BlzGetFrameByName("SimpleBuildTimeIndicator", 1), FRAMEPOINT_TOPLEFT, INFO_X + PROGRESS_X, INFO_Y + PROGRESS_Y)
            BlzFrameSetAbsPoint(BlzGetFrameByName("SimpleBuildTimeIndicator", 1), FRAMEPOINT_BOTTOMRIGHT, INFO_X + PROGRESS_X + PROGRESS_WIDTH, INFO_Y + PROGRESS_Y - PROGRESS_HEIGHT)
            BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_CHAT_MSG, 0), FRAMEPOINT_TOPLEFT, CHAT_X, CHAT_Y)
            BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_CHAT_MSG, 0), FRAMEPOINT_BOTTOMRIGHT, CHAT_X + CHAT_WIDTH, CHAT_Y - CHAT_HEIGHT)
            BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_UNIT_MSG, 0), FRAMEPOINT_TOPLEFT, CHAT_X, CHAT_Y)
            BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_UNIT_MSG, 0), FRAMEPOINT_BOTTOMRIGHT, CHAT_X + CHAT_WIDTH, CHAT_Y - CHAT_HEIGHT)
            BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR, 0), FRAMEPOINT_TOPLEFT, INFO_X + BUFF_X, INFO_Y + BUFF_Y)
            BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR, 0), FRAMEPOINT_BOTTOMRIGHT, INFO_X + BUFF_X + BUFF_WIDTH, INFO_Y + BUFF_Y - BUFF_HEIGHT)
            TimerStart(CreateTimer(), 0.1, true, Interface.onPeriod)
        end
    end
end)