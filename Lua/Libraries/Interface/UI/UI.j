globals 
    framehandle MainUI = null 
    trigger TriggerMainUI = null 
endglobals 
 
library UI initializer init 
    private function CommandButtons takes nothing returns nothing
        local framehandle btn

        // Removes the Move command button
        set btn = BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, 0)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_RIGHT, -999.0, -999.0)

        // Removes the Stop command button
        set btn = BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, 1)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_RIGHT, -999.0, -999.0)

        // Removes the Hold command button
        set btn = BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, 2)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_RIGHT, -999.0, -999.0)

        // Removes the Attack command button
        set btn = BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, 3)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_RIGHT, -999.0, -999.0)

        // Removes the Patrol command button
        set btn = BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, 4)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_RIGHT, -999.0, -999.0)

        // Reposition the + command button
        set btn = BlzGetOriginFrame(ORIGIN_FRAME_COMMAND_BUTTON, 7)
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_TOPLEFT, 0.00242900, 0.0467700) 
        call BlzFrameSetAbsPoint(btn, FRAMEPOINT_BOTTOMRIGHT, 0.0342090, 0.0150000) 

        set btn = null
    endfunction

    private function init takes nothing returns nothing 
        call BlzHideOriginFrames(true) 
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
    endfunction 
endlibrary
