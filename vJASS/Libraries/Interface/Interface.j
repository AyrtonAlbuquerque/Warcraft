library Interface requires Table, RegisterPlayerUnitEvent, GetMainSelectedUnit, Components
    /* ------------------------------------- Interface v2.0 ------------------------------------ */
    // Credits
    //      - Bribe          - Table
    //      - Tasyen         - GetMainSelectedUnit
    //      - Magtheridon96  - RegisterPlayerUnitEvent
    /* -------------------------------------- By Chopinski ------------------------------------- */

    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    globals
        /* --------------------------------------- Info Panel -------------------------------------- */
        // The initial position of the info panel
        private constant real INFO_X = 0.34
        private constant real INFO_Y = 0.11
        // The size of the info panel
        private constant real INFO_WIDTH = 0.12
        private constant real INFO_HEIGHT = 0.15
        /* ---------------------------------------- Portrait --------------------------------------- */
        // The initial position of the portrait (relative to the info panel)
        private real PORTRAIT_X = 0.017
        private constant real PORTRAIT_Y = -0.017
        // Size of the portrait
        private real PORTRAIT_WIDTH = 0.085
        private constant real PORTRAIT_HEIGHT = 0.09
        // Portrait darkness level (0 -> Normal, > 0 -> Darker)
        private constant integer PORTRAIT_DARKNESS = 104
        /* --------------------------------------- Health Bar -------------------------------------- */
        // The initial position of the health bar (relative to the info panel)
        private constant real HEALTH_X = 0.017
        private constant real HEALTH_Y = -0.092
        // Size of the health bar
        private constant real HEALTH_WIDTH = 0.085
        private constant real HEALTH_HEIGHT = 0.0075
        // The health bar texture
        private constant string HEALTH_TEXTURE = "replaceabletextures\\teamcolor\\teamcolor00"
        // The size of the health text
        private constant real HEALTH_TEXT_SCALE = 0.65
        // The transparency of the health bar (0 -> 100%, 255 -> 0%)
        private constant integer HEALTH_TRANSPARENCY = 128
        /* ---------------------------------------- Mana Bar --------------------------------------- */
        // The initial position of the mana bar (relative to the info panel)
        private constant real MANA_X = 0.017
        private constant real MANA_Y = -0.0995
        // Size of the mana bar
        private constant real MANA_WIDTH = 0.085
        private constant real MANA_HEIGHT = 0.0075
        // The mana bar texture
        private constant string MANA_TEXTURE = "replaceabletextures\\teamcolor\\teamcolor01"
        // The size of the mana text
        private constant real MANA_TEXT_SCALE = 0.65
        // The transparency of the mana bar (0 -> 100%, 255 -> 0%)
        private constant integer MANA_TRANSPARENCY = 128
        /* -------------------------------------- Progress Bar ------------------------------------- */
        // The initial position of the xp/timed life/progess bar (relative to the info panel)
        private constant real PROGRESS_X = 0.017
        private constant real PROGRESS_Y = -0.107
        // Size of the progress bar
        private constant real PROGRESS_WIDTH = 0.085
        private constant real PROGRESS_HEIGHT = 0.003
        // The initial position of the buffs bar (relative to the info panel)
        /* ---------------------------------------- Buff Bar --------------------------------------- */
        private constant real BUFF_X = 0.006
        private constant real BUFF_Y = 0.012
        // Size of the buffs bar
        private constant real BUFF_WIDTH = 0.1235
        private constant real BUFF_HEIGHT = 0.015
        /* --------------------------------------- Attributes -------------------------------------- */
        // The Initial position of the attributes buttons (relative to the info panel)
        private constant real ATTRIBUTES_X = 0.017
        private constant real ATTRIBUTES_Y = -0.02
        // The gap between each button
        private constant real ATTRIBUTES_GAP = 0.014
        // The size of the attributes buttons
        private constant real ATTRIBUTES_WIDTH = 0.0125
        private constant real ATTRIBUTES_HEIGHT = 0.0125
        // The position of the attributes text (relative to the attributes buttons)
        private constant real ATTRIBUTES_TEXT_X = 0.02
        private constant real ATTRIBUTES_TEXT_Y = -0.0025
        // The size of the attributes text
        private constant real ATTRIBUTES_TEXT_WIDTH = 0.15
        private constant real ATTRIBUTES_TEXT_HEIGHT = 0.0125
        private constant real ATTRIBUTES_TEXT_SCALE = 0.65
        /* ------------------------------------ Attributes Panel ----------------------------------- */
        // The size of the attributes toggle button
        private constant real ATTRIBUTES_TOGGLE_WIDTH = 0.0125
        private constant real ATTRIBUTES_TOGGLE_HEIGHT = 0.0125
        // The attributes toggle button textures
        private constant string ATTRIBUTES_TOGGLE_OPEN = "UI\\Minimap\\minimap-gold.blp"
        private constant string ATTRIBUTES_TOGGLE_CLOSE = "UI\\Widgets\\EscMenu\\Human\\radiobutton-button.blp"
        // The initial offsets of the buttons (relative to the panel)
        private constant real ATTRIBUTES_BUTTON_X = 0.005
        private constant real ATTRIBUTES_BUTTON_Y = 0.005
        // The width and height of the attributes buttons
        private constant real ATTRIBUTES_BUTTON_WIDTH = 0.02
        private constant real ATTRIBUTES_BUTTON_HEIGHT = 0.02
        // The gap between each button
        private constant real ATTRIBUTES_BUTTON_GAP = 0.001
        // The panel maximum columns
        private constant integer ATTRIBUTES_COLUMNS = 5
        /* ----------------------------------------- Damage ---------------------------------------- */
        // The damage button texture
        private constant string DAMAGE_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNAttack.blp"
        /* ----------------------------------------- Armor ----------------------------------------- */
        // The armor button texture
        private constant string ARMOR_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpOne.blp"
        /* ---------------------------------------- Strenght --------------------------------------- */
        // The strength button texture
        private constant string STRENGTH_TEXTURE = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-str.blp"
        /* ---------------------------------------- Agility ---------------------------------------- */
        // The agility button texture
        private constant string AGILITY_TEXTURE = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-agi.blp"
        /* -------------------------------------- Intelligence ------------------------------------- */
        // The intelligence button texture
        private constant string INTELLIGENCE_TEXTURE = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-int.blp"
        /* ---------------------------------- Attribute Highlight ---------------------------------- */
        // Main attribute highlight
        private constant string ATTRIBUTE_HIGHLIGHT = "goldenbrown.mdx"
        private constant real HIGHLIGHT_SCALE = 0.125
        private constant real HIGHLIGHT_XOFFSET = 0.052
        private constant real HIGHLIGHT_YOFFSET = 0.048
        /* ------------------------------------- Ability Panel ------------------------------------- */
        // The initial position of the abilities panel
        private constant real ABILITY_PANEL_X = 0.105
        private constant real ABILITY_PANEL_Y = 0.055
        // Size of the ability slots
        private constant real ABILITY_SLOT_WIDTH = 0.038
        private constant real ABILITY_SLOT_HEIGHT = 0.038
        // The initial position of the abilities slot inside the panel (relative to the panel)
        private constant real ABILITY_SLOT_X = 0.017
        private constant real ABILITY_SLOT_Y = -0.017
        // The initial position of the ability icon inside the slot (relative to the slot)
        private constant real ABILITY_ICON_X = 0.02
        private constant real ABILITY_ICON_Y = -0.02
        // Size of the ability icons
        private constant real ABILITY_ICON_WIDTH = 0.032
        private constant real ABILITY_ICON_HEIGHT = 0.032
        // Gap between each slot
        private constant real ABILITY_SLOT_GAP = 0.0375
        // Numbers of slots
        private constant integer ABILITY_SLOT_COUNT = 6
        // Set this to a texture to replace the default gold icon
        private constant string ABILITY_SLOT_TEXTURE = "SpellSlot.blp"
        /* --------------------------------------- Item Panel -------------------------------------- */
        // The initial position of the item panel
        private constant real ITEM_PANEL_X = 0.435
        private constant real ITEM_PANEL_Y = 0.055
        // Size of the item slots
        private constant real ITEM_SLOT_WIDTH = 0.038
        private constant real ITEM_SLOT_HEIGHT = 0.038
        // The initial position of the item slot inside the panel (relative to the panel)
        private constant real ITEM_SLOT_X = 0.017
        private constant real ITEM_SLOT_Y = -0.017
        // The initial position of the item icon inside the slot (relative to the slot)
        private constant real ITEM_ICON_X = 0.02
        private constant real ITEM_ICON_Y = -0.02
        // Size of the item icons
        private constant real ITEM_ICON_WIDTH = 0.032
        private constant real ITEM_ICON_HEIGHT = 0.032
        // Gap between each slot
        private constant real ITEM_SLOT_GAP = 0.0375
        // Numbers of slots
        private constant integer ITEM_SLOT_COUNT = 6
        // Set this to a texture to replace the default gold icon
        private constant string ITEM_SLOT_TEXTURE = "ItemSlot.blp"
        /* --------------------------------------- Hero List --------------------------------------- */
        // The initial position of the first hero icon
        private real HERO_LIST_X = -0.128
        private constant real HERO_LIST_Y = 0.573
        // Size of the hero icon
        private constant real HERO_LIST_WIDTH = 0.038
        private constant real HERO_LIST_HEIGHT = 0.038
        // The gap between each icon
        private constant real HERO_LIST_GAP = 0.0505
        /* ------------------------------------------ Chat ----------------------------------------- */
        // The initial position of the chat
        private constant real CHAT_X = 0.00
        private constant real CHAT_Y = 0.35
        // The size of the chat
        private constant real CHAT_WIDTH = 0.35
        private constant real CHAT_HEIGHT = 0.2
        /* ------------------------------------ Group Selection ------------------------------------ */
        // The initial position of the first group buttons (relative to the abilities and item panels)
        private constant real GROUP_X = 0.0235
        private constant real GROUP_Y = 0.04
        // Size of the group buttons
        private constant real GROUP_WIDTH = 0.025
        private constant real GROUP_HEIGHT = 0.025
        // Gap between each button
        private constant real GROUP_GAP = 0.0375
        /* ------------------------------------------ Menu ----------------------------------------- */
        // The initial position of the menu button
        private constant real MENU_X = 0.39
        private constant real MENU_Y = 0.60
        // The size of the menu button
        private constant real MENU_WIDTH = 0.02
        private constant real MENU_HEIGHT = 0.02
        // The menu button texture
        private constant string OPEN_MENU_TEXTURE = "UI\\Widgets\\Glues\\Gluescreen-Scrollbar-DownArrow.blp"
        private constant string CLOSE_MENU_TEXTURE = "UI\\Widgets\\Glues\\Gluescreen-Scrollbar-UpArrow.blp"
        // The initial position of the menu frame
        private constant real MENU_FRAME_X = -0.19
        private constant real MENU_FRAME_Y = -0.02
        // The size of the menu frame
        private constant real MENU_FRAME_WIDTH = 0.40
        private constant real MENU_FRAME_HEIGHT = 0.25
        /* -------------------------------------- Menu Options ------------------------------------- */
        private constant real MENU_X_OFFSET = 0.04
        private constant real MENU_Y_OFFSET = -0.025
        private constant real MENU_Y_GAP = -0.005
        private constant real CHECK_WIDTH = 0.015
        private constant real CHECK_HEIGHT = 0.015
        private constant real CHECK_TEXT_X = 0.002
        private constant real CHECK_TEXT_Y = 0.0
        private constant real CHECK_TEXT_WIDTH = 0.2
        private constant real CHECK_TEXT_HEIGHT = 0.015
        private constant real CHECK_TEXT_SCALE = 1
        private constant real SLIDER_WIDTH = 0.30
        private constant real SLIDER_HEIGHT = 0.015
        private constant real SLIDER_TEXT_WIDTH = 0.15
        private constant real SLIDER_TEXT_HEIGHT = 0.015
        /* ------------------------------------------ Gold ----------------------------------------- */
        // The initial position of the gold background (relative to the menu button)
        private constant real GOLD_BACKGROUND_X = 0.0165
        private constant real GOLD_BACKGROUND_Y = 0.0025
        // The size of the gold background
        private constant real GOLD_BACKGROUND_WIDTH = 0.07
        private constant real GOLD_BACKGROUND_HEIGHT = 0.0225
        // The initial position of the gold icon (relative to the gold background)
        private constant real GOLD_ICON_X = 0.005
        private constant real GOLD_ICON_Y = -0.005
        // The size of the gold icon
        private constant real GOLD_ICON_WIDTH = 0.0125
        private constant real GOLD_ICON_HEIGHT = 0.0125
        // The gold icon texture
        private constant string GOLD_ICON_TEXTURE = "UI\\Feedback\\Resources\\ResourceGold.blp"
        // The initial position of the gold text (relative to the gold icon)
        private constant real GOLD_TEXT_X = 0.013
        private constant real GOLD_TEXT_Y = 0.0
        // The size of the gold text
        private constant real GOLD_TEXT_WIDTH = 0.0575
        private constant real GOLD_TEXT_HEIGHT = 0.0125
        private constant real GOLD_TEXT_SCALE = 1.0
        /* ----------------------------------------- Lumber ---------------------------------------- */
        // The initial position of the lumber background (relative to the menu button)
        private constant real LUMBER_BACKGROUND_X = -0.067
        private constant real LUMBER_BACKGROUND_Y = 0.0025
        // The size of the lumber background
        private constant real LUMBER_BACKGROUND_WIDTH = 0.07
        private constant real LUMBER_BACKGROUND_HEIGHT = 0.0225
        // The initial position of the lumber icon (relative to the lumber background)
        private constant real LUMBER_ICON_X = 0.0525
        private constant real LUMBER_ICON_Y = -0.005
        // The size of the lumber icon
        private constant real LUMBER_ICON_WIDTH = 0.0125
        private constant real LUMBER_ICON_HEIGHT = 0.0125
        // The lumber icon texture
        private constant string LUMBER_ICON_TEXTURE = "UI\\Feedback\\Resources\\ResourceLumber.blp"
        // The initial position of the lumber text (relative to the lumber icon)
        private constant real LUMBER_TEXT_X = -0.06
        private constant real LUMBER_TEXT_Y = 0.0
        // The size of the lumber text
        private constant real LUMBER_TEXT_WIDTH = 0.0575
        private constant real LUMBER_TEXT_HEIGHT = 0.0125
        private constant real LUMBER_TEXT_SCALE = 1.0
        /* ---------------------------------------- Minimap ---------------------------------------- */
        // The min/max x position of the minimap when on the right side of the screen
        private constant real MINIMAP_RIGHT_MIN = 0.785
        private constant real MINIMAP_RIGHT_MAX = 0.97
        // the min/max x position of the minimap when on the left side of the screen
        private constant real MINIMAP_LEFT_MIN = -0.32
        private constant real MINIMAP_LEFT_MAX = -0.135
        // The minimap y
        private constant real MINIMAP_Y = 0.15
        // The size of the minimap
        private constant real MINIMAP_WIDTH = 0.15
        private constant real MINIMAP_HEIGHT = 0.15
        // Minimap initial transparency (0 -> 100%, 255 -> 0%)
        private constant real MAP_TRANSPARENCY = 57
        // The minimap toggle key
        private constant oskeytype MINIMAP_TOGGLE_KEY = OSKEY_TAB
        /* ------------------------------------------ Shop ----------------------------------------- */
        // The initial position of the shop panel
        private constant real SHOP_PANEL_X = 0.308
        private constant real SHOP_PANEL_Y = 0.25
        // The initial position of the first shop slot inside the panel (relative to the panel)
        private constant real SHOP_SLOT_X = 0.017
        private constant real SHOP_SLOT_Y = -0.017
        // Size of the shop slots
        private constant real SHOP_SLOT_WIDTH = 0.038
        private constant real SHOP_SLOT_HEIGHT = 0.038
        // The shop slot texture
        private constant string SHOP_SLOT_TEXTURE = "SpellSlot.blp"
        // The initial position of the shop icon inside the slot (relative to the slot)
        private constant real SHOP_ICON_X = 0.02
        private constant real SHOP_ICON_Y = -0.02
        // Size of the shop icons
        private constant real SHOP_ICON_WIDTH = 0.032
        private constant real SHOP_ICON_HEIGHT = 0.032
        // Number of columns
        private constant integer SHOP_COLUMNS = 4
        // Number of rows
        private constant integer SHOP_ROWS = 3
        // Total count
        private constant integer SHOP_COUNT = SHOP_ROWS * SHOP_COLUMNS
        // Gap between each slot
        private constant real SHOP_SLOT_GAP = 0.0375
        // When true and a unit that has "Select Unit" or "Select Hero" or "Shop Purchase Item" 
        // abilities is selected a panel above the portrait is created to show the items/units
        private constant boolean DISPLAY_SHOP = true
        /* ----------------------------------- Hero skill button ----------------------------------- */
        // If true, the + icon will be displayed on top of all abilities when the hero has a skill point
        private constant boolean SEPARATE_LEVELUP = true
        // The size of the + icon
        private constant real SEPARATE_LEVELUP_WIDTH = 0.0125
        private constant real SEPARATE_LEVELUP_HEIGHT = 0.0125
        // The + icon texture
        private constant string SEPARATE_LEVELUP_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNSkillz.blp"
        /* -------------------------------------- Damage Value ------------------------------------- */
        // If true the damage value will be trimmed to show only the last value (xx - xx + yy) => (xx + yy)
        private constant boolean TRIM_DAMAGE = true
    endglobals

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function IsUnitShop takes unit u, player p returns boolean
        return (GetUnitAbilityLevel(u, 'Aneu') > 0 or GetUnitAbilityLevel(u, 'Ane2') > 0 or GetUnitAbilityLevel(u, 'Apit') > 0) and not IsUnitEnemy(u, p)
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private struct Resource extends Panel
        private Text value
        private Backdrop image

        method operator text= takes string value returns nothing
            set this.value.text = value
        endmethod

        method operator text takes nothing returns string
            return value.text
        endmethod

        method operator icon= takes string texture returns nothing
            set image.texture = texture
        endmethod

        method operator icon takes nothing returns string
            return image.texture
        endmethod

        method destroy takes nothing returns nothing
            call value.destroy()
            call image.destroy()
            call deallocate()
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent, boolean gold returns thistype
            local thistype this = thistype.allocate(x, y, width, height, parent, "Leaderboard", false)

            if gold then
                set image = Backdrop.create(GOLD_ICON_X, GOLD_ICON_Y, GOLD_ICON_WIDTH, GOLD_ICON_HEIGHT, frame, GOLD_ICON_TEXTURE)
                set value = Text.create(GOLD_TEXT_X, GOLD_TEXT_Y, GOLD_TEXT_WIDTH, GOLD_TEXT_HEIGHT, GOLD_TEXT_SCALE, false, image.frame, null, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            else
                set image = Backdrop.create(LUMBER_ICON_X, LUMBER_ICON_Y, LUMBER_ICON_WIDTH, LUMBER_ICON_HEIGHT, frame, LUMBER_ICON_TEXTURE)
                set value = Text.create(LUMBER_TEXT_X, LUMBER_TEXT_Y, LUMBER_TEXT_WIDTH, LUMBER_TEXT_HEIGHT, LUMBER_TEXT_SCALE, false, image.frame, null, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_RIGHT)
            endif

            return this
        endmethod
    endstruct

    private struct Options extends Panel
        private static trigger key = CreateTrigger()
        private static Table table

        CheckBox right
        Text rightText
        CheckBox toggle
        Text toggleText
        CheckBox heroes
        Text heroesText
        CheckBox default
        Text defaultText
        Slider slider
        Text sliderText
        Slider shader
        Text shaderText
        Text mapText
        Slider mapSlider

        method destroy takes nothing returns nothing
            call right.destroy()
            call toggle.destroy()
            call heroes.destroy()
            call slider.destroy()
            call shader.destroy()
            call default.destroy()
            call rightText.destroy()
            call toggleText.destroy()
            call heroesText.destroy()
            call defaultText.destroy()
            call sliderText.destroy()
            call shaderText.destroy()
            call mapText.destroy()
            call mapSlider.destroy()
            call deallocate()
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent returns thistype
            local integer i = 0
            local thistype this = thistype.allocate(x, y, width, height, parent, "EscMenuBackdrop", false)

            set right = CheckBox.create(MENU_X_OFFSET, MENU_Y_OFFSET, CHECK_WIDTH, CHECK_HEIGHT, frame, "QuestCheckBox")
            set right.onCheck = function thistype.onChecked
            set right.onUncheck = function thistype.onUnchecked
            set rightText = Text.create(0, 0, CHECK_TEXT_WIDTH, CHECK_TEXT_HEIGHT, CHECK_TEXT_SCALE, false, right.frame, "|cffffffffShow Minimap on the Right|r", TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            set toggle = CheckBox.create(0, 0, CHECK_WIDTH, CHECK_HEIGHT, right.frame, "QuestCheckBox")
            set toggle.onCheck = function thistype.onChecked
            set toggle.onUncheck = function thistype.onUnchecked
            set toggleText = Text.create(0, 0, CHECK_TEXT_WIDTH, CHECK_TEXT_HEIGHT, CHECK_TEXT_SCALE, false, toggle.frame, "|cffffffffEnable Minimap Toggle (Hold Tab)|r", TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            set heroes = CheckBox.create(0, 0, CHECK_WIDTH, CHECK_HEIGHT, toggle.frame, "QuestCheckBox")
            set heroes.onCheck = function thistype.onChecked
            set heroes.onUncheck = function thistype.onUnchecked
            set heroesText = Text.create(0, 0, CHECK_TEXT_WIDTH, CHECK_TEXT_HEIGHT, CHECK_TEXT_SCALE, false, heroes.frame, "|cffffffffShow Heroes Bar|r", TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            set default = CheckBox.create(0, 0, CHECK_WIDTH, CHECK_HEIGHT, heroes.frame, "QuestCheckBox")
            set default.onCheck = function thistype.onChecked
            set default.onUncheck = function thistype.onUnchecked
            set defaultText = Text.create(0, 0, CHECK_TEXT_WIDTH, CHECK_TEXT_HEIGHT, CHECK_TEXT_SCALE, false, default.frame, "|cffffffffShow Default Menu|r", TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            set sliderText = Text.create(0, 0, SLIDER_TEXT_WIDTH, SLIDER_TEXT_HEIGHT, CHECK_TEXT_SCALE, false, default.frame, "|cffffffffMinimap Opacity: " + I2S(R2I((MAP_TRANSPARENCY*100)/255)) + "%|r", TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
            set slider = Slider.create(0, 0, SLIDER_WIDTH, SLIDER_HEIGHT, sliderText.frame, "EscMenuSliderTemplate")
            set slider.max = 255
            set slider.value = MAP_TRANSPARENCY
            set slider.onSlide = function thistype.onSlider
            set shaderText = Text.create(0, 0, SLIDER_TEXT_WIDTH, SLIDER_TEXT_HEIGHT, CHECK_TEXT_SCALE, false, slider.frame, "|cffffffffPortrait Opacity: " + I2S(R2I((PORTRAIT_DARKNESS*100)/255)) + "%|r", TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
            set shader = Slider.create(0, 0, SLIDER_WIDTH, SLIDER_HEIGHT, shaderText.frame, "EscMenuSliderTemplate")
            set shader.max = 255
            set shader.value = PORTRAIT_DARKNESS
            set shader.onSlide = function thistype.onSlider
            set mapText = Text.create(0, 0, CHECK_TEXT_WIDTH, CHECK_TEXT_HEIGHT, CHECK_TEXT_SCALE, false, shader.frame, "|cffffffffMinimap Position|r", TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
            set mapSlider = Slider.create(0, 0, SLIDER_WIDTH, SLIDER_HEIGHT, mapText.frame, "EscMenuSliderTemplate")
            set mapSlider.min = MINIMAP_LEFT_MIN
            set mapSlider.max = MINIMAP_LEFT_MAX
            set mapSlider.step = 0.00185
            set mapSlider.value = MINIMAP_LEFT_MAX
            set mapSlider.onSlide = function thistype.onSlider
            set table[right] = this
            set table[toggle] = this
            set table[heroes] = this
            set table[shader] = this
            set table[slider] = this
            set table[default] = this
            set table[mapSlider] = this

            call right.setPoint(FRAMEPOINT_TOPLEFT, FRAMEPOINT_TOPLEFT, MENU_X_OFFSET, MENU_Y_OFFSET)
            call rightText.setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, CHECK_TEXT_X, CHECK_TEXT_Y)
            call toggle.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, MENU_Y_GAP)
            call toggleText.setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, CHECK_TEXT_X, CHECK_TEXT_Y)
            call heroes.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, MENU_Y_GAP)
            call heroesText.setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, CHECK_TEXT_X, CHECK_TEXT_Y)
            call default.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, MENU_Y_GAP)
            call defaultText.setPoint(FRAMEPOINT_LEFT, FRAMEPOINT_RIGHT, CHECK_TEXT_X, CHECK_TEXT_Y)
            call sliderText.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, width/2 - MENU_X_OFFSET - 0.0075, MENU_Y_GAP)
            call slider.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, MENU_Y_GAP)
            call shaderText.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, MENU_Y_GAP)
            call shader.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, MENU_Y_GAP)
            call mapText.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, MENU_Y_GAP)
            call mapSlider.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, MENU_Y_GAP)

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    set table[GetHandleId(Player(i))] = this
                set i = i + 1
            endloop

            return this
        endmethod

        private static method onKey takes nothing returns nothing
            local thistype this = table[GetHandleId(GetTriggerPlayer())]

            if GetLocalPlayer() == GetTriggerPlayer() then
                if toggle.checked then
                    set Interface.map.visible = BlzGetTriggerPlayerIsKeyDown()
                endif
            endif
        endmethod

        private static method onSlider takes nothing returns nothing
            local Slider slide = GetTriggerSlider()
            local thistype this = table[slide]

            if this != 0 and GetLocalPlayer() == GetTriggerPlayer() then
                if slide == slider then
                    set sliderText.text = "|cffffffffMinimap Opacity: " + I2S(R2I((slider.value*100)/255)) + "%|r"
                    set Interface.map.opacity = R2I(slider.value)
                elseif slide == shader then
                    set shaderText.text = "|cffffffffPortrait Opacity: " + I2S(R2I((shader.value*100)/255)) + "%|r"
                    set Interface.portrait.opacity = R2I(shader.value)
                elseif slide == mapSlider then
                    set Interface.map.x = mapSlider.value
                endif
            endif
        endmethod

        private static method onChecked takes nothing returns nothing
            local CheckBox check = GetTriggerCheckBox()
            local thistype this = table[check]

            if this != 0 and GetLocalPlayer() == GetTriggerPlayer() then
                if check == right then
                    set Interface.map.x = MINIMAP_RIGHT_MIN - (mapSlider.min - mapSlider.value)
                    set mapSlider.min = MINIMAP_RIGHT_MIN
                    set mapSlider.max = MINIMAP_RIGHT_MAX
                    set mapSlider.value = Interface.map.x
                elseif check == toggle then
                    set Interface.map.visible = false
                elseif check == heroes then
                    set Interface.heroes = true
                elseif check == default then
                    call BlzFrameSetVisible(Interface.default, true)
                endif
            endif
        endmethod

        private static method onUnchecked takes nothing returns nothing
            local CheckBox check = GetTriggerCheckBox()
            local thistype this = table[check]

            if this != 0 and GetLocalPlayer() == GetTriggerPlayer() then
                if check == right then
                    set Interface.map.x = MINIMAP_LEFT_MIN + (mapSlider.value - mapSlider.min)
                    set mapSlider.min = MINIMAP_LEFT_MIN
                    set mapSlider.max = MINIMAP_LEFT_MAX
                    set mapSlider.value = Interface.map.x
                elseif check == toggle then
                    set Interface.map.visible = true
                elseif check == heroes then
                    set Interface.heroes = false
                elseif check == default then
                    call BlzFrameSetVisible(Interface.default, false)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            local integer i = 0

            set table = Table.create()

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    call BlzTriggerRegisterPlayerKeyEvent(key, Player(i), MINIMAP_TOGGLE_KEY, 0, true)
                    call BlzTriggerRegisterPlayerKeyEvent(key, Player(i), MINIMAP_TOGGLE_KEY, 0, false)
                set i = i + 1
            endloop

            call TriggerAddAction(key, function thistype.onKey)
        endmethod
    endstruct
    
    private struct Menu extends Button
        Options panel

        method destroy takes nothing returns nothing
            call panel.destroy()
            call deallocate()
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent returns thistype
            local thistype this = thistype.allocate(x, y, width, height, parent, true, false)

            set texture = OPEN_MENU_TEXTURE
            set tooltip.text = "Open Menu"
            set panel = Options.create(MENU_FRAME_X, MENU_FRAME_Y, MENU_FRAME_WIDTH, MENU_FRAME_HEIGHT, frame)
            set panel.visible = false

            call tooltip.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, -0.008)

            return this
        endmethod

        method onClick takes nothing returns nothing
            if GetLocalPlayer() == GetTriggerPlayer() then
                set panel.visible = not panel.visible

                if panel.visible then
                    set texture = CLOSE_MENU_TEXTURE
                    set tooltip.text = "Close Menu"
                else
                    set texture = OPEN_MENU_TEXTURE
                    set tooltip.text = "Open Menu"
                endif
            endif
        endmethod
    endstruct
    
    private struct Grid extends Panel
        private static framehandle array button

        private boolean isVisible
        private Backdrop array slot[SHOP_COUNT]

        method operator visible= takes boolean flag returns nothing
            local integer i = 0
            local integer j = 0
            local integer k = 0

            set isVisible = flag

            if isVisible then
                loop
                    exitwhen i == SHOP_ROWS
                        set j = 0

                        loop
                            exitwhen j == SHOP_COLUMNS
                                if k < 12 then
                                    call BlzFrameSetAbsPoint(button[k], FRAMEPOINT_TOPLEFT, x + (SHOP_ICON_X + (j*SHOP_SLOT_GAP)), y + SHOP_ICON_Y - (i*SHOP_SLOT_GAP))
                                    call BlzFrameSetScale(button[k], SHOP_ICON_WIDTH/0.04)
                                endif

                                set k = k + 1
                            set j = j + 1
                        endloop
                    set i = i + 1
                endloop
            endif

            call BlzFrameSetVisible(frame, isVisible)
        endmethod

        method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method destroy takes nothing returns nothing
            local integer i = 0
            local integer j = 0
            local integer k = 0

            loop
                exitwhen i == SHOP_ROWS
                    set j = 0

                    loop
                        exitwhen j == SHOP_COLUMNS
                            call slot[k].destroy() 
                            set k = k + 1
                        set j = j + 1
                    endloop
                set i = i + 1
            endloop

            call deallocate()
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent returns thistype
            local thistype this = thistype.allocate(x, y, width, height, parent, "EscMenuBackdrop", false)
            local integer i = 0
            local integer j = 0
            local integer k = 0

            loop
                exitwhen i == SHOP_ROWS
                    set j = 0

                    loop
                        exitwhen j == SHOP_COLUMNS
                            set slot[k] = Backdrop.create(SHOP_SLOT_X + (j*SHOP_SLOT_GAP), SHOP_SLOT_Y - (i*SHOP_SLOT_GAP), SHOP_SLOT_WIDTH, SHOP_SLOT_HEIGHT, frame, SHOP_SLOT_TEXTURE)
                            set k = k + 1
                        set j = j + 1
                    endloop
                set i = i + 1
            endloop

            set visible = false

            return this
        endmethod

        private static method onInit takes nothing returns nothing
            local integer i = 0

            loop
                exitwhen i == 12
                    set button[i] = BlzGetFrameByName("CommandButton_" + I2S(i), 0)
                set i = i + 1
            endloop
        endmethod
    endstruct

    private struct Portrait extends Panel
        private static integer array attribute

        readonly static framehandle agi
        readonly static framehandle str
        readonly static framehandle int
        readonly static framehandle attack
        readonly static framehandle defense
        readonly static framehandle portrait

        StatusBar mana
        Text manaText
        StatusBar health
        Text healthText
        Attribute damage
        Attribute armor
        Attribute strength
        Attribute agility
        Attribute intelligence

        framehandle array shades[5]

        method destroy takes nothing returns nothing
            local integer i = 0

            loop
                exitwhen i == 5
                    call BlzDestroyFrame(shades[i])
                set i = i - 1
            endloop

            call mana.destroy()
            call health.destroy()
            call manaText.destroy()
            call healthText.destroy()
            call damage.destroy()
            call armor.destroy()
            call strength.destroy()
            call agility.destroy()
            call intelligence.destroy()
            call deallocate()
        endmethod

        method operator opacity= takes integer value returns nothing
            local integer i = 0

            loop
                exitwhen i == 5
                    call BlzFrameSetAlpha(shades[i], value)
                set i = i + 1
            endloop
        endmethod

        method trim takes string text, boolean flag returns string
            local integer i = 0
            local integer length

            if flag and text != null then
                set length = StringLength(text)

                loop
                    exitwhen i == length - 1
                        if SubString(text, i, i + 1) == "-" then
                            return SubString(text, i + 2, length)
                        endif
                    set i = i + 1
                endloop
            endif

            return text
        endmethod

        method update takes unit u, player p returns nothing
            local group g = CreateGroup()
            local boolean visible = IsUnitVisible(u, p)
            local boolean hero = IsUnitType(u, UNIT_TYPE_HERO)
            local integer id = GetPlayerId(GetLocalPlayer())
            local integer primary = BlzGetUnitIntegerField(u, UNIT_IF_PRIMARY_ATTRIBUTE)
            local integer count

            call GroupEnumUnitsSelected(g, p, null)

            set count = CountUnitsInGroup(g)
            set mana.value = GetUnitManaPercent(u)
            set health.value = GetUnitLifePercent(u)
            set manaText.visible = BlzGetUnitMaxMana(u) > 0 
            set healthText.visible = BlzGetUnitMaxHP(u) > 0 
            set manaText.text = "|cffFFFFFF" + I2S(R2I(GetUnitState(u,  UNIT_STATE_MANA))) + " / " + I2S(BlzGetUnitMaxMana(u)) + "|r"
            set healthText.text = "|cffFFFFFF" + I2S(R2I(GetWidgetLife(u))) + " / " + I2S(BlzGetUnitMaxHP(u)) + "|r"
            set damage.value.text = trim(BlzFrameGetText(attack), TRIM_DAMAGE)
            set damage.tooltip.text = "Damage: " + damage.value.text
            set damage.visible = BlzGetUnitWeaponBooleanField(u, UNIT_WEAPON_BF_ATTACKS_ENABLED, 0) and visible and count == 1
            set armor.value.text = BlzFrameGetText(defense)
            set armor.tooltip.text = "Armor: " + armor.value.text
            set armor.visible = armor.value.text != null and visible and count == 1
            set strength.value.text = BlzFrameGetText(str)
            set strength.tooltip.text = "Strength: " + strength.value.text
            set strength.visible = hero and visible and count == 1
            set agility.value.text = BlzFrameGetText(agi)
            set agility.tooltip.text = "Agility: " + agility.value.text
            set agility.visible = hero and visible and count == 1
            set intelligence.value.text = BlzFrameGetText(int)
            set intelligence.tooltip.text = "Intelligence: " + intelligence.value.text
            set intelligence.visible = hero and visible and count == 1

            if hero then
                if primary == 3 and attribute[id] != primary then
                    set attribute[id] = primary
                    call agility.display(ATTRIBUTE_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
                    call intelligence.display(null, 0, 0, 0)
                    call strength.display(null, 0, 0, 0)
                elseif primary == 2 and attribute[id] != primary then
                    set attribute[id] = primary
                    call agility.display(null, 0, 0, 0)
                    call intelligence.display(ATTRIBUTE_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
                    call strength.display(null, 0, 0, 0)
                elseif primary == 1 and attribute[id] != primary then
                    set attribute[id] = primary
                    call agility.display(null, 0, 0, 0)
                    call intelligence.display(null, 0, 0, 0)
                    call strength.display(ATTRIBUTE_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
                endif
            endif
            
            if BlzGetUnitMaxMana(u) <= 0 then
                call BlzFrameSetAllPoints(health.frame, mana.frame)
                call BlzFrameSetAllPoints(healthText.frame, health.frame)
            else
                call BlzFrameSetAbsPoint(health.frame, FRAMEPOINT_TOPLEFT, x + HEALTH_X, y + HEALTH_Y)
                call BlzFrameSetAbsPoint(health.frame, FRAMEPOINT_BOTTOMRIGHT, x + HEALTH_X + HEALTH_WIDTH, y + HEALTH_Y - HEALTH_HEIGHT)
                call BlzFrameSetAllPoints(healthText.frame, health.frame)
            endif

            call DestroyGroup(g)

            set g = null
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent returns thistype
            local integer i = 0
            local thistype this = thistype.allocate(x, y, width, height, parent, "EscMenuBackdrop", false)

            set mana = StatusBar.create(MANA_X, MANA_Y, MANA_WIDTH, MANA_HEIGHT, frame, MANA_TEXTURE)
            set mana.alpha = MANA_TRANSPARENCY
            set manaText = Text.create(0, 0, mana.width, mana.height, MANA_TEXT_SCALE, false, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), null, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
            set health = StatusBar.create(HEALTH_X, HEALTH_Y, HEALTH_WIDTH, HEALTH_HEIGHT, frame, HEALTH_TEXTURE)
            set health.alpha = HEALTH_TRANSPARENCY
            set healthText = Text.create(0, 0, health.width, health.height, HEALTH_TEXT_SCALE, false, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), null, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)
            set damage = Attribute.create(x + ATTRIBUTES_X, y + ATTRIBUTES_Y - (0*ATTRIBUTES_GAP), ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), DAMAGE_TEXTURE, "Damage", null)
            set armor = Attribute.create(x + ATTRIBUTES_X, y + ATTRIBUTES_Y - (1*ATTRIBUTES_GAP), ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), ARMOR_TEXTURE, "Armor", null)
            set strength = Attribute.create(x + ATTRIBUTES_X, y + ATTRIBUTES_Y - (2*ATTRIBUTES_GAP), ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), STRENGTH_TEXTURE, "Strength", null)
            set agility = Attribute.create(x + ATTRIBUTES_X, y + ATTRIBUTES_Y - (3*ATTRIBUTES_GAP), ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), AGILITY_TEXTURE, "Agility", null)
            set intelligence = Attribute.create(x + ATTRIBUTES_X, y + ATTRIBUTES_Y - (4*ATTRIBUTES_GAP), ATTRIBUTES_WIDTH, ATTRIBUTES_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), INTELLIGENCE_TEXTURE, "Intelligence", null)

            call BlzFrameSetVisible(portrait, true)
            call BlzFrameClearAllPoints(portrait)
            call BlzFrameSetAbsPoint(portrait, FRAMEPOINT_TOPLEFT, x + PORTRAIT_X + 0.01, y + PORTRAIT_Y)
            call BlzFrameSetAbsPoint(portrait, FRAMEPOINT_BOTTOMRIGHT, x + PORTRAIT_X + PORTRAIT_WIDTH - 0.01, y + PORTRAIT_Y - PORTRAIT_HEIGHT)
            call BlzFrameSetAllPoints(manaText.frame, mana.frame)
            call BlzFrameSetAllPoints(healthText.frame, health.frame)

            loop
                exitwhen i == 5
                    set shades[i] = BlzCreateFrame("SemiTransparentBackdrop", portrait, 0, 0)
                    call BlzFrameSetAllPoints(shades[i], frame)
                    call BlzFrameSetAlpha(shades[i], PORTRAIT_DARKNESS)
                set i = i + 1
            endloop

            return this
        endmethod

        private static method onInit takes nothing returns nothing
            set agi = BlzGetFrameByName("InfoPanelIconHeroAgilityValue", 6)
            set str = BlzGetFrameByName("InfoPanelIconHeroStrengthValue", 6)
            set int = BlzGetFrameByName("InfoPanelIconHeroIntellectValue", 6)
            set attack = BlzGetFrameByName("InfoPanelIconValue", 0)
            set defense = BlzGetFrameByName("InfoPanelIconValue", 2)
            set portrait = BlzGetOriginFrame(ORIGIN_FRAME_PORTRAIT, 0)
        endmethod
    endstruct

    private struct Abilities extends Panel
        readonly static framehandle level
        private static framehandle array button

        private boolean isVisible

        Backdrop array slot[ABILITY_SLOT_COUNT]
        Button array levelup[ABILITY_SLOT_COUNT]

        method operator visible= takes boolean flag returns nothing
            local integer i = 0

            if not isVisible and flag then
                loop
                    exitwhen i == 12
                        if i < ABILITY_SLOT_COUNT then
                            call BlzFrameSetAbsPoint(button[i], FRAMEPOINT_TOPLEFT, x + (ABILITY_ICON_X + (i*ABILITY_SLOT_GAP)), y + ABILITY_ICON_Y)
                            call BlzFrameSetScale(button[i], ABILITY_ICON_WIDTH/0.04)
                        else
                            call BlzFrameSetAbsPoint(button[i], FRAMEPOINT_TOPLEFT, 999, 999)
                            call BlzFrameSetAbsPoint(button[i], FRAMEPOINT_BOTTOMRIGHT, 999, 999)
                        endif
                    set i = i + 1
                endloop
            endif

            set isVisible = flag
        endmethod

        method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method destroy takes nothing returns nothing
            local integer i = 0

            loop
                exitwhen i == ABILITY_SLOT_COUNT
                    call slot[i].destroy()

                    static if SEPARATE_LEVELUP then
                        call levelup[i].destroy()
                    endif
                set i = i + 1
            endloop

            call deallocate()
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent returns thistype
            local thistype this = thistype.allocate(x, y, width, height, parent, "EscMenuBackdrop", false)
            local integer i = 0

            loop
                exitwhen i == ABILITY_SLOT_COUNT
                    set slot[i] = Backdrop.create(ABILITY_SLOT_X + (i*ABILITY_SLOT_GAP), ABILITY_SLOT_Y, ABILITY_SLOT_WIDTH, ABILITY_SLOT_HEIGHT, frame, ABILITY_SLOT_TEXTURE)

                    static if SEPARATE_LEVELUP then
                        set levelup[i] = Button.create(slot[i].width/2 - SEPARATE_LEVELUP_WIDTH/2, slot[i].y + 2*SEPARATE_LEVELUP_HEIGHT, SEPARATE_LEVELUP_WIDTH, SEPARATE_LEVELUP_HEIGHT, slot[i].frame, true, false)
                        set levelup[i].texture = SEPARATE_LEVELUP_TEXTURE
                        set levelup[i].tooltip.visible = false
                        set levelup[i].onEnter = function thistype.onHover
                        set levelup[i].visible = false
                        call levelup[i].setPoint(FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0, 0)
                    endif
                set i = i + 1
            endloop

            set visible = true

            return this
        endmethod

        private static method onHover takes nothing returns nothing
            local unit u = GetMainSelectedUnitEx()
            local Button b = GetTriggerComponent()
            
            if GetLocalPlayer() == GetTriggerPlayer() then
                if GetHeroSkillPoints(u) > 0 then
                    call BlzFrameSetAllPoints(level, b.frame)
                    call BlzFrameSetScale(level, b.width/0.04)
                else
                    call BlzFrameSetAbsPoint(level, FRAMEPOINT_TOPLEFT, 999, 999)
                    call BlzFrameSetAbsPoint(level, FRAMEPOINT_BOTTOMRIGHT, 999, 999)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set level = BlzGetFrameByName("CommandButton_7", 0)
            set button[0] = BlzGetFrameByName("CommandButton_8", 0)
            set button[1] = BlzGetFrameByName("CommandButton_9", 0)
            set button[2] = BlzGetFrameByName("CommandButton_10", 0)
            set button[3] = BlzGetFrameByName("CommandButton_11", 0)
            set button[4] = BlzGetFrameByName("CommandButton_5", 0)
            set button[5] = BlzGetFrameByName("CommandButton_6", 0)
            set button[6] = BlzGetFrameByName("CommandButton_7", 0)
            set button[7] = BlzGetFrameByName("CommandButton_0", 0)
            set button[8] = BlzGetFrameByName("CommandButton_1", 0)
            set button[9] = BlzGetFrameByName("CommandButton_2", 0)
            set button[10] = BlzGetFrameByName("CommandButton_3", 0)
            set button[11] = BlzGetFrameByName("CommandButton_4", 0)
        endmethod
    endstruct

    private struct Inventory extends Panel
        private Backdrop array slot[ITEM_SLOT_COUNT]

        method destroy takes nothing returns nothing
            local integer i = 0

            loop
                exitwhen i == ITEM_SLOT_COUNT
                    call slot[i].destroy()
                set i = i + 1
            endloop

            call deallocate()
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent returns thistype
            local thistype this = thistype.allocate(x, y, width, height, parent, "EscMenuBackdrop", false)
            local integer i = 0

            loop
                exitwhen i == ITEM_SLOT_COUNT
                    set slot[i] = Backdrop.create(ITEM_SLOT_X + (i*ITEM_SLOT_GAP), ITEM_SLOT_Y, ITEM_SLOT_WIDTH, ITEM_SLOT_HEIGHT, frame, ITEM_SLOT_TEXTURE)

                    call BlzFrameSetAbsPoint(BlzGetFrameByName("InventoryButton_" + I2S(i), 0), FRAMEPOINT_TOPLEFT, x + (ITEM_ICON_X + (i*ITEM_SLOT_GAP)), y + ITEM_ICON_Y)
                    call BlzFrameSetScale(BlzGetFrameByName("InventoryButton_" + I2S(i), 0), ITEM_ICON_WIDTH/0.032)
                set i = i + 1
            endloop

            return this
        endmethod
    endstruct

    private struct Minimap extends Panel
        readonly static framehandle minimap

        private Panel helper

        method destroy takes nothing returns nothing
            call BlzFrameSetParent(minimap, parent)
            call helper.destroy()
            call deallocate()
        endmethod

        method operator opacity= takes integer value returns nothing
            call BlzFrameSetAlpha(minimap, value)
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent returns thistype
            local thistype this = thistype.allocate(x, y, width, height, parent, "Leaderboard", false)
            
            set helper = Panel.create(x, y, width - 0.01, height - 0.01, frame, "TransparentBackdrop", false)

            call helper.setPoint(FRAMEPOINT_CENTER, FRAMEPOINT_CENTER, 0, 0)
            call BlzFrameSetParent(minimap, helper.frame)
            call BlzFrameSetAlpha(minimap, R2I(MAP_TRANSPARENCY))
            call BlzFrameSetAllPoints(minimap, helper.frame)
            call BlzFrameSetVisible(minimap, true)

            return this
        endmethod

        private static method onInit takes nothing returns nothing
            set minimap = BlzGetFrameByName("MiniMapFrame", 0)
        endmethod
    endstruct

    struct Attribute extends Button
        private static timer timer = CreateTimer()
        private static integer key = -1
        private static Button menu
        private static Panel panel
        private static Table table
        private static thistype array array

        private integer id
        private Button button
        private boolean isVisible = true

        Text value

        method operator visible= takes boolean flag returns nothing
            set isVisible = flag
            call BlzFrameSetVisible(frame, flag and button.available)
        endmethod

        method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method destroy takes nothing returns nothing
            call value.destroy()
            call button.destroy()
            
            set array[id] = array[key]
            set key = key - 1

            if key == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()
        endmethod

        stub method update takes unit u returns nothing
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent, string texture, string tooltip, framepointtype point returns thistype
            local thistype this

            if parent == null then
                set parent = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)
            endif

            if point == null then
                set point = FRAMEPOINT_TOPRIGHT
            endif
            
            set this = thistype.allocate(x, y, width, height, parent, true, false)
            set key = key + 1
            set array[key] = this
            set this.id = key
            set this.texture = texture
            set this.tooltip.text = tooltip
            set value = Text.create(ATTRIBUTES_TEXT_X, ATTRIBUTES_TEXT_Y, ATTRIBUTES_TEXT_WIDTH, ATTRIBUTES_TEXT_HEIGHT, ATTRIBUTES_TEXT_SCALE, false, frame, null, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            set button = Button.create(ATTRIBUTES_BUTTON_X + ((ATTRIBUTES_BUTTON_WIDTH + ATTRIBUTES_BUTTON_GAP) * ModuloInteger(key, ATTRIBUTES_COLUMNS)), - (ATTRIBUTES_BUTTON_Y + ((ATTRIBUTES_BUTTON_HEIGHT + ATTRIBUTES_BUTTON_GAP) * R2I(key/ATTRIBUTES_COLUMNS))), ATTRIBUTES_BUTTON_WIDTH, ATTRIBUTES_BUTTON_HEIGHT, panel.frame, true, false)
            set button.texture = texture
            set button.tooltip.text = tooltip
            set button.onClick = function thistype.onClicked
            set table[button] = this
            set panel.width = RMaxBJ(panel.width, (ATTRIBUTES_BUTTON_WIDTH * (ModuloInteger(key, ATTRIBUTES_COLUMNS) + 1)) + (2 * ATTRIBUTES_BUTTON_X) + (ATTRIBUTES_BUTTON_GAP * ModuloInteger(key, ATTRIBUTES_COLUMNS)))
            set panel.height = RMaxBJ(panel.height, (ATTRIBUTES_BUTTON_HEIGHT * (R2I(key/ATTRIBUTES_COLUMNS) + 1)) + (2 * ATTRIBUTES_BUTTON_Y) + (ATTRIBUTES_BUTTON_GAP * R2I(key/ATTRIBUTES_COLUMNS)))

            if point == FRAMEPOINT_LEFT or point == FRAMEPOINT_TOPLEFT or point == FRAMEPOINT_BOTTOMLEFT then
                set value.horizontal = TEXT_JUSTIFY_RIGHT
                call value.setPoint(FRAMEPOINT_TOPRIGHT, FRAMEPOINT_TOPLEFT, -ATTRIBUTES_TEXT_X + ATTRIBUTES_WIDTH + 0.005, ATTRIBUTES_TEXT_Y)
            elseif point == FRAMEPOINT_TOP then
                set value.horizontal = TEXT_JUSTIFY_CENTER
                call value.setPoint(FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0, ATTRIBUTES_TEXT_Y + 0.005)
            elseif point == FRAMEPOINT_BOTTOM then
                set value.horizontal = TEXT_JUSTIFY_CENTER
                call value.setPoint(FRAMEPOINT_TOP, FRAMEPOINT_BOTTOM, 0, -ATTRIBUTES_TEXT_Y - 0.005)
            endif

            if key == 0 then
                call TimerStart(timer, 0.2, true, function thistype.onUpdate)
            endif

            return this
        endmethod

        private static method onClicked takes nothing returns nothing
            local Button b = GetTriggerComponent()
            local thistype this = table[b]

            if GetLocalPlayer() == GetTriggerPlayer() then
                if b == menu then
                    set panel.visible = not panel.visible

                    if panel.visible then
                        set b.texture = ATTRIBUTES_TOGGLE_CLOSE
                        set b.tooltip.text = "Close Attribute Menu"
                    else
                        set b.texture = ATTRIBUTES_TOGGLE_OPEN
                        set b.tooltip.text = "Open Attribute Menu"
                    endif
                else
                    set button.available = not button.available
                    set visible = visible
                endif
            endif
        endmethod

        private static method onUpdate takes nothing returns nothing
            local integer i = 0
            local unit u = GetMainSelectedUnitEx()

            loop
                exitwhen i > key
                    call array[i].update(u)
                set i = i + 1
            endloop

            set u = null
        endmethod

        private static method onInit takes nothing returns nothing
            set table = Table.create()
            set menu = Button.create(INFO_X + INFO_WIDTH/2 - ATTRIBUTES_TOGGLE_WIDTH/2, INFO_Y - 0.004, ATTRIBUTES_TOGGLE_WIDTH, ATTRIBUTES_TOGGLE_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), true, false)
            set menu.texture = ATTRIBUTES_TOGGLE_OPEN
            set menu.tooltip.text = "Open Attribute Menu"
            set menu.onClick = function thistype.onClicked
            set panel = Panel.create(0, 0, 0.03, 0.03, menu.frame, "Leaderboard", false)
            set panel.visible = false

            call panel.setPoint(FRAMEPOINT_BOTTOM, FRAMEPOINT_TOP, 0, BUFF_Y)
        endmethod
    endstruct

    struct Interface
        private static framehandle array hero
        private static framehandle array highlight

        readonly static Menu menu
        readonly static Grid grid
        readonly static Minimap map
        readonly static Resource gold
        readonly static Resource lumber
        readonly static Portrait portrait
        readonly static Inventory inventory
        readonly static Abilities abilities

        readonly static framehandle coin
        readonly static framehandle wood
        readonly static framehandle tooltip
        readonly static framehandle minimap
        readonly static framehandle default

        static method operator heroes= takes boolean show returns nothing
            local integer i = 0

            if show then
                loop
                    exitwhen i >= 7
                        call BlzFrameSetAbsPoint(hero[i], FRAMEPOINT_TOPLEFT, HERO_LIST_X, HERO_LIST_Y - (i*HERO_LIST_GAP))
                        call BlzFrameSetScale(hero[i], HERO_LIST_WIDTH/0.038)
                        call BlzFrameSetScale(highlight[i], HERO_LIST_WIDTH/0.038)
                    set i = i + 1
                endloop
            else
                loop
                    exitwhen i >= 7
                        call BlzFrameSetAbsPoint(hero[i], FRAMEPOINT_TOPLEFT, 999, 999)
                    set i = i + 1
                endloop
            endif
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local player p = GetLocalPlayer()
            local unit u = GetMainSelectedUnitEx()
            local boolean shop = IsUnitShop(u, p)
            local integer points = GetHeroSkillPoints(u)

            if not IsUnitVisible(u, p) then
                set u = null
            endif

            call portrait.update(u, p)

            set gold.text = BlzFrameGetText(coin)
            set lumber.text = BlzFrameGetText(wood)

            static if DISPLAY_SHOP then
                set grid.visible = shop
                set abilities.visible = not grid.visible

                if grid.visible then
                    call BlzFrameSetPoint(tooltip, FRAMEPOINT_BOTTOM, grid.frame, FRAMEPOINT_TOP, 0, 0)
                else
                    call BlzFrameSetPoint(tooltip, FRAMEPOINT_BOTTOM, portrait.frame, FRAMEPOINT_TOP, 0, BUFF_Y)
                endif
            endif

            static if SEPARATE_LEVELUP then
                loop
                    exitwhen i == ABILITY_SLOT_COUNT
                        set abilities.levelup[i].visible = points > 0 and not grid.visible and GetOwningPlayer(u) == p
                    set i = i + 1
                endloop

                if (not shop and points <= 0) or (shop and not DISPLAY_SHOP) then
                    call BlzFrameSetAbsPoint(abilities.level, FRAMEPOINT_TOPLEFT, 999, 999)
                    call BlzFrameSetAbsPoint(abilities.level, FRAMEPOINT_BOTTOMRIGHT, 999, 999)
                endif
            endif

            set u = null
            set p = null
        endmethod

        private static method onInit takes nothing returns nothing
            local framehandle frame
            local integer i = 0

            if BlzGetLocalClientWidth() > 1920 then
                set HERO_LIST_X = -0.315
                set PORTRAIT_X = PORTRAIT_X + 0.01
                set PORTRAIT_WIDTH = PORTRAIT_WIDTH - 0.02
            endif

            set coin = BlzGetFrameByName("ResourceBarGoldText" , 0) 
            set wood = BlzGetFrameByName("ResourceBarLumberText" , 0)
            set default = BlzGetFrameByName("UpperButtonBarFrame", 0)
            set tooltip = BlzGetOriginFrame(ORIGIN_FRAME_UBERTOOLTIP , 0)
            set map = Minimap.create(MINIMAP_LEFT_MAX, MINIMAP_Y, MINIMAP_WIDTH, MINIMAP_HEIGHT, BlzGetFrameByName("ConsoleUIBackdrop", 0))
            set menu = Menu.create(MENU_X, MENU_Y, MENU_WIDTH, MENU_HEIGHT, null)
            set portrait = Portrait.create(INFO_X, INFO_Y, INFO_WIDTH, INFO_HEIGHT, null)
            set grid = Grid.create(SHOP_PANEL_X, SHOP_PANEL_Y, SHOP_COLUMNS*SHOP_SLOT_WIDTH + 0.032, SHOP_SLOT_HEIGHT*SHOP_ROWS + 0.034, null)
            set gold = Resource.create(GOLD_BACKGROUND_X, GOLD_BACKGROUND_Y, GOLD_BACKGROUND_WIDTH, GOLD_BACKGROUND_HEIGHT, menu.frame, true)
            set lumber = Resource.create(LUMBER_BACKGROUND_X, LUMBER_BACKGROUND_Y, LUMBER_BACKGROUND_WIDTH, LUMBER_BACKGROUND_HEIGHT, menu.frame, false)
            set abilities = Abilities.create(ABILITY_PANEL_X, ABILITY_PANEL_Y, ABILITY_SLOT_COUNT*ABILITY_SLOT_WIDTH + 0.032, ABILITY_SLOT_HEIGHT + 0.034, null)
            set inventory = Inventory.create(ITEM_PANEL_X, ITEM_PANEL_Y, ITEM_SLOT_COUNT*ITEM_SLOT_WIDTH + 0.032, ITEM_SLOT_HEIGHT + 0.034, null)

            loop
                exitwhen i >= 12
                    set frame = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), i), 1)

                    if i < 7 then
                        set hero[i] = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, i)
                        set highlight[i] = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, i)
                    endif

                    if i >= 6 then
                        call BlzFrameSetAbsPoint(frame, FRAMEPOINT_TOPLEFT, ITEM_PANEL_X + (GROUP_X + ((i - 6)*GROUP_GAP)), ITEM_PANEL_Y + GROUP_Y)
                        call BlzFrameSetAbsPoint(frame, FRAMEPOINT_BOTTOMRIGHT, ITEM_PANEL_X + (GROUP_X + ((i - 6)*GROUP_GAP)) + GROUP_WIDTH, ITEM_PANEL_Y + GROUP_Y - GROUP_HEIGHT)
                    else
                        call BlzFrameSetAbsPoint(frame, FRAMEPOINT_TOPLEFT, ABILITY_PANEL_X + (GROUP_X + (i*GROUP_GAP)), ABILITY_PANEL_Y + GROUP_Y)
                        call BlzFrameSetAbsPoint(frame, FRAMEPOINT_BOTTOMRIGHT, ABILITY_PANEL_X + (GROUP_X + (i*GROUP_GAP)) + GROUP_WIDTH, ABILITY_PANEL_Y + GROUP_Y - GROUP_HEIGHT)
                    endif
                set i = i + 1
            endloop

            call BlzEnableUIAutoPosition(false)
            call BlzFrameSetParent(tooltip, BlzGetFrameByName("ConsoleUI", 0))
            call BlzFrameSetAlpha(BlzGetFrameByName("SimpleInventoryCover", 0), 0)
            call BlzFrameSetScale(BlzGetFrameByName("InventoryText", 0), 0.0001)
            call BlzFrameSetScale(BlzGetFrameByName("SimpleNameValue", 0), 0.00001)
            call BlzFrameSetScale(BlzGetFrameByName("SimpleClassValue", 0), 0.00001)
            call BlzFrameSetScale(BlzGetFrameByName("SimpleBuildingNameValue", 1), 0.00001)
            call BlzFrameSetScale(BlzGetFrameByName("SimpleBuildingActionLabel", 1), 0.00001)
            call BlzFrameSetScale(BlzGetFrameByName("SimpleHoldNameValue", 2), 0.00001)
            call BlzFrameSetScale(BlzGetFrameByName("SimpleHoldDescriptionNameValue", 2), 0.00001)
            call BlzFrameSetScale(BlzGetFrameByName("SimpleItemNameValue", 3), 0.00001)
            call BlzFrameSetScale(BlzGetFrameByName("SimpleItemDescriptionValue", 3), 0.00001)
            call BlzFrameSetScale(BlzGetFrameByName("SimpleDestructableNameValue", 4), 0.00001)
            call BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR_LABEL, 0), 0.00001)
            call BlzFrameSetVisible(default, false)
            call BlzFrameSetVisible(BlzFrameGetChild(BlzGetFrameByName("ConsoleBottomBar", 0), 3), false)
            call BlzFrameSetVisible(BlzFrameGetChild(BlzFrameGetChild(BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 5),0), false)
            call BlzFrameSetPoint(tooltip, FRAMEPOINT_BOTTOM, portrait.frame, FRAMEPOINT_TOP, 0, BUFF_Y)
            call BlzFrameSetAbsPoint(BlzGetFrameByName("ConsoleUI", 0), FRAMEPOINT_TOPLEFT, 0.0, 0.633)
            call BlzFrameSetAbsPoint(BlzGetFrameByName("ResourceBarFrame", 0), FRAMEPOINT_TOPLEFT, 999, 999)
            call BlzFrameSetAbsPoint(BlzGetFrameByName("ResourceBarFrame", 0), FRAMEPOINT_BOTTOMRIGHT, 999, 999)
            call BlzFrameSetAbsPoint(BlzGetFrameByName("SimpleProgressIndicator", 0), FRAMEPOINT_TOPLEFT, INFO_X + PROGRESS_X, INFO_Y + PROGRESS_Y)
            call BlzFrameSetAbsPoint(BlzGetFrameByName("SimpleProgressIndicator", 0), FRAMEPOINT_BOTTOMRIGHT, INFO_X + PROGRESS_X + PROGRESS_WIDTH, INFO_Y + PROGRESS_Y - PROGRESS_HEIGHT)
            call BlzFrameSetAbsPoint(BlzGetFrameByName("SimpleHeroLevelBar", 0), FRAMEPOINT_TOPLEFT, INFO_X + PROGRESS_X, INFO_Y + PROGRESS_Y)
            call BlzFrameSetAbsPoint(BlzGetFrameByName("SimpleHeroLevelBar", 0), FRAMEPOINT_BOTTOMRIGHT, INFO_X + PROGRESS_X + PROGRESS_WIDTH, INFO_Y + PROGRESS_Y - PROGRESS_HEIGHT)
            call BlzFrameSetAbsPoint(BlzGetFrameByName("SimpleBuildTimeIndicator", 1), FRAMEPOINT_TOPLEFT, INFO_X + PROGRESS_X, INFO_Y + PROGRESS_Y)
            call BlzFrameSetAbsPoint(BlzGetFrameByName("SimpleBuildTimeIndicator", 1), FRAMEPOINT_BOTTOMRIGHT, INFO_X + PROGRESS_X + PROGRESS_WIDTH, INFO_Y + PROGRESS_Y - PROGRESS_HEIGHT)
            call BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_CHAT_MSG, 0), FRAMEPOINT_TOPLEFT, CHAT_X, CHAT_Y)
            call BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_CHAT_MSG, 0), FRAMEPOINT_BOTTOMRIGHT, CHAT_X + CHAT_WIDTH, CHAT_Y - CHAT_HEIGHT)
            call BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_UNIT_MSG, 0), FRAMEPOINT_TOPLEFT, CHAT_X, CHAT_Y)
            call BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_UNIT_MSG, 0), FRAMEPOINT_BOTTOMRIGHT, CHAT_X + CHAT_WIDTH, CHAT_Y - CHAT_HEIGHT)
            call BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR, 0), FRAMEPOINT_TOPLEFT, INFO_X + BUFF_X, INFO_Y + BUFF_Y)
            call BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR, 0), FRAMEPOINT_BOTTOMRIGHT, INFO_X + BUFF_X + BUFF_WIDTH, INFO_Y + BUFF_Y - BUFF_HEIGHT)
            call TimerStart(CreateTimer(), 0.1, true, function thistype.onPeriod)

            set frame = null
        endmethod
    endstruct
endlibrary
