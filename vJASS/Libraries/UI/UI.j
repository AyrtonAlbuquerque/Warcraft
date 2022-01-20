globals 
    framehandle MainUI = null 
    trigger TriggerMainUI = null 
endglobals 
 
library UI initializer init 
    private function CommandButtons takes nothing returns nothing
        local framehandle btn

        // Removes the Move command button
        //call BlzFrameSetVisible(BlzGetFrameByName("CommandButton_0", 0), false)

        // Removes the Stop command button
        //call BlzFrameSetVisible(BlzGetFrameByName("CommandButton_1", 0), false)
        
        // Removes the Hold command button
        //call BlzFrameSetVisible(BlzGetFrameByName("CommandButton_2", 0), false)

        // Removes the Attack command button
        //call BlzFrameSetVisible(BlzGetFrameByName("CommandButton_3", 0), false)

        // Removes the Patrol command button
        //call BlzFrameSetVisible(BlzGetFrameByName("CommandButton_4", 0), false)
        
        // Reposition the D command button
        set btn = BlzGetFrameByName("CommandButton_5", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.186900, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.216900, 0.0150000) 
        call BlzFrameSetSize(btn, 0.03178, 0.03178)
        
        // Reposition the F command button
        set btn = BlzGetFrameByName("CommandButton_6", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.223700, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.254200, 0.0150000) 
        call BlzFrameSetSize(btn, 0.03178, 0.03178)
        
        // Reposition the + command button
        set btn = BlzGetFrameByName("CommandButton_7", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.00242900, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.0342090, 0.0150000)
        call BlzFrameSetSize(btn, 0.03178, 0.03178)
        
        // Reposition the Q command button
        set btn = BlzGetFrameByName("CommandButton_8", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.0399070, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.0716870, 0.0150000) 
        call BlzFrameSetSize(btn, 0.03178, 0.03178)
        
        // Reposition the W command button
        set btn = BlzGetFrameByName("CommandButton_9", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.0765555, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.1095555, 0.0150000) 
        call BlzFrameSetSize(btn, 0.03178, 0.03178) 
        
        // Reposition the E command button
        set btn = BlzGetFrameByName("CommandButton_10", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.113070, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.144850, 0.0150000) 
        call BlzFrameSetSize(btn, 0.03178, 0.03178) 
        
        // Reposition the R command button
        set btn = BlzGetFrameByName("CommandButton_11", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.150070, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.181850, 0.0150000)
        call BlzFrameSetSize(btn, 0.03178, 0.03178)
        
        set btn = null
    endfunction
    
    private function InventoryButtons takes nothing returns nothing
        local framehandle btn
        
        // Reposition the 0 inventory button
        set btn = BlzGetFrameByName("InventoryButton_0", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.552700, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.584480, 0.0150000) 
        call BlzFrameSetSize(btn, 0.03178, 0.03178)
        
        // Reposition the 1 inventory button
        set btn = BlzGetFrameByName("InventoryButton_1", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.589100, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.621900, 0.0150000) 
        call BlzFrameSetSize(btn, 0.03178, 0.03178)
        
        // Reposition the 2 inventory button
        set btn = BlzGetFrameByName("InventoryButton_2", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.625750, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.657530, 0.0150000)
        call BlzFrameSetSize(btn, 0.03178, 0.03178)
        
        // Reposition the 3 inventory button
        set btn = BlzGetFrameByName("InventoryButton_3", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.662999, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.694999, 0.0150000)
        call BlzFrameSetSize(btn, 0.03178, 0.03178)
        
        // Reposition the 4 inventory button
        set btn = BlzGetFrameByName("InventoryButton_4", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.699700, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.731480, 0.0150000) 
        call BlzFrameSetSize(btn, 0.03178, 0.03178)
        
        // Reposition the 5 inventory button
        set btn = BlzGetFrameByName("InventoryButton_5", 0) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.736555, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.768555, 0.0150000)
        call BlzFrameSetSize(btn, 0.03178, 0.03178)
        
        set btn = null
    endfunction

    private function InfoPanel takes nothing returns nothing
        local framehandle btn
        
        // Reposition the Buff bar
        set btn = BlzGetOriginFrame(ORIGIN_FRAME_UNIT_PANEL_BUFF_BAR, 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.364600, 0.0280800) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.476200, 0.0147800)  
        call BlzFrameSetScale(btn, 0.9)
        
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
        set btn = BlzGetFrameByName("InfoPanelIconHeroIcon", 6)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.449800, 0.0581100) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.474930, 0.0329900)

        // Reposition the Strength label and value
        set btn = BlzGetFrameByName("InfoPanelIconHeroStrengthLabel", 6)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.476900, 0.0757800) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.530850, 0.0624800) 
        set btn = BlzGetFrameByName("InfoPanelIconHeroStrengthValue", 6) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.480000, 0.0657200) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.499950, 0.0553800) 

        // Reposition the Agility label and value
        set btn = BlzGetFrameByName("InfoPanelIconHeroAgilityLabel", 6)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.477400, 0.0559200) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.532090, 0.0426200) 
        set btn = BlzGetFrameByName("InfoPanelIconHeroAgilityValue", 6) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.480300, 0.0445700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.500250, 0.0342300) 

        // Reposition the Intelligence label and value
        set btn = BlzGetFrameByName("InfoPanelIconHeroIntellectLabel", 6)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.476900, 0.0346500) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.531590, 0.0213500) 
        set btn = BlzGetFrameByName("InfoPanelIconHeroIntellectValue", 6) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.480600, 0.0240700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.500550, 0.0137300)  

        // Reposition the Timed Life bar
        set btn = BlzGetFrameByName("SimpleProgressIndicator", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.00000, 0.0100000) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.770000, 0.00000)
        call BlzFrameSetSize(btn, 0.77000, 0.01000)
        
        // Reposition the XP bar
        set btn = BlzGetFrameByName("SimpleHeroLevelBar", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.00000, 0.0100000) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.770000, 0.00000)
        call BlzFrameSetSize(btn, 0.77000, 0.01000)

        // Reposition the Training bar
        set btn = BlzGetFrameByName("SimpleBuildTimeIndicator", 1)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.00000, 0.0100000) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.770000, 0.00000)
        call BlzFrameSetSize(btn, 0.77000, 0.01000)

        // Reposition the Attack 1 block
        set btn = BlzGetFrameByName("InfoPanelIconBackdrop", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.261800, 0.0723200) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.289140, 0.0449800) 
        call BlzFrameSetSize(btn, 0.02734, 0.02734)
        
        // Reposition the Armor block
        set btn = BlzGetFrameByName("InfoPanelIconBackdrop", 2)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.261100, 0.0439700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.288440, 0.0166300) 
        call BlzFrameSetSize(btn, 0.02734, 0.02734)
        
        set btn = null
    endfunction

    private function HeroButtons takes nothing returns nothing
        // local integer i = 0
        local framehandle f

        set f = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 0)
        call BlzFrameSetAbsPoint(f, FRAMEPOINT_TOPLEFT, -0.131300, 0.599480) 
        call BlzFrameSetAbsPoint(f, FRAMEPOINT_BOTTOMRIGHT, -0.103220, 0.571400) 
        call BlzFrameSetScale(f, 0.7)
        call BlzFrameSetScale(BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON_INDICATOR, 0), 0.71)

        // loop
        //     exitwhen i > 6
        //         set f = BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, i)
        //         call BlzFrameSetAbsPoint(frm, FRAMEPOINT_TOPLEFT, - 0.127600, 0.575110) 
        //         call BlzFrameSetAbsPoint(frm, FRAMEPOINT_BOTTOMRIGHT, - 0.0891700, 0.538900) 
        //     i = i + 1
        // endloop
    endfunction

    private function Portrait takes nothing returns nothing
        local framehandle f = BlzGetOriginFrame(ORIGIN_FRAME_PORTRAIT, 0)

        call BlzFrameSetAbsPoint(f, FRAMEPOINT_TOPLEFT, 0.373500, 0.0977600) 
        call BlzFrameSetAbsPoint(f, FRAMEPOINT_BOTTOMRIGHT, 0.431555, 0.0157400)

        set f = null
    endfunction

    private function init takes nothing returns nothing
        call BlzFrameSetAlpha(BlzGetFrameByName("SimpleInventoryCover", 0), 0)
        call BlzFrameSetScale(BlzGetFrameByName("InventoryText", 0), 0.0001)
        call BlzFrameSetAbsPoint(BlzGetFrameByName("ConsoleUI", 0), FRAMEPOINT_TOPLEFT, 0.0, 0.633)
        //call BlzFrameSetAbsPoint(BlzGetFrameByName("ConsoleUI", 0), FRAMEPOINT_BOTTOM, 0.4, -0.18)
        call BlzFrameSetVisible(BlzGetFrameByName("ResourceBarFrame", 0), false)
        call BlzFrameSetVisible(BlzGetFrameByName("UpperButtonBarFrame", 0), false)
        call BlzFrameSetVisible(BlzFrameGetChild(BlzGetFrameByName("ConsoleUI", 0), 7), false)
        call BlzFrameSetVisible(BlzFrameGetChild(BlzFrameGetChild(BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 5),0), false)

        set MainUI = BlzCreateFrameByType("BACKDROP", "MainUI", BlzGetFrameByName("ConsoleUIBackdrop", 0), "", 1) 
        call BlzFrameSetAbsPoint(MainUI, FRAMEPOINT_TOPLEFT, 0.00000, 0.100000) 
        call BlzFrameSetAbsPoint(MainUI, FRAMEPOINT_BOTTOMRIGHT, 0.770000, 0.00000) 
        call BlzFrameSetTexture(MainUI, "UI.blp", 0, true) 

        //call HeroButtons()
        call CommandButtons()
        call InventoryButtons()
        call InfoPanel()
        call Portrait()
    endfunction 
endlibrary
