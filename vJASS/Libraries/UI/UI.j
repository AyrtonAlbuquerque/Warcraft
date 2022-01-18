globals 
    framehandle MainUI = null 
    trigger TriggerMainUI = null 
endglobals 
 
library UI initializer init 
    private function CommandButtons takes nothing returns nothing
        local framehandle btn

        // Removes the Move command button
        call BlzFrameSetVisible(BlzGetFrameByName("CommandButton_0", 0), false)

        // Removes the Stop command button
        call BlzFrameSetVisible(BlzGetFrameByName("CommandButton_1", 0), false)
        
        // Removes the Hold command button
        call BlzFrameSetVisible(BlzGetFrameByName("CommandButton_2", 0), false)

        // Removes the Attack command button
        call BlzFrameSetVisible(BlzGetFrameByName("CommandButton_3", 0), false)

        // Removes the Patrol command button
        call BlzFrameSetVisible(BlzGetFrameByName("CommandButton_4", 0), false)
        
        // Reposition the D command button
        set btn = BlzGetFrameByName("CommandButton_5", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.186200, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.217980, 0.0150000) 
        call BlzFrameSetSize(btn, 0.03178, 0.03178)
        
        // Reposition the F command button
        set btn = BlzGetFrameByName("CommandButton_6", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.222200, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.253980, 0.0150000) 
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
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.0760700, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.107850, 0.0150000) 
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
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.551700, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.583480, 0.0150000) 
        call BlzFrameSetSize(btn, 0.03178, 0.03178)
        
        // Reposition the 1 inventory button
        set btn = BlzGetFrameByName("InventoryButton_1", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.588700, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.620480, 0.0150000) 
        call BlzFrameSetSize(btn, 0.03178, 0.03178)
        
        // Reposition the 2 inventory button
        set btn = BlzGetFrameByName("InventoryButton_2", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.624700, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.656480, 0.0150000)
        call BlzFrameSetSize(btn, 0.03178, 0.03178)
        
        // Reposition the 3 inventory button
        set btn = BlzGetFrameByName("InventoryButton_3", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.661700, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.693480, 0.0150000)
        call BlzFrameSetSize(btn, 0.03178, 0.03178)
        
        // Reposition the 4 inventory button
        set btn = BlzGetFrameByName("InventoryButton_4", 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.698700, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.730480, 0.0150000) 
        call BlzFrameSetSize(btn, 0.03178, 0.03178)
        
        // Reposition the 5 inventory button
        set btn = BlzGetFrameByName("InventoryButton_5", 0) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.734700, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.766480, 0.0150000)
        call BlzFrameSetSize(btn, 0.03178, 0.03178)
        
        set btn = null
    endfunction

    private function init takes nothing returns nothing 
        local framehandle parent = BlzCreateFrameByType("SIMPLEFRAME", "", BlzGetFrameByName("ConsoleUI", 0), "", 0)
    
        call BlzHideOriginFrames(true) 
        call BlzFrameSetVisible(parent, false)
        call BlzFrameSetVisible(BlzFrameGetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0)), true)
        call BlzFrameSetParent(BlzGetFrameByName("SimpleInfoPanelUnitDetail", 0), parent)
        call BlzFrameSetVisible(BlzFrameGetParent(BlzGetOriginFrame(ORIGIN_FRAME_HERO_BUTTON, 0)), true)
        call BlzFrameSetAlpha(BlzGetFrameByName("SimpleInventoryCover", 0), 0)
        call BlzFrameSetScale(BlzGetFrameByName("InventoryText", 0), 0.0001)
        call BlzFrameSetVisible(BlzFrameGetChild(BlzGetFrameByName("ConsoleUI", 0), 5), false)
        call BlzFrameSetSize(BlzGetFrameByName("ConsoleUIBackdrop",0), 0, 0.0001)
        call BlzFrameSetVisible(BlzGetOriginFrame(ORIGIN_FRAME_MINIMAP,0), false)
        call BlzFrameSetVisible(BlzGetFrameByName("ResourceBarFrame",0), false)
        call BlzFrameSetVisible(BlzGetFrameByName("UpperButtonBarFrame",0), false)
        call BlzFrameSetVisible(BlzGetOriginFrame(ORIGIN_FRAME_PORTRAIT, 0), false)


        set MainUI = BlzCreateFrameByType("BACKDROP", "MainUI", BlzGetFrameByName("ConsoleUIBackdrop", 0), "", 1) 
        call BlzFrameSetAbsPoint(MainUI, FRAMEPOINT_TOPLEFT, 0.00000, 0.100000) 
        call BlzFrameSetAbsPoint(MainUI, FRAMEPOINT_BOTTOMRIGHT, 0.770000, 0.00000) 
        call BlzFrameSetTexture(MainUI, "UI.blp", 0, true) 

        call CommandButtons()
        call InventoryButtons()
        
        set parent = null
    endfunction 
endlibrary
