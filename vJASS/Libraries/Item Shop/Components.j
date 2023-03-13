library Components
    /* ------------------------------------ Components v1.0 ------------------------------------ */
    // Credits:
    //      Taysen: TasItemShop and FDF file
    /* -------------------------------------- By Chopinski ------------------------------------- */

    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    globals
        private constant real TOOLTIP_SIZE          = 0.2
        private constant real SCROLL_DELAY          = 0.01
        private constant real DOUBLE_CLICK_DELAY    = 0.25
        private constant string HIGHLIGHT           = "UI\\Widgets\\Glues\\GlueScreen-Button-KeyboardHighlight"
        private constant string CHECKED_BUTTON      = "UI\\Widgets\\EscMenu\\Human\\checkbox-check.blp"
        private constant string UNAVAILABLE_BUTTON  = "ui\\widgets\\battlenet\\chaticons\\bnet-squelch"
    endglobals

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    struct Tooltip
        private framehandle box
        private framehandle line
        private framehandle tooltip
        private framehandle iconFrame
        private framehandle nameFrame
        private framehandle parent
        private framepointtype pointType
        private real widthSize
        private string texture
        private boolean isVisible
        private boolean simple

        readonly framehandle frame

        method operator text= takes string description returns nothing
            call BlzFrameSetText(tooltip, description)
        endmethod

        method operator text takes nothing returns string
            return BlzFrameGetText(tooltip)
        endmethod

        method operator name= takes string newName returns nothing
            call BlzFrameSetText(nameFrame, newName)
        endmethod

        method operator name takes nothing returns string
            return BlzFrameGetText(nameFrame)
        endmethod

        method operator icon= takes string texture returns nothing
            set .texture = texture
            call BlzFrameSetTexture(iconFrame, texture, 0, false)
        endmethod

        method operator icon takes nothing returns string
            return texture
        endmethod

        method operator width= takes real newWidth returns nothing
            set widthSize = newWidth

            if not simple then
                call BlzFrameClearAllPoints(tooltip)
                call BlzFrameSetSize(tooltip, newWidth, 0)
            endif
        endmethod

        method operator width takes nothing returns real
            return widthSize
        endmethod

        method operator point= takes framepointtype newPoint returns nothing
            set pointType = newPoint

            if not simple then
                call BlzFrameClearAllPoints(tooltip)
                
                if newPoint == FRAMEPOINT_TOPLEFT then
                    call BlzFrameSetPoint(tooltip, newPoint, parent, FRAMEPOINT_TOPRIGHT, 0.005, -0.05)
                elseif newPoint == FRAMEPOINT_TOPRIGHT then
                    call BlzFrameSetPoint(tooltip, newPoint, parent, FRAMEPOINT_TOPLEFT, -0.005, -0.05)
                elseif newPoint == FRAMEPOINT_BOTTOMLEFT then
                    call BlzFrameSetPoint(tooltip, newPoint, parent, FRAMEPOINT_BOTTOMRIGHT, 0.005, 0.0)
                else
                    call BlzFrameSetPoint(tooltip, newPoint, parent, FRAMEPOINT_BOTTOMLEFT, -0.005, 0.0)
                endif
            endif
        endmethod

        method operator point takes nothing returns framepointtype
            return pointType
        endmethod

        method operator visible= takes boolean visibility returns nothing
            set isVisible = visibility
            call BlzFrameSetVisible(box, visibility)
        endmethod

        method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method destroy takes nothing returns nothing
            call BlzDestroyFrame(nameFrame)
            call BlzDestroyFrame(iconFrame)
            call BlzDestroyFrame(tooltip)
            call BlzDestroyFrame(line)
            call BlzDestroyFrame(box)
            call BlzDestroyFrame(frame)
            call deallocate()

            set frame = null
            set box = null
            set line = null
            set tooltip = null
            set iconFrame = null
            set nameFrame = null
            set pointType = null
            set parent = null
        endmethod

        static method create takes framehandle owner, real width, framepointtype point, boolean simpleTooltip returns thistype
            local thistype this = thistype.allocate()

            set parent = owner
            set simple = simpleTooltip
            set widthSize = width
            set pointType = point
            set isVisible = true

            if simpleTooltip then
                set frame = BlzCreateFrameByType("FRAME", "", owner, "", 0)
                set box = BlzCreateFrame("Leaderboard", frame, 0, 0)
                set tooltip = BlzCreateFrameByType("TEXT", "", box, "", 0)

                call BlzFrameSetPoint(tooltip, FRAMEPOINT_BOTTOM, owner, FRAMEPOINT_TOP, 0, 0.008)
                call BlzFrameSetPoint(box, FRAMEPOINT_TOPLEFT, tooltip, FRAMEPOINT_TOPLEFT, -0.008, 0.008)
                call BlzFrameSetPoint(box, FRAMEPOINT_BOTTOMRIGHT, tooltip, FRAMEPOINT_BOTTOMRIGHT, 0.008, -0.008)
            else
                set frame = BlzCreateFrame("TooltipBoxFrame", owner, 0, 0)
                set box = BlzGetFrameByName("TooltipBox", 0)
                set line = BlzGetFrameByName("TooltipSeperator", 0)
                set tooltip = BlzGetFrameByName("TooltipText", 0)
                set iconFrame = BlzGetFrameByName("TooltipIcon", 0)
                set nameFrame = BlzGetFrameByName("TooltipName", 0)

                if point == FRAMEPOINT_TOPLEFT then
                    call BlzFrameSetPoint(tooltip, point, owner, FRAMEPOINT_TOPRIGHT, 0.005, -0.05)
                elseif point == FRAMEPOINT_TOPRIGHT then
                    call BlzFrameSetPoint(tooltip, point, owner, FRAMEPOINT_TOPLEFT, -0.005, -0.05)
                elseif point == FRAMEPOINT_BOTTOMLEFT then
                    call BlzFrameSetPoint(tooltip, point, owner, FRAMEPOINT_BOTTOMRIGHT, 0.005, 0.0)
                else
                    call BlzFrameSetPoint(tooltip, point, owner, FRAMEPOINT_BOTTOMLEFT, -0.005, 0.0)
                endif

                call BlzFrameSetPoint(box, FRAMEPOINT_TOPLEFT, iconFrame, FRAMEPOINT_TOPLEFT, -0.005, 0.005)
                call BlzFrameSetPoint(box, FRAMEPOINT_BOTTOMRIGHT, tooltip, FRAMEPOINT_BOTTOMRIGHT, 0.005, -0.005)
                call BlzFrameSetSize(tooltip, width, 0)
            endif

            return this
        endmethod
    endstruct

    struct Button
        private static hashtable table = InitHashtable()
        private static trigger clicked = CreateTrigger()
        private static trigger scrolled = CreateTrigger()
        private static trigger rightClicked = CreateTrigger()
        private static timer double = CreateTimer()
        private static timer array timer
        private static boolean array canScroll

        private trigger click
        private trigger scroll
        private trigger doubleClick
        private trigger rightClick
        private framehandle iconFrame
        private framehandle availableFrame
        private framehandle checkedFrame
        private framehandle highlightFrame
        private framehandle parent
        private boolean isVisible
        private boolean isAvailable
        private boolean isChecked
        private boolean isHighlighted
        private boolean isEnabled
        private string texture
        private real widhtSize
        private real heightSize
        private real xPos
        private real yPos
        private real doubleTime
        
        readonly framehandle frame
        Tooltip tooltip

        method operator x= takes real newX returns nothing
            set xPos = newX

            call BlzFrameClearAllPoints(iconFrame)
            call BlzFrameSetPoint(iconFrame, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, xPos, yPos)
        endmethod

        method operator x takes nothing returns real
            return xPos
        endmethod

        method operator y= takes real newY returns nothing
            set yPos = newY

            call BlzFrameClearAllPoints(iconFrame)
            call BlzFrameSetPoint(iconFrame, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, xPos, yPos)
        endmethod

        method operator y takes nothing returns real
            return yPos
        endmethod

        method operator icon= takes string texture returns nothing
            set .texture = texture
            call BlzFrameSetTexture(iconFrame, texture, 0, true)
        endmethod

        method operator icon takes nothing returns string
            return texture
        endmethod

        method operator width= takes real newWidth returns nothing
            set widhtSize = newWidth

            call BlzFrameClearAllPoints(iconFrame)
            call BlzFrameSetSize(iconFrame, newWidth, heightSize)
        endmethod

        method operator width takes nothing returns real
            return widhtSize
        endmethod

        method operator height= takes real newHeight returns nothing
            set heightSize = newHeight

            call BlzFrameClearAllPoints(iconFrame)
            call BlzFrameSetSize(iconFrame, widhtSize, newHeight)
        endmethod

        method operator height takes nothing returns real
            return heightSize
        endmethod

        method operator visible= takes boolean visibility returns nothing
            set isVisible = visibility
            call BlzFrameSetVisible(iconFrame, visibility)
        endmethod

        method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method operator available= takes boolean flag returns nothing
            set isAvailable = flag

            if flag then
                call BlzFrameSetVisible(availableFrame, false)
            else
                call BlzFrameSetVisible(availableFrame, true)
                call BlzFrameSetTexture(availableFrame, UNAVAILABLE_BUTTON, 0, true)
            endif
        endmethod

        method operator available takes nothing returns boolean
            return isAvailable
        endmethod

        method operator checked= takes boolean flag returns nothing
            set isChecked = flag

            if flag then
                call BlzFrameSetVisible(checkedFrame, true)
                call BlzFrameSetTexture(checkedFrame, CHECKED_BUTTON, 0, true)
            else
                call BlzFrameSetVisible(checkedFrame, false)
            endif
        endmethod

        method operator checked takes nothing returns boolean
            return isChecked
        endmethod

        method operator highlighted= takes boolean flag returns nothing
            set isHighlighted = flag

            if flag then
                call BlzFrameSetVisible(highlightFrame, true)
                call BlzFrameSetTexture(highlightFrame, HIGHLIGHT, 0, true)
            else
                call BlzFrameSetVisible(highlightFrame, false)
            endif
        endmethod

        method operator highlighted takes nothing returns boolean
            return isHighlighted
        endmethod

        method operator enabled= takes boolean flag returns nothing
            local string t = texture

            set isEnabled = flag

            if not flag then
                if SubString(t, 34, 35) == "\\" then
                    set t = SubString(t, 0, 34) + "Disabled\\DIS" + SubString(t, 35, StringLength(t))
                endif
            endif
    
            call BlzFrameSetTexture(iconFrame, t, 0, true)
        endmethod

        method operator enabled takes nothing returns boolean
            return isEnabled
        endmethod

        method operator onClick= takes code c returns nothing
            call DestroyTrigger(click)
            set click = null

            if c != null then
                set click = CreateTrigger()
                call TriggerAddCondition(click, Condition(c))
            endif
        endmethod

        method operator onScroll= takes code c returns nothing
            call DestroyTrigger(scroll)
            set scroll = null

            if c != null then
                set scroll = CreateTrigger()
                call TriggerAddCondition(scroll, Condition(c))
            endif
        endmethod

        method operator onDoubleClick= takes code c returns nothing
            call DestroyTrigger(doubleClick)
            set doubleClick = null

            if c != null then
                set doubleClick = CreateTrigger()
                call TriggerAddCondition(doubleClick, Condition(c))
            endif
        endmethod

        method operator onRightClick= takes code c returns nothing
            call DestroyTrigger(rightClick)
            set rightClick = null

            if c != null then
                set rightClick = CreateTrigger()
                call TriggerAddCondition(rightClick, Condition(c))
            endif
        endmethod

        method destroy takes nothing returns nothing
            call FlushChildHashtable(table, GetHandleId(frame))
            call DestroyTrigger(click)
            call DestroyTrigger(scroll)
            call DestroyTrigger(doubleClick)
            call DestroyTrigger(rightClick)
            call BlzDestroyFrame(frame)
            call BlzDestroyFrame(iconFrame)
            call BlzDestroyFrame(availableFrame)
            call BlzDestroyFrame(checkedFrame)
            call tooltip.destroy()
            call deallocate()

            set availableFrame = null
            set checkedFrame = null
            set iconFrame = null
            set doubleClick = null
            set rightClick = null
            set parent = null
            set scroll = null
            set frame = null
            set click = null
        endmethod

        static method create takes framehandle owner, real width, real height, real x, real y, boolean simpleTooltip returns thistype
            local thistype this = thistype.allocate()
            local integer i = 0

            set parent = owner
            set xPos = x
            set yPos = y
            set doubleTime = 0
            set widhtSize = width
            set heightSize = height
            set isVisible = true
            set isAvailable = true
            set isChecked = false
            set isHighlighted = false
            set iconFrame = BlzCreateFrameByType("BACKDROP", "", owner, "", 0)   
            set availableFrame = BlzCreateFrameByType("BACKDROP", "", iconFrame, "", 0)  
            set checkedFrame = BlzCreateFrameByType("BACKDROP", "", iconFrame, "", 0)
            set highlightFrame = BlzCreateFrameByType("BACKDROP", "", iconFrame, "", 0)
            set frame = BlzCreateFrame("IconButtonTemplate", iconFrame, 0, 0)
            set tooltip = Tooltip.create(frame, TOOLTIP_SIZE, FRAMEPOINT_TOPLEFT, simpleTooltip)
            
            call BlzFrameSetPoint(iconFrame, FRAMEPOINT_TOPLEFT, owner, FRAMEPOINT_TOPLEFT, x, y)
            call BlzFrameSetSize(iconFrame, width, height)
            call BlzFrameSetAllPoints(frame, highlightFrame)
            call BlzFrameSetTooltip(frame, tooltip.frame)
            call BlzFrameSetAllPoints(availableFrame, iconFrame)
            call BlzFrameSetVisible(availableFrame, false)
            call BlzFrameSetAllPoints(checkedFrame, iconFrame)
            call BlzFrameSetVisible(checkedFrame, false)
            call BlzFrameSetAllPoints(highlightFrame, iconFrame)
            call BlzFrameSetVisible(highlightFrame, false)
            call SaveInteger(table, GetHandleId(frame), 0, this)
            call BlzTriggerRegisterFrameEvent(clicked, frame, FRAMEEVENT_CONTROL_CLICK)
            call BlzTriggerRegisterFrameEvent(scrolled, frame, FRAMEEVENT_MOUSE_WHEEL)
            call BlzTriggerRegisterFrameEvent(rightClicked, frame, FRAMEEVENT_MOUSE_UP)

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    set timer[i] = CreateTimer()
                    set canScroll[i] = true
                set i = i + 1
            endloop

            return this
        endmethod

        private static method onExpire takes nothing returns nothing
            set canScroll[GetPlayerId(GetLocalPlayer())] = true
        endmethod

        private static method onScrolled takes nothing returns nothing
            local thistype this = LoadInteger(table, GetHandleId(BlzGetTriggerFrame()), 0)
            local integer i = GetPlayerId(GetLocalPlayer())

            if this != 0 then
                if canScroll[i] and scroll != null then
                    if SCROLL_DELAY > 0 then
                        set canScroll[i] = false
                    endif

                    call TriggerEvaluate(scroll)
                endif
            endif

            if SCROLL_DELAY > 0 then
                call TimerStart(timer[i], TimerGetRemaining(timer[i]), false, function thistype.onExpire)
            endif
        endmethod

        private static method onRightClicked takes nothing returns nothing
            local thistype this = LoadInteger(table, GetHandleId(BlzGetTriggerFrame()), 0)

            if this != 0 then
                if BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT and rightClick != null then
                    call TriggerEvaluate(rightClick)
                endif
            endif
        endmethod

        private static method onClicked takes nothing returns nothing
            local thistype this = LoadInteger(table, GetHandleId(BlzGetTriggerFrame()), 0)
            local real time

            if this != 0 then
                if click != null then
                    call TriggerEvaluate(click)
                endif

                if GetLocalPlayer() == GetTriggerPlayer() then
                    set time = TimerGetElapsed(double)

                    if time - doubleTime <= DOUBLE_CLICK_DELAY then
                        set doubleTime = 0

                        if doubleClick != null then
                            call TriggerEvaluate(doubleClick)
                        endif
                    else
                        set doubleTime = time
                    endif
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call TimerStart(double, 9999999999, false, null)
            call TriggerAddAction(clicked, function thistype.onClicked)
            call TriggerAddAction(scrolled, function thistype.onScrolled)
            call TriggerAddAction(rightClicked, function thistype.onRightClicked)
        endmethod
    endstruct
endlibrary