library Interface requires RegisterPlayerUnitEvent, GetMainSelectedUnit, Components
    /* --------------------------------------- Interface v1.6 --------------------------------------- */
    // Credits
    //      - Tasyen         - GetMainSelectedUnit
    //      - Magtheridon96  - RegisterPlayerUnitEvent
    /* ---------------------------------------- By Chopinski ---------------------------------------- */

    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
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
        private constant real PORTRAIT_X = 0.017
        private constant real PORTRAIT_Y = -0.017
        // Size of the portrait
        private constant real PORTRAIT_WIDTH = 0.085
        private constant real PORTRAIT_HEIGHT = 0.09
        // Portrait darkness level (<= 0 -> None, > 0 -> Darker)
        private constant integer PORTRAIT_DARKNESS = 2
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
        private constant integer HEALTH_TRANSPARENCY = 64
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
        private constant integer MANA_TRANSPARENCY = 64
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
        /* ----------------------------------------- Damage ---------------------------------------- */
        // The Initial position of the damage button (relative to the info panel)
        private constant real DAMAGE_X = 0.02
        private constant real DAMAGE_Y = -0.0235
        // The size of the damage button
        private constant real DAMAGE_WIDTH = 0.0125
        private constant real DAMAGE_HEIGHT = 0.0125
        // The damage button texture
        private constant string DAMAGE_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNAttack.blp"
        // The Initial position of the damage text (relative to the damage button)
        private constant real DAMAGE_TEXT_X = 0.013
        private constant real DAMAGE_TEXT_Y = 0.0
        // The size of the damage text
        private constant real DAMAGE_TEXT_WIDTH = 0.08
        private constant real DAMAGE_TEXT_HEIGHT = 0.0125
        private constant real DAMAGE_TEXT_SCALE = 0.65
        /* ----------------------------------------- Armor ----------------------------------------- */
        // The Initial position of the armor button (relative to the info panel)
        private constant real ARMOR_X = 0.02
        private constant real ARMOR_Y = -0.0375
        // The size of the armor button
        private constant real ARMOR_WIDTH = 0.0125
        private constant real ARMOR_HEIGHT = 0.0125
        // The armor button texture
        private constant string ARMOR_TEXTURE = "ReplaceableTextures\\CommandButtons\\BTNHumanArmorUpOne.blp"
        // The Initial position of the armor text (relative to the armor button)
        private constant real ARMOR_TEXT_X = 0.013
        private constant real ARMOR_TEXT_Y = 0.0
        // The size of the armor text
        private constant real ARMOR_TEXT_WIDTH = 0.08
        private constant real ARMOR_TEXT_HEIGHT = 0.0125
        private constant real ARMOR_TEXT_SCALE = 0.65
        /* ---------------------------------------- Strenght --------------------------------------- */
        // The Initial position of the strength button (relative to the info panel)
        private constant real STRENGTH_X = 0.02
        private constant real STRENGTH_Y = -0.0515
        // The size of the strength button
        private constant real STRENGTH_WIDTH = 0.0125
        private constant real STRENGTH_HEIGHT = 0.0125
        // The strength button texture
        private constant string STRENGTH_TEXTURE = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-str.blp"
        // The Initial position of the armor text (relative to the strength button)
        private constant real STRENGTH_TEXT_X = 0.013
        private constant real STRENGTH_TEXT_Y = 0.0
        // The size of the strength text
        private constant real STRENGTH_TEXT_WIDTH = 0.08
        private constant real STRENGTH_TEXT_HEIGHT = 0.0125
        private constant real STRENGTH_TEXT_SCALE = 0.65
        /* ---------------------------------------- Agility ---------------------------------------- */
        // The Initial position of the agility button (relative to the info panel)
        private constant real AGILITY_X = 0.02
        private constant real AGILITY_Y = -0.0655
        // The size of the agility button
        private constant real AGILITY_WIDTH = 0.0125
        private constant real AGILITY_HEIGHT = 0.0125
        // The agility button texture
        private constant string AGILITY_TEXTURE = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-agi.blp"
        // The Initial position of the armor text (relative to the agility button)
        private constant real AGILITY_TEXT_X = 0.013
        private constant real AGILITY_TEXT_Y = 0.0
        // The size of the agility text
        private constant real AGILITY_TEXT_WIDTH = 0.08
        private constant real AGILITY_TEXT_HEIGHT = 0.0125
        private constant real AGILITY_TEXT_SCALE = 0.65
        /* -------------------------------------- Intelligence ------------------------------------- */
        // The Initial position of the intelligence button (relative to the info panel)
        private constant real INTELLIGENCE_X = 0.02
        private constant real INTELLIGENCE_Y = -0.0795
        // The size of the intelligence button
        private constant real INTELLIGENCE_WIDTH = 0.0125
        private constant real INTELLIGENCE_HEIGHT = 0.0125
        // The intelligence button texture
        private constant string INTELLIGENCE_TEXTURE = "UI\\Widgets\\Console\\Human\\infocard-heroattributes-int.blp"
        // The Initial position of the armor text (relative to the intelligence button)
        private constant real INTELLIGENCE_TEXT_X = 0.013
        private constant real INTELLIGENCE_TEXT_Y = 0.0
        // The size of the intelligence text
        private constant real INTELLIGENCE_TEXT_WIDTH = 0.08
        private constant real INTELLIGENCE_TEXT_HEIGHT = 0.0125
        private constant real INTELLIGENCE_TEXT_SCALE = 0.65
        /* ---------------------------------- Attribute Highlight ---------------------------------- */
        // Main attribute highlight
        private constant string ATTRIBUTE_HIGHLIGHT = "goldenbrown.mdx"
        private constant real HIGHLIGHT_SCALE = 0.125
        private constant real HIGHLIGHT_XOFFSET = 0
        private constant real HIGHLIGHT_YOFFSET = 0
        private constant framepointtype HIGHLIGHT_POINT = FRAMEPOINT_BOTTOMLEFT
        private constant framepointtype HIGHLIGHT_RELATIVE_POINT = FRAMEPOINT_CENTER
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
        // If true, the + icon will be displayed in a special position
        private constant boolean SEPARATE_MENU = true
        // If true and SEPARATE_MENU is true, the + icon will auto hide when not skill points are available
        private constant boolean AUTO_HIDE = true
        // The initial position of the + icon (relative to the INFO panel)
        private constant real SEPARATE_MENU_X = 0.085
        private constant real SEPARATE_MENU_Y = -0.077
        // The size of the + icon
        private constant real SEPARATE_MENU_WIDTH = 0.015
        private constant real SEPARATE_MENU_HEIGHT = 0.015
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
        private constant real HERO_LIST_X = -0.128
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
        private constant real MENU_FRAME_HEIGHT = 0.20
        /* -------------------------------------- Menu Options ------------------------------------- */
        // The initial position of the move minimap to the right check box (relative to the menu frame)
        private constant real MINIMAP_CHECK_RIGHT_X = 0.04
        private constant real MINIMAP_CHECK_RIGHT_Y = -0.025
        // The size of the move minimap to the right check box
        private constant real MINIMAP_CHECK_RIGHT_WIDTH = 0.015
        private constant real MINIMAP_CHECK_RIGHT_HEIGHT = 0.015
        // The initial position of the move minimap to the right text (relative to the move minimap to the right check box)
        private constant real MINIMAP_CHECK_RIGHT_TEXT_X = 0.02
        private constant real MINIMAP_CHECK_RIGHT_TEXT_Y = 0.0
        // The size of the move minimap to the right text
        private constant real MINIMAP_CHECK_RIGHT_TEXT_WIDTH = 0.15
        private constant real MINIMAP_CHECK_RIGHT_TEXT_HEIGHT = 0.015
        // The initial position of the move minimap to the left check box (relative to the menu frame)
        private constant real MINIMAP_CHECK_LEFT_X = 0.04
        private constant real MINIMAP_CHECK_LEFT_Y = -0.045
        // The size of the move minimap to the left check box
        private constant real MINIMAP_CHECK_LEFT_WIDTH = 0.015
        private constant real MINIMAP_CHECK_LEFT_HEIGHT = 0.015
        // The initial position of the move minimap to the left text (relative to the move minimap to the left check box)
        private constant real MINIMAP_CHECK_LEFT_TEXT_X = 0.02
        private constant real MINIMAP_CHECK_LEFT_TEXT_Y = 0.0
        // The size of the move minimap to the left text
        private constant real MINIMAP_CHECK_LEFT_TEXT_WIDTH = 0.15
        private constant real MINIMAP_CHECK_LEFT_TEXT_HEIGHT = 0.015
        // The initial position of the minimap toggle enable check box (relative to the menu frame)
        private constant real MINIMAP_CHECK_TOGGLE_X = 0.04
        private constant real MINIMAP_CHECK_TOGGLE_Y = -0.065
        // The size of the minimap toggle enable check box
        private constant real MINIMAP_CHECK_TOGGLE_WIDTH = 0.015
        private constant real MINIMAP_CHECK_TOGGLE_HEIGHT = 0.015
        // The initial position of the minimap toggle enable text (relative to the minimap toggle enable check box)
        private constant real MINIMAP_CHECK_TOGGLE_TEXT_X = 0.02
        private constant real MINIMAP_CHECK_TOGGLE_TEXT_Y = 0.0
        // The size of the minimap toggle enable text
        private constant real MINIMAP_CHECK_TOGGLE_TEXT_WIDTH = 0.175
        private constant real MINIMAP_CHECK_TOGGLE_TEXT_HEIGHT = 0.015
        // The initial position of the show heroes bar check box (relative to the menu frame)
        private constant real HEROES_BAR_CHECK_X = 0.04
        private constant real HEROES_BAR_CHECK_Y = -0.085
        // The size of the show heroes bar check box
        private constant real HEROES_BAR_CHECK_WIDTH = 0.015
        private constant real HEROES_BAR_CHECK_HEIGHT = 0.015
        // The initial position of the show heroes bar text (relative to the show heroes bar check box)
        private constant real HEROES_BAR_CHECK_TEXT_X = 0.02
        private constant real HEROES_BAR_CHECK_TEXT_Y = 0.0
        // The size of the show heroes bar text
        private constant real HEROES_BAR_CHECK_TEXT_WIDTH = 0.15
        private constant real HEROES_BAR_CHECK_TEXT_HEIGHT = 0.015
        // The initial position of the show default menu check box (relative to the menu frame)
        private constant real DEFAULT_MENU_CHECK_X = 0.04
        private constant real DEFAULT_MENU_CHECK_Y = -0.105
        // The size of the show default menu check box
        private constant real DEFAULT_MENU_CHECK_WIDTH = 0.015
        private constant real DEFAULT_MENU_CHECK_HEIGHT = 0.015
        // The initial position of the show default menu text (relative to the show default menu check box)
        private constant real DEFAULT_MENU_CHECK_TEXT_X = 0.02
        private constant real DEFAULT_MENU_CHECK_TEXT_Y = 0.0
        // The size of the show default menu text
        private constant real DEFAULT_MENU_CHECK_TEXT_WIDTH = 0.15
        private constant real DEFAULT_MENU_CHECK_TEXT_HEIGHT = 0.015
        // The initial position of the minimap transparency slider (relative to the menu frame)
        private constant real MINIMAP_SLIDER_X = 0.05
        private constant real MINIMAP_SLIDER_Y = -0.145
        // The size of the minimap transparency slider
        private constant real MINIMAP_SLIDER_WIDTH = 0.30
        private constant real MINIMAP_SLIDER_HEIGHT = 0.015
        // The initial position of the minimap transparency text (relative to the minimap transparency slider)
        private constant real MINIMAP_SLIDER_TEXT_X = 0.075
        private constant real MINIMAP_SLIDER_TEXT_Y = 0.02
        // The size of the minimap transparency text
        private constant real MINIMAP_SLIDER_TEXT_WIDTH = 0.15
        private constant real MINIMAP_SLIDER_TEXT_HEIGHT = 0.015
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
        private constant real GOLD_TEXT_X = 0.0125
        private constant real GOLD_TEXT_Y = 0.0
        // The size of the gold text
        private constant real GOLD_TEXT_WIDTH = 0.0575
        private constant real GOLD_TEXT_HEIGHT = 0.0125
        private constant real GOLD_TEXT_SCALE = 1.0
        /* ----------------------------------------- Lumber ---------------------------------------- */
        // The initial position of the lumber background (relative to the menu button)
        private constant real LUMBER_BACKGROUND_X = -0.0675
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
        // The initial position of the minimap on the right side of the screen
        private constant real MINIMAP_RIGHT_X = 0.785
        private constant real MINIMAP_RIGHT_Y = 0.15
        // The initial position of the minimap on the left side of the screen
        private constant real MINIMAP_LEFT_X = -0.13365
        private constant real MINIMAP_LEFT_Y = 0.15
        // The size of the minimap
        private constant real MINIMAP_WIDTH = 0.15
        private constant real MINIMAP_HEIGHT = 0.15
        // Minimap initial transparency (0 -> 100%, 255 -> 0%)
        private constant real MAP_TRANSPARENCY = 64
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
        // Gap between each slot
        private constant real SHOP_SLOT_GAP = 0.0375
        // When true and a unit that has "Select Unit" or "Select Hero" or "Shop Purchase Item" 
        // abilities is selected a panel above the portrait is created to show the items/units
        private constant boolean DISPLAY_SHOP = true
    endglobals

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    private struct UI
        private static trigger sliderTrigger = CreateTrigger()
        private static trigger checkTrigger = CreateTrigger()
        private static trigger keyPress = CreateTrigger()
        private static timer timer = CreateTimer()
        private static integer array currentAttribute
        private static boolean array openedMenu
        private static boolean array shopVisible
        private static boolean array abilitiesVisible
        private static boolean array minimapRight
        private static boolean array minimapLeft
        private static boolean array minimapToggle
        private static framehandle array ability
        private static framehandle array button
        private static framehandle array group
        private static framehandle array item
        private static framehandle array hero
        private static framehandle array heroIndicator
        private static framehandle array commandButton

        private static integer key = -1
        private static thistype array array
        private static thistype array struct

        private static framehandle handle
        private static framehandle infopanel
        private static framehandle abilities
        private static framehandle inventory
        private static framehandle portrait
        private static framehandle minimap
        private static framehandle buff
        private static framehandle level
        private static framehandle shop
        private static framehandle experience
        private static framehandle training
        private static framehandle resourceBar
        private static framehandle buttonBar
        private static framehandle timedlife
        private static framehandle healthBar
        private static framehandle healthText
        private static framehandle manaBar
        private static framehandle manaText
        private static framehandle menuFrame
        private static framehandle minimapRightCheck
        private static framehandle minimapRightCheckText
        private static framehandle minimapLeftCheck
        private static framehandle minimapLeftCheckText
        private static framehandle minimapToggleCheck
        private static framehandle minimapToggleCheckText
        private static framehandle heroesBarCheck
        private static framehandle heroesBarCheckText
        private static framehandle defaultMenuCheck
        private static framehandle defaultMenuCheckText
        private static framehandle minimapSlider
        private static framehandle minimapSliderText
        private static Button menu
        private static Button damage
        private static framehandle damageValue
        private static Button armor
        private static framehandle armorValue
        private static Button strength
        private static framehandle strengthValue
        private static Button agility
        private static framehandle agilityValue
        private static Button intelligence
        private static framehandle intelligenceValue
        private static framehandle gold
        private static framehandle lumber
        private static framehandle goldBackground
        private static framehandle goldIcon
        private static framehandle goldText
        private static framehandle lumberBackground
        private static framehandle lumberIcon
        private static framehandle lumberText

        unit unit
        player player
        integer id
        real health
        real mana
        string hp
        string mp

        method remove takes integer i returns integer
            set array[i] = array[key]
            set key = key - 1
            set struct[id] = 0
            set unit = null
            set player = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        private static method showHeroBar takes boolean show returns nothing
            local integer i = 0

            if show then
                loop
                    exitwhen i >= 7
                        call BlzFrameSetAbsPoint(hero[i], FRAMEPOINT_TOPLEFT, HERO_LIST_X, HERO_LIST_Y - (i*HERO_LIST_GAP))
                        call BlzFrameSetScale(hero[i], HERO_LIST_WIDTH/0.038)
                        call BlzFrameSetScale(heroIndicator[i], HERO_LIST_WIDTH/0.038)
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

        private static method showMinimap takes real x, real y returns nothing
            call BlzFrameSetAbsPoint(minimap, FRAMEPOINT_TOPLEFT, x, y)
            call BlzFrameSetAbsPoint(minimap, FRAMEPOINT_BOTTOMRIGHT, x + MINIMAP_WIDTH, y - MINIMAP_HEIGHT)
            call BlzFrameSetVisible(minimap, true)
        endmethod

        private static method showShop takes nothing returns nothing
            local integer i = 0
            local integer j = 0
            local integer k = 0
            local integer id = GetPlayerId(GetLocalPlayer())

            if not shopVisible[id] then
                loop
                    exitwhen i == SHOP_ROWS
                        set j = 0

                        loop
                            exitwhen j == SHOP_COLUMNS
                                if k < 12 then
                                    call BlzFrameSetAbsPoint(commandButton[k], FRAMEPOINT_TOPLEFT, SHOP_PANEL_X + (SHOP_ICON_X + (j*SHOP_SLOT_GAP)), SHOP_PANEL_Y + SHOP_ICON_Y - (i*SHOP_SLOT_GAP))
                                    call BlzFrameSetScale(commandButton[k], SHOP_ICON_WIDTH/0.04)
                                endif

                                set k = k + 1
                            set j = j + 1
                        endloop
                    set i = i + 1
                endloop

                call BlzFrameSetVisible(shop, true)

                set shopVisible[id] = true
                set abilitiesVisible[id] = false
            endif
        endmethod

        private static method showAbilities takes nothing returns nothing
            local integer i = 0
            local integer id = GetPlayerId(GetLocalPlayer())

            if not abilitiesVisible[id] then
                loop
                    exitwhen i == 12
                        if i < ABILITY_SLOT_COUNT then
                            call BlzFrameSetAbsPoint(button[i], FRAMEPOINT_TOPLEFT, ABILITY_PANEL_X + (ABILITY_ICON_X + (i*ABILITY_SLOT_GAP)), ABILITY_PANEL_Y + ABILITY_ICON_Y)
                            call BlzFrameSetScale(button[i], ABILITY_ICON_WIDTH/0.04)
                            // call BlzFrameSetAbsPoint(button[i], FRAMEPOINT_BOTTOMRIGHT, ABILITY_PANEL_X + (ABILITY_ICON_X + (i*ABILITY_SLOT_GAP)) + ABILITY_ICON_WIDTH, ABILITY_PANEL_Y + ABILITY_ICON_Y - ABILITY_ICON_HEIGHT)
                        else
                            call BlzFrameSetAbsPoint(button[i], FRAMEPOINT_TOPLEFT, 999, 999)
                            call BlzFrameSetAbsPoint(button[i], FRAMEPOINT_BOTTOMRIGHT, 999, 999)
                        endif
                    set i = i + 1
                endloop

                static if SEPARATE_MENU then
                    call BlzFrameSetAbsPoint(level, FRAMEPOINT_TOPLEFT, INFO_X + SEPARATE_MENU_X, INFO_Y + SEPARATE_MENU_Y)
                    call BlzFrameSetScale(level, SEPARATE_MENU_WIDTH/0.04)
                endif

                call BlzFrameSetVisible(shop, false)

                set shopVisible[id] = false
                set abilitiesVisible[id] = true
            endif
        endmethod
        
        private static method onShop takes nothing returns nothing
            local integer i = 0
            local integer j = 0
            local framehandle slot

            call BlzFrameSetAbsPoint(shop, FRAMEPOINT_TOPLEFT, SHOP_PANEL_X, SHOP_PANEL_Y)
            call BlzFrameSetSize(shop, SHOP_COLUMNS*SHOP_SLOT_WIDTH + 0.032, SHOP_SLOT_HEIGHT*SHOP_ROWS + 0.034)

            loop
                exitwhen i == 12
                    set commandButton[i] = BlzGetFrameByName("CommandButton_" + I2S(i), 0)
                set i = i + 1
            endloop

            set i = 0

            loop
                exitwhen i == SHOP_ROWS
                    set j = 0

                    loop
                        exitwhen j == SHOP_COLUMNS
                            set slot = BlzCreateFrameByType("BACKDROP", "", shop, "", 1)

                            call BlzFrameSetPoint(slot, FRAMEPOINT_TOPLEFT, shop, FRAMEPOINT_TOPLEFT, SHOP_SLOT_X + (j*SHOP_SLOT_GAP), SHOP_SLOT_Y - (i*SHOP_SLOT_GAP))
                            call BlzFrameSetSize(slot, SHOP_SLOT_WIDTH, SHOP_SLOT_HEIGHT)
                            call BlzFrameSetTexture(slot, SHOP_SLOT_TEXTURE, 0, true)
                        set j = j + 1
                    endloop
                set i = i + 1
            endloop

            call BlzFrameSetVisible(shop, false)
        endmethod

        private static method onAbilties takes nothing returns nothing
            local integer i = 0

            set button[0] = BlzGetFrameByName("CommandButton_8", 0)
            set button[1] = BlzGetFrameByName("CommandButton_9", 0)
            set button[2] = BlzGetFrameByName("CommandButton_10", 0)
            set button[3] = BlzGetFrameByName("CommandButton_11", 0)
            set button[4] = BlzGetFrameByName("CommandButton_5", 0)
            set button[5] = BlzGetFrameByName("CommandButton_6", 0)

            static if not SEPARATE_MENU then
                set button[6] = BlzGetFrameByName("CommandButton_7", 0)
                set button[7] = BlzGetFrameByName("CommandButton_0", 0)
                set button[8] = BlzGetFrameByName("CommandButton_1", 0)
                set button[9] = BlzGetFrameByName("CommandButton_2", 0)
                set button[10] = BlzGetFrameByName("CommandButton_3", 0)
                set button[11] = BlzGetFrameByName("CommandButton_4", 0)
            else
                set level = BlzGetFrameByName("CommandButton_7", 0)
                set button[6] = BlzGetFrameByName("CommandButton_0", 0)
                set button[7] = BlzGetFrameByName("CommandButton_1", 0)
                set button[8] = BlzGetFrameByName("CommandButton_2", 0)
                set button[9] = BlzGetFrameByName("CommandButton_3", 0)
                set button[10] = BlzGetFrameByName("CommandButton_4", 0)
            endif

            set abilities = BlzCreateFrame("EscMenuBackdrop", BlzGetFrameByName("ConsoleUIBackdrop", 0), 0, 0)

            call BlzFrameSetAbsPoint(abilities, FRAMEPOINT_TOPLEFT, ABILITY_PANEL_X, ABILITY_PANEL_Y)
            call BlzFrameSetSize(abilities, ABILITY_SLOT_COUNT*ABILITY_SLOT_WIDTH + 0.032, ABILITY_SLOT_HEIGHT + 0.034)

            loop
                exitwhen i == 12
                    if i < ABILITY_SLOT_COUNT then
                        set ability[i] = BlzCreateFrameByType("BACKDROP", "", abilities, "", 1)

                        call BlzFrameSetPoint(ability[i], FRAMEPOINT_TOPLEFT, abilities, FRAMEPOINT_TOPLEFT, ABILITY_SLOT_X + (i*ABILITY_SLOT_GAP), ABILITY_SLOT_Y)
                        call BlzFrameSetSize(ability[i], ABILITY_SLOT_WIDTH, ABILITY_SLOT_HEIGHT)
                        call BlzFrameSetTexture(ability[i], ABILITY_SLOT_TEXTURE, 0, true)
                    endif
                set i = i + 1
            endloop

            call showAbilities()
        endmethod

        private static method onInventory takes nothing returns nothing
            local integer i = 0

            set inventory = BlzCreateFrame("EscMenuBackdrop", BlzGetFrameByName("ConsoleUIBackdrop", 0), 0, 0)

            call BlzFrameSetAbsPoint(inventory, FRAMEPOINT_TOPLEFT, ITEM_PANEL_X, ITEM_PANEL_Y)
            call BlzFrameSetSize(inventory, ITEM_SLOT_COUNT*ITEM_SLOT_WIDTH + 0.032, 2*ITEM_SLOT_HEIGHT)

            loop
                exitwhen i == ITEM_SLOT_COUNT
                    set item[i] = BlzCreateFrameByType("BACKDROP", "", inventory, "", 1)

                    call BlzFrameSetPoint(item[i], FRAMEPOINT_TOPLEFT, inventory, FRAMEPOINT_TOPLEFT, ITEM_SLOT_X + (i*ITEM_SLOT_GAP), ITEM_SLOT_Y)
                    call BlzFrameSetSize(item[i], ITEM_SLOT_WIDTH, ITEM_SLOT_HEIGHT)
                    call BlzFrameSetTexture(item[i], ITEM_SLOT_TEXTURE, 0, true)

                    call BlzFrameSetAbsPoint(BlzGetFrameByName("InventoryButton_" + I2S(i), 0), FRAMEPOINT_TOPLEFT, ITEM_PANEL_X + (ITEM_ICON_X + (i*ITEM_SLOT_GAP)), ITEM_PANEL_Y + ITEM_ICON_Y)
                    call BlzFrameSetScale(BlzGetFrameByName("InventoryButton_" + I2S(i), 0), ITEM_ICON_WIDTH/0.032)
                    // call BlzFrameSetAbsPoint(BlzGetFrameByName("InventoryButton_" + I2S(i), 0), FRAMEPOINT_BOTTOMRIGHT, ITEM_PANEL_X + (ITEM_ICON_X + (i*ITEM_SLOT_GAP)) + ITEM_ICON_WIDTH, ITEM_PANEL_Y + ITEM_ICON_Y - ITEM_ICON_HEIGHT)
                set i = i + 1
            endloop
        endmethod

        private static method onInfoPanel takes nothing returns nothing
            set infopanel = BlzCreateFrame("EscMenuBackdrop", BlzGetFrameByName("ConsoleUIBackdrop", 0), 0, 0)
            set healthBar = BlzCreateFrameByType("SIMPLESTATUSBAR", "", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
            set healthText = BlzCreateFrameByType("TEXT", "", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
            set manaBar = BlzCreateFrameByType("SIMPLESTATUSBAR", "", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0) 
            set manaText = BlzCreateFrameByType("TEXT", "", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
            
            call BlzFrameSetAbsPoint(infopanel, FRAMEPOINT_TOPLEFT, INFO_X, INFO_Y)
            call BlzFrameSetAbsPoint(infopanel, FRAMEPOINT_BOTTOMRIGHT, INFO_X + INFO_WIDTH, INFO_Y - INFO_HEIGHT)
            
            // Remove Names and Descriptions
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

            // Reposition the Attack 1 block
            set damage = Button.create(null, DAMAGE_WIDTH, DAMAGE_HEIGHT, INFO_X + DAMAGE_X, INFO_Y + DAMAGE_Y, true)
            set damage.icon = DAMAGE_TEXTURE
            set damage.tooltip.text = "Damage"
            set damage.visible = false
            set damageValue = BlzCreateFrameByType("TEXT", "", damage.frame, "", 0)

            call BlzFrameSetAbsPoint(damageValue, FRAMEPOINT_TOPLEFT, INFO_X + DAMAGE_X + DAMAGE_TEXT_X, INFO_Y + DAMAGE_Y + DAMAGE_TEXT_Y)
            call BlzFrameSetAbsPoint(damageValue, FRAMEPOINT_BOTTOMRIGHT, INFO_X + DAMAGE_X + DAMAGE_TEXT_X + DAMAGE_TEXT_WIDTH, INFO_Y + DAMAGE_Y + DAMAGE_TEXT_Y - DAMAGE_TEXT_HEIGHT)
            call BlzFrameSetTextAlignment(damageValue, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            call BlzFrameSetScale(damageValue, DAMAGE_TEXT_SCALE)
            call BlzFrameSetEnable(damageValue, false)
            // call BlzFrameSetScale(BlzGetFrameByName("InfoPanelIconLabel", 0), 0.0001)
            // call BlzFrameSetAllPoints(BlzGetFrameByName("InfoPanelIconBackdrop", 0), damage.frame)
            // call BlzFrameSetAbsPoint(BlzGetFrameByName("InfoPanelIconValue", 0), FRAMEPOINT_TOPLEFT, INFO_X + DAMAGE_X + DAMAGE_TEXT_X, INFO_Y + DAMAGE_Y + DAMAGE_TEXT_Y)
            // call BlzFrameSetAbsPoint(BlzGetFrameByName("InfoPanelIconValue", 0), FRAMEPOINT_BOTTOMRIGHT, INFO_X + DAMAGE_X + DAMAGE_TEXT_X + DAMAGE_TEXT_WIDTH, INFO_Y + DAMAGE_Y + DAMAGE_TEXT_Y - DAMAGE_TEXT_HEIGHT)
            
            // Reposition the Armor block
            set armor = Button.create(null, ARMOR_WIDTH, ARMOR_HEIGHT, INFO_X + ARMOR_X, INFO_Y + ARMOR_Y, true)
            set armor.icon = ARMOR_TEXTURE
            set armor.tooltip.text = "Armor"
            set armor.visible = false
            set armorValue = BlzCreateFrameByType("TEXT", "", armor.frame, "", 0)

            call BlzFrameSetAbsPoint(armorValue, FRAMEPOINT_TOPLEFT, INFO_X + ARMOR_X + ARMOR_TEXT_X, INFO_Y + ARMOR_Y + ARMOR_TEXT_Y)
            call BlzFrameSetAbsPoint(armorValue, FRAMEPOINT_BOTTOMRIGHT, INFO_X + ARMOR_X + ARMOR_TEXT_X + ARMOR_TEXT_WIDTH, INFO_Y + ARMOR_Y + ARMOR_TEXT_Y - ARMOR_TEXT_HEIGHT)
            call BlzFrameSetTextAlignment(armorValue, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            call BlzFrameSetScale(armorValue, ARMOR_TEXT_SCALE)
            call BlzFrameSetEnable(armorValue, false)
            // call BlzFrameSetScale(BlzGetFrameByName("InfoPanelIconLabel", 2), 0.0001)
            // call BlzFrameSetAllPoints(BlzGetFrameByName("InfoPanelIconBackdrop", 2), armor.frame)
            // call BlzFrameSetAbsPoint(BlzGetFrameByName("InfoPanelIconValue", 2), FRAMEPOINT_TOPLEFT, INFO_X + ARMOR_X + ARMOR_TEXT_X, INFO_Y + ARMOR_Y + ARMOR_TEXT_Y)
            // call BlzFrameSetAbsPoint(BlzGetFrameByName("InfoPanelIconValue", 2), FRAMEPOINT_BOTTOMRIGHT, INFO_X + ARMOR_X + ARMOR_TEXT_X + ARMOR_TEXT_WIDTH, INFO_Y + ARMOR_Y + ARMOR_TEXT_Y - ARMOR_TEXT_HEIGHT)

            // Reposition the Strength label and value
            set strength = Button.create(null, STRENGTH_WIDTH, STRENGTH_HEIGHT, INFO_X + STRENGTH_X, INFO_Y + STRENGTH_Y, true)
            set strength.icon = STRENGTH_TEXTURE
            set strength.tooltip.text = "Strength"
            set strength.visible = false
            set strengthValue = BlzCreateFrameByType("TEXT", "", strength.frame, "", 0)

            call BlzFrameSetAbsPoint(strengthValue, FRAMEPOINT_TOPLEFT, INFO_X + STRENGTH_X + STRENGTH_TEXT_X, INFO_Y + STRENGTH_Y + STRENGTH_TEXT_Y)
            call BlzFrameSetAbsPoint(strengthValue, FRAMEPOINT_BOTTOMRIGHT, INFO_X + STRENGTH_X + STRENGTH_TEXT_X + STRENGTH_TEXT_WIDTH, INFO_Y + STRENGTH_Y + STRENGTH_TEXT_Y - STRENGTH_TEXT_HEIGHT)
            call BlzFrameSetTextAlignment(strengthValue, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            call BlzFrameSetScale(strengthValue, STRENGTH_TEXT_SCALE)
            call BlzFrameSetEnable(strengthValue, false)
            // call BlzFrameSetScale(BlzGetFrameByName("InfoPanelIconHeroStrengthLabel", 6), 0.0001)
            // call BlzFrameSetAbsPoint(BlzGetFrameByName("InfoPanelIconHeroStrengthValue", 6), FRAMEPOINT_TOPLEFT, INFO_X + STRENGTH_X + STRENGTH_TEXT_X, INFO_Y + STRENGTH_Y + STRENGTH_TEXT_Y)
            // call BlzFrameSetAbsPoint(BlzGetFrameByName("InfoPanelIconHeroStrengthValue", 6), FRAMEPOINT_BOTTOMRIGHT, INFO_X + STRENGTH_X + STRENGTH_TEXT_X + STRENGTH_TEXT_WIDTH, INFO_Y + STRENGTH_Y + STRENGTH_TEXT_Y - STRENGTH_TEXT_HEIGHT)

            // Reposition the Agility label and value
            set agility = Button.create(null, AGILITY_WIDTH, AGILITY_HEIGHT, INFO_X + AGILITY_X, INFO_Y + AGILITY_Y, true)
            set agility.icon = AGILITY_TEXTURE
            set agility.tooltip.text = "Agility"
            set agility.visible = false
            set agilityValue = BlzCreateFrameByType("TEXT", "", agility.frame, "", 0)

            call BlzFrameSetAbsPoint(agilityValue, FRAMEPOINT_TOPLEFT, INFO_X + AGILITY_X + AGILITY_TEXT_X, INFO_Y + AGILITY_Y + AGILITY_TEXT_Y)
            call BlzFrameSetAbsPoint(agilityValue, FRAMEPOINT_BOTTOMRIGHT, INFO_X + AGILITY_X + AGILITY_TEXT_X + AGILITY_TEXT_WIDTH, INFO_Y + AGILITY_Y + AGILITY_TEXT_Y - AGILITY_TEXT_HEIGHT)
            call BlzFrameSetTextAlignment(agilityValue, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            call BlzFrameSetScale(agilityValue, AGILITY_TEXT_SCALE)
            call BlzFrameSetEnable(agilityValue, false)
            // call BlzFrameSetScale(BlzGetFrameByName("InfoPanelIconHeroAgilityLabel", 6), 0.0001)
            // call BlzFrameSetAbsPoint(BlzGetFrameByName("InfoPanelIconHeroAgilityValue", 6), FRAMEPOINT_TOPLEFT, INFO_X + AGILITY_X + AGILITY_TEXT_X, INFO_Y + AGILITY_Y + AGILITY_TEXT_Y)
            // call BlzFrameSetAbsPoint(BlzGetFrameByName("InfoPanelIconHeroAgilityValue", 6), FRAMEPOINT_BOTTOMRIGHT, INFO_X + AGILITY_X + AGILITY_TEXT_X + AGILITY_TEXT_WIDTH, INFO_Y + AGILITY_Y + AGILITY_TEXT_Y - AGILITY_TEXT_HEIGHT)

            // Reposition the Intelligence label and value
            set intelligence = Button.create(null, INTELLIGENCE_WIDTH, INTELLIGENCE_HEIGHT, INFO_X + INTELLIGENCE_X, INFO_Y + INTELLIGENCE_Y, true)
            set intelligence.icon = INTELLIGENCE_TEXTURE
            set intelligence.tooltip.text = "Intelligence"
            set intelligence.visible = false
            set intelligenceValue = BlzCreateFrameByType("TEXT", "", intelligence.frame, "", 0)

            call BlzFrameSetAbsPoint(intelligenceValue, FRAMEPOINT_TOPLEFT, INFO_X + INTELLIGENCE_X + INTELLIGENCE_TEXT_X, INFO_Y + INTELLIGENCE_Y + INTELLIGENCE_TEXT_Y)
            call BlzFrameSetAbsPoint(intelligenceValue, FRAMEPOINT_BOTTOMRIGHT, INFO_X + INTELLIGENCE_X + INTELLIGENCE_TEXT_X + INTELLIGENCE_TEXT_WIDTH, INFO_Y + INTELLIGENCE_Y + INTELLIGENCE_TEXT_Y - INTELLIGENCE_TEXT_HEIGHT)
            call BlzFrameSetTextAlignment(intelligenceValue, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            call BlzFrameSetScale(intelligenceValue, INTELLIGENCE_TEXT_SCALE)
            call BlzFrameSetEnable(intelligenceValue, false)
            // call BlzFrameSetScale(BlzGetFrameByName("InfoPanelIconHeroIntellectLabel", 6), 0.0001)
            // call BlzFrameSetAbsPoint(BlzGetFrameByName("InfoPanelIconHeroIntellectValue", 6), FRAMEPOINT_TOPLEFT, INFO_X + INTELLIGENCE_X + INTELLIGENCE_TEXT_X, INFO_Y + INTELLIGENCE_Y + INTELLIGENCE_TEXT_Y)
            // call BlzFrameSetAbsPoint(BlzGetFrameByName("InfoPanelIconHeroIntellectValue", 6), FRAMEPOINT_BOTTOMRIGHT, INFO_X + INTELLIGENCE_X + INTELLIGENCE_TEXT_X + INTELLIGENCE_TEXT_WIDTH, INFO_Y + INTELLIGENCE_Y + INTELLIGENCE_TEXT_Y - INTELLIGENCE_TEXT_HEIGHT)

            // Reposition the Buff bar
            call BlzFrameSetAbsPoint(buff, FRAMEPOINT_TOPLEFT, INFO_X + BUFF_X, INFO_Y + BUFF_Y)
            call BlzFrameSetAbsPoint(buff, FRAMEPOINT_BOTTOMRIGHT, INFO_X + BUFF_X + BUFF_WIDTH, INFO_Y + BUFF_Y - BUFF_HEIGHT)

            // Reposition the Health bar/text
            call BlzFrameSetValue(healthBar, 0)
            call BlzFrameSetAlpha(healthBar, HEALTH_TRANSPARENCY)
            call BlzFrameSetTexture(healthBar, HEALTH_TEXTURE, 0, true)
            call BlzFrameSetAbsPoint(healthBar, FRAMEPOINT_TOPLEFT, INFO_X + HEALTH_X, INFO_Y + HEALTH_Y)
            call BlzFrameSetAbsPoint(healthBar, FRAMEPOINT_BOTTOMRIGHT, INFO_X + HEALTH_X + HEALTH_WIDTH, INFO_Y + HEALTH_Y - HEALTH_HEIGHT)
            call BlzFrameSetAllPoints(healthText, healthBar)
            call BlzFrameSetEnable(healthText, false)
            call BlzFrameSetScale(healthText, HEALTH_TEXT_SCALE)
            call BlzFrameSetTextAlignment(healthText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)

            // Reosition the Mana bar
            call BlzFrameSetValue(manaBar, 0)
            call BlzFrameSetAlpha(manaBar, MANA_TRANSPARENCY)
            call BlzFrameSetTexture(manaBar, MANA_TEXTURE, 0, true)
            call BlzFrameSetAbsPoint(manaBar, FRAMEPOINT_TOPLEFT, INFO_X + MANA_X, INFO_Y + MANA_Y)
            call BlzFrameSetAbsPoint(manaBar, FRAMEPOINT_BOTTOMRIGHT, INFO_X + MANA_X + MANA_WIDTH, INFO_Y + MANA_Y - MANA_HEIGHT)
            call BlzFrameSetAllPoints(manaText, manaBar)
            call BlzFrameSetEnable(manaText, false)
            call BlzFrameSetScale(manaText, MANA_TEXT_SCALE)
            call BlzFrameSetTextAlignment(manaText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)

            // Reposition the Timed Life bar
            call BlzFrameSetAbsPoint(timedlife, FRAMEPOINT_TOPLEFT, INFO_X + PROGRESS_X, INFO_Y + PROGRESS_Y)
            call BlzFrameSetAbsPoint(timedlife, FRAMEPOINT_BOTTOMRIGHT, INFO_X + PROGRESS_X + PROGRESS_WIDTH, INFO_Y + PROGRESS_Y - PROGRESS_HEIGHT)
            
            // Reposition the XP bar
            call BlzFrameSetAbsPoint(experience, FRAMEPOINT_TOPLEFT, INFO_X + PROGRESS_X, INFO_Y + PROGRESS_Y)
            call BlzFrameSetAbsPoint(experience, FRAMEPOINT_BOTTOMRIGHT, INFO_X + PROGRESS_X + PROGRESS_WIDTH, INFO_Y + PROGRESS_Y - PROGRESS_HEIGHT)

            // Reposition the Training bar
            call BlzFrameSetAbsPoint(training, FRAMEPOINT_TOPLEFT, INFO_X + PROGRESS_X, INFO_Y + PROGRESS_Y)
            call BlzFrameSetAbsPoint(training, FRAMEPOINT_BOTTOMRIGHT, INFO_X + PROGRESS_X + PROGRESS_WIDTH, INFO_Y + PROGRESS_Y - PROGRESS_HEIGHT)
        endmethod

        private static method onPortrait takes nothing returns nothing
            local integer i = PORTRAIT_DARKNESS

            call BlzFrameSetVisible(portrait, true)
            call BlzFrameClearAllPoints(portrait)
            call BlzFrameSetAbsPoint(portrait, FRAMEPOINT_TOPLEFT, INFO_X + PORTRAIT_X + 0.01, INFO_Y + PORTRAIT_Y)
            call BlzFrameSetAbsPoint(portrait, FRAMEPOINT_BOTTOMRIGHT, INFO_X + PORTRAIT_X + PORTRAIT_WIDTH - 0.01, INFO_Y + PORTRAIT_Y - PORTRAIT_HEIGHT)

            loop
                exitwhen i <= 0
                    call BlzFrameSetAllPoints(BlzCreateFrame("Leaderboard", portrait, 0, 0), infopanel)
                set i = i - 1
            endloop

            // call BlzFrameSetAbsPoint(portrait, FRAMEPOINT_TOPLEFT, 0.399, 0.001)
            // call BlzFrameSetAbsPoint(portrait, FRAMEPOINT_BOTTOMRIGHT, 0.4, 0.0)
        endmethod

        private static method onHeroes takes nothing returns nothing
            local integer i = 0

            loop
                exitwhen i >= 7
                    set hero[i] = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, i)
                    set heroIndicator[i] = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, i)
                set i = i + 1
            endloop
        endmethod

        private static method onCheck takes nothing returns nothing
            local integer id = GetPlayerId(GetTriggerPlayer())
            local framehandle frame = BlzGetTriggerFrame()

            if BlzGetTriggerFrameEvent() == FRAMEEVENT_CHECKBOX_CHECKED then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    if frame == minimapRightCheck then
                        set minimapRight[id] = true

                        if not minimapToggle[id] then
                            call showMinimap(MINIMAP_RIGHT_X, MINIMAP_RIGHT_Y)
                        endif
                    elseif frame == minimapLeftCheck then
                        set minimapLeft[id] = true

                        if not minimapToggle[id] then
                            call showMinimap(MINIMAP_LEFT_X, MINIMAP_LEFT_Y)
                        endif
                    elseif frame == minimapToggleCheck then
                        set minimapToggle[id] = true
                        call BlzFrameSetVisible(minimap, false)
                    elseif frame == heroesBarCheck then
                        call showHeroBar(true)
                    elseif frame == defaultMenuCheck then
                        call BlzFrameSetVisible(buttonBar, true)
                    endif
                endif
            else
                if GetLocalPlayer() == GetTriggerPlayer() then
                    if frame == minimapRightCheck then
                        set minimapRight[id] = false

                        if not minimapToggle[id] and minimapLeft[id] then
                            call showMinimap(MINIMAP_LEFT_X, MINIMAP_LEFT_Y)
                        else
                            call BlzFrameSetVisible(minimap, false)
                        endif
                    elseif frame == minimapLeftCheck then
                        set minimapLeft[id] = false

                        if not minimapToggle[id] and minimapRight[id] then
                            call showMinimap(MINIMAP_RIGHT_X, MINIMAP_RIGHT_Y)
                        else
                            call BlzFrameSetVisible(minimap, false)
                        endif
                    elseif frame == minimapToggleCheck then
                        set minimapToggle[id] = false

                        if minimapRight[id] then
                            call showMinimap(MINIMAP_RIGHT_X, MINIMAP_RIGHT_Y)
                        elseif minimapLeft[id] then
                            call showMinimap(MINIMAP_LEFT_X, MINIMAP_LEFT_Y)
                        endif
                    elseif frame == heroesBarCheck then
                        call showHeroBar(false)
                    elseif frame == defaultMenuCheck then
                        call BlzFrameSetVisible(buttonBar, false)
                    endif
                endif
            endif
        endmethod

        private static method onSlider takes nothing returns nothing
            local integer value = R2I(BlzGetTriggerFrameValue())
            local string text = I2S(R2I((value*100)/255))

            if GetLocalPlayer() == GetTriggerPlayer() then
                call BlzFrameSetAlpha(minimap, value)
                call BlzFrameSetText(minimapSliderText, "|cffffffffMinimap Opacity: " + text + "%|r")
            endif
        endmethod

        private static method onGroup takes nothing returns nothing
            local integer i = 0
            
            loop
                exitwhen i >= 12
                    set group[i] = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), i), 1)

                    if i >= 6 then
                        call BlzFrameSetAbsPoint(group[i], FRAMEPOINT_TOPLEFT, ITEM_PANEL_X + (GROUP_X + ((i - 6)*GROUP_GAP)), ITEM_PANEL_Y + GROUP_Y)
                        call BlzFrameSetAbsPoint(group[i], FRAMEPOINT_BOTTOMRIGHT, ITEM_PANEL_X + (GROUP_X + ((i - 6)*GROUP_GAP)) + GROUP_WIDTH, ITEM_PANEL_Y + GROUP_Y - GROUP_HEIGHT)
                    else
                        call BlzFrameSetAbsPoint(group[i], FRAMEPOINT_TOPLEFT, ABILITY_PANEL_X + (GROUP_X + (i*GROUP_GAP)), ABILITY_PANEL_Y + GROUP_Y)
                        call BlzFrameSetAbsPoint(group[i], FRAMEPOINT_BOTTOMRIGHT, ABILITY_PANEL_X + (GROUP_X + (i*GROUP_GAP)) + GROUP_WIDTH, ABILITY_PANEL_Y + GROUP_Y - GROUP_HEIGHT)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onResources takes nothing returns nothing
            set goldBackground = BlzCreateFrame("Leaderboard", BlzGetFrameByName("ConsoleUIBackdrop", 0), 0, 0)
            call BlzFrameSetAbsPoint(goldBackground, FRAMEPOINT_TOPLEFT, MENU_X + GOLD_BACKGROUND_X, MENU_Y + GOLD_BACKGROUND_Y)
            call BlzFrameSetSize(goldBackground, GOLD_BACKGROUND_WIDTH, GOLD_BACKGROUND_HEIGHT)
        
            set goldIcon = BlzCreateFrameByType("BACKDROP", "", goldBackground, "", 1)
            call BlzFrameSetPoint(goldIcon, FRAMEPOINT_TOPLEFT, goldBackground, FRAMEPOINT_TOPLEFT, GOLD_ICON_X, GOLD_ICON_Y)
            call BlzFrameSetSize(goldIcon, GOLD_ICON_WIDTH, GOLD_ICON_HEIGHT)
            call BlzFrameSetTexture(goldIcon, GOLD_ICON_TEXTURE, 0, true)

            set goldText = BlzCreateFrameByType("TEXT", "", goldIcon, "", 0) 
            call BlzFrameSetPoint(goldText, FRAMEPOINT_TOPLEFT, goldIcon, FRAMEPOINT_TOPLEFT, GOLD_TEXT_X, GOLD_TEXT_Y)
            call BlzFrameSetSize(goldText, GOLD_TEXT_WIDTH, GOLD_TEXT_HEIGHT) 
            call BlzFrameSetEnable(goldText, false) 
            call BlzFrameSetScale(goldText, GOLD_TEXT_SCALE) 
            call BlzFrameSetTextAlignment(goldText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT) 

            set lumberBackground = BlzCreateFrame("Leaderboard", BlzGetFrameByName("ConsoleUIBackdrop", 0), 0, 0)
            call BlzFrameSetAbsPoint(lumberBackground, FRAMEPOINT_TOPLEFT, MENU_X + LUMBER_BACKGROUND_X, MENU_Y + LUMBER_BACKGROUND_Y)
            call BlzFrameSetSize(lumberBackground, LUMBER_BACKGROUND_WIDTH, LUMBER_BACKGROUND_HEIGHT)
        
            set lumberIcon = BlzCreateFrameByType("BACKDROP", "", lumberBackground, "", 1) 
            call BlzFrameSetPoint(lumberIcon, FRAMEPOINT_TOPLEFT, lumberBackground, FRAMEPOINT_TOPLEFT, LUMBER_ICON_X, LUMBER_ICON_Y)
            call BlzFrameSetSize(lumberIcon, LUMBER_ICON_WIDTH, LUMBER_ICON_HEIGHT)
            call BlzFrameSetTexture(lumberIcon, LUMBER_ICON_TEXTURE, 0, true) 
        
            set lumberText = BlzCreateFrameByType("TEXT", "", lumberIcon, "", 0) 
            call BlzFrameSetPoint(lumberText, FRAMEPOINT_TOPLEFT, lumberIcon, FRAMEPOINT_TOPLEFT, LUMBER_TEXT_X, LUMBER_TEXT_Y)
            call BlzFrameSetSize(lumberText, LUMBER_TEXT_WIDTH, LUMBER_TEXT_HEIGHT)
            call BlzFrameSetEnable(lumberText, false) 
            call BlzFrameSetScale(lumberText, LUMBER_TEXT_SCALE) 
            call BlzFrameSetTextAlignment(lumberText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_RIGHT) 
        endmethod

        private static method onUpdate takes nothing returns nothing
            local integer count
            local integer id = GetPlayerId(GetLocalPlayer())
            local unit u = GetMainSelectedUnitEx()
            local group g = CreateGroup()
            local integer points = GetHeroSkillPoints(u)
            local boolean visible = IsUnitVisible(u, GetLocalPlayer())
            local boolean hero = IsUnitType(u, UNIT_TYPE_HERO)
            local boolean attackEnabled = BlzGetUnitWeaponBooleanField(u, UNIT_WEAPON_BF_ATTACKS_ENABLED, 0)
            local integer mainAttribute = BlzGetUnitIntegerField(u, UNIT_IF_PRIMARY_ATTRIBUTE)
            local string damageText = BlzFrameGetText(BlzGetFrameByName("InfoPanelIconValue", 0))
            local string armorText = BlzFrameGetText(BlzGetFrameByName("InfoPanelIconValue", 2))
            local string strengthText = BlzFrameGetText(BlzGetFrameByName("InfoPanelIconHeroStrengthValue", 6))
            local string agilityText = BlzFrameGetText(BlzGetFrameByName("InfoPanelIconHeroAgilityValue", 6))
            local string intelligenceText = BlzFrameGetText(BlzGetFrameByName("InfoPanelIconHeroIntellectValue", 6))

            // Gold and Lumber text
            call BlzFrameSetText(goldText, BlzFrameGetText(gold))
            call BlzFrameSetText(lumberText, BlzFrameGetText(lumber))

            call GroupEnumUnitsSelected(g, GetLocalPlayer(), null)
            set count = CountUnitsInGroup(g)

            if u != null and count == 1 and visible then
                if attackEnabled then
                    set damage.visible = true
                    set damage.tooltip.text = "Damage: " + damageText
                    call BlzFrameSetText(damageValue, damageText)
                else
                    set damage.visible = false
                endif

                if armorText != null and armorText != "" then
                    set armor.visible = true
                    set armor.tooltip.text = "Armor: " + armorText
                    call BlzFrameSetText(armorValue, armorText)
                else
                    set armor.visible = false
                endif

                if hero then
                    set strength.visible = true
                    set strength.tooltip.text = "Strength: " + strengthText
                    call BlzFrameSetText(strengthValue, strengthText)
    
                    set agility.visible = true
                    set agility.tooltip.text = "Agility: " + agilityText
                    call BlzFrameSetText(agilityValue, agilityText)
    
                    set intelligence.visible = true
                    set intelligence.tooltip.text = "Intelligence: " + intelligenceText
                    call BlzFrameSetText(intelligenceValue, intelligenceText)

                    if mainAttribute == 3 and currentAttribute[id] != mainAttribute then
                        set currentAttribute[id] = mainAttribute
                        call agility.display(ATTRIBUTE_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_POINT, HIGHLIGHT_RELATIVE_POINT, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
                        call intelligence.display(null, 0, null, null, 0, 0)
                        call strength.display(null, 0, null, null, 0, 0)
                    elseif mainAttribute == 2 and currentAttribute[id] != mainAttribute then
                        set currentAttribute[id] = mainAttribute
                        call agility.display(null, 0, null, null, 0, 0)
                        call intelligence.display(ATTRIBUTE_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_POINT, HIGHLIGHT_RELATIVE_POINT, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
                        call strength.display(null, 0, null, null, 0, 0)
                    elseif mainAttribute == 1 and currentAttribute[id] != mainAttribute then
                        set currentAttribute[id] = mainAttribute
                        call agility.display(null, 0, null, null, 0, 0)
                        call intelligence.display(null, 0, null, null, 0, 0)
                        call strength.display(ATTRIBUTE_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_POINT, HIGHLIGHT_RELATIVE_POINT, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
                    endif
                else
                    set strength.visible = false
                    set agility.visible = false
                    set intelligence.visible = false
                endif

                static if SEPARATE_MENU and AUTO_HIDE then
                    if not shopVisible[id] then
                        if points > 0 then
                            call BlzFrameSetAbsPoint(level, FRAMEPOINT_TOPLEFT, INFO_X + SEPARATE_MENU_X, INFO_Y + SEPARATE_MENU_Y)
                            call BlzFrameSetScale(level, SEPARATE_MENU_WIDTH/0.04)
                        else
                            call BlzFrameSetAbsPoint(level, FRAMEPOINT_TOPLEFT, 999, 999)
                            call BlzFrameSetAbsPoint(level, FRAMEPOINT_BOTTOMRIGHT, 999, 999)
                        endif
                    endif
                endif
            else
                set damage.visible = false
                set armor.visible = false
                set strength.visible = false
                set agility.visible = false
                set intelligence.visible = false
            endif

            call DestroyGroup(g)

            set g = null
            set u = null
        endmethod

        private static method onChat takes nothing returns nothing
            call BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_CHAT_MSG, 0), FRAMEPOINT_TOPLEFT, CHAT_X, CHAT_Y)
            call BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_CHAT_MSG, 0), FRAMEPOINT_BOTTOMRIGHT, CHAT_X + CHAT_WIDTH, CHAT_Y - CHAT_HEIGHT)
            call BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_UNIT_MSG, 0), FRAMEPOINT_TOPLEFT, CHAT_X, CHAT_Y)
            call BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_UNIT_MSG, 0), FRAMEPOINT_BOTTOMRIGHT, CHAT_X + CHAT_WIDTH, CHAT_Y - CHAT_HEIGHT)
        endmethod

        private static method onKey takes nothing returns nothing
            local integer id = GetPlayerId(GetTriggerPlayer())
            local boolean pressed = BlzGetTriggerPlayerIsKeyDown()

            if GetLocalPlayer() == GetTriggerPlayer() then
                if minimapToggle[id] then
                    if pressed then
                        if minimapRight[id] then
                            call showMinimap(MINIMAP_RIGHT_X, MINIMAP_RIGHT_Y)
                        elseif minimapLeft[id] then
                            call showMinimap(MINIMAP_LEFT_X, MINIMAP_LEFT_Y)
                        endif
                    else
                        call BlzFrameSetVisible(minimap, false)
                    endif
                endif
            endif
        endmethod

        private static method onMenuClick takes nothing returns nothing
            local integer id = GetPlayerId(GetTriggerPlayer())

            if GetLocalPlayer() == GetTriggerPlayer() then
                if not openedMenu[id] then
                    set openedMenu[id] = true
                    set menu.icon = CLOSE_MENU_TEXTURE
                    call BlzFrameSetVisible(menuFrame, true)
                else
                    set openedMenu[id] = false
                    set menu.icon = OPEN_MENU_TEXTURE
                    call BlzFrameSetVisible(menuFrame, false)
                endif
            endif
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local integer maxMana
            local real newHP
            local real newMP
            local string newHptext
            local string newMptext
            local boolean isShop
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if GetPlayerSlotState(player) != PLAYER_SLOT_STATE_LEFT then
                        set unit = GetMainSelectedUnitEx()

                        static if DISPLAY_SHOP then
                            set isShop = (GetUnitAbilityLevel(unit, 'Aneu') > 0 or GetUnitAbilityLevel(unit, 'Ane2') > 0 or GetUnitAbilityLevel(unit, 'Apit') > 0) and not IsUnitEnemy(unit, player)

                            if GetLocalPlayer() == player then
                                if isShop then
                                    call showShop()
                                else
                                    call showAbilities()
                                endif
                            endif
                        endif

                        if not IsUnitVisible(unit, player) then
                            set unit = null
                        endif

                        set health = BlzFrameGetValue(healthBar) 
                        set mana = BlzFrameGetValue(manaBar)
                        set newHP = GetUnitLifePercent(unit)
                        set newMP = GetUnitManaPercent(unit)
                        set maxMana = BlzGetUnitMaxMana(unit)
                        set hp = BlzFrameGetText(healthText)
                        set mp = BlzFrameGetText(manaText)
                        set newHptext = I2S(R2I(GetWidgetLife(unit))) + " / " + I2S(BlzGetUnitMaxHP(unit))
                        set newMptext = I2S(R2I(GetUnitState(unit,  UNIT_STATE_MANA))) + " / " + I2S(BlzGetUnitMaxMana(unit))

                        if GetLocalPlayer() == player then
                            set health = newHP
                            set mana = newMP

                            if newHptext == "0 / 0" then
                                set newHptext = ""
                            endif

                            if newMptext == "0 / 0" then
                                set newMptext = ""
                            endif

                            if maxMana <= 0 then
                                call BlzFrameSetAllPoints(healthBar, manaBar)
                                call BlzFrameSetAllPoints(healthText, healthBar)
                            else
                                call BlzFrameSetAbsPoint(healthBar, FRAMEPOINT_TOPLEFT, INFO_X + HEALTH_X, INFO_Y + HEALTH_Y)
                                call BlzFrameSetAbsPoint(healthBar, FRAMEPOINT_BOTTOMRIGHT, INFO_X + HEALTH_X + HEALTH_WIDTH, INFO_Y + HEALTH_Y - HEALTH_HEIGHT)
                                call BlzFrameSetAllPoints(healthText, healthBar)
                            endif

                            set hp = newHptext
                            set mp = newMptext
                        endif

                        call BlzFrameSetValue(healthBar, health)
                        call BlzFrameSetValue(manaBar, mana)
                        call BlzFrameSetText(healthText, "|cffFFFFFF" + hp + "|r")
                        call BlzFrameSetText(manaText, "|cffFFFFFF" + mp + "|r")
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onSelect takes nothing returns nothing
            local integer id = GetPlayerId(GetTriggerPlayer())
            local thistype this

            if struct[id] != 0 then
                set this = struct[id]
            else
                set this = thistype.allocate()
                set .id = id
                set player = GetTriggerPlayer()
                set health = 0
                set mana = 0
                set hp = ""
                set mp = ""
                set key = key + 1
                set array[key] = this
                set struct[id] = this
                
                if key == 0 then
                    call TimerStart(timer, 0.05, true, function thistype.onPeriod)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            local integer i = 0

            call BlzLoadTOCFile("Templates.toc")
            call BlzLoadTOCFile("Shop.toc")

            set menu = Button.create(null, MENU_WIDTH, MENU_HEIGHT, MENU_X, MENU_Y, true)
            set menu.icon = OPEN_MENU_TEXTURE
            set menu.tooltip.text = "Open Menu"
            set menu.visible = true
            set menu.onClick = function thistype.onMenuClick
            set menuFrame = BlzCreateFrame("EscMenuBackdrop", menu.frame, 0, 0)
            set minimapRightCheck = BlzCreateFrame("QuestCheckBox", menuFrame, 0, 0)
            set minimapRightCheckText = BlzCreateFrameByType("TEXT", "", minimapRightCheck, "", 0)
            set minimapLeftCheck = BlzCreateFrame("QuestCheckBox", menuFrame, 0, 0)
            set minimapLeftCheckText = BlzCreateFrameByType("TEXT", "", minimapLeftCheck, "", 0)
            set minimapToggleCheck = BlzCreateFrame("QuestCheckBox", menuFrame, 0, 0)
            set minimapToggleCheckText = BlzCreateFrameByType("TEXT", "", minimapToggleCheck, "", 0)
            set heroesBarCheck = BlzCreateFrame("QuestCheckBox", menuFrame, 0, 0)
            set heroesBarCheckText = BlzCreateFrameByType("TEXT", "", heroesBarCheck, "", 0)
            set defaultMenuCheck = BlzCreateFrame("QuestCheckBox", menuFrame, 0, 0)
            set defaultMenuCheckText = BlzCreateFrameByType("TEXT", "", defaultMenuCheck, "", 0)
            set minimapSlider = BlzCreateFrame("EscMenuSliderTemplate", menuFrame, 0, 0)
            set minimapSliderText = BlzCreateFrameByType("TEXT", "", minimapSlider, "", 0)
            set shop = BlzCreateFrame("EscMenuBackdrop", BlzGetFrameByName("ConsoleUIBackdrop", 0), 0, 0) 
            set portrait = BlzGetOriginFrame(ORIGIN_FRAME_PORTRAIT, 0)
            set buff = BlzGetOriginFrame(ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR, 0)
            set minimap = BlzGetFrameByName("MiniMapFrame", 0)
            set gold = BlzGetFrameByName("ResourceBarGoldText" , 0) 
            set lumber = BlzGetFrameByName("ResourceBarLumberText" , 0) 
            set experience = BlzGetFrameByName("SimpleHeroLevelBar", 0)
            set training = BlzGetFrameByName("SimpleBuildTimeIndicator", 1)
            set timedlife = BlzGetFrameByName("SimpleProgressIndicator", 0)
            set resourceBar = BlzGetFrameByName("ResourceBarFrame", 0)
            set buttonBar = BlzGetFrameByName("UpperButtonBarFrame", 0)

            call BlzEnableUIAutoPosition(false)
            call BlzFrameSetAlpha(BlzGetFrameByName("SimpleInventoryCover", 0), 0)
            call BlzFrameSetScale(BlzGetFrameByName("InventoryText", 0), 0.0001)
            call BlzFrameSetAbsPoint(BlzGetFrameByName("ConsoleUI", 0), FRAMEPOINT_TOPLEFT, 0.0, 0.633)
            call BlzFrameSetAbsPoint(resourceBar, FRAMEPOINT_TOPLEFT, 999, 999)
            call BlzFrameSetAbsPoint(resourceBar, FRAMEPOINT_BOTTOMRIGHT, 999, 999)
            call BlzFrameSetVisible(buttonBar, false)
            call BlzFrameSetVisible(BlzFrameGetChild(BlzGetFrameByName("ConsoleUI", 0), 7), false)
            call BlzFrameSetVisible(BlzFrameGetChild(BlzFrameGetChild(BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 5),0), false)
            call BlzFrameSetParent(minimap, BlzGetFrameByName("ConsoleUIBackdrop", 0))
            call BlzFrameSetAlpha(minimap, R2I(MAP_TRANSPARENCY))
            call BlzFrameSetVisible(minimap, false)
            call BlzFrameSetPoint(menuFrame, FRAMEPOINT_TOPLEFT, menu.frame, FRAMEPOINT_TOPLEFT, MENU_FRAME_X, MENU_FRAME_Y)
            call BlzFrameSetSize(menuFrame, MENU_FRAME_WIDTH, MENU_FRAME_HEIGHT)
            call BlzFrameSetVisible(menuFrame, false)
            call BlzFrameSetPoint(minimapRightCheck, FRAMEPOINT_TOPLEFT, menuFrame, FRAMEPOINT_TOPLEFT, MINIMAP_CHECK_RIGHT_X, MINIMAP_CHECK_RIGHT_Y)
            call BlzFrameSetSize(minimapRightCheck, MINIMAP_CHECK_RIGHT_WIDTH, MINIMAP_CHECK_RIGHT_HEIGHT)
            call BlzFrameSetPoint(minimapRightCheckText, FRAMEPOINT_TOPLEFT, minimapRightCheck, FRAMEPOINT_TOPLEFT, MINIMAP_CHECK_RIGHT_TEXT_X, MINIMAP_CHECK_RIGHT_TEXT_Y)
            call BlzFrameSetSize(minimapRightCheckText, MINIMAP_CHECK_RIGHT_TEXT_WIDTH, MINIMAP_CHECK_RIGHT_TEXT_HEIGHT)
            call BlzFrameSetText(minimapRightCheckText, "|cffffffffShow Minimap on the Right|r")
            call BlzFrameSetEnable(minimapRightCheckText, false)
            call BlzFrameSetScale(minimapRightCheckText, 1.00)
            call BlzFrameSetTextAlignment(minimapRightCheckText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            call BlzFrameSetPoint(minimapLeftCheck, FRAMEPOINT_TOPLEFT, menuFrame, FRAMEPOINT_TOPLEFT, MINIMAP_CHECK_LEFT_X, MINIMAP_CHECK_LEFT_Y)
            call BlzFrameSetSize(minimapLeftCheck, MINIMAP_CHECK_LEFT_WIDTH, MINIMAP_CHECK_LEFT_HEIGHT)
            call BlzFrameSetPoint(minimapLeftCheckText, FRAMEPOINT_TOPLEFT, minimapLeftCheck, FRAMEPOINT_TOPLEFT, MINIMAP_CHECK_LEFT_TEXT_X, MINIMAP_CHECK_LEFT_TEXT_Y)
            call BlzFrameSetSize(minimapLeftCheckText, MINIMAP_CHECK_LEFT_TEXT_WIDTH, MINIMAP_CHECK_LEFT_TEXT_HEIGHT)
            call BlzFrameSetText(minimapLeftCheckText, "|cffffffffShow Minimap on the Left|r")
            call BlzFrameSetEnable(minimapLeftCheckText, false)
            call BlzFrameSetScale(minimapLeftCheckText, 1.00)
            call BlzFrameSetTextAlignment(minimapLeftCheckText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            call BlzFrameSetPoint(minimapToggleCheck, FRAMEPOINT_TOPLEFT, menuFrame, FRAMEPOINT_TOPLEFT, MINIMAP_CHECK_TOGGLE_X, MINIMAP_CHECK_TOGGLE_Y)
            call BlzFrameSetSize(minimapToggleCheck, MINIMAP_CHECK_TOGGLE_WIDTH, MINIMAP_CHECK_TOGGLE_HEIGHT)
            call BlzFrameSetPoint(minimapToggleCheckText, FRAMEPOINT_TOPLEFT, minimapToggleCheck, FRAMEPOINT_TOPLEFT, MINIMAP_CHECK_TOGGLE_TEXT_X, MINIMAP_CHECK_TOGGLE_TEXT_Y)
            call BlzFrameSetSize(minimapToggleCheckText, MINIMAP_CHECK_TOGGLE_TEXT_WIDTH, MINIMAP_CHECK_TOGGLE_TEXT_HEIGHT)
            call BlzFrameSetText(minimapToggleCheckText, "|cffffffffEnable Minimap Toggle (Hold Tab)|r")
            call BlzFrameSetEnable(minimapToggleCheckText, false)
            call BlzFrameSetScale(minimapToggleCheckText, 1.00)
            call BlzFrameSetTextAlignment(minimapToggleCheckText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            call BlzFrameSetPoint(heroesBarCheck, FRAMEPOINT_TOPLEFT, menuFrame, FRAMEPOINT_TOPLEFT, HEROES_BAR_CHECK_X, HEROES_BAR_CHECK_Y)
            call BlzFrameSetSize(heroesBarCheck, HEROES_BAR_CHECK_WIDTH, HEROES_BAR_CHECK_HEIGHT)
            call BlzFrameSetPoint(heroesBarCheckText, FRAMEPOINT_TOPLEFT, heroesBarCheck, FRAMEPOINT_TOPLEFT, HEROES_BAR_CHECK_TEXT_X, HEROES_BAR_CHECK_TEXT_Y)
            call BlzFrameSetSize(heroesBarCheckText, HEROES_BAR_CHECK_TEXT_WIDTH, HEROES_BAR_CHECK_TEXT_HEIGHT)
            call BlzFrameSetText(heroesBarCheckText, "|cffffffffShow Heroes Bar|r")
            call BlzFrameSetEnable(heroesBarCheckText, false)
            call BlzFrameSetScale(heroesBarCheckText, 1.00)
            call BlzFrameSetTextAlignment(heroesBarCheckText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            call BlzFrameSetPoint(defaultMenuCheck, FRAMEPOINT_TOPLEFT, menuFrame, FRAMEPOINT_TOPLEFT, DEFAULT_MENU_CHECK_X, DEFAULT_MENU_CHECK_Y)
            call BlzFrameSetSize(defaultMenuCheck, DEFAULT_MENU_CHECK_WIDTH, DEFAULT_MENU_CHECK_HEIGHT)
            call BlzFrameSetPoint(defaultMenuCheckText, FRAMEPOINT_TOPLEFT, defaultMenuCheck, FRAMEPOINT_TOPLEFT, DEFAULT_MENU_CHECK_TEXT_X, DEFAULT_MENU_CHECK_TEXT_Y)
            call BlzFrameSetSize(defaultMenuCheckText, DEFAULT_MENU_CHECK_TEXT_WIDTH, DEFAULT_MENU_CHECK_TEXT_HEIGHT)
            call BlzFrameSetText(defaultMenuCheckText, "|cffffffffShow Default Menu|r")
            call BlzFrameSetEnable(defaultMenuCheckText, false)
            call BlzFrameSetScale(defaultMenuCheckText, 1.00)
            call BlzFrameSetTextAlignment(defaultMenuCheckText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            call BlzFrameSetPoint(minimapSlider, FRAMEPOINT_TOPLEFT, menuFrame, FRAMEPOINT_TOPLEFT, MINIMAP_SLIDER_X, MINIMAP_SLIDER_Y)
            call BlzFrameSetSize(minimapSlider, MINIMAP_SLIDER_WIDTH, MINIMAP_SLIDER_HEIGHT)
            call BlzFrameSetMinMaxValue(minimapSlider, 0, 255)
            call BlzFrameSetValue(minimapSlider, MAP_TRANSPARENCY)
            call BlzFrameSetStepSize(minimapSlider, 1)
            call BlzFrameSetPoint(minimapSliderText, FRAMEPOINT_TOPLEFT, minimapSlider, FRAMEPOINT_TOPLEFT, MINIMAP_SLIDER_TEXT_X, MINIMAP_SLIDER_TEXT_Y)
            call BlzFrameSetSize(minimapSliderText, MINIMAP_SLIDER_TEXT_WIDTH, MINIMAP_SLIDER_TEXT_HEIGHT)
            call BlzFrameSetText(minimapSliderText, "|cffffffffMinimap Opacity: " + I2S(R2I((MAP_TRANSPARENCY*100)/255)) + "%|r")
            call BlzFrameSetEnable(minimapSliderText, false)
            call BlzFrameSetScale(minimapSliderText, 1.00)
            call BlzFrameSetTextAlignment(minimapSliderText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    call BlzTriggerRegisterPlayerKeyEvent(keyPress, Player(i), MINIMAP_TOGGLE_KEY, 0, true)
                    call BlzTriggerRegisterPlayerKeyEvent(keyPress, Player(i), MINIMAP_TOGGLE_KEY, 0, false)
                set i = i + 1
            endloop

            call BlzTriggerRegisterFrameEvent(checkTrigger, minimapRightCheck, FRAMEEVENT_CHECKBOX_CHECKED)
            call BlzTriggerRegisterFrameEvent(checkTrigger, minimapRightCheck, FRAMEEVENT_CHECKBOX_UNCHECKED)
            call BlzTriggerRegisterFrameEvent(checkTrigger, minimapLeftCheck, FRAMEEVENT_CHECKBOX_CHECKED)
            call BlzTriggerRegisterFrameEvent(checkTrigger, minimapLeftCheck, FRAMEEVENT_CHECKBOX_UNCHECKED)
            call BlzTriggerRegisterFrameEvent(checkTrigger, minimapToggleCheck, FRAMEEVENT_CHECKBOX_CHECKED)
            call BlzTriggerRegisterFrameEvent(checkTrigger, minimapToggleCheck, FRAMEEVENT_CHECKBOX_UNCHECKED)
            call BlzTriggerRegisterFrameEvent(checkTrigger, heroesBarCheck, FRAMEEVENT_CHECKBOX_CHECKED)
            call BlzTriggerRegisterFrameEvent(checkTrigger, heroesBarCheck, FRAMEEVENT_CHECKBOX_UNCHECKED)
            call BlzTriggerRegisterFrameEvent(checkTrigger, defaultMenuCheck, FRAMEEVENT_CHECKBOX_CHECKED)
            call BlzTriggerRegisterFrameEvent(checkTrigger, defaultMenuCheck, FRAMEEVENT_CHECKBOX_UNCHECKED)
            call BlzTriggerRegisterFrameEvent(sliderTrigger, minimapSlider, FRAMEEVENT_SLIDER_VALUE_CHANGED)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, function thistype.onSelect)
            call TriggerAddAction(keyPress, function thistype.onKey)
            call TriggerAddAction(checkTrigger, function thistype.onCheck)
            call TriggerAddAction(sliderTrigger, function thistype.onSlider)
            call TimerStart(CreateTimer(), 0.2, true, function thistype.onUpdate)

            call onInfoPanel()
            call onAbilties()
            call onInventory()
            call onPortrait()
            call onResources()
            call onHeroes()
            call onChat()
            call onShop()
            call onGroup()
        endmethod
    endstruct
endlibrary
