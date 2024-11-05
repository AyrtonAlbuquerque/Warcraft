library Components requires Table
    /* ------------------------------------ Components v1.2 ------------------------------------ */
    // Credits:
    //      Taysen: FDF file
    //      Bribe: Table library
    /* -------------------------------------- By Chopinski ------------------------------------- */

    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    globals
        private constant real TOOLTIP_SIZE          = 0.2
        private constant real DOUBLE_CLICK_DELAY    = 0.25
        private constant string HIGHLIGHT           = "UI\\Widgets\\Glues\\GlueScreen-Button-KeyboardHighlight"
        private constant string CHECKED_BUTTON      = "UI\\Widgets\\EscMenu\\Human\\checkbox-check.blp"
        private constant string UNAVAILABLE_BUTTON  = "ui\\widgets\\battlenet\\chaticons\\bnet-squelch"

        private timer DOUBLE = CreateTimer()
    endglobals

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function GetTriggerComponent takes nothing returns Component
        return Component.get()
    endfunction

    function GetTriggerEditBox takes nothing returns EditBox
        return EditBox.get()
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private interface Events
        method onText takes nothing returns nothing defaults nothing
        method onEnter takes nothing returns nothing defaults nothing
        method onLeave takes nothing returns nothing defaults nothing
        method onClick takes nothing returns nothing defaults nothing
        method onScroll takes nothing returns nothing defaults nothing
        method onRightClick takes nothing returns nothing defaults nothing
        method onMiddleClick takes nothing returns nothing defaults nothing
        method onDoubleClick takes nothing returns nothing defaults nothing
    endinterface

    struct Tooltip
        private framehandle box
        private framehandle line
        private framehandle tooltip
        private framehandle iconFrame
        private framehandle nameFrame
        private framehandle parentFrame
        private framepointtype pointType
        private real widthSize
        private string texture
        private boolean isVisible
        private boolean simple

        readonly framehandle frame

        method operator parent takes nothing returns framehandle
            return parentFrame
        endmethod

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
                elseif newPoint == FRAMEPOINT_BOTTOM then
                    call BlzFrameSetPoint(tooltip, newPoint, parent, FRAMEPOINT_TOP, 0.0, 0.005)
                elseif newPoint == FRAMEPOINT_TOP then
                    call BlzFrameSetPoint(tooltip, newPoint, parent, FRAMEPOINT_BOTTOM, 0.0, -0.05)
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
            set parentFrame = null
        endmethod

        static method create takes framehandle owner, real width, framepointtype point, boolean simpleTooltip returns thistype
            local thistype this = thistype.allocate()

            set parentFrame = owner
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

    struct Component extends Events
        private static trigger click = CreateTrigger()
        private static trigger enter = CreateTrigger()
        private static trigger leave = CreateTrigger()
        private static trigger scroll = CreateTrigger()
        private static Table table
        private static HashTable time
        private static HashTable doubleTime
        private static framehandle console
        private static framehandle world
        private static thistype array array

        private real xPos
        private real yPos
        private real widthSize
        private real heightSize
        private string path
        private boolean isVisible
        private boolean isEnabled
        private trigger exited
        private trigger entered
        private trigger clicked
        private trigger scrolled
        private trigger rightClicked
        private trigger doubleClicked
        private trigger middleClicked
        private framehandle base
        private framehandle image
        private framehandle button
        private framehandle listener

        readonly framehandle parent

        method operator x= takes real newX returns nothing
            set xPos = newX

            if parent == console or parent == world then
                call BlzFrameSetAbsPoint(base, FRAMEPOINT_TOPLEFT, xPos, yPos)
            else
                call BlzFrameSetPoint(base, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, xPos, yPos)
            endif
        endmethod

        method operator x takes nothing returns real
            return xPos
        endmethod

        method operator y= takes real newY returns nothing
            set yPos = newY

            if parent == console or parent == world then
                call BlzFrameSetAbsPoint(base, FRAMEPOINT_TOPLEFT, xPos, yPos)
            else
                call BlzFrameSetPoint(base, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, xPos, yPos)
            endif
        endmethod

        method operator y takes nothing returns real
            return yPos
        endmethod

        method operator width= takes real newWidth returns nothing
            set widthSize = newWidth

            call BlzFrameClearAllPoints(base)
            call BlzFrameSetSize(base, newWidth, heightSize)
        endmethod

        method operator width takes nothing returns real
            return widthSize
        endmethod

        method operator height= takes real newHeight returns nothing
            set heightSize = newHeight

            call BlzFrameClearAllPoints(base)
            call BlzFrameSetSize(base, widthSize, newHeight)
        endmethod

        method operator height takes nothing returns real
            return heightSize
        endmethod

        method operator texture= takes string path returns nothing
            set .path = path

            if path != "" and path != null then
                call BlzFrameSetTexture(image, path, 0, true)
                call BlzFrameSetVisible(image, true)
            else
                call BlzFrameSetVisible(image, false)
            endif
        endmethod

        method operator texture takes nothing returns string
            return path
        endmethod

        stub method operator visible= takes boolean visibility returns nothing
            set isVisible = visibility
            call BlzFrameSetVisible(base, visibility)
        endmethod

        stub method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method operator enabled= takes boolean flag returns nothing
            local string t = path

            set isEnabled = flag

            if not flag then
                if SubString(t, 34, 35) == "\\" then
                    set t = SubString(t, 0, 34) + "Disabled\\DIS" + SubString(t, 35, StringLength(t))
                endif
            endif
    
            call BlzFrameSetTexture(image, t, 0, true)
        endmethod

        method operator enabled takes nothing returns boolean
            return isEnabled
        endmethod

        method operator frame takes nothing returns framehandle
            return base
        endmethod

        method operator actor takes nothing returns framehandle
            return listener
        endmethod

        method operator onEnter= takes code c returns nothing
            call DestroyTrigger(entered)
            set entered = null

            if c != null then
                set entered = CreateTrigger()
                call TriggerAddCondition(entered, Condition(c))
            endif
        endmethod

        method operator onLeave= takes code c returns nothing
            call DestroyTrigger(exited)
            set exited = null

            if c != null then
                set exited = CreateTrigger()
                call TriggerAddCondition(exited, Condition(c))
            endif
        endmethod

        method operator onClick= takes code c returns nothing
            call DestroyTrigger(clicked)
            set clicked = null

            if c != null then
                set clicked = CreateTrigger()
                call TriggerAddCondition(clicked, Condition(c))
            endif
        endmethod

        method operator onScroll= takes code c returns nothing
            call DestroyTrigger(scrolled)
            set scrolled = null

            if c != null then
                set scrolled = CreateTrigger()
                call TriggerAddCondition(scrolled, Condition(c))
            endif
        endmethod

        method operator onRightClick= takes code c returns nothing
            call DestroyTrigger(rightClicked)
            set rightClicked = null

            if c != null then
                set rightClicked = CreateTrigger()
                call TriggerAddCondition(rightClicked, Condition(c))
            endif
        endmethod

        method operator onDoubleClick= takes code c returns nothing
            call DestroyTrigger(doubleClicked)
            set doubleClicked = null

            if c != null then
                set doubleClicked = CreateTrigger()
                call TriggerAddCondition(doubleClicked, Condition(c))
            endif
        endmethod

        method operator onMiddleClick= takes code c returns nothing
            call DestroyTrigger(middleClicked)
            set middleClicked = null

            if c != null then
                set middleClicked = CreateTrigger()
                call TriggerAddCondition(middleClicked, Condition(c))
            endif
        endmethod

        method destroy takes nothing returns nothing
            call table.remove(GetHandleId(listener))
            call table.remove(GetHandleId(button))
            call BlzDestroyFrame(image)
            call BlzDestroyFrame(listener)
            call BlzDestroyFrame(base)

            set base = null
            set image = null
            set button = null
            set parent = null
            set listener = null
        endmethod

        static method get takes nothing returns thistype
            return array[GetPlayerId(GetTriggerPlayer())]
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent, string frameType, string template returns thistype
            local thistype this = thistype.allocate()

            if parent == null then
                set parent = console
            endif

            if template == "" or template == null then
                set template = "TransparentBackdrop"
            endif

            set .x = x
            set .y = y
            set .width = width
            set .height = height
            set .parent = parent
            set base = BlzCreateFrame(template, parent, 0, 0)
            set listener = BlzCreateFrame(frameType, base, 0, 0)
            set button = BlzFrameGetChild(listener, 0)
            set image = BlzCreateFrameByType("BACKDROP", "", listener, "", 0)
            set table[GetHandleId(listener)] = this
            set table[GetHandleId(button)] = this

            if parent == console or parent == world then
                call BlzFrameSetAbsPoint(base, FRAMEPOINT_TOPLEFT, x, y)
            else
                call BlzFrameSetPoint(base, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, x, y)
            endif

            call BlzFrameSetSize(base, width, height)
            call BlzFrameSetAllPoints(listener, base)
            call BlzFrameSetAllPoints(image, listener)
            call BlzFrameSetVisible(image, false)
            call BlzTriggerRegisterFrameEvent(enter, listener, FRAMEEVENT_MOUSE_ENTER)
            call BlzTriggerRegisterFrameEvent(leave, listener, FRAMEEVENT_MOUSE_LEAVE)
            call BlzTriggerRegisterFrameEvent(scroll, button, FRAMEEVENT_MOUSE_WHEEL)

            return this
        endmethod

        private static method onScrolled takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())]

            if this != 0 then
                if onScroll.exists then
                    call onScroll()
                endif

                if scrolled != null then
                    call TriggerEvaluate(scrolled)
                endif
            endif
        endmethod

        private static method onClicked takes nothing returns nothing
            local integer id = GetPlayerId(GetTriggerPlayer())
            local thistype this = array[id]

            if this != 0 then
                if BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_LEFT then
                    set time[id].real[this] = TimerGetElapsed(DOUBLE)

                    call BlzFrameSetEnable(listener, false)
                    call BlzFrameSetEnable(listener, true)
    
                    if onClick.exists then
                        call onClick()
                    endif

                    if clicked != null then
                        call TriggerEvaluate(clicked)
                    endif
    
                    if time[id].real[this] - doubleTime[id].real[this] <= DOUBLE_CLICK_DELAY then
                        set doubleTime[id][this] = 0
    
                        if onDoubleClick.exists then
                            call onDoubleClick()
                        endif

                        if doubleClicked != null then
                            call TriggerEvaluate(doubleClicked)
                        endif
                    else
                        set doubleTime[id].real[this] = time[id].real[this]
                    endif
                endif

                if BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_RIGHT then
                    if onRightClick.exists then
                        call onRightClick()
                    endif

                    if rightClicked != null then
                        call TriggerEvaluate(rightClicked)
                    endif
                endif

                if BlzGetTriggerPlayerMouseButton() == MOUSE_BUTTON_TYPE_MIDDLE then
                    if onMiddleClick.exists then
                        call onMiddleClick()
                    endif

                    if middleClicked != null then
                        call TriggerEvaluate(middleClicked)
                    endif
                endif
            endif
        endmethod

        private static method onEntered takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())]

            set array[GetPlayerId(GetTriggerPlayer())] = this

            if this != 0 then
                if onEnter.exists then
                    call onEnter()
                endif

                if entered != null then
                    call TriggerEvaluate(entered)
                endif
            endif
        endmethod

        private static method onExited takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())]

            set array[GetPlayerId(GetTriggerPlayer())] = 0

            if this != 0 then
                if onLeave.exists then
                    call onLeave()
                endif

                if exited != null then
                    call TriggerEvaluate(exited)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            local integer i = 0

            set table = Table.create()
            set time = HashTable.create()
            set doubleTime = HashTable.create()
            set console = BlzGetFrameByName("ConsoleUIBackdrop", 0)
            set world = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)

            call BlzLoadTOCFile("Components.toc")
            call TimerStart(DOUBLE, 9999999999, false, null)
            call TriggerAddAction(enter, function thistype.onEntered)
            call TriggerAddAction(leave, function thistype.onExited)
            call TriggerAddAction(click, function thistype.onClicked)
            call TriggerAddAction(scroll, function thistype.onScrolled)

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    set array[i] = 0
                    call TriggerRegisterPlayerEvent(click, Player(i), EVENT_PLAYER_MOUSE_UP)
                set i = i + 1
            endloop
        endmethod
    endstruct

    struct Button extends Component
        private boolean isChecked
        private boolean isAvailable
        private boolean isHighlighted
        private framehandle tagFrame
        private framehandle spriteFrame
        private framehandle displayFrame
        private framehandle checkedFrame
        private framehandle chargesFrame
        private framehandle availableFrame
        private framehandle highlightFrame

        Tooltip tooltip

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

        method destroy takes nothing returns nothing
            call BlzDestroyFrame(tagFrame)
            call BlzDestroyFrame(spriteFrame)
            call BlzDestroyFrame(displayFrame)
            call BlzDestroyFrame(checkedFrame)
            call BlzDestroyFrame(availableFrame)
            call BlzDestroyFrame(highlightFrame)
            call tooltip.destroy()

            set tagFrame = null
            set spriteFrame = null
            set checkedFrame = null
            set displayFrame = null
            set highlightFrame = null
            set availableFrame = null
        endmethod

        method play takes string model, real scale, integer animation returns nothing
            if model != "" and model != null then
                call BlzFrameClearAllPoints(spriteFrame)
                call BlzFrameSetPoint(spriteFrame, FRAMEPOINT_CENTER, frame, FRAMEPOINT_CENTER, 0, 0)
                call BlzFrameSetSize(spriteFrame, width, height)
                call BlzFrameSetModel(spriteFrame, model, 0)
                call BlzFrameSetScale(spriteFrame, scale)
                call BlzFrameSetSpriteAnimate(spriteFrame, animation, 0)
            endif
        endmethod

        method display takes string model, real scale, framepointtype point, framepointtype relativePoint, real offsetX, real offsetY returns nothing
            if model != "" and model != null then
                call BlzFrameSetPoint(displayFrame, point, frame, relativePoint, offsetX, offsetY)
                call BlzFrameSetSize(displayFrame, 0.00001, 0.00001)
                call BlzFrameSetScale(displayFrame, scale)
                call BlzFrameSetModel(displayFrame, model, 0)
                call BlzFrameSetVisible(displayFrame, true)
            else
                call BlzFrameSetVisible(displayFrame, false)
            endif
        endmethod

        method tag takes string model, real scale, framepointtype point, framepointtype relativePoint, real offsetX, real offsetY returns nothing
            if model != "" and model != null then
                call BlzFrameSetPoint(tagFrame, point, frame, relativePoint, offsetX, offsetY)
                call BlzFrameSetSize(tagFrame, 0.00001, 0.00001)
                call BlzFrameSetScale(tagFrame, scale)
                call BlzFrameSetModel(tagFrame, model, 0)
                call BlzFrameSetVisible(tagFrame, true)
            else
                call BlzFrameSetVisible(tagFrame, false)
            endif
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent, boolean simpleTooltip returns thistype
            local thistype this = thistype.allocate(x, y, width, height, parent, "ComponentFrame", null)
            
            set availableFrame = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)  
            set checkedFrame = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set highlightFrame = BlzCreateFrame("HighlightFrame", frame, 0, 0)
            set displayFrame = BlzCreateFrameByType("SPRITE", "", frame, "", 0)
            set tagFrame = BlzCreateFrameByType("SPRITE", "", frame, "", 0)
            set spriteFrame = BlzCreateFrameByType("SPRITE", "", frame, "", 0)
            set tooltip = Tooltip.create(frame, TOOLTIP_SIZE, FRAMEPOINT_TOPLEFT, simpleTooltip)
            set available = true
            set checked = false
            set highlighted = false

            call BlzFrameSetTooltip(actor, tooltip.frame)
            call BlzFrameSetAllPoints(availableFrame, frame)
            call BlzFrameSetVisible(availableFrame, false)
            call BlzFrameSetAllPoints(checkedFrame, frame)
            call BlzFrameSetVisible(checkedFrame, false)
            call BlzFrameSetPoint(highlightFrame, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, - 0.004, 0.0045)
            call BlzFrameSetSize(highlightFrame, width + 0.0085, height + 0.0085)
            call BlzFrameSetVisible(highlightFrame, false)

            return this
        endmethod
    endstruct

    struct Panel extends Component
        static method create takes real x, real y, real width, real height, framehandle parent, string template returns thistype
            return thistype.allocate(x, y, width, height, parent, "PanelFrame", template)
        endmethod
    endstruct

    struct EditBox extends Events
        private static trigger typing = CreateTrigger()
        private static trigger enter = CreateTrigger()
        private static Table table
        private static framehandle console
        private static framehandle world

        private real xPos
        private real yPos
        private real widthSize
        private real heightSize
        private string value
        private integer textLength
        private boolean isVisible
        private trigger typed
        private trigger entered
        private framehandle base

        readonly framehandle parent

        method operator x= takes real newX returns nothing
            set xPos = newX

            if parent == console or parent == world then
                call BlzFrameSetAbsPoint(base, FRAMEPOINT_TOPLEFT, xPos, yPos)
            else
                call BlzFrameSetPoint(base, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, xPos, yPos)
            endif
        endmethod

        method operator x takes nothing returns real
            return xPos
        endmethod

        method operator y= takes real newY returns nothing
            set yPos = newY

            if parent == console or parent == world then
                call BlzFrameSetAbsPoint(base, FRAMEPOINT_TOPLEFT, xPos, yPos)
            else
                call BlzFrameSetPoint(base, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, xPos, yPos)
            endif
        endmethod

        method operator y takes nothing returns real
            return yPos
        endmethod

        method operator width= takes real newWidth returns nothing
            set widthSize = newWidth

            call BlzFrameClearAllPoints(base)
            call BlzFrameSetSize(base, newWidth, heightSize)
        endmethod

        method operator width takes nothing returns real
            return widthSize
        endmethod

        method operator height= takes real newHeight returns nothing
            set heightSize = newHeight

            call BlzFrameClearAllPoints(base)
            call BlzFrameSetSize(base, widthSize, newHeight)
        endmethod

        method operator height takes nothing returns real
            return heightSize
        endmethod

        method operator limit= takes integer length returns nothing
            set textLength = length
            call BlzFrameSetTextSizeLimit(base, length)
        endmethod

        method operator limit takes nothing returns integer
            return textLength
        endmethod

        method operator text= takes string newText returns nothing
            set value = newText
            call BlzFrameSetText(base, newText)
        endmethod

        method operator text takes nothing returns string
            set value = BlzFrameGetText(base)
            return value
        endmethod

        stub method operator visible= takes boolean visibility returns nothing
            set isVisible = visibility
            call BlzFrameSetVisible(base, visibility)
        endmethod

        stub method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method operator frame takes nothing returns framehandle
            return base
        endmethod

        method operator onEnter= takes code c returns nothing
            call DestroyTrigger(entered)
            set entered = null

            if c != null then
                set entered = CreateTrigger()
                call TriggerAddCondition(entered, Condition(c))
            endif
        endmethod

        method operator onText= takes code c returns nothing
            call DestroyTrigger(typed)
            set typed = null

            if c != null then
                set typed = CreateTrigger()
                call TriggerAddCondition(typed, Condition(c))
            endif
        endmethod

        method destroy takes nothing returns nothing
            call BlzDestroyFrame(base)

            set base = null
            set parent = null
        endmethod

        static method get takes nothing returns thistype
            return table[GetHandleId(BlzGetTriggerFrame())]
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent, string template returns thistype
            local thistype this = thistype.allocate()

            if parent == null then
                set parent = console
            endif

            if template == "" or template == null then
                set template = "EscMenuEditBoxTemplate"
            endif

            set .x = x
            set .y = y
            set .width = width
            set .height = height
            set .parent = parent
            set base = BlzCreateFrame(template, parent, 0, 0)
            set table[GetHandleId(base)] = this

            if parent == console or parent == world then
                call BlzFrameSetAbsPoint(base, FRAMEPOINT_TOPLEFT, x, y)
            else
                call BlzFrameSetPoint(base, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, x, y)
            endif

            call BlzFrameSetSize(base, width, height)
            call BlzTriggerRegisterFrameEvent(enter, base, FRAMEEVENT_EDITBOX_ENTER)
            call BlzTriggerRegisterFrameEvent(typing, base, FRAMEEVENT_EDITBOX_TEXT_CHANGED)

            return this
        endmethod

        private static method onTyping takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())]

            if this != 0 then
                set value = BlzGetTriggerFrameText()

                if onText.exists then
                    call onText()
                endif

                if typed != null then
                    call TriggerEvaluate(typed)
                endif
            endif
        endmethod

        private static method onEntered takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())]

            if this != 0 then
                if onEnter.exists then
                    call onEnter()
                endif

                if entered != null then
                    call TriggerEvaluate(entered)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set table = Table.create()
            set console = BlzGetFrameByName("ConsoleUIBackdrop", 0)
            set world = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)

            call TriggerAddAction(enter, function thistype.onEntered)
            call TriggerAddAction(typing, function thistype.onTyping)
        endmethod
    endstruct
endlibrary