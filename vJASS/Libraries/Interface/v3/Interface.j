library Interface requires RegisterPlayerUnitEvent, GetMainSelectedUnit
    /* --------------------------------------- Interface v1.6 --------------------------------------- */
    // Credits
    //      - Tasyen         - GetMainSelectedUnit
    //      - Magtheridon96  - RegisterPlayerUnitEvent
    /* ---------------------------------------- By Chopinski ---------------------------------------- */

    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // Set this to a texture to replace the default gold icon
        private constant string GOLD_ICON   = ""
        // Minimap transparency (0 -> 100%, 255 -> 0%)
        private constant integer MAP_TRANSPARENCY = 0
        // When true and a unit that has "Select Unit" or "Select Hero" or "Shop Purchase Item" 
        // abilities is select a panel above the portrait is created to show the items/units
        private constant boolean DISPLAY_SHOP = true
    endglobals

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    private struct UI
        private static trigger maptrigger = CreateTrigger()
        private static trigger herotrigger = CreateTrigger()
        private static trigger menutrigger = CreateTrigger()
        private static trigger trigger = CreateTrigger()
        private static timer timer = CreateTimer()

        private static integer key = -1
        private static thistype array array
        private static thistype array struct

        private static framehandle handle = null
        private static framehandle UI = null
        private static framehandle ShopSlots = null
        private static framehandle HealthBar = null
        private static framehandle ManaBar = null
        private static framehandle HeroCheck = null
        private static framehandle HPText = null
        private static framehandle MPText = null
        private static framehandle Gold = null
        private static framehandle Lumber = null
        private static framehandle CheckBL = null
        private static framehandle CheckBR = null
        private static framehandle Minimap = null
        private static framehandle MenuCheck = null
        private static framehandle LumberIcon = null
        private static framehandle GoldIcon = null

        private static real array x1
        private static real array x2
        private static real array y01
        private static real array y02
        private static real array y11
        private static real array y12
        private static real array y21
        private static real array y22
        private static real array y31
        private static real array y32
        private static real array y41
        private static real array y42
        private static real array y51
        private static real array y52
        private static real array y61
        private static real array y62

        private static real array mapX1
        private static real array mapY1
        private static real array mapX2
        private static real array mapY2

        private static real array frameX1
        private static real array frameY1
        private static real array frameX2
        private static real array frameY2

        private static real array command0X1
        private static real array command0Y1
        private static real array command0X2
        private static real array command0Y2
        private static real array command1X1
        private static real array command1Y1
        private static real array command1X2
        private static real array command1Y2
        private static real array command2X1
        private static real array command2Y1
        private static real array command2X2
        private static real array command2Y2
        private static real array command3X1
        private static real array command3Y1
        private static real array command3X2
        private static real array command3Y2
        private static real array command4X1
        private static real array command4Y1
        private static real array command4X2
        private static real array command4Y2
        private static real array command5X1
        private static real array command5Y1
        private static real array command5X2
        private static real array command5Y2
        private static real array command6X1
        private static real array command6Y1
        private static real array command6X2
        private static real array command6Y2
        private static real array command7X1
        private static real array command7Y1
        private static real array command7X2
        private static real array command7Y2
        private static real array command8X1
        private static real array command8Y1
        private static real array command8X2
        private static real array command8Y2
        private static real array command9X1
        private static real array command9Y1
        private static real array command9X2
        private static real array command9Y2
        private static real array command10X1
        private static real array command10Y1
        private static real array command10X2
        private static real array command10Y2
        private static real array command11X1
        private static real array command11Y1
        private static real array command11X2
        private static real array command11Y2

        private static boolean array shop
        private static unit array main

        private static boolean array checkL
        private static boolean array checkR

        private static boolean array checkMenu

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

        private static method onCommandButtons takes nothing returns nothing
            local integer id = GetPlayerId(GetLocalPlayer())
            local real scale = 0.8205

            if shop[id] then
                set command0X1[id] = 0.333500
                set command0Y1[id] = 0.213950
                set command0X2[id] = 0.366760
                set command0Y2[id] = 0.180700
                set command1X1[id] = 0.370500
                set command1Y1[id] = 0.213950
                set command1X2[id] = 0.403760
                set command1Y2[id] = 0.180700
                set command2X1[id] = 0.407400
                set command2Y1[id] = 0.213650
                set command2X2[id] = 0.440660
                set command2Y2[id] = 0.180400
                set command3X1[id] = 0.444400
                set command3Y1[id] = 0.213650
                set command3X2[id] = 0.477660
                set command3Y2[id] = 0.180400
                set command4X1[id] = 0.333500
                set command4Y1[id] = 0.175250
                set command4X2[id] = 0.366760
                set command4Y2[id] = 0.142000
                set command5X1[id] = 0.370500
                set command5Y1[id] = 0.175250
                set command5X2[id] = 0.403760
                set command5Y2[id] = 0.142000 
                set command6X1[id] = 0.407400
                set command6Y1[id] = 0.175250
                set command6X2[id] = 0.440660
                set command6Y2[id] = 0.142000
                set command7X1[id] = 0.444400
                set command7Y1[id] = 0.175250
                set command7X2[id] = 0.477660
                set command7Y2[id] = 0.142000
                set command8X1[id] = 0.333500
                set command8Y1[id] = 0.136850
                set command8X2[id] = 0.366760
                set command8Y2[id] = 0.103600
                set command9X1[id] = 0.370500
                set command9Y1[id] = 0.136850
                set command9X2[id] = 0.403760
                set command9Y2[id] = 0.103600
                set command10X1[id] = 0.407400
                set command10Y1[id] = 0.136850
                set command10X2[id] = 0.440660
                set command10Y2[id] = 0.103600
                set command11X1[id] = 0.444400
                set command11Y1[id] = 0.136850
                set command11X2[id] = 0.477660
                set command11Y2[id] = 0.103600
            else
                set command0X1[id] = 999.0
                set command0Y1[id] = 999.0
                set command0X2[id] = 999.0
                set command0Y2[id] = 999.0
                set command1X1[id] = 999.0
                set command1Y1[id] = 999.0
                set command1X2[id] = 999.0
                set command1Y2[id] = 999.0
                set command2X1[id] = 999.0
                set command2Y1[id] = 999.0
                set command2X2[id] = 999.0
                set command2Y2[id] = 999.0
                set command3X1[id] = 999.0
                set command3Y1[id] = 999.0
                set command3X2[id] = 999.0
                set command3Y2[id] = 999.0
                set command4X1[id] = 999.0
                set command4Y1[id] = 999.0
                set command4X2[id] = 999.0
                set command4Y2[id] = 999.0 
                set command5X1[id] = 0.286200
                set command5Y1[id] = 0.0461300
                set command5X2[id] = 0.318200
                set command5Y2[id] = 0.0141300
                set command6X1[id] = 0.324000
                set command6Y1[id] = 0.0461300
                set command6X2[id] = 0.356000
                set command6Y2[id] = 0.0141300
                set command7X1[id] = 0.360510
                set command7Y1[id] = 0.0490700
                set command7X2[id] = 0.380910
                set command7Y2[id] = 0.0286700
                set command8X1[id] = 0.135000
                set command8Y1[id] = 0.0461300
                set command8X2[id] = 0.167000
                set command8Y2[id] = 0.0141300
                set command9X1[id] = 0.173050
                set command9Y1[id] = 0.0461300
                set command9X2[id] = 0.205050
                set command9Y2[id] = 0.0141300
                set command10X1[id] = 0.210600
                set command10Y1[id] = 0.0461300
                set command10X2[id] = 0.242600
                set command10Y2[id] = 0.0141300
                set command11X1[id] = 0.248400
                set command11Y1[id] = 0.0461300
                set command11X2[id] = 0.280400
                set command11Y2[id] = 0.0141300
            endif

            // Display the 12 slot grid
            call BlzFrameSetVisible(ShopSlots, shop[id])

            // Reposition the Move command button
            set handle = BlzGetFrameByName("CommandButton_0", 0) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, command0X1[id], command0Y1[id]) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, command0X2[id], command0Y2[id]) 
            call BlzFrameSetScale(handle, scale)

            // Reposition the Stop command button
            set handle = BlzGetFrameByName("CommandButton_1", 0) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, command1X1[id], command1Y1[id]) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, command1X2[id], command1Y2[id])
            call BlzFrameSetScale(handle, scale)
            
            // Reposition the Hold command button
            set handle = BlzGetFrameByName("CommandButton_2", 0) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, command2X1[id], command2Y1[id]) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, command2X2[id], command2Y2[id]) 
            call BlzFrameSetScale(handle, scale)

            // Reposition the Attack command button
            set handle = BlzGetFrameByName("CommandButton_3", 0) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, command3X1[id], command3Y1[id]) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, command3X2[id], command3Y2[id])
            call BlzFrameSetScale(handle, scale)

            // Reposition the Patrol command button
            set handle = BlzGetFrameByName("CommandButton_4", 0) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, command4X1[id], command4Y1[id]) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, command4X2[id], command4Y2[id]) 
            call BlzFrameSetScale(handle, scale)

            // Reposition the D command button
            set handle = BlzGetFrameByName("CommandButton_5", 0) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, command5X1[id], command5Y1[id]) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, command5X2[id], command5Y2[id]) 
            call BlzFrameSetScale(handle, scale)
            
            // Reposition the F command button
            set handle = BlzGetFrameByName("CommandButton_6", 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, command6X1[id], command6Y1[id]) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, command6X2[id], command6Y2[id]) 
            call BlzFrameSetScale(handle, scale)
            
            // Reposition the + command button
            set handle = BlzGetFrameByName("CommandButton_7", 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, command7X1[id], command7Y1[id]) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, command7X2[id], command7Y2[id])
            call BlzFrameSetScale(handle, 0.5923)
            
            // Reposition the Q command button
            set handle = BlzGetFrameByName("CommandButton_8", 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, command8X1[id], command8Y1[id]) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, command8X2[id], command8Y2[id]) 
            call BlzFrameSetScale(handle, scale)
            
            // Reposition the W command button
            set handle = BlzGetFrameByName("CommandButton_9", 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, command9X1[id], command9Y1[id]) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, command9X2[id], command9Y2[id])
            call BlzFrameSetScale(handle, scale)
            
            // Reposition the E command button
            set handle = BlzGetFrameByName("CommandButton_10", 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, command10X1[id], command10Y1[id]) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, command10X2[id], command10Y2[id]) 
            call BlzFrameSetScale(handle, scale)
            
            // Reposition the R command button
            set handle = BlzGetFrameByName("CommandButton_11", 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, command11X1[id], command11Y1[id]) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, command11X2[id], command11Y2[id])
            call BlzFrameSetScale(handle, scale)

            set handle = null
        endmethod

        private static method onInventoryButtons takes nothing returns nothing
            // Reposition the 0 inventory button
            set handle = BlzGetFrameByName("InventoryButton_0", 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.443500, 0.0461300)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.475500, 0.0141300)
            call BlzFrameSetSize(handle, 0.032, 0.032)
            
            // Reposition the 1 inventory button
            set handle = BlzGetFrameByName("InventoryButton_1", 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.481100, 0.0461300)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.513100, 0.0141300)
            call BlzFrameSetSize(handle, 0.032, 0.032)
            
            // Reposition the 2 inventory button
            set handle = BlzGetFrameByName("InventoryButton_2", 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.518700, 0.0461300)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.550700, 0.0141300)
            call BlzFrameSetSize(handle, 0.032, 0.032)
            
            // Reposition the 3 inventory button
            set handle = BlzGetFrameByName("InventoryButton_3", 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.556500, 0.0461300)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.588500, 0.0141300)
            call BlzFrameSetSize(handle, 0.032, 0.032)
            
            // Reposition the 4 inventory button
            set handle = BlzGetFrameByName("InventoryButton_4", 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.594300, 0.0461300)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.626300, 0.0141300)
            call BlzFrameSetSize(handle, 0.032, 0.032)
            
            // Reposition the 5 inventory button
            set handle = BlzGetFrameByName("InventoryButton_5", 0) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.632100, 0.0461300)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.664100, 0.0141300)
            call BlzFrameSetSize(handle, 0.032, 0.032)
            
            set handle = null
        endmethod

        private static method onInfoPanel takes nothing returns nothing
            // Reposition the Buff bar
            set handle = BlzGetOriginFrame(ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR, 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.359120, 0.115000)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.482620, 0.100000)
            
            //Remove the Status text
            call BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR_LABEL, 0), 0.00001)
            
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
            
            // Reposition the Hero Main Stat
            set handle = BlzGetFrameByName("InfoPanelIconHeroIcon", 6)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.422900, 0.0284300)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.439600, 0.0117300)

            // Reposition the Strength label and value
            set handle = BlzGetFrameByName("InfoPanelIconHeroStrengthLabel", 6)
            call BlzFrameSetScale(handle, 0.00001)
            set handle = BlzGetFrameByName("InfoPanelIconHeroStrengthValue", 6) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.466810, 0.0867600)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.541350, 0.0736400)

            // Reposition the Agility label and value
            set handle = BlzGetFrameByName("InfoPanelIconHeroAgilityLabel", 6)
            call BlzFrameSetScale(handle, 0.00001)
            set handle = BlzGetFrameByName("InfoPanelIconHeroAgilityValue", 6) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.541900, 0.0867600)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.610880, 0.0736400)

            // Reposition the Intelligence label and value
            set handle = BlzGetFrameByName("InfoPanelIconHeroIntellectLabel", 6)
            call BlzFrameSetScale(handle, 0.00001)
            set handle = BlzGetFrameByName("InfoPanelIconHeroIntellectValue", 6) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.611490, 0.0867600)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.667120, 0.0736400)

            // Reposition the Timed Life bar
            set handle = BlzGetFrameByName("SimpleProgressIndicator", 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.133280, 0.0105000)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.667280, 0.000500000)
            
            // Reposition the XP bar
            set handle = BlzGetFrameByName("SimpleHeroLevelBar", 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.133280, 0.0105000)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.667280, 0.000500000)

            // Reposition the Training bar
            set handle = BlzGetFrameByName("SimpleBuildTimeIndicator", 1)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.133280, 0.0105000)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.667280, 0.000500000)

            // Reposition the Attack 1 block
            set handle = BlzGetFrameByName("InfoPanelIconBackdrop", 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.136230, 0.0951800)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.160340, 0.0710700)
            call BlzFrameSetSize(handle, 0.01800, 0.01800)
            set handle = BlzGetFrameByName("InfoPanelIconValue", 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.160340, 0.0867600)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.247120, 0.0736400)
            call BlzFrameSetScale(BlzGetFrameByName("InfoPanelIconLabel", 0), 0.0001)
            
            // Reposition the Armor block
            set handle = BlzGetFrameByName("InfoPanelIconBackdrop", 2)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.247020, 0.0951800)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.271130, 0.0710700)
            call BlzFrameSetSize(handle, 0.01800, 0.01800)
            set handle = BlzGetFrameByName("InfoPanelIconValue", 2)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.271990, 0.0867600)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.358770, 0.0736400)
            call BlzFrameSetScale(BlzGetFrameByName("InfoPanelIconLabel", 2), 0.0001)
            
            set handle = null
        endmethod

        private static method onPortrait takes nothing returns nothing
            set handle = BlzGetOriginFrame(ORIGIN_FRAME_PORTRAIT, 0)

            call BlzEnableUIAutoPosition(false)
            call BlzFrameSetVisible(handle, true)
            call BlzFrameClearAllPoints(handle)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.370500, 0.0977600) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.429450, 0.0284500)

            set handle = null
        endmethod

        private static method onHeroCheck takes nothing returns nothing
            local integer i = GetPlayerId(GetLocalPlayer())

            if BlzGetTriggerFrameEvent() == FRAMEEVENT_CHECKBOX_CHECKED then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    set x1[i] = -0.131300
                    set x2[i] = -0.103220 
                    set y01[i] = 0.581980
                    set y02[i] = 0.553900
                    set y11[i] = 0.544980
                    set y12[i] = 0.516900
                    set y21[i] = 0.510680
                    set y22[i] = 0.482600
                    set y31[i] = 0.474280
                    set y32[i] = 0.446200
                    set y41[i] = 0.437880
                    set y42[i] = 0.409800
                    set y51[i] = 0.401480
                    set y52[i] = 0.373400
                    set y61[i] = 0.365080
                    set y62[i] = 0.337000
                endif

                // Reposition the hero button 0
                set handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 0)
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y01[i])
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y02[i])
                call BlzFrameSetScale(handle, 0.7)
                call BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, 0), 0.71)

                // Reposition the hero button 1
                set handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 1)
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y11[i]) 
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y12[i])
                call BlzFrameSetScale(handle, 0.7)
                call BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, 1), 0.71)

                // Reposition the hero button 2
                set handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 2)
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y21[i]) 
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y22[i])  
                call BlzFrameSetScale(handle, 0.7)
                call BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, 2), 0.71)

                // Reposition the hero button 3
                set handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 3)
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y31[i]) 
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y32[i]) 
                call BlzFrameSetScale(handle, 0.7)
                call BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, 3), 0.71)

                // Reposition the hero button 4
                set handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 4)
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y41[i]) 
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y42[i]) 
                call BlzFrameSetScale(handle, 0.7)
                call BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, 4), 0.71)

                // Reposition the hero button 5
                set handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 5)
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y51[i]) 
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y52[i])  
                call BlzFrameSetScale(handle, 0.7)
                call BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, 5), 0.71)

                // Reposition the hero button 6
                set handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 6)
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y61[i]) 
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y62[i]) 
                call BlzFrameSetScale(handle, 0.7)
                call BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, 6), 0.71)

                set handle = null
            else
                if GetLocalPlayer() == GetTriggerPlayer() then
                    set x1[i] = 999.0
                    set x2[i] = 999.0
                    set y01[i] = 999.0
                    set y02[i] = 999.0
                    set y11[i] = 999.0
                    set y12[i] = 999.0
                    set y21[i] = 999.0
                    set y22[i] = 999.0
                    set y31[i] = 999.0
                    set y32[i] = 999.0
                    set y41[i] = 999.0
                    set y42[i] = 999.0
                    set y51[i] = 999.0
                    set y52[i] = 999.0
                    set y61[i] = 999.0
                    set y62[i] = 999.0
                endif

                // Hides the hero button 0
                set handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 0)
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y01[i])
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y02[i])

                // Hides the hero button 1
                set handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 1)
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y11[i]) 
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y12[i])

                // Hides the hero button 2
                set handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 2)
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y21[i]) 
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y22[i])

                // Hides the hero button 3
                set handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 3)
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y31[i]) 
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y32[i]) 

                // Hides the hero button 4
                set handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 4)
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y41[i]) 
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y42[i]) 

                // Hides the hero button 5
                set handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 5)
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y51[i]) 
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y52[i])

                // Hides the hero button 6
                set handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 6)
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y61[i]) 
                call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y62[i])

                set handle = null
            endif
        endmethod

        private static method onGroupSelection takes nothing returns nothing
            // Reposistion the Group selection button 0
            set handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 0), 1)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.132400, 0.133000)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.155400, 0.110000)

            // Reposistion the Group selection button 1
            set handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 1), 1)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.172400, 0.133000)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.195400, 0.110000)

            // Reposistion the Group selection button 2
            set handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 2), 1)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.212400, 0.133000)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.235400, 0.110000)

            // Reposistion the Group selection button 3
            set handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 3), 1)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.252400, 0.133000)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.275400, 0.110000)    
            
            // Reposistion the Group selection button 4
            set handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 4), 1)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.332400, 0.133000)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.355400, 0.110000)

            // Reposistion the Group selection button 5
            set handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 5), 1)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.292400, 0.133000)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.315400, 0.110000)

            // Reposistion the Group selection button 6
            set handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 6), 1)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.444000, 0.133000)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.467000, 0.110000)

            // Reposistion the Group selection button 7
            set handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 7), 1)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.484000, 0.133000)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.507000, 0.110000)

            // Reposistion the Group selection button 8
            set handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 8), 1)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.524000, 0.133000)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.547000, 0.110000)

            // Reposistion the Group selection button 9
            set handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 9), 1)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.564000, 0.133000)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.587000, 0.110000)

            // Reposistion the Group selection button 10
            set handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 10), 1)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.604000, 0.133000)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.627000, 0.110000)

            // Reposistion the Group selection button 11
            set handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 11), 1)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.644000, 0.133000)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.667000, 0.110000)

            set handle = null
        endmethod

        private static method onResources takes nothing returns nothing
            call BlzFrameSetText(Gold, "|cffffcc00" + I2S(GetPlayerState(GetLocalPlayer(), PLAYER_STATE_RESOURCE_GOLD)) + "|r")
            call BlzFrameSetText(Lumber, "|cff00ff00" + I2S(GetPlayerState(GetLocalPlayer(), PLAYER_STATE_RESOURCE_LUMBER)) + "|r")
        endmethod

        private static method onChat takes nothing returns nothing
            set handle = BlzGetOriginFrame(ORIGIN_FRAME_CHAT_MSG, 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.132400, 0.336900)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.532400, 0.134400)

            set handle = BlzGetOriginFrame(ORIGIN_FRAME_UNIT_MSG, 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.132400, 0.336900)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.532400, 0.134400)

            set handle = null
        endmethod

        private static method onMinimap takes nothing returns nothing
            local integer i = GetPlayerId(GetLocalPlayer())

            if BlzGetTriggerFrameEvent() == FRAMEEVENT_CHECKBOX_CHECKED then
                if BlzGetTriggerFrame() == CheckBL then
                    if GetLocalPlayer() == GetTriggerPlayer() then
                        set mapX1[i] = - 0.133630
                        set mapY1[i] = 0.150000
                        set mapX2[i] = 0.0163700
                        set mapY2[i] = 0.00000
                        set checkL[i] = true
                    endif
                else
                    if GetLocalPlayer() == GetTriggerPlayer() then
                        set mapX1[i] = 0.785470
                        set mapY1[i] = 0.150000
                        set mapX2[i] = 0.935470
                        set mapY2[i] = 0.00000
                        set checkR[i] = true
                    endif
                endif
            else
                if BlzGetTriggerFrame() == CheckBL then
                    if GetLocalPlayer() == GetTriggerPlayer() then
                        if checkR[i] then
                            set mapX1[i] = 0.785470
                            set mapY1[i] = 0.150000
                            set mapX2[i] = 0.935470
                            set mapY2[i] = 0.00000
                        else
                            set mapX1[i] = 999.0
                            set mapY1[i] = 999.0
                            set mapX2[i] = 999.0
                            set mapY2[i] = 999.0
                        endif
                        set checkL[i] = false
                    endif
                else
                    if GetLocalPlayer() == GetTriggerPlayer() then
                        if checkL[i] then
                            set mapX1[i] = - 0.133630
                            set mapY1[i] = 0.150000
                            set mapX2[i] = 0.0163700
                            set mapY2[i] = 0.00000
                        else
                            set mapX1[i] = 999.0
                            set mapY1[i] = 999.0
                            set mapX2[i] = 999.0
                            set mapY2[i] = 999.0
                        endif
                        set checkR[i] = false
                    endif
                endif
            endif

            set handle = BlzGetFrameByName("MiniMapFrame", 0)
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, mapX1[i], mapY1[i]) 
            call BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, mapX2[i], mapY2[i])
            call BlzFrameSetAlpha(handle, MAP_TRANSPARENCY)

            set handle = null
        endmethod

        private static method onMenu takes nothing returns nothing
            local integer i = GetPlayerId(GetLocalPlayer())

            if BlzGetTriggerFrameEvent() == FRAMEEVENT_CHECKBOX_CHECKED then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    set checkMenu[i] = true
                endif
            else
                if GetLocalPlayer() == GetTriggerPlayer() then
                    set checkMenu[i] = false
                endif
            endif

            call BlzFrameSetVisible(BlzGetFrameByName("UpperButtonBarFrame", 0), checkMenu[i])
            call BlzFrameSetVisible(BlzGetFrameByName("ResourceBarFrame", 0), checkMenu[i])
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local real newHP
            local real newMP
            local string newHptext
            local string newMptext
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if GetPlayerSlotState(player) != PLAYER_SLOT_STATE_LEFT then
                        set unit = GetMainSelectedUnitEx()

                        static if DISPLAY_SHOP then
                            if main[id] != unit then
                                set main[id] = unit
                                set shop[id] = (GetUnitAbilityLevel(unit, 'Aneu') > 0 or GetUnitAbilityLevel(unit, 'Ane2') > 0 or GetUnitAbilityLevel(unit, 'Apit') > 0) and not IsUnitEnemy(unit, player)
                                call onCommandButtons()
                            endif
                        endif

                        if not IsUnitVisible(unit, player) then
                            set unit = null
                        endif

                        set health = BlzFrameGetValue(HealthBar) 
                        set mana = BlzFrameGetValue(ManaBar)
                        set newHP = GetUnitLifePercent(unit)
                        set newMP = GetUnitManaPercent(unit)
                        set hp = BlzFrameGetText(HPText)
                        set mp = BlzFrameGetText(MPText)
                        set newHptext = I2S(R2I(GetWidgetLife(unit))) + " / " + I2S(BlzGetUnitMaxHP(unit))
                        set newMptext = I2S(R2I(GetUnitState(unit,  UNIT_STATE_MANA))) + " / " + I2S(BlzGetUnitMaxMana(unit))

                        if GetLocalPlayer() == player then
                            set health = newHP
                            set mana = newMP
                            set hp = newHptext
                            set mp = newMptext
                        endif

                        call BlzFrameSetValue(HealthBar, health)
                        call BlzFrameSetValue(ManaBar, mana)
                        call BlzFrameSetText(HPText, "|cffFFFFFF" + hp + "|r")
                        call BlzFrameSetText(MPText, "|cffFFFFFF" + mp + "|r")
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
                set hp = "0 / 0"
                set mp = "0 / 0"
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
            local fogmodifier fog

            call BlzFrameSetAlpha(BlzGetFrameByName("SimpleInventoryCover", 0), 0)
            call BlzFrameSetScale(BlzGetFrameByName("InventoryText", 0), 0.0001)
            call BlzFrameSetAbsPoint(BlzGetFrameByName("ConsoleUI", 0), FRAMEPOINT_TOPLEFT, 0.0, 0.633)
            call BlzFrameSetVisible(BlzGetFrameByName("ResourceBarFrame", 0), false)
            call BlzFrameSetVisible(BlzGetFrameByName("UpperButtonBarFrame", 0), false)
            call BlzFrameSetVisible(BlzFrameGetChild(BlzFrameGetChild(BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 5),0), false)
            call BlzFrameSetParent(BlzGetFrameByName("MiniMapFrame", 0), BlzGetFrameByName("ConsoleUIBackdrop", 0))
            call BlzFrameSetVisible(BlzFrameGetChild(BlzGetFrameByName("ConsoleBottomBar", 0), 3), false)
            call BlzFrameSetParent(BlzGetOriginFrame(ORIGIN_FRAME_UBERTOOLTIP , 0), BlzGetFrameByName("ConsoleUIBackdrop", 0))
            call BlzFrameSetAbsPoint(BlzGetOriginFrame(ORIGIN_FRAME_UBERTOOLTIP , 0), FRAMEPOINT_BOTTOMRIGHT, 0.8, 0.165)

            set UI = BlzCreateFrameByType("BACKDROP", "UI", BlzGetFrameByName("ConsoleUIBackdrop", 0), "", 1) 
            call BlzFrameSetAbsPoint(UI, FRAMEPOINT_TOPLEFT, 0.132400, 0.0991800)
            call BlzFrameSetAbsPoint(UI, FRAMEPOINT_BOTTOMRIGHT, 0.667380, 0.00000)
            call BlzFrameSetTexture(UI, "UI.blp", 0, true) 

            set ShopSlots = BlzCreateFrameByType("BACKDROP", "ShopSlots", BlzGetFrameByName("ConsoleUIBackdrop", 0), "", 1) 
            call BlzFrameSetAbsPoint(ShopSlots, FRAMEPOINT_TOPLEFT, 0.330600, 0.216500) 
            call BlzFrameSetAbsPoint(ShopSlots, FRAMEPOINT_BOTTOMRIGHT, 0.478600, 0.100700) 
            call BlzFrameSetTexture(ShopSlots, "12Slot.blp", 0, true)

            set HealthBar = BlzCreateFrameByType("SIMPLESTATUSBAR", "", UI, "", 0) 
            call BlzFrameSetTexture(HealthBar, "replaceabletextures\\teamcolor\\teamcolor00", 0, true) 
            call BlzFrameSetAbsPoint(HealthBar, FRAMEPOINT_TOPLEFT, 0.134950, 0.0678600)
            call BlzFrameSetAbsPoint(HealthBar, FRAMEPOINT_BOTTOMRIGHT, 0.359120, 0.0486800)
            call BlzFrameSetValue(HealthBar, 0) 

            set ManaBar = BlzCreateFrameByType("SIMPLESTATUSBAR", "", UI, "", 0) 
            call BlzFrameSetTexture(ManaBar, "replaceabletextures\\teamcolor\\teamcolor01", 0, true) 
            call BlzFrameSetAbsPoint(ManaBar, FRAMEPOINT_TOPLEFT, 0.440380, 0.0678600)
            call BlzFrameSetAbsPoint(ManaBar, FRAMEPOINT_BOTTOMRIGHT, 0.664550, 0.0486800)
            call BlzFrameSetValue(ManaBar, 0)  

            set HeroCheck = BlzCreateFrame("QuestCheckBox", UI, 0, 0) 
            call BlzFrameSetAbsPoint(HeroCheck, FRAMEPOINT_TOPLEFT, -0.131300, 0.600240) 
            call BlzFrameSetAbsPoint(HeroCheck, FRAMEPOINT_BOTTOMRIGHT, -0.117260, 0.586200)

            set HPText = BlzCreateFrameByType("TEXT", "HPTEXT", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0) 
            call BlzFrameSetAbsPoint(HPText, FRAMEPOINT_TOPLEFT, 0.134950, 0.0678800)
            call BlzFrameSetAbsPoint(HPText, FRAMEPOINT_BOTTOMRIGHT, 0.359120, 0.0487000)
            call BlzFrameSetText(HPText, "|cffFFFFFF|r") 
            call BlzFrameSetEnable(HPText, false) 
            call BlzFrameSetScale(HPText, 1.00) 
            call BlzFrameSetTextAlignment(HPText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE) 

            set MPText = BlzCreateFrameByType("TEXT", "MPTEXT", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0) 
            call BlzFrameSetAbsPoint(MPText, FRAMEPOINT_TOPLEFT, 0.440880, 0.0678800)
            call BlzFrameSetAbsPoint(MPText, FRAMEPOINT_BOTTOMRIGHT, 0.665050, 0.0487000)
            call BlzFrameSetText(MPText, "|cffFFFFFF|r") 
            call BlzFrameSetEnable(MPText, false) 
            call BlzFrameSetScale(MPText, 1.00) 
            call BlzFrameSetTextAlignment(MPText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE) 

            set Gold = BlzCreateFrameByType("TEXT", "GOLD", UI, "", 0) 
            call BlzFrameSetAbsPoint(Gold, FRAMEPOINT_TOPLEFT, 0.377110, 0.0266100)
            call BlzFrameSetAbsPoint(Gold, FRAMEPOINT_BOTTOMRIGHT, 0.423110, 0.0132600)
            call BlzFrameSetText(Gold, "|cffffcc00|r") 
            call BlzFrameSetEnable(Gold, false) 
            call BlzFrameSetScale(Gold, 1.00) 
            call BlzFrameSetTextAlignment(Gold, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT) 

            set CheckBL = BlzCreateFrame("QuestCheckBox", UI, 0, 0) 
            call BlzFrameSetAbsPoint(CheckBL, FRAMEPOINT_TOPLEFT, 0.122370, 0.0100000)
            call BlzFrameSetAbsPoint(CheckBL, FRAMEPOINT_BOTTOMRIGHT, 0.132370, 0.00000)

            set CheckBR = BlzCreateFrame("QuestCheckBox", UI, 0, 0) 
            call BlzFrameSetAbsPoint(CheckBR, FRAMEPOINT_TOPLEFT, 0.667350, 0.0100000)
            call BlzFrameSetAbsPoint(CheckBR, FRAMEPOINT_BOTTOMRIGHT, 0.677350, 0.00000)

            set MenuCheck = BlzCreateFrame("QuestCheckBox", UI, 0, 0) 
            call BlzFrameSetAbsPoint(MenuCheck, FRAMEPOINT_TOPLEFT, 0.918800, 0.601640) 
            call BlzFrameSetAbsPoint(MenuCheck, FRAMEPOINT_BOTTOMRIGHT, 0.932840, 0.587600) 

            set GoldIcon = BlzCreateFrameByType("BACKDROP", "GoldIcon", UI, "", 1) 
            call BlzFrameSetAbsPoint(GoldIcon, FRAMEPOINT_TOPLEFT, 0.359900, 0.0284300)
            call BlzFrameSetAbsPoint(GoldIcon, FRAMEPOINT_BOTTOMRIGHT, 0.376600, 0.0117300)

            if GOLD_ICON != "" then
                call BlzFrameSetTexture(GoldIcon, GOLD_ICON, 0, true)
            else
                call BlzFrameSetVisible(GoldIcon, false)
            endif
            
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, function thistype.onSelect)
            call BlzTriggerRegisterFrameEvent(herotrigger, HeroCheck, FRAMEEVENT_CHECKBOX_CHECKED) 
            call BlzTriggerRegisterFrameEvent(herotrigger, HeroCheck, FRAMEEVENT_CHECKBOX_UNCHECKED) 
            call TriggerAddAction(herotrigger, function thistype.onHeroCheck)
            call BlzTriggerRegisterFrameEvent(maptrigger, CheckBL, FRAMEEVENT_CHECKBOX_CHECKED) 
            call BlzTriggerRegisterFrameEvent(maptrigger, CheckBL, FRAMEEVENT_CHECKBOX_UNCHECKED)
            call BlzTriggerRegisterFrameEvent(maptrigger, CheckBR, FRAMEEVENT_CHECKBOX_CHECKED) 
            call BlzTriggerRegisterFrameEvent(maptrigger, CheckBR, FRAMEEVENT_CHECKBOX_UNCHECKED)
            call TriggerAddAction(maptrigger, function thistype.onMinimap)
            call BlzTriggerRegisterFrameEvent(menutrigger, MenuCheck, FRAMEEVENT_CHECKBOX_CHECKED) 
            call BlzTriggerRegisterFrameEvent(menutrigger, MenuCheck, FRAMEEVENT_CHECKBOX_UNCHECKED)
            call TriggerAddAction(menutrigger, function thistype.onMenu)
            call TimerStart(CreateTimer(), 0.2, true, function thistype.onResources) 
            
            loop
                exitwhen i > bj_MAX_PLAYER_SLOTS
                    set x1[i] = 999.0
                    set x2[i] = 999.0
                    set y01[i] = 999.0
                    set y02[i] = 999.0
                    set y11[i] = 999.0
                    set y12[i] = 999.0
                    set y21[i] = 999.0
                    set y22[i] = 999.0
                    set y31[i] = 999.0
                    set y32[i] = 999.0
                    set y41[i] = 999.0
                    set y42[i] = 999.0
                    set y51[i] = 999.0
                    set y52[i] = 999.0
                    set y61[i] = 999.0
                    set y62[i] = 999.0
                    set mapX1[i] = 999.0
                    set mapY1[i] = 999.0
                    set mapX2[i] = 999.0
                    set mapY2[i] = 999.0
                    set frameX1[i] = 999.0
                    set frameY1[i] = 999.0
                    set frameX2[i] = 999.0
                    set frameY2[i] = 999.0
                    set command0X1[i] = 999.0
                    set command0Y1[i] = 999.0
                    set command1X1[i] = 999.0
                    set command1Y1[i] = 999.0
                    set command2X1[i] = 999.0
                    set command2Y1[i] = 999.0
                    set command3X1[i] = 999.0
                    set command3Y1[i] = 999.0
                    set command4X1[i] = 999.0
                    set command4Y1[i] = 999.0
                    set command5X1[i] = 999.0
                    set command5Y1[i] = 999.0
                    set command6X1[i] = 999.0
                    set command6Y1[i] = 999.0
                    set command7X1[i] = 999.0
                    set command7Y1[i] = 999.0
                    set command8X1[i] = 999.0
                    set command8Y1[i] = 999.0
                    set command9X1[i] = 999.0
                    set command9Y1[i] = 999.0
                    set command10X1[i] = 999.0
                    set command10Y1[i] = 999.0
                    set command11X1[i] = 999.0
                    set command11Y1[i] = 999.0
                    set command0X2[i] = 999.0
                    set command0Y2[i] = 999.0
                    set command1X2[i] = 999.0
                    set command1Y2[i] = 999.0
                    set command2X2[i] = 999.0
                    set command2Y2[i] = 999.0
                    set command3X2[i] = 999.0
                    set command3Y2[i] = 999.0
                    set command4X2[i] = 999.0
                    set command4Y2[i] = 999.0
                    set command5X2[i] = 999.0
                    set command5Y2[i] = 999.0
                    set command6X2[i] = 999.0
                    set command6Y2[i] = 999.0
                    set command7X2[i] = 999.0
                    set command7Y2[i] = 999.0
                    set command8X2[i] = 999.0
                    set command8Y2[i] = 999.0
                    set command9X2[i] = 999.0
                    set command9Y2[i] = 999.0
                    set command10X2[i] = 999.0
                    set command10Y2[i] = 999.0
                    set command11X2[i] = 999.0
                    set command11Y2[i] = 999.0
                    set shop[i] = false
                    set main[i] = null
                    set checkL[i] = false
                    set checkR[i] = false
                    set checkMenu[i] = false
                    set fog = CreateFogModifierRect(Player(i), FOG_OF_WAR_VISIBLE, GetPlayableMapRect(), true, false)
                    
                    call FogModifierStart(fog)
                    call FogModifierStop(fog)
                    call DestroyFogModifier(fog)
                set i = i + 1
            endloop

            call onCommandButtons()
            call onInventoryButtons()
            call onInfoPanel()
            call onPortrait()
            call onGroupSelection()
            call onChat()

            set fog = null
        endmethod
    endstruct
endlibrary
