--[[ requires onInit, RegisterPlayerUnitEvent
    /* -------------------------- UI v1.2 by Chopinski -------------------------- */
    // Credits
    //      - Tasyen     GetMainSelectedUnit
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- Set this to a texture to replace the default gold icon
    local GOLD_ICON   = ""
    -- Set this to a texture to replace the default lumber icon
    local LUMBER_ICON = ""

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    MainUI = setmetatable({}, {})
    local mt = getmetatable(MainUI)
    mt.__index = mt

    local maptrigger = CreateTrigger()
    local herotrigger = CreateTrigger()
    local menutrigger = CreateTrigger()
    local trigger = CreateTrigger()
    local timer = CreateTimer()

    local key = 0
    local array = {}
    local struct = {}

    local handle = nil
    local UI = nil
    local HealthBar = nil
    local ManaBar = nil
    local HeroCheck = nil
    local HPText = nil
    local MPText = nil
    local Gold = nil
    local Lumber = nil
    local CheckBL = nil
    local CheckBR = nil
    local Minimap = nil
    local MenuCheck = nil
    local LumberIcon = nil
    local GoldIcon = nil

    local x1 = {}
    local x2 = {}
    local y01 = {}
    local y02 = {}
    local y11 = {}
    local y12 = {}
    local y21 = {}
    local y22 = {}
    local y31 = {}
    local y32 = {}
    local y41 = {}
    local y42 = {}
    local y51 = {}
    local y52 = {}
    local y61 = {}
    local y62 = {}

    local mapX1 = {}
    local mapY1 = {}
    local mapX2 = {}
    local mapY2 = {}

    local frameX1 = {}
    local frameY1 = {}
    local frameX2 = {}
    local frameY2 = {}

    local checkL = {}
    local checkR = {}

    local checkMenu = {}

    function mt:remove(i)
        array[i] = array[key]
        key = key - 1
        struct[self.id] = nil
        self = nil

        if key == 0 then
            PauseTimer(timer)
        end

        return i - 1
    end

    function mt:onCommandButtons()
        -- Removes the Move command button
        -- BlzFrameSetVisible(BlzGetFrameByName("CommandButton_0", 0), false)

        -- Removes the Stop command button
        -- BlzFrameSetVisible(BlzGetFrameByName("CommandButton_1", 0), false)

        -- Removes the Hold command button
        -- BlzFrameSetVisible(BlzGetFrameByName("CommandButton_2", 0), false)

        -- Removes the Attack command button
        -- BlzFrameSetVisible(BlzGetFrameByName("CommandButton_3", 0), false)

        -- Removes the Patrol command button
        -- BlzFrameSetVisible(BlzGetFrameByName("CommandButton_4", 0), false)

        -- Reposition the D command button
        handle = BlzGetFrameByName("CommandButton_5", 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.186900, 0.0467700)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.216900, 0.0150000)
        BlzFrameSetSize(handle, 0.03178, 0.03178)

        -- Reposition the F command button
        handle = BlzGetFrameByName("CommandButton_6", 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.223700, 0.0467700)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.254200, 0.0150000)
        BlzFrameSetSize(handle, 0.03178, 0.03178)

        -- Reposition the + command button
        handle = BlzGetFrameByName("CommandButton_7", 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.00242900, 0.0467700)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.0342090, 0.0150000)
        BlzFrameSetSize(handle, 0.03178, 0.03178)

        -- Reposition the Q command button
        handle = BlzGetFrameByName("CommandButton_8", 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.0399070, 0.0467700)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.0716870, 0.0150000)
        BlzFrameSetSize(handle, 0.03178, 0.03178)

        -- Reposition the W command button
        handle = BlzGetFrameByName("CommandButton_9", 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.0765555, 0.0467700)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.1095555, 0.0150000)
        BlzFrameSetSize(handle, 0.03178, 0.03178)

        -- Reposition the E command button
        handle = BlzGetFrameByName("CommandButton_10", 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.113070, 0.0467700)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.144850, 0.0150000)
        BlzFrameSetSize(handle, 0.03178, 0.03178)

        -- Reposition the R command button
        handle = BlzGetFrameByName("CommandButton_11", 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.150070, 0.0467700)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.181850, 0.0150000)
        BlzFrameSetSize(handle, 0.03178, 0.03178)

        handle = nil
    end

    function mt:onInventoryButtons()
        -- Reposition the 0 inventory button
        handle = BlzGetFrameByName("InventoryButton_0", 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.552700, 0.0467700)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.584480, 0.0150000)
        BlzFrameSetSize(handle, 0.03178, 0.03178)

        -- Reposition the 1 inventory button
        handle = BlzGetFrameByName("InventoryButton_1", 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.589100, 0.0467700)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.621900, 0.0150000)
        BlzFrameSetSize(handle, 0.03178, 0.03178)

        -- Reposition the 2 inventory button
        handle = BlzGetFrameByName("InventoryButton_2", 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.625750, 0.0467700)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.657530, 0.0150000)
        BlzFrameSetSize(handle, 0.03178, 0.03178)

        -- Reposition the 3 inventory button
        handle = BlzGetFrameByName("InventoryButton_3", 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.662999, 0.0467700)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.694999, 0.0150000)
        BlzFrameSetSize(handle, 0.03178, 0.03178)

        -- Reposition the 4 inventory button
        handle = BlzGetFrameByName("InventoryButton_4", 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.699700, 0.0467700)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.731480, 0.0150000)
        BlzFrameSetSize(handle, 0.03178, 0.03178)

        -- Reposition the 5 inventory button
        handle = BlzGetFrameByName("InventoryButton_5", 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.736555, 0.0467700)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.768555, 0.0150000)
        BlzFrameSetSize(handle, 0.03178, 0.03178)

        handle = nil
    end

    function mt:onInfoPanel()
        -- Reposition the Buff bar
        handle = BlzGetOriginFrame(ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR, 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.364600, 0.0280800)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.476200, 0.0147800)
        BlzFrameSetScale(handle, 0.9)

        -- Remove the Status text
        BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR_LABEL, 0), 0.00001)

        -- Remove Names and Descriptions
        BlzFrameSetScale(BlzGetFrameByName("SimpleNameValue", 0), 0.00001)
        BlzFrameSetScale(BlzGetFrameByName("SimpleClassValue", 0), 0.00001)
        BlzFrameSetScale(BlzGetFrameByName("SimpleBuildingNameValue", 1), 0.00001)
        BlzFrameSetScale(BlzGetFrameByName("SimpleBuildingActionLabel", 1), 0.00001)
        BlzFrameSetScale(BlzGetFrameByName("SimpleHoldNameValue", 2), 0.00001)
        BlzFrameSetScale(BlzGetFrameByName("SimpleHoldDescriptionNameValue", 2), 0.00001)
        BlzFrameSetScale(BlzGetFrameByName("SimpleItemNameValue", 3), 0.00001)
        BlzFrameSetScale(BlzGetFrameByName("SimpleItemDescriptionValue", 3), 0.00001)
        BlzFrameSetScale(BlzGetFrameByName("SimpleDestructableNameValue", 4), 0.00001)

        -- Reposition the Hero Main Stat
        handle = BlzGetFrameByName("InfoPanelIconHeroIcon", 6)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.449800, 0.0581100)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.474930, 0.0329900)

        -- Reposition the Strength label and value
        handle = BlzGetFrameByName("InfoPanelIconHeroStrengthLabel", 6)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.476900, 0.0757800)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.530850, 0.0624800)
        handle = BlzGetFrameByName("InfoPanelIconHeroStrengthValue", 6)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.480000, 0.0657200)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.550000, 0.0553800)

        -- Reposition the Agility label and value
        handle = BlzGetFrameByName("InfoPanelIconHeroAgilityLabel", 6)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.477400, 0.0559200)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.532090, 0.0426200)
        handle = BlzGetFrameByName("InfoPanelIconHeroAgilityValue", 6)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.480300, 0.0445700)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.550000, 0.0342300)

        -- Reposition the Intelligence label and value
        handle = BlzGetFrameByName("InfoPanelIconHeroIntellectLabel", 6)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.476900, 0.0346500)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.531590, 0.0213500)
        handle = BlzGetFrameByName("InfoPanelIconHeroIntellectValue", 6)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.480600, 0.0240700)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.550000, 0.0137300)

        -- Reposition the Timed Life bar
        handle = BlzGetFrameByName("SimpleProgressIndicator", 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.00000, 0.0100000)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.770000, 0.00000)
        BlzFrameSetSize(handle, 0.77000, 0.01000)

        -- Reposition the XP bar
        handle = BlzGetFrameByName("SimpleHeroLevelBar", 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.00000, 0.0100000)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.770000, 0.00000)
        BlzFrameSetSize(handle, 0.77000, 0.01000)

        -- Reposition the Training bar
        handle = BlzGetFrameByName("SimpleBuildTimeIndicator", 1)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.00000, 0.0100000)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.770000, 0.00000)
        BlzFrameSetSize(handle, 0.77000, 0.01000)

        -- Reposition the Attack 1 block
        handle = BlzGetFrameByName("InfoPanelIconBackdrop", 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.261800, 0.0723200)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.289140, 0.0449800)
        BlzFrameSetSize(handle, 0.02734, 0.02734)

        -- Reposition the Armor block
        handle = BlzGetFrameByName("InfoPanelIconBackdrop", 2)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.261100, 0.0439700)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.288440, 0.0166300)
        BlzFrameSetSize(handle, 0.02734, 0.02734)

        handle = nil
    end

    function mt:onPortrait()
        handle = BlzGetOriginFrame(ORIGIN_FRAME_PORTRAIT, 0)

        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.373500, 0.0977600)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.431555, 0.0157400)

        handle = nil
    end

    function mt:onHeroCheck()
        local i = GetPlayerId(GetLocalPlayer())

        if BlzGetTriggerFrameEvent() == FRAMEEVENT_CHECKBOX_CHECKED then
            if GetLocalPlayer() == GetTriggerPlayer() then
                x1[i] = -0.131300
                x2[i] = -0.103220
                y01[i] = 0.581980
                y02[i] = 0.553900
                y11[i] = 0.544980
                y12[i] = 0.516900
                y21[i] = 0.510680
                y22[i] = 0.482600
                y31[i] = 0.474280
                y32[i] = 0.446200
                y41[i] = 0.437880
                y42[i] = 0.409800
                y51[i] = 0.401480
                y52[i] = 0.373400
                y61[i] = 0.365080
                y62[i] = 0.337000
            end

            -- Reposition the hero button 0
            handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 0)
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y01[i])
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y02[i])
            BlzFrameSetScale(handle, 0.7)
            BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, 0), 0.71)

            -- Reposition the hero button 1
            handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 1)
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y11[i])
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y12[i])
            BlzFrameSetScale(handle, 0.7)
            BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, 1), 0.71)

            -- Reposition the hero button 2
            handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 2)
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y21[i])
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y22[i])
            BlzFrameSetScale(handle, 0.7)
            BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, 2), 0.71)

            -- Reposition the hero button 3
            handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 3)
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y31[i])
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y32[i])
            BlzFrameSetScale(handle, 0.7)
            BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, 3), 0.71)

            -- Reposition the hero button 4
            handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 4)
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y41[i])
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y42[i])
            BlzFrameSetScale(handle, 0.7)
            BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, 4), 0.71)

            -- Reposition the hero button 5
            handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 5)
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y51[i])
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y52[i])
            BlzFrameSetScale(handle, 0.7)
            BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, 5), 0.71)

            -- Reposition the hero button 6
            handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 6)
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y61[i])
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y62[i])
            BlzFrameSetScale(handle, 0.7)
            BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, 6), 0.71)

            handle = nil
        else
            if GetLocalPlayer() == GetTriggerPlayer() then
                x1[i] = 999.0
                x2[i] = 999.0
                y01[i] = 999.0
                y02[i] = 999.0
                y11[i] = 999.0
                y12[i] = 999.0
                y21[i] = 999.0
                y22[i] = 999.0
                y31[i] = 999.0
                y32[i] = 999.0
                y41[i] = 999.0
                y42[i] = 999.0
                y51[i] = 999.0
                y52[i] = 999.0
                y61[i] = 999.0
                y62[i] = 999.0
            end

            -- Hides the hero button 0
            handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 0)
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y01[i])
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y02[i])

            -- Hides the hero button 1
            handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 1)
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y11[i])
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y12[i])

            -- Hides the hero button 2
            handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 2)
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y21[i])
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y22[i])

            -- Hides the hero button 3
            handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 3)
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y31[i])
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y32[i])

            -- Hides the hero button 4
            handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 4)
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y41[i])
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y42[i])

            -- Hides the hero button 5
            handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 5)
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y51[i])
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y52[i])

            -- Hides the hero button 6
            handle = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 6)
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, x1[i], y61[i])
            BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, x2[i], y62[i])

            handle = nil
        end
    end

    function mt:onGroupSelection()
        -- Reposistion the Group selection button 0
        handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 0), 1)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.262600, 0.0776200)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.285600, 0.0546200)

        -- Reposistion the Group selection button 1
        handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 1), 1)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.295800, 0.0731200)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.318800, 0.0501200)

        -- Reposistion the Group selection button 2
        handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 2), 1)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.328300, 0.0731200)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.351300, 0.0501200)

        -- Reposistion the Group selection button 3
        handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 3), 1)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.262600, 0.0414100)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.285600, 0.0184100)

        -- Reposistion the Group selection button 4
        handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 4), 1)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.295800, 0.0414000)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.318800, 0.0184000)

        -- Reposistion the Group selection button 5
        handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 5), 1)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.329100, 0.0414000)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.352100, 0.0184000)

        -- Reposistion the Group selection button 6
        handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 6), 1)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.449300, 0.0731200)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.472300, 0.0501200)

        -- Reposistion the Group selection button 7
        handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 7), 1)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.483500, 0.0731200)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.506500, 0.0501200)

        -- Reposistion the Group selection button 8
        handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 8), 1)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.516800, 0.0731200)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.539800, 0.0501200)

        -- Reposistion the Group selection button 9
        handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 9), 1)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.450300, 0.0414000)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.473300, 0.0184000)

        -- Reposistion the Group selection button 10
        handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 10), 1)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.483500, 0.0414000)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.506500, 0.0184000)

        -- Reposistion the Group selection button 11
        handle = BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetChild(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), 5), 0), 11), 1)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.516800, 0.0414000)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.539800, 0.0184000)

        handle = nil
    end

    function mt:onResources()
        BlzFrameSetText(Gold, "|cffffcc00" .. I2S(GetPlayerState(GetLocalPlayer(), PLAYER_STATE_RESOURCE_GOLD)) .. "|r")
        BlzFrameSetText(Lumber, "|cff00ff00" .. I2S(GetPlayerState(GetLocalPlayer(), PLAYER_STATE_RESOURCE_LUMBER)) .. "|r")
    end

    function mt:onChat()
        handle = BlzGetOriginFrame(ORIGIN_FRAME_CHAT_MSG, 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.000212200, 0.302800)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.400212, 0.100300)

        handle = BlzGetOriginFrame(ORIGIN_FRAME_UNIT_MSG, 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, 0.000212200, 0.302800)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, 0.400212, 0.100300)

        handle = nil
    end

    function mt:onMinimap()
        local i = GetPlayerId(GetLocalPlayer())

        if BlzGetTriggerFrameEvent() == FRAMEEVENT_CHECKBOX_CHECKED then
            if BlzGetTriggerFrame() == CheckBL then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    mapX1[i] = - 0.132100
                    mapY1[i] = 0.0986970
                    mapX2[i] = - 0.0351000
                    mapY2[i] = 0.00169700
                    frameX1[i] = - 0.133600
                    frameY1[i] = 0.100939
                    frameX2[i] = - 0.0338300
                    frameY2[i] = 0.000438700
                    checkL[i] = true
                end
            else
                if GetLocalPlayer() == GetTriggerPlayer() then
                    mapX1[i] = 0.835800
                    mapY1[i] = 0.0999999
                    mapX2[i] = 0.933610
                    mapY2[i] = 0.000219400
                    frameX1[i] = 0.833900
                    frameY1[i] = 0.100939
                    frameX2[i] = 0.933670
                    frameY2[i] = 0.000438700
                    checkR[i] = true
                end
            end
        else
            if BlzGetTriggerFrame() == CheckBL then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    if checkR[i] then
                        mapX1[i] = 0.835800
                        mapY1[i] = 0.0999999
                        mapX2[i] = 0.933610
                        mapY2[i] = 0.000219400
                        frameX1[i] = 0.833900
                        frameY1[i] = 0.100939
                        frameX2[i] = 0.933670
                        frameY2[i] = 0.000438700
                    else
                        mapX1[i] = 999.0
                        mapY1[i] = 999.0
                        mapX2[i] = 999.0
                        mapY2[i] = 999.0
                        frameX1[i] = 999.0
                        frameY1[i] = 999.0
                        frameX2[i] = 999.0
                        frameY2[i] = 999.0
                    end
                    checkL[i] = false
                end
            else
                if GetLocalPlayer() == GetTriggerPlayer() then
                    if checkL[i] then
                        mapX1[i] = - 0.132100
                        mapY1[i] = 0.0986970
                        mapX2[i] = - 0.0351000
                        mapY2[i] = 0.00169700
                        frameX1[i] = - 0.133600
                        frameY1[i] = 0.100939
                        frameX2[i] = - 0.0338300
                        frameY2[i] = 0.000438700
                    else
                        mapX1[i] = 999.0
                        mapY1[i] = 999.0
                        mapX2[i] = 999.0
                        mapY2[i] = 999.0
                        frameX1[i] = 999.0
                        frameY1[i] = 999.0
                        frameX2[i] = 999.0
                        frameY2[i] = 999.0
                    end
                    checkR[i] = false
                end
            end
        end

        handle = BlzGetFrameByName("MiniMapFrame", 0)
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_TOPLEFT, mapX1[i], mapY1[i])
        BlzFrameSetAbsPoint(handle, FRAMEPOINT_BOTTOMRIGHT, mapX2[i], mapY2[i])
        BlzFrameSetAbsPoint(Minimap, FRAMEPOINT_TOPLEFT, frameX1[i], frameY1[i])
        BlzFrameSetAbsPoint(Minimap, FRAMEPOINT_BOTTOMRIGHT, frameX2[i], frameY2[i])

        handle = nil
    end

    function mt:onMenu()
        local i = GetPlayerId(GetLocalPlayer())

        if BlzGetTriggerFrameEvent() == FRAMEEVENT_CHECKBOX_CHECKED then
            if GetLocalPlayer() == GetTriggerPlayer() then
                checkMenu[i] = true
            end
        else
            if GetLocalPlayer() == GetTriggerPlayer() then
                checkMenu[i] = false
            end
        end

        BlzFrameSetVisible(BlzGetFrameByName("UpperButtonBarFrame", 0), checkMenu[i])
    end

    function mt:onPeriod()
        local i = 1
        local newHP
        local newMP
        local newHPtext
        local newMPtext
        local this

        while i <= key do
            this = array[i]

            if GetPlayerSlotState(this.player) ~= PLAYER_SLOT_STATE_LEFT then
                this.unit = GetMainSelectedUnitEx()

                if not IsUnitVisible(this.unit, this.player) then
                    this.unit = nil
                end

                this.health = BlzFrameGetValue(HealthBar)
                this.mana = BlzFrameGetValue(ManaBar)
                newHP = GetUnitLifePercent(this.unit)
                newMP = GetUnitManaPercent(this.unit)
                this.hp = BlzFrameGetText(HPText)
                this.mp = BlzFrameGetText(MPText)
                newHPtext = I2S(R2I(GetWidgetLife(this.unit))) .. " / " .. I2S(BlzGetUnitMaxHP(this.unit))
                newMPtext = I2S(R2I(GetUnitState(this.unit,  UNIT_STATE_MANA))) .. " / " .. I2S(BlzGetUnitMaxMana(this.unit))

                if GetLocalPlayer() == this.player then
                    this.health = newHP
                    this.mana = newMP
                    this.hp = newHPtext
                    this.mp = newMPtext
                end

                BlzFrameSetValue(HealthBar, this.health)
                BlzFrameSetValue(ManaBar, this.mana)
                BlzFrameSetText(HPText, "|cffFFFFFF" .. this.hp .. "|r")
                BlzFrameSetText(MPText, "|cffFFFFFF" .. this.mp .. "|r")
            else
                i = this:remove(i)
            end
            i = i + 1
        end
    end

    function mt:onSelect()
        local id = GetPlayerId(GetTriggerPlayer())
        local this

        if struct[id] then
            this = struct[id]
        else
            this = {}
            setmetatable(this, mt)

            this.id = id
            this.unit = nil
            this.player = GetTriggerPlayer()
            this.health = 0
            this.mana = 0
            this.hp = "0 / 0"
            this.mp = "0 / 0"
            key = key + 1
            array[key] = this
            struct[id] = this

            if key == 1 then
                TimerStart(timer, 0.05, true, function() MainUI:onPeriod() end)
            end
        end
    end

    onInit(function()
        BlzFrameSetAlpha(BlzGetFrameByName("SimpleInventoryCover", 0), 0)
        BlzFrameSetScale(BlzGetFrameByName("InventoryText", 0), 0.0001)
        BlzFrameSetAbsPoint(BlzGetFrameByName("ConsoleUI", 0), FRAMEPOINT_TOPLEFT, 0.0, 0.633)
        BlzFrameSetVisible(BlzGetFrameByName("ResourceBarFrame", 0), false)
        BlzFrameSetVisible(BlzGetFrameByName("UpperButtonBarFrame", 0), false)
        BlzFrameSetVisible(BlzFrameGetChild(BlzGetFrameByName("ConsoleUI", 0), 7), false)
        BlzFrameSetVisible(BlzFrameGetChild(BlzFrameGetChild(BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 5),0), false)
        BlzFrameSetParent(BlzGetFrameByName("MiniMapFrame", 0), BlzGetFrameByName("ConsoleUIBackdrop", 0))

        UI = BlzCreateFrameByType("BACKDROP", "UI", BlzGetFrameByName("ConsoleUIBackdrop", 0), "", 1)
        BlzFrameSetAbsPoint(UI, FRAMEPOINT_TOPLEFT, 0.00000, 0.100000)
        BlzFrameSetAbsPoint(UI, FRAMEPOINT_BOTTOMRIGHT, 0.770000, 0.00000)
        BlzFrameSetTexture(UI, "UI.blp", 0, true)

        HealthBar = BlzCreateFrameByType("SIMPLESTATUSBAR", "", UI, "", 0)
        BlzFrameSetTexture(HealthBar, "replaceabletextures\\teamcolor\\teamcolor00", 0, true)
        BlzFrameSetAbsPoint(HealthBar, FRAMEPOINT_TOPLEFT, 0.0386400, 0.0778900)
        BlzFrameSetAbsPoint(HealthBar, FRAMEPOINT_BOTTOMRIGHT, 0.255140, 0.0535100)
        BlzFrameSetValue(HealthBar, 0)

        ManaBar = BlzCreateFrameByType("SIMPLESTATUSBAR", "", UI, "", 0)
        BlzFrameSetTexture(ManaBar, "replaceabletextures\\teamcolor\\teamcolor01", 0, true)
        BlzFrameSetAbsPoint(ManaBar, FRAMEPOINT_TOPLEFT, 0.551500, 0.0778000)
        BlzFrameSetAbsPoint(ManaBar, FRAMEPOINT_BOTTOMRIGHT, 0.768000, 0.0534200)
        BlzFrameSetValue(ManaBar, 0)

        HeroCheck = BlzCreateFrame("QuestCheckBox", UI, 0, 0)
        BlzFrameSetAbsPoint(HeroCheck, FRAMEPOINT_TOPLEFT, -0.131300, 0.600240)
        BlzFrameSetAbsPoint(HeroCheck, FRAMEPOINT_BOTTOMRIGHT, -0.117260, 0.586200)

        HPText = BlzCreateFrameByType("TEXT", "HPTEXT", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
        BlzFrameSetAbsPoint(HPText, FRAMEPOINT_TOPLEFT, 0.108100, 0.0726300)
        BlzFrameSetAbsPoint(HPText, FRAMEPOINT_BOTTOMRIGHT, 0.184960, 0.0585900)
        BlzFrameSetText(HPText, "|cffFFFFFF|r")
        BlzFrameSetEnable(HPText, false)
        BlzFrameSetScale(HPText, 1.00)
        BlzFrameSetTextAlignment(HPText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)

        MPText = BlzCreateFrameByType("TEXT", "MPTEXT", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
        BlzFrameSetAbsPoint(MPText, FRAMEPOINT_TOPLEFT, 0.622500, 0.0726000)
        BlzFrameSetAbsPoint(MPText, FRAMEPOINT_BOTTOMRIGHT, 0.699360, 0.0585600)
        BlzFrameSetText(MPText, "|cffFFFFFF|r")
        BlzFrameSetEnable(MPText, false)
        BlzFrameSetScale(MPText, 1.00)
        BlzFrameSetTextAlignment(MPText, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_MIDDLE)

        Lumber = BlzCreateFrameByType("TEXT", "GOLD", UI, "", 0)
        BlzFrameSetAbsPoint(Lumber, FRAMEPOINT_TOPLEFT, 0.291100, 0.0970200)
        BlzFrameSetAbsPoint(Lumber, FRAMEPOINT_BOTTOMRIGHT, 0.346530, 0.0815000)
        BlzFrameSetText(Lumber, "|cff00ff00|r")
        BlzFrameSetEnable(Lumber, false)
        BlzFrameSetScale(Lumber, 1.00)
        BlzFrameSetTextAlignment(Lumber, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_RIGHT)

        Gold = BlzCreateFrameByType("TEXT", "LUMBER", UI, "", 0)
        BlzFrameSetAbsPoint(Gold, FRAMEPOINT_TOPLEFT, 0.460600, 0.0972500)
        BlzFrameSetAbsPoint(Gold, FRAMEPOINT_BOTTOMRIGHT, 0.516030, 0.0817300)
        BlzFrameSetText(Gold, "|cffffcc00|r")
        BlzFrameSetEnable(Gold, false)
        BlzFrameSetScale(Gold, 1.00)
        BlzFrameSetTextAlignment(Gold, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)

        CheckBL = BlzCreateFrame("QuestCheckBox", UI, 0, 0)
        BlzFrameSetAbsPoint(CheckBL, FRAMEPOINT_TOPLEFT, 0.269200, 0.102200)
        BlzFrameSetAbsPoint(CheckBL, FRAMEPOINT_BOTTOMRIGHT, 0.292850, 0.0778100)

        CheckBR = BlzCreateFrame("QuestCheckBox", UI, 0, 0)
        BlzFrameSetAbsPoint(CheckBR, FRAMEPOINT_TOPLEFT, 0.514800, 0.102200)
        BlzFrameSetAbsPoint(CheckBR, FRAMEPOINT_BOTTOMRIGHT, 0.538450, 0.0778100)

        Minimap = BlzCreateFrameByType("BACKDROP", "Minimap", UI, "", 1)
        BlzFrameSetAbsPoint(Minimap, FRAMEPOINT_TOPLEFT, 999.0, 999.0)
        BlzFrameSetAbsPoint(Minimap, FRAMEPOINT_BOTTOMRIGHT, 999.0, 999.0)
        BlzFrameSetTexture(Minimap, "Minimap.blp", 0, true)

        MenuCheck = BlzCreateFrame("QuestCheckBox", UI, 0, 0)
        BlzFrameSetAbsPoint(MenuCheck, FRAMEPOINT_TOPLEFT, 0.918800, 0.601640)
        BlzFrameSetAbsPoint(MenuCheck, FRAMEPOINT_BOTTOMRIGHT, 0.932840, 0.587600)

        LumberIcon = BlzCreateFrameByType("BACKDROP", "LumberIcon", UI, "", 1)
        BlzFrameSetAbsPoint(LumberIcon, FRAMEPOINT_TOPLEFT, 0.347600, 0.0966800)
        BlzFrameSetAbsPoint(LumberIcon, FRAMEPOINT_BOTTOMRIGHT, 0.362600, 0.0816800)

        if LUMBER_ICON ~= "" then
            BlzFrameSetTexture(LumberIcon, LUMBER_ICON, 0, true)
        else
            BlzFrameSetVisible(LumberIcon, false)
        end

        GoldIcon = BlzCreateFrameByType("BACKDROP", "GoldIcon", UI, "", 1)
        BlzFrameSetAbsPoint(GoldIcon, FRAMEPOINT_TOPLEFT, 0.445900, 0.0966600)
        BlzFrameSetAbsPoint(GoldIcon, FRAMEPOINT_BOTTOMRIGHT, 0.460900, 0.0816600)

        if GOLD_ICON ~= "" then
            BlzFrameSetTexture(GoldIcon, GOLD_ICON, 0, true)
        else
            BlzFrameSetVisible(GoldIcon, false)
        end

        MainUI:onCommandButtons()
        MainUI:onInventoryButtons()
        MainUI:onInfoPanel()
        MainUI:onPortrait()
        MainUI:onGroupSelection()
        MainUI:onChat()

        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, function() MainUI:onSelect() end)
        BlzTriggerRegisterFrameEvent(herotrigger, HeroCheck, FRAMEEVENT_CHECKBOX_CHECKED)
        BlzTriggerRegisterFrameEvent(herotrigger, HeroCheck, FRAMEEVENT_CHECKBOX_UNCHECKED)
        TriggerAddAction(herotrigger, function() MainUI:onHeroCheck() end)
        BlzTriggerRegisterFrameEvent(maptrigger, CheckBL, FRAMEEVENT_CHECKBOX_CHECKED)
        BlzTriggerRegisterFrameEvent(maptrigger, CheckBL, FRAMEEVENT_CHECKBOX_UNCHECKED)
        BlzTriggerRegisterFrameEvent(maptrigger, CheckBR, FRAMEEVENT_CHECKBOX_CHECKED)
        BlzTriggerRegisterFrameEvent(maptrigger, CheckBR, FRAMEEVENT_CHECKBOX_UNCHECKED)
        TriggerAddAction(maptrigger, function() MainUI:onMinimap() end)
        BlzTriggerRegisterFrameEvent(menutrigger, MenuCheck, FRAMEEVENT_CHECKBOX_CHECKED)
        BlzTriggerRegisterFrameEvent(menutrigger, MenuCheck, FRAMEEVENT_CHECKBOX_UNCHECKED)
        TriggerAddAction(menutrigger, function() MainUI:onMenu() end)
        TimerStart(CreateTimer(), 0.2, true, function() MainUI:onResources() end)

        for i = 0, 24 do
            x1[i] = 999.0
            x2[i] = 999.0
            y01[i] = 999.0
            y02[i] = 999.0
            y11[i] = 999.0
            y12[i] = 999.0
            y21[i] = 999.0
            y22[i] = 999.0
            y31[i] = 999.0
            y32[i] = 999.0
            y41[i] = 999.0
            y42[i] = 999.0
            y51[i] = 999.0
            y52[i] = 999.0
            y61[i] = 999.0
            y62[i] = 999.0
            mapX1[i] = 999.0
            mapY1[i] = 999.0
            mapX2[i] = 999.0
            mapY2[i] = 999.0
            frameX1[i] = 999.0
            frameY1[i] = 999.0
            frameX2[i] = 999.0
            frameY2[i] = 999.0
            checkL[i] = false
            checkR[i] = false
            checkMenu[i] = false
        end
    end)
end