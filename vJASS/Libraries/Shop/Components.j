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
        private framehandle CONSOLE
        private framehandle WORLD
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

    function GetTriggerCheckBox takes nothing returns CheckBox
        return CheckBox.get()
    endfunction

    function GetTriggerSlider takes nothing returns Slider
        return Slider.get()
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private interface IComponent
        method onText takes nothing returns nothing defaults nothing
        method onCheck takes nothing returns nothing defaults nothing
        method onEnter takes nothing returns nothing defaults nothing
        method onLeave takes nothing returns nothing defaults nothing
        method onClick takes nothing returns nothing defaults nothing
        method onSlide takes nothing returns nothing defaults nothing
        method onScroll takes nothing returns nothing defaults nothing
        method onUncheck takes nothing returns nothing defaults nothing
        method onRightClick takes nothing returns nothing defaults nothing
        method onMiddleClick takes nothing returns nothing defaults nothing
        method onDoubleClick takes nothing returns nothing defaults nothing
    endinterface

    private module Operators
        private real _x
        private real _y
        private real _scale
        private real _width
        private real _height
        private integer _alpha
        private boolean _enabled = true
        private boolean _visible = true
        private framehandle _frame
        private framepointtype _point = FRAMEPOINT_TOPLEFT
        private framepointtype _relative = FRAMEPOINT_TOPLEFT

        readonly framehandle parent

        method operator x= takes real newX returns nothing
            set _x = newX

            if parent == CONSOLE or parent == WORLD then
                call BlzFrameSetAbsPoint(frame, _point, _x, _y)
            else
                call BlzFrameSetPoint(frame, _point, parent, _relative, _x, _y)
            endif
        endmethod

        method operator x takes nothing returns real
            return _x
        endmethod

        method operator y= takes real newY returns nothing
            set _y = newY

            if parent == CONSOLE or parent == WORLD then
                call BlzFrameSetAbsPoint(frame, _point, _x, _y)
            else
                call BlzFrameSetPoint(frame, _point, parent, _relative, _x, _y)
            endif
        endmethod

        method operator y takes nothing returns real
            return _y
        endmethod

        method operator point= takes framepointtype newPoint returns nothing
            set _point = newPoint

            call BlzFrameClearAllPoints(frame)

            if parent == CONSOLE or parent == WORLD then
                call BlzFrameSetAbsPoint(frame, _point, _x, _y)
            else
                call BlzFrameSetPoint(frame, _point, parent, _relative, _x, _y)
            endif
        endmethod

        method operator point takes nothing returns framepointtype
            return _point
        endmethod

        method operator relative= takes framepointtype newPoint returns nothing
            set _relative = newPoint

            call BlzFrameClearAllPoints(frame)

            if parent == CONSOLE or parent == WORLD then
                call BlzFrameSetAbsPoint(frame, _point, _x, _y)
            else
                call BlzFrameSetPoint(frame, _point, parent, _relative, _x, _y)
            endif
        endmethod

        method operator relative takes nothing returns framepointtype
            return _relative
        endmethod

        method operator alpha= takes integer newAlpha returns nothing
            set _alpha = newAlpha

            call BlzFrameSetAlpha(frame, newAlpha)
        endmethod

        method operator alpha takes nothing returns integer
            return _alpha
        endmethod

        method operator scale= takes real newScale returns nothing
            set _scale = newScale
            call BlzFrameSetScale(frame, newScale)
        endmethod

        method operator scale takes nothing returns real
            return _scale
        endmethod

        method operator width= takes real newWidth returns nothing
            set _width = newWidth

            call BlzFrameSetSize(frame, newWidth, _height)
        endmethod

        method operator width takes nothing returns real
            return _width
        endmethod

        method operator height= takes real newHeight returns nothing
            set _height = newHeight

            call BlzFrameSetSize(frame, _width, newHeight)
        endmethod

        method operator height takes nothing returns real
            return _height
        endmethod

        method operator enabled= takes boolean flag returns nothing
            set _enabled = flag

            call BlzFrameSetEnable(frame, flag)
        endmethod

        method operator enabled takes nothing returns boolean
            return _enabled
        endmethod

        stub method operator visible= takes boolean visibility returns nothing
            set _visible = visibility
            call BlzFrameSetVisible(frame, visibility)
        endmethod

        stub method operator visible takes nothing returns boolean
            return _visible
        endmethod

        method operator frame= takes framehandle newFrame returns nothing
            set _frame = newFrame
        endmethod

        method operator frame takes nothing returns framehandle
            return _frame
        endmethod

        method operator set= takes framehandle target returns nothing
            call BlzFrameSetAllPoints(frame, target)
        endmethod

        method setPoint takes framepointtype point, framepointtype relative, real x, real y returns nothing
            set _x = x
            set _y = y
            set _point = point
            set _relative = relative

            call BlzFrameClearAllPoints(frame)

            if parent == CONSOLE or parent == WORLD then
                call BlzFrameSetAbsPoint(frame, point, x, y)
            else
                call BlzFrameSetPoint(frame, point, parent, relative, x, y)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set CONSOLE = BlzGetFrameByName("ConsoleUIBackdrop", 0)
            set WORLD = BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0)

            call BlzLoadTOCFile("Components.toc")
            call TimerStart(DOUBLE, 9999999999, false, null)
        endmethod
    endmodule

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
                call BlzFrameSetSize(tooltip, newWidth, 0)
            endif
        endmethod

        method operator width takes nothing returns real
            return widthSize
        endmethod

        method operator point= takes framepointtype newPoint returns nothing
            set pointType = newPoint

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

        method setPoint takes framepointtype point, framepointtype relative, real x, real y returns nothing
            call BlzFrameClearAllPoints(tooltip)
            call BlzFrameSetPoint(tooltip, point, parent, relative, x, y)
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

    struct Backdrop
        private string path

        implement Operators

        method operator texture= takes string path returns nothing
            set .path = path

            if path != "" and path != null then
                call BlzFrameSetTexture(frame, path, 0, true)
                call BlzFrameSetVisible(frame, true)
            else
                call BlzFrameSetVisible(frame, false)
            endif
        endmethod

        method operator texture takes nothing returns string
            return path
        endmethod

        method destroy takes nothing returns nothing
            call BlzDestroyFrame(frame)

            set frame = null
            set parent = null
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent, string texture returns thistype
            local thistype this = thistype.allocate()

            if parent == null then
                set parent = CONSOLE
            endif

            set .x = x
            set .y = y
            set .width = width
            set .height = height
            set .parent = parent
            set .texture = texture
            set frame = BlzCreateFrameByType("BACKDROP", "", parent, "", 0)

            if parent == CONSOLE or parent == WORLD then
                call BlzFrameSetAbsPoint(frame, point, x, y)
            else
                call BlzFrameSetPoint(frame, point, parent, relative, x, y)
            endif

            call BlzFrameSetSize(frame, width, height)
            call BlzFrameSetTexture(frame, texture, 0, true)

            return this
        endmethod
    endstruct

    struct Sprite
        private string path
        private integer index
        private integer animtype

        implement Operators

        method operator model= takes string path returns nothing
            set .path = path

            call BlzFrameSetModel(frame, path, index)
        endmethod

        method operator model takes nothing returns string
            return path
        endmethod

        method operator camera= takes integer index returns nothing
            set .index = index

            call BlzFrameSetModel(frame, path, index)
        endmethod

        method operator camera takes nothing returns integer
            return index
        endmethod

        method operator animation= takes integer i returns nothing
            set .animtype = i

            call BlzFrameSetSpriteAnimate(frame, i, 0)
        endmethod

        method operator animation takes nothing returns integer
            return animtype
        endmethod

        method destroy takes nothing returns nothing
            call BlzDestroyFrame(frame)

            set frame = null
            set parent = null
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent, framepointtype point, framepointtype relative returns thistype
            local thistype this = thistype.allocate()
            
            if parent == null then
                set parent = CONSOLE
            endif
            
            set .x = x
            set .y = y
            set .point = point
            set .relative = relative
            set .width = width
            set .height = height
            set .parent = parent
            set frame = BlzCreateFrameByType("SPRITE", "", parent, "", 0)

            if parent == CONSOLE or parent == WORLD then
                call BlzFrameSetAbsPoint(frame, point, x, y)
            else
                call BlzFrameSetPoint(frame, point, parent, relative, x, y)
            endif

            call BlzFrameSetSize(frame, width, height)

            return this
        endmethod
    endstruct

    struct Text
        private string value
        private textaligntype vert
        private textaligntype horz

        implement Operators

        method operator text= takes string value returns nothing
            set .value = value

            call BlzFrameSetText(frame, value)
        endmethod

        method operator text takes nothing returns string
            return value
        endmethod

        method operator vertical= takes textaligntype alignment returns nothing
            set vert = alignment
            call BlzFrameSetTextAlignment(frame, alignment, horz)
        endmethod

        method operator vertical takes nothing returns textaligntype
            return vert
        endmethod

        method operator horizontal= takes textaligntype alignment returns nothing
            set horz = alignment
            call BlzFrameSetTextAlignment(frame, vert, alignment)
        endmethod

        method operator horizontal takes nothing returns textaligntype
            return horz
        endmethod

        method destroy takes nothing returns nothing
            call BlzDestroyFrame(frame)

            set frame = null
            set parent = null
        endmethod

        static method create takes real x, real y, real width, real height, real scale, boolean enabled, framehandle parent, string value, textaligntype vert, textaligntype horz returns thistype
            local thistype this = thistype.allocate()

            if parent == null then
                set parent = CONSOLE
            endif

            if vert == null then
                set vert = TEXT_JUSTIFY_CENTER
            endif

            if horz == null then
                set horz = TEXT_JUSTIFY_CENTER
            endif

            set .x = x
            set .y = y
            set .text = value
            set .scale = scale
            set .width = width
            set .height = height
            set .enabled = enabled
            set .parent = parent
            set .vertical = vert
            set .horizontal = horz
            set frame = BlzCreateFrameByType("TEXT", "", parent, "", 0)

            if parent == CONSOLE or parent == WORLD then
                call BlzFrameSetAbsPoint(frame, point, x, y)
            else
                call BlzFrameSetPoint(frame, point, parent, relative, x, y)
            endif

            call BlzFrameSetSize(frame, width, height)
            call BlzFrameSetText(frame, value)
            call BlzFrameSetEnable(frame, enabled)
            call BlzFrameSetScale(frame, scale)
            call BlzFrameSetTextAlignment(frame, vert, horz)

            return this
        endmethod
    endstruct

    struct TextArea
        private string value

        implement Operators

        method operator text= takes string value returns nothing
            set .value = value

            call BlzFrameSetText(frame, value)
        endmethod

        method operator text takes nothing returns string
            return value
        endmethod

        method destroy takes nothing returns nothing
            call BlzDestroyFrame(frame)

            set frame = null
            set parent = null
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent, string template returns thistype
            local thistype this = thistype.allocate()

            if parent == null then
                set parent = CONSOLE
            endif

            if template == "" or template == null then
                set template = "DescriptionArea"
            endif

            set .x = x
            set .y = y
            set .width = width
            set .height = height
            set .parent = parent
            set frame = BlzCreateFrame(template, parent, 0, 0)

            if parent == CONSOLE or parent == WORLD then
                call BlzFrameSetAbsPoint(frame, point, x, y)
            else
                call BlzFrameSetPoint(frame, point, parent, relative, x, y)
            endif

            call BlzFrameSetSize(frame, width, height)

            return this
        endmethod
    endstruct

    struct StatusBar
        private string path

        implement Operators

        method operator value= takes real val returns nothing
            call BlzFrameSetValue(frame, val)
        endmethod

        method operator value takes nothing returns real
            return BlzFrameGetValue(frame)
        endmethod

        method operator texture= takes string path returns nothing
            set .path = path

            if path != "" and path != null then
                call BlzFrameSetTexture(frame, path, 0, true)
                call BlzFrameSetVisible(frame, true)
            else
                call BlzFrameSetVisible(frame, false)
            endif
        endmethod

        method operator texture takes nothing returns string
            return path
        endmethod

        method destroy takes nothing returns nothing
            call BlzDestroyFrame(frame)

            set frame = null
            set parent = null
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent, string texture returns thistype
            local thistype this = thistype.allocate()

            if parent == null then
                set parent = CONSOLE
            endif

            set .x = x
            set .y = y
            set .width = width
            set .height = height
            set .parent = parent
            set .texture = texture
            set frame = BlzCreateFrameByType("SIMPLESTATUSBAR", "", parent, "", 0)

            if parent == CONSOLE or parent == WORLD then
                call BlzFrameSetAbsPoint(frame, point, x, y)
            else
                call BlzFrameSetPoint(frame, point, parent, relative, x, y)
            endif

            call BlzFrameSetValue(frame, 0)
            call BlzFrameSetSize(frame, width, height)
            call BlzFrameSetTexture(frame, texture, 0, true)

            return this
        endmethod
    endstruct

    struct Component extends IComponent
        private static trigger click = CreateTrigger()
        private static trigger enter = CreateTrigger()
        private static trigger leave = CreateTrigger()
        private static trigger scroll = CreateTrigger()
        private static Table table
        private static HashTable time
        private static HashTable doubleTime
        private static thistype array array

        private Backdrop image
        private boolean isActive = true
        private trigger exited
        private trigger entered
        private trigger clicked
        private trigger scrolled
        private trigger rightClicked
        private trigger doubleClicked
        private trigger middleClicked
        private framehandle button
        private framehandle listener

        implement Operators

        method operator texture= takes string path returns nothing
            set image.texture = path
        endmethod

        method operator texture takes nothing returns string
            return image.texture
        endmethod

        method operator active= takes boolean flag returns nothing
            set isActive = flag

            if not flag then
                if SubString(image.texture, 34, 35) == "\\" then
                    set image.texture = SubString(image.texture, 0, 34) + "Disabled\\DIS" + SubString(image.texture, 35, StringLength(image.texture))
                endif
            else
                if SubString(image.texture, 34, 46) == "Disabled\\DIS" then
                    set image.texture = SubString(image.texture, 0, 34) + "\\" + SubString(image.texture, 46, StringLength(image.texture))
                endif
            endif
        endmethod

        method operator active takes nothing returns boolean
            return isActive
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
            call image.destroy()
            call table.remove(GetHandleId(listener))
            call table.remove(GetHandleId(button))
            call BlzDestroyFrame(frame)
            call BlzDestroyFrame(listener)
            call DestroyTrigger(exited)
            call DestroyTrigger(entered)
            call DestroyTrigger(clicked)
            call DestroyTrigger(scrolled)
            call DestroyTrigger(rightClicked)
            call DestroyTrigger(doubleClicked)
            call DestroyTrigger(middleClicked)

            set frame = null
            set button = null
            set parent = null
            set listener = null
            set exited = null
            set entered = null
            set clicked = null
            set scrolled = null
            set rightClicked = null
            set doubleClicked = null
            set middleClicked = null
        endmethod

        static method get takes nothing returns thistype
            return array[GetPlayerId(GetTriggerPlayer())]
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent, string frameType, string template returns thistype
            local thistype this = thistype.allocate()

            if parent == null then
                set parent = CONSOLE
            endif

            if template == "" or template == null then
                set template = "TransparentBackdrop"
            endif

            set .x = x
            set .y = y
            set .width = width
            set .height = height
            set .parent = parent
            set frame = BlzCreateFrame(template, parent, 0, 0)
            set listener = BlzCreateFrame(frameType, frame, 0, 0)
            set button = BlzFrameGetChild(listener, 0)
            set image = Backdrop.create(0, 0, width, height, listener, null)
            set image.visible = false
            set table[GetHandleId(listener)] = this
            set table[GetHandleId(button)] = this

            if parent == CONSOLE or parent == WORLD then
                call BlzFrameSetAbsPoint(frame, point, x, y)
            else
                call BlzFrameSetPoint(frame, point, parent, relative, x, y)
            endif

            call BlzFrameSetSize(frame, width, height)
            call BlzFrameSetAllPoints(listener, frame)
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
            
            call TriggerAddAction(enter, function thistype.onEntered)
            call TriggerAddAction(leave, function thistype.onExited)
            call TriggerAddAction(click, function thistype.onClicked)
            call TriggerAddAction(scroll, function thistype.onScrolled)

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                        set array[i] = 0
                        call TriggerRegisterPlayerEvent(click, Player(i), EVENT_PLAYER_MOUSE_UP)
                    endif
                set i = i + 1
            endloop
        endmethod
    endstruct

    struct EditBox extends IComponent
        private static trigger typing = CreateTrigger()
        private static trigger enter = CreateTrigger()
        private static Table table

        private string value
        private integer length
        private trigger typed
        private trigger entered

        implement Operators

        method operator limit= takes integer length returns nothing
            set .length = length

            call BlzFrameSetTextSizeLimit(frame, length)
        endmethod

        method operator limit takes nothing returns integer
            return length
        endmethod

        method operator text= takes string newText returns nothing
            set value = newText
            call BlzFrameSetText(frame, newText)
        endmethod

        method operator text takes nothing returns string
            set value = BlzFrameGetText(frame)
            return value
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
            call BlzDestroyFrame(frame)
            call DestroyTrigger(typed)
            call DestroyTrigger(entered)

            set frame = null
            set typed = null
            set parent = null
            set entered = null
        endmethod

        static method get takes nothing returns thistype
            return table[GetHandleId(BlzGetTriggerFrame())]
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent, string template returns thistype
            local thistype this = thistype.allocate()

            if parent == null then
                set parent = CONSOLE
            endif

            if template == "" or template == null then
                set template = "EscMenuEditBoxTemplate"
            endif

            set .x = x
            set .y = y
            set .width = width
            set .height = height
            set .parent = parent
            set frame = BlzCreateFrame(template, parent, 0, 0)
            set table[GetHandleId(frame)] = this

            if parent == CONSOLE or parent == WORLD then
                call BlzFrameSetAbsPoint(frame, point, x, y)
            else
                call BlzFrameSetPoint(frame, point, parent, relative, x, y)
            endif

            call BlzFrameSetSize(frame, width, height)
            call BlzTriggerRegisterFrameEvent(enter, frame, FRAMEEVENT_EDITBOX_ENTER)
            call BlzTriggerRegisterFrameEvent(typing, frame, FRAMEEVENT_EDITBOX_TEXT_CHANGED)

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

            call TriggerAddAction(enter, function thistype.onEntered)
            call TriggerAddAction(typing, function thistype.onTyping)
        endmethod
    endstruct

    struct CheckBox extends IComponent
        private static trigger event = CreateTrigger()
        private static Table table

        private trigger check
        private trigger uncheck
        private boolean array isChecked[28]

        implement Operators

        method operator checked takes nothing returns boolean
            return isChecked[GetPlayerId(GetLocalPlayer())]
        endmethod

        method operator onCheck= takes code c returns nothing
            call DestroyTrigger(check)
            set check = null

            if c != null then
                set check = CreateTrigger()
                call TriggerAddCondition(check, Condition(c))
            endif
        endmethod

        method operator onUncheck= takes code c returns nothing
            call DestroyTrigger(uncheck)
            set uncheck = null

            if c != null then
                set uncheck = CreateTrigger()
                call TriggerAddCondition(uncheck, Condition(c))
            endif
        endmethod

        method destroy takes nothing returns nothing
            call BlzDestroyFrame(frame)
            call DestroyTrigger(check)
            call DestroyTrigger(uncheck)

            set frame = null
            set parent = null
            set check = null
            set uncheck = null
        endmethod

        static method get takes nothing returns thistype
            return table[GetHandleId(BlzGetTriggerFrame())]
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent, string template returns thistype
            local thistype this = thistype.allocate()

            if parent == null then
                set parent = CONSOLE
            endif

            if template == "" or template == null then
                set template = "QuestCheckBox"
            endif

            set .x = x
            set .y = y
            set .width = width
            set .height = height
            set .parent = parent
            set frame = BlzCreateFrame(template, parent, 0, 0)
            set table[GetHandleId(frame)] = this

            if parent == CONSOLE or parent == WORLD then
                call BlzFrameSetAbsPoint(frame, point, x, y)
            else
                call BlzFrameSetPoint(frame, point, parent, relative, x, y)
            endif

            call BlzFrameSetSize(frame, width, height)
            call BlzTriggerRegisterFrameEvent(event, frame, FRAMEEVENT_CHECKBOX_CHECKED)
            call BlzTriggerRegisterFrameEvent(event, frame, FRAMEEVENT_CHECKBOX_UNCHECKED)

            return this
        endmethod

        private static method onChecked takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())]

            if this != 0 then
                set isChecked[GetPlayerId(GetTriggerPlayer())] = BlzGetTriggerFrameEvent() == FRAMEEVENT_CHECKBOX_CHECKED

                if BlzGetTriggerFrameEvent() == FRAMEEVENT_CHECKBOX_CHECKED then
                    if onCheck.exists then
                        call onCheck()
                    endif

                    if check != null then
                        call TriggerEvaluate(check)
                    endif
                else
                    if onUncheck.exists then
                        call onUncheck()
                    endif

                    if uncheck != null then
                        call TriggerEvaluate(uncheck)
                    endif
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set table = Table.create()

            call TriggerAddAction(event, function thistype.onChecked)
        endmethod
    endstruct

    struct Slider extends IComponent
        private static trigger event = CreateTrigger()
        private static Table table

        private real minimum = 0
        private real maximum = 100
        private real stepping = 1
        private trigger slided

        implement Operators

        method operator min= takes real value returns nothing
            set minimum = value

            call BlzFrameSetMinMaxValue(frame, minimum, maximum)
        endmethod

        method operator min takes nothing returns real
            return minimum
        endmethod

        method operator max= takes real value returns nothing
            set maximum = value

            call BlzFrameSetMinMaxValue(frame, minimum, maximum)
        endmethod

        method operator max takes nothing returns real
            return maximum
        endmethod

        method operator step= takes real value returns nothing
            set stepping = value

            call BlzFrameSetStepSize(frame, stepping)
        endmethod

        method operator step takes nothing returns real
            return stepping
        endmethod

        method operator value= takes real val returns nothing
            call BlzFrameSetValue(frame, val)
        endmethod

        method operator value takes nothing returns real
            return BlzFrameGetValue(frame)
        endmethod

        method operator onSlide= takes code c returns nothing
            call DestroyTrigger(slided)
            set slided = null

            if c != null then
                set slided = CreateTrigger()
                call TriggerAddCondition(slided, Condition(c))
            endif
        endmethod

        method destroy takes nothing returns nothing
            call BlzDestroyFrame(frame)
            call DestroyTrigger(slided)

            set frame = null
            set parent = null
            set slided = null
        endmethod

        static method get takes nothing returns thistype
            return table[GetHandleId(BlzGetTriggerFrame())]
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent, string template returns thistype
            local thistype this = thistype.allocate()

            if parent == null then
                set parent = CONSOLE
            endif

            if template == "" or template == null then
                set template = "EscMenuSliderTemplate"
            endif

            set .x = x
            set .y = y
            set .width = width
            set .height = height
            set .parent = parent
            set frame = BlzCreateFrame(template, parent, 0, 0)
            set table[GetHandleId(frame)] = this

            if parent == CONSOLE or parent == WORLD then
                call BlzFrameSetAbsPoint(frame, point, x, y)
            else
                call BlzFrameSetPoint(frame, point, parent, relative, x, y)
            endif

            call BlzFrameSetSize(frame, width, height)
            call BlzFrameSetStepSize(frame, stepping)
            call BlzFrameSetMinMaxValue(frame, minimum, maximum)
            call BlzTriggerRegisterFrameEvent(event, frame, FRAMEEVENT_SLIDER_VALUE_CHANGED)

            return this
        endmethod

        private static method onSlided takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())]

            if this != 0 then
                if onSlide.exists then
                    call onSlide()
                endif

                if slided != null then
                    call TriggerEvaluate(slided)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set table = Table.create()

            call TriggerAddAction(event, function thistype.onSlided)
        endmethod
    endstruct

    struct Button extends Component
        private Sprite tagger
        private Sprite sprite
        private Sprite player
        private Backdrop check
        private Backdrop block
        private boolean isHighlighted
        private framehandle highlight
        private framehandle chargesFrame

        Tooltip tooltip

        method operator available= takes boolean flag returns nothing
            set block.visible = not flag
        endmethod

        method operator available takes nothing returns boolean
            return not block.visible
        endmethod

        method operator checked= takes boolean flag returns nothing
            set check.visible = flag
        endmethod

        method operator checked takes nothing returns boolean
            return check.visible
        endmethod

        method operator highlighted= takes boolean flag returns nothing
            set isHighlighted = flag

            call BlzFrameSetVisible(highlight, flag)
        endmethod

        method operator highlighted takes nothing returns boolean
            return isHighlighted
        endmethod

        method destroy takes nothing returns nothing
            call check.destroy()
            call block.destroy()
            call tagger.destroy()
            call sprite.destroy()
            call player.destroy()
            call tooltip.destroy()
            call BlzDestroyFrame(highlight)

            call super.destroy()

            set highlight = null
        endmethod

        method play takes string model, real scale, integer animation returns nothing
            if model != "" and model != null then
                set sprite.scale = scale
                set sprite.model = model
                set sprite.animation = animation
            endif
        endmethod

        method display takes string model, real scale, real offsetX, real offsetY returns nothing
            set player.visible = model != "" and model != null

            if player.visible then
                set player.x = offsetX
                set player.y = offsetY
                set player.scale = scale
                set player.model = model
            endif
        endmethod

        method tag takes string model, real scale, real offsetX, real offsetY returns nothing
            set tagger.visible = model != "" and model != null
            
            if tagger.visible then
                set tagger.x = offsetX
                set tagger.y = offsetY
                set tagger.scale = scale
                set tagger.model = model
            endif
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent, boolean simpleTooltip returns thistype
            local thistype this = thistype.allocate(x, y, width, height, parent, "ComponentFrame", null)

            set check = Backdrop.create(0, 0, width, height, frame, CHECKED_BUTTON)
            set block = Backdrop.create(0, 0, width, height, frame, UNAVAILABLE_BUTTON)
            set sprite = Sprite.create(0, 0, width, height, frame, FRAMEPOINT_CENTER, FRAMEPOINT_CENTER)
            set tagger = Sprite.create(0, 0, 0.00001, 0.00001, frame, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT)
            set player = Sprite.create(0, 0, 0.00001, 0.00001, frame, FRAMEPOINT_BOTTOMLEFT, FRAMEPOINT_BOTTOMLEFT)
            set tooltip = Tooltip.create(frame, TOOLTIP_SIZE, FRAMEPOINT_TOPLEFT, simpleTooltip)
            set highlight = BlzCreateFrame("HighlightFrame", frame, 0, 0)
            set checked = false
            set available = true
            set highlighted = false

            call BlzFrameSetTooltip(actor, tooltip.frame)
            call BlzFrameSetPoint(highlight, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, - 0.004, 0.0045)
            call BlzFrameSetSize(highlight, width + 0.0085, height + 0.0085)
            call BlzFrameSetTexture(highlight, HIGHLIGHT, 0, true)

            return this
        endmethod
    endstruct

    struct Panel extends Component
        method destroy takes nothing returns nothing
            call super.destroy()
        endmethod

        static method create takes real x, real y, real width, real height, framehandle parent, string template returns thistype
            return thistype.allocate(x, y, width, height, parent, "PanelFrame", template)
        endmethod
    endstruct

    struct Line extends Backdrop
        method destroy takes nothing returns nothing
            call super.destroy()
        endmethod
            
        static method create takes real x, real y, real width, real height, framehandle parent, string texture returns thistype
            return thistype.allocate(x, y, width, height, parent, texture)
        endmethod
    endstruct
endlibrary