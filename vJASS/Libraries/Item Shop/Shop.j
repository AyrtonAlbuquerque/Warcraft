library Shop requires RegisterPlayerUnitEvent, TimerUtils
    /* --------------------------------------- Shop v1.0 --------------------------------------- */
    // Credits:
    //      Taysen: TasItemShop and FDF file
    //      Nestharus and Bribe: A2S funciton
    /* -------------------------------------- By Chopinski ------------------------------------- */

    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    globals
        // Main window 
        private constant real X                         = 0.0
        private constant real Y                         = 0.56
        private constant real WIDTH                     = 0.8
        private constant real HEIGHT                    = 0.4
        private constant integer ROWS                   = 5
        private constant integer COLUMNS                = 13
        private constant integer DETAILED_ROWS          = 5
        private constant integer DETAILED_COLUMNS       = 8

        // Details window
        private constant real DETAIL_WIDTH              = 0.3125
        private constant real DETAIL_HEIGHT             = 0.4

        // Side Panels
        private constant real SIDE_WIDTH                = 0.075
        private constant real SIDE_HEIGHT               = 0.4

        // Category and Favorite buttons
        private constant integer CATEGORY_COUNT         = 13
        private constant real CATEGORY_SIZE             = 0.02750
        private constant real CATEGORY_GAP              = 0.0

        // Favorite key 
        // LSHIT, LCONTROL are buggy on KeyDown event, 
        // complain to blizzard, not me
        private constant oskeytype FAVORITE_KEY         = OSKEY_TAB

        // Item slots
        private constant real SLOT_WIDTH                = 0.04
        private constant real SLOT_HEIGHT               = 0.05
        private constant real ITEM_SIZE                 = 0.04
        private constant real GOLD_SIZE                 = 0.01
        private constant real COST_WIDTH                = 0.045
        private constant real COST_HEIGHT               = 0.01
        private constant real COST_SCALE                = 0.8
        private constant real TOOLTIP_SIZE              = 0.2
        private constant real SLOT_GAP_X                = 0.018
        private constant real SLOT_GAP_Y                = 0.022
        private constant string GOLD_ICON               = "UI\\Feedback\\Resources\\ResourceGold.blp"

        // Scroll
        private constant real SCROLL_DELAY              = 0.01

        // Dont touch
        private hashtable table = InitHashtable()
    endglobals 

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function CreateShop takes integer id returns nothing
        call Shop.create(id)
    endfunction
    
    function ShopAddCategory takes integer id, string icon, string description returns integer
        return Shop.addCategory(id, icon, description)
    endfunction

    function ShopAddItem takes integer id, integer itemId, integer categories returns nothing
        call Shop.addItem(id, itemId, categories)
    endfunction

    function ItemAddComponents takes integer whichItem, integer a, integer b, integer c, integer d, integer e returns nothing
        call Item.addComponents(whichItem, a, b, c, d, e)
    endfunction

    function A2S takes integer id returns string
        local string array c
        local string s = ""

        set c[8]="\b"
        set c[9]="\t"
        set c[10]="\n"
        set c[12]="\f"
        set c[13]="\r"
        set c[32]=" "
        set c[33]="!"
        set c[34]="\""
        set c[35]="#"
        set c[36]="$"
        set c[37]="%"
        set c[38]="&"
        set c[39]="'"
        set c[40]="("
        set c[41]=")"
        set c[42]="*"
        set c[43]="+"
        set c[44]=","
        set c[45]="-"
        set c[46]="."
        set c[47]="/"
        set c[48]="0"
        set c[49]="1"
        set c[50]="2"
        set c[51]="3"
        set c[52]="4"
        set c[53]="5"
        set c[54]="6"
        set c[55]="7"
        set c[56]="8"
        set c[57]="9"
        set c[58]=":"
        set c[59]=";"
        set c[60]="<"
        set c[61]="="
        set c[62]=">"
        set c[63]="?"
        set c[64]="@"
        set c[65]="A"
        set c[66]="B"
        set c[67]="C"
        set c[68]="D"
        set c[69]="E"
        set c[70]="F"
        set c[71]="G"
        set c[72]="H"
        set c[73]="I"
        set c[74]="J"
        set c[75]="K"
        set c[76]="L"
        set c[77]="M"
        set c[78]="N"
        set c[79]="O"
        set c[80]="P"
        set c[81]="Q"
        set c[82]="R"
        set c[83]="S"
        set c[84]="T"
        set c[85]="U"
        set c[86]="V"
        set c[87]="W"
        set c[88]="X"
        set c[89]="Y"
        set c[90]="Z"
        set c[92]="\\"
        set c[97]="a"
        set c[98]="b"
        set c[99]="c"
        set c[100]="d"
        set c[101]="e"
        set c[102]="f"
        set c[103]="g"
        set c[104]="h"
        set c[105]="i"
        set c[106]="j"
        set c[107]="k"
        set c[108]="l"
        set c[109]="m"
        set c[110]="n"
        set c[111]="o"
        set c[112]="p"
        set c[113]="q"
        set c[114]="r"
        set c[115]="s"
        set c[116]="t"
        set c[117]="u"
        set c[118]="v"
        set c[119]="w"
        set c[120]="x"
        set c[121]="y"
        set c[122]="z"
        set c[91]="["
        set c[93]="]"
        set c[94]="^"
        set c[95]="_"
        set c[96]="`"
        set c[123]="{"
        set c[124]="|"
        set c[125]="}"
        set c[126]="~"

        if (7 < id) then
            loop
                set s = c[id-id/256*256]+s
                set id = id/256
                exitwhen 0 == id
            endloop

            return s
        endif

        return null
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    struct Item
        private static unit shop
        private static rect rect
        private static player player = Player(bj_PLAYER_NEUTRAL_EXTRA)
        readonly static hashtable itempool = InitHashtable()
        readonly static hashtable relation = InitHashtable()

        string name
        string icon
        string tooltip
        integer id
        integer gold
        integer categories
        
        method destroy takes nothing returns nothing
            call deallocate()
        endmethod

        method operator components takes nothing returns integer
            return LoadInteger(itempool, id, 6)
        endmethod

        static method get takes integer id returns thistype
            return LoadInteger(itempool, id, 0)
        endmethod

        static method save takes integer id, integer component returns nothing
            local thistype this
            local integer i = 0

            if component > 0 and component != id then
                if not LoadBoolean(relation, component, id) then
                    loop
                        exitwhen not HaveSavedInteger(relation, component, i)
                        set i = i + 1
                    endloop
    
                    call SaveBoolean(relation, component, id, true)
                    call SaveInteger(relation, component, i, id)
                endif

                call SaveInteger(itempool, id, 6, LoadInteger(itempool, id, 6) + 1)
            endif
        endmethod

        static method addComponents takes integer id, integer a, integer b, integer c, integer d, integer e returns nothing
            local thistype this

            if id > 0 then
                call SaveInteger(itempool, id, 1, a)
                call SaveInteger(itempool, id, 2, b)
                call SaveInteger(itempool, id, 3, c)
                call SaveInteger(itempool, id, 4, d)
                call SaveInteger(itempool, id, 5, e)
                call SaveInteger(itempool, id, 6, 0)
                call save(id, a)
                call save(id, b)
                call save(id, c)
                call save(id, d)
                call save(id, e)
                call create(id, 0)
            endif
        endmethod

        static method clear takes nothing returns nothing
            call RemoveItem(GetEnumItem())
        endmethod

        static method cost takes integer id returns integer
            local integer old

            call AddItemToStock(shop, id, 1, 1)
            call SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, 9999999)
            set old = GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD)
            call IssueNeutralImmediateOrderById(player, shop, id)
            call RemoveItemFromStock(shop, id)
            call EnumItemsInRect(rect, null, function thistype.clear)

            return old - GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD)
        endmethod

        static method create takes integer id, integer category returns thistype
            local thistype this
            local item i

            if HaveSavedInteger(itempool, id, 0) then
                set this = LoadInteger(itempool, id, 0)

                if category > 0 then
                    set categories = category
                endif

                return this
            else
                set i = CreateItem(id, 0, 0)

                if i != null then
                    set this = thistype.allocate()
                    set .id = id
                    set categories = category
                    set name = GetItemName(i)
                    set icon = BlzGetItemIconPath(i)
                    set tooltip = BlzGetItemExtendedTooltip(i)
                    set gold = cost(id)

                    call RemoveItem(i)
                    call SaveInteger(itempool, id, 0, this)

                    set i = null
                    return this
                else
                    return 0
                endif
            endif
        endmethod

        static method onInit takes nothing returns nothing
            set rect = Rect(0, 0, 0, 0)
            set shop = CreateUnit(player, 'nmrk', 0, 0, 0)

            call SetRect(rect, GetUnitX(shop) - 1000, GetUnitY(shop) - 1000, GetUnitX(shop) + 1000, GetUnitY(shop) + 1000)
            call UnitAddAbility(shop, 'AInv')
            call IssueNeutralTargetOrder(player, shop, "smart", shop)
            call ShowUnit(shop, false)
        endmethod
    endstruct
    
    private struct Slot
        private boolean isVisible = true
        private real xPos
        private real yPos

        Item item
        framehandle parent
        framehandle slot
        framehandle icon
        framehandle gold
        framehandle cost
        framehandle button
        framehandle tooltip
        framehandle tooltipFrame
        framehandle tooltipName
        framehandle tooltipIcon

        method operator x= takes real newX returns nothing
            set xPos = newX

            call BlzFrameClearAllPoints(slot)
            call BlzFrameSetPoint(slot, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, xPos, yPos)
        endmethod

        method operator x takes nothing returns real
            return xPos
        endmethod

        method operator y= takes real newY returns nothing
            set yPos = newY

            call BlzFrameClearAllPoints(slot)
            call BlzFrameSetPoint(slot, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, xPos, yPos)
        endmethod

        method operator y takes nothing returns real
            return yPos
        endmethod

        method operator visible= takes boolean visibility returns nothing
            set isVisible = visibility
            call BlzFrameSetVisible(slot, visibility)
        endmethod

        method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method destroy takes nothing returns nothing
            call BlzDestroyFrame(tooltip)
            call BlzDestroyFrame(tooltipFrame)
            call BlzDestroyFrame(tooltipName)
            call BlzDestroyFrame(tooltipIcon)
            call BlzDestroyFrame(cost)
            call BlzDestroyFrame(gold)
            call BlzDestroyFrame(button)
            call BlzDestroyFrame(icon)
            call BlzDestroyFrame(slot)
            call deallocate()

            set slot = null
            set icon = null
            set gold = null
            set cost = null
            set button = null
            set tooltip = null
            set tooltipFrame = null
            set tooltipName = null
            set tooltipIcon = null
        endmethod

        method setTooltip takes framepointtype point, framehandle parent returns framehandle
            local framehandle frame = BlzCreateFrame("TooltipBoxFrame", parent, 0, 0)
            local framehandle box = BlzGetFrameByName("TooltipBox", 0)
            local framehandle tooltipSeparator = BlzGetFrameByName("TooltipSeperator", 0)

            set tooltip = BlzGetFrameByName("TooltipText", 0)
            set tooltipIcon = BlzGetFrameByName("TooltipIcon", 0)
            set tooltipName = BlzGetFrameByName("TooltipName", 0)

            if point == FRAMEPOINT_TOPLEFT then
                call BlzFrameSetPoint(tooltip, point, parent, FRAMEPOINT_TOPRIGHT, 0.005, -0.05)
            elseif point == FRAMEPOINT_TOPRIGHT then
                call BlzFrameSetPoint(tooltip, point, parent, FRAMEPOINT_TOPLEFT, -0.005, -0.05)
            elseif point == FRAMEPOINT_BOTTOMLEFT then
                call BlzFrameSetPoint(tooltip, point, parent, FRAMEPOINT_BOTTOMRIGHT, 0.005, 0.0)
            else
                call BlzFrameSetPoint(tooltip, point, parent, FRAMEPOINT_BOTTOMLEFT, -0.005, 0.0)
            endif

            call BlzFrameSetPoint(box, FRAMEPOINT_TOPLEFT, tooltipIcon, FRAMEPOINT_TOPLEFT, -0.005, 0.005)
            call BlzFrameSetPoint(box, FRAMEPOINT_BOTTOMRIGHT, tooltip, FRAMEPOINT_BOTTOMRIGHT, 0.005, -0.005)
            call BlzFrameSetSize(tooltip, TOOLTIP_SIZE, 0)

            if item != 0 then
                call BlzFrameSetText(tooltip, item.tooltip)
                call BlzFrameSetText(tooltipName, item.name)
                call BlzFrameSetTexture(tooltipIcon, item.icon, 0, false)
            endif

            return frame
        endmethod

        static method create takes framehandle parent, Item i, real x, real y, framepointtype point returns thistype
            local thistype this = thistype.allocate()

            set item = i
            set xPos = x
            set yPos = y
            set .parent = parent
            set slot = BlzCreateFrameByType("FRAME", "", parent, "", 0)
            set icon = BlzCreateFrameByType("BACKDROP", "", slot, "", 0)    
            set button = BlzCreateFrame("IconButtonTemplate", icon, 0, 0)
            set gold = BlzCreateFrameByType("BACKDROP", "", slot, "", 0)
            set cost = BlzCreateFrameByType("TEXT", "", gold, "", 0)
            set tooltipFrame = setTooltip(point, button)
            
            call BlzFrameSetPoint(slot, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, xPos, yPos)
            call BlzFrameSetSize(slot, SLOT_WIDTH, SLOT_HEIGHT)
            call BlzFrameSetPoint(icon, FRAMEPOINT_TOPLEFT, slot, FRAMEPOINT_TOPLEFT, 0.0000, 0.0000)
            call BlzFrameSetSize(icon, ITEM_SIZE, ITEM_SIZE)
            // call BlzFrameSetTexture(icon, item.icon, 0, true)
            call BlzFrameSetPoint(gold, FRAMEPOINT_TOPLEFT, slot, FRAMEPOINT_TOPLEFT, 0.0000, - 0.040000)
            call BlzFrameSetSize(gold, GOLD_SIZE, GOLD_SIZE)
            call BlzFrameSetTexture(gold, GOLD_ICON, 0, true)
            call BlzFrameSetPoint(cost, FRAMEPOINT_TOPLEFT, gold, FRAMEPOINT_TOPLEFT, 0.013250, - 0.0019300)
            call BlzFrameSetSize(cost, COST_WIDTH, COST_HEIGHT)
            // call BlzFrameSetText(cost, "|cffFFCC00" + I2S(item.gold) + "|r")
            call BlzFrameSetEnable(cost, false)
            call BlzFrameSetScale(cost, COST_SCALE)
            call BlzFrameSetTextAlignment(cost, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            call BlzFrameSetAllPoints(button, icon)
            call BlzFrameSetTooltip(button, tooltipFrame)

            if item != 0 then
                call BlzFrameSetTexture(icon, item.icon, 0, true)
                call BlzFrameSetText(cost, "|cffFFCC00" + I2S(item.gold) + "|r")
            endif

            return this
        endmethod
    endstruct

    private struct ShopSlot extends Slot
        readonly static trigger click = CreateTrigger()
        readonly static trigger scroll = CreateTrigger()

        Shop shop
        Slot next
        Slot prev
        Slot right
        Slot left
        integer row
        integer column

        method destroy takes nothing returns nothing
            call FlushChildHashtable(table, GetHandleId(button))
            call deallocate()
        endmethod

        method move takes integer row, integer column returns nothing
            set .row = row
            set .column = column
            set x = 0.030000 + ((SLOT_WIDTH + SLOT_GAP_X) * column)
            set y = - (0.030000 + ((SLOT_HEIGHT + SLOT_GAP_Y) * row))

            call update(button)
        endmethod

        method update takes framehandle frame returns nothing
            call BlzFrameClearAllPoints(tooltip)

            if column <= (shop.columns / 2) and row < 3 then
                call BlzFrameSetPoint(tooltip, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPRIGHT, 0.005, -0.05)
            elseif column >= ((shop.columns / 2) + 1) and row < 3 then
                call BlzFrameSetPoint(tooltip, FRAMEPOINT_TOPRIGHT, frame, FRAMEPOINT_TOPLEFT, -0.005, -0.05)
            elseif column <= (shop.columns / 2) and row >= 3 then
                call BlzFrameSetPoint(tooltip, FRAMEPOINT_BOTTOMLEFT, frame, FRAMEPOINT_BOTTOMRIGHT, 0.005, 0.0)
            else
                call BlzFrameSetPoint(tooltip, FRAMEPOINT_BOTTOMRIGHT, frame, FRAMEPOINT_BOTTOMLEFT, -0.005, 0.0)
            endif
        endmethod

        static method create takes Shop shop, Item i, integer row, integer column returns thistype
            local thistype this = thistype.allocate(shop.main, i, 0.030000 + ((SLOT_WIDTH + SLOT_GAP_X) * column), - (0.030000 + ((SLOT_HEIGHT + SLOT_GAP_Y) * row)), FRAMEPOINT_TOPLEFT)

            set .shop = shop
            set next = 0
            set prev = 0
            set right = 0
            set left = 0
            set .row = row
            set .column = column
            
            call SaveInteger(table, GetHandleId(button), 0, this)
            call BlzTriggerRegisterFrameEvent(click, button, FRAMEEVENT_CONTROL_CLICK)
            call BlzTriggerRegisterFrameEvent(scroll, button, FRAMEEVENT_MOUSE_WHEEL)
            call update(button)

            return this
        endmethod

        static method onScroll takes nothing returns nothing
            local thistype this = LoadInteger(table, GetHandleId(BlzGetTriggerFrame()), 0)

            if this != 0 then
                call shop.scroll(BlzGetTriggerFrameValue() < 0, GetTriggerPlayer())
            endif
        endmethod

        static method onClick takes nothing returns nothing
            local framehandle frame = BlzGetTriggerFrame()
            local thistype this = LoadInteger(table, GetHandleId(frame), 0)

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    if Shop.tag[GetPlayerId(GetTriggerPlayer())] then
                        call shop.favorites.add(item)
                    else
                        call shop.detail(item)
                    endif
                endif
            endif

            set frame = null
        endmethod

        static method onInit takes nothing returns nothing
            call TriggerAddAction(click, function thistype.onClick)
            call TriggerAddAction(scroll, function thistype.onScroll)
        endmethod
    endstruct

    private struct Detail
        Shop shop
        Item item
        Slot main
        Slot center
        Slot left1
        Slot left2
        Slot right1
        Slot right2
        framehandle frame
        framehandle tooltip
        framehandle topSeparator
        framehandle bottomSeparator
        framehandle usedIn
        framehandle mainVerticalLine
        framehandle centerVerticalLine
        framehandle left1HorizontalLine
        framehandle left1VerticalLine
        framehandle left2HorizontalLine
        framehandle left2VerticalLine
        framehandle right1HorizontalLine
        framehandle right1VerticalLine
        framehandle right2HorizontalLine
        framehandle right2VerticalLine

        method destroy takes nothing returns nothing
            call main.destroy()
            call center.destroy()
            call left1.destroy()
            call left2.destroy()
            call right1.destroy()
            call right2.destroy()
            call BlzDestroyFrame(topSeparator)
            call BlzDestroyFrame(bottomSeparator)
            call BlzDestroyFrame(usedIn)
            call BlzDestroyFrame(mainVerticalLine)
            call BlzDestroyFrame(centerVerticalLine)
            call BlzDestroyFrame(left1HorizontalLine)
            call BlzDestroyFrame(left1VerticalLine)
            call BlzDestroyFrame(left2HorizontalLine)
            call BlzDestroyFrame(left2VerticalLine)
            call BlzDestroyFrame(right1HorizontalLine)
            call BlzDestroyFrame(right1VerticalLine)
            call BlzDestroyFrame(right2HorizontalLine)
            call BlzDestroyFrame(right2VerticalLine)
            call BlzDestroyFrame(tooltip)
            call BlzDestroyFrame(frame)
            call deallocate()

            set frame = null
            set tooltip = null
            set topSeparator = null
            set bottomSeparator = null
            set usedIn = null
            set mainVerticalLine = null
            set centerVerticalLine = null
            set left1HorizontalLine = null
            set left1VerticalLine = null
            set left2HorizontalLine = null
            set left2VerticalLine = null
            set right1HorizontalLine = null
            set right1VerticalLine = null
            set right2HorizontalLine = null
            set right2VerticalLine = null
        endmethod

        method update takes framehandle frame, framepointtype point, framehandle parent, framepointtype relative, real width, real height, real x, real y, boolean visible returns nothing
            if visible then
                call BlzFrameClearAllPoints(frame)
                call BlzFrameSetPoint(frame, point, parent, relative, x, y)
                call BlzFrameSetSize(frame, width, height)
            endif

            call BlzFrameSetVisible(frame, visible)
        endmethod

        method hide takes nothing returns nothing
            call BlzFrameSetVisible(frame, false)
        endmethod

        method show takes Item i returns nothing
            local Item component
            local Slot slot
            local integer j = 1
            local integer k = 1
            local integer cost

            if i != 0 then
                set item = i
                set cost = item.gold

                if item.components > 0 then
                    loop
                        exitwhen j > item.components or k > 5
                            set component = item.get(LoadInteger(item.itempool, item.id, j))

                            if component != 0 then
                                if item.components == 1 then
                                    set slot = center
                                    set left1.visible = false
                                    set left2.visible = false
                                    set right1.visible = false
                                    set right2.visible = false

                                    call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.13625, - 0.10200, true)
                                    call BlzFrameSetVisible(mainVerticalLine, true)
                                    call BlzFrameSetVisible(centerVerticalLine, true)
                                    call BlzFrameSetVisible(left1HorizontalLine, false)
                                    call BlzFrameSetVisible(left1VerticalLine, false)
                                    call BlzFrameSetVisible(left2HorizontalLine, false)
                                    call BlzFrameSetVisible(left2VerticalLine, false)
                                    call BlzFrameSetVisible(right1HorizontalLine, false)
                                    call BlzFrameSetVisible(right1VerticalLine, false)
                                    call BlzFrameSetVisible(right2HorizontalLine, false)
                                    call BlzFrameSetVisible(right2VerticalLine, false)
                                elseif item.components == 2 then
                                    if j == 1 then
                                        set slot = left1
                                        set center.visible = false
                                        set left2.visible = false
                                        set right2.visible = false

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.087250, - 0.10200, true)
                                        call update(left1HorizontalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.048, 0.001, 0.10700, - 0.091500, true)
                                        call update(left1VerticalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.10700, - 0.092500, true)
                                        call BlzFrameSetVisible(mainVerticalLine, true)
                                        call BlzFrameSetVisible(centerVerticalLine, false)
                                        call BlzFrameSetVisible(left2HorizontalLine, false)
                                        call BlzFrameSetVisible(left2VerticalLine, false)
                                    else
                                        set slot = right1

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.18525, - 0.10200, true)
                                        call update(right1HorizontalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.048, 0.001, 0.15700, - 0.091500, true)
                                        call update(right1VerticalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.20500, - 0.092500, true)
                                        call BlzFrameSetVisible(right2HorizontalLine, false)
                                        call BlzFrameSetVisible(right2VerticalLine, false)
                                    endif
                                elseif item.components == 3 then
                                    if j == 1 then
                                        set slot = left2
                                        set left1.visible = false
                                        set right1.visible = false

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.038250, - 0.10200, true)
                                        call update(left2HorizontalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.1, 0.001, 0.057000, - 0.091500, true)
                                        call update(left2VerticalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.057000, - 0.092500, true)
                                        call BlzFrameSetVisible(mainVerticalLine, true)
                                        call BlzFrameSetVisible(left1HorizontalLine, false)
                                        call BlzFrameSetVisible(left1VerticalLine, false)
                                    elseif j == 2 then
                                        set slot = center

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.13625, - 0.10200, true)
                                        call BlzFrameSetVisible(centerVerticalLine, true)
                                    else
                                        set slot = right2

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.23425, - 0.10200, true)
                                        call update(right2HorizontalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.1, 0.001, 0.15700, - 0.091500, true)
                                        call update(right2VerticalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.25600, - 0.092500, true)
                                        call BlzFrameSetVisible(right1HorizontalLine, false)
                                        call BlzFrameSetVisible(right1VerticalLine, false)
                                    endif
                                elseif item.components == 4 then
                                    if j == 1 then
                                        set slot = left2
                                        set right2.visible = false

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.038250, - 0.10200, true)
                                        call update(left2HorizontalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.1, 0.001, 0.057000, - 0.091500, true)
                                        call update(left2VerticalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.057000, - 0.092500, true)
                                        call BlzFrameSetVisible(mainVerticalLine, true)
                                    elseif j == 2 then
                                        set slot = left1

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.10350, - 0.10200, true)
                                        call update(left1VerticalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.12250, - 0.092500, true)
                                        call BlzFrameSetVisible(left1HorizontalLine, false)
                                    elseif j == 3 then
                                        set slot = center

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.16875, - 0.10200, true)
                                        call update(right1VerticalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.18950, - 0.092500, true)
                                        call BlzFrameSetVisible(centerVerticalLine, false)
                                    else
                                        set slot = right1

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.23400, - 0.10200, true)
                                        call update(right2HorizontalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.1, 0.001, 0.15700, - 0.091500, true)
                                        call update(right2VerticalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.25600, - 0.092500, true)
                                        call BlzFrameSetVisible(right1HorizontalLine, false)
                                    endif
                                else
                                    if j == 1 then
                                        set slot = left2

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.038250, - 0.10200, true)
                                        call update(left2HorizontalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.1, 0.001, 0.057000, - 0.091500, true)
                                        call update(left2VerticalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.057000, - 0.092500, true)
                                        call BlzFrameSetVisible(mainVerticalLine, true)
                                    elseif j == 2 then
                                        set slot = left1

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.087250, - 0.10200, true)
                                        call update(left1VerticalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.10700, - 0.092500, true)
                                        call BlzFrameSetVisible(left1HorizontalLine, false)
                                    elseif j == 3 then
                                        set slot = center

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.13625, - 0.10200, true)
                                        call BlzFrameSetVisible(centerVerticalLine, true)
                                    elseif j == 4 then
                                        set slot = right1

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.18525, - 0.10200, true)
                                        call update(right1VerticalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.20500, - 0.092500, true)
                                        call BlzFrameSetVisible(right1HorizontalLine, false)
                                    else
                                        set slot = right2

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.23425, - 0.10200, true)
                                        call update(right2HorizontalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.1, 0.001, 0.15700, - 0.091500, true)
                                        call update(right2VerticalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.25600, - 0.092500, true)
                                    endif
                                endif

                                call BlzFrameSetTexture(slot.icon, component.icon, 0, true)
                                call BlzFrameSetText(slot.cost, "|cffFFCC00" + I2S(component.gold) + "|r")
                                call BlzFrameSetText(slot.tooltip, component.tooltip)
                                call BlzFrameSetText(slot.tooltipName, component.name)
                                call BlzFrameSetTexture(slot.tooltipIcon, component.icon, 0, false)
                                
                                //set cost = cost + component.gold
                                set slot.visible = true
                                set j = j + 1
                            endif
                        set k = k + 1
                    endloop
                else
                    set center.visible = false
                    set left1.visible = false
                    set left2.visible = false
                    set right1.visible = false
                    set right2.visible = false

                    call BlzFrameSetVisible(mainVerticalLine, false)
                    call BlzFrameSetVisible(centerVerticalLine, false)
                    call BlzFrameSetVisible(left1HorizontalLine, false)
                    call BlzFrameSetVisible(left1VerticalLine, false)
                    call BlzFrameSetVisible(left2HorizontalLine, false)
                    call BlzFrameSetVisible(left2VerticalLine, false)
                    call BlzFrameSetVisible(right1HorizontalLine, false)
                    call BlzFrameSetVisible(right1VerticalLine, false)
                    call BlzFrameSetVisible(right2HorizontalLine, false)
                    call BlzFrameSetVisible(right2VerticalLine, false)
                endif

                call BlzFrameSetTexture(main.icon, item.icon, 0, true)
                call BlzFrameSetText(main.cost, "|cffFFCC00" + I2S(cost) + "|r")
                call BlzFrameSetText(main.tooltip, item.tooltip)
                call BlzFrameSetText(main.tooltipName, item.name)
                call BlzFrameSetTexture(main.tooltipIcon, item.icon, 0, false)
                call BlzFrameSetText(tooltip, item.tooltip)
                call BlzFrameSetVisible(frame, true)
            endif
        endmethod

        static method create takes Shop shop returns thistype
            local thistype this = thistype.allocate()
            local integer i = 0

            set .shop = shop
            set frame = BlzCreateFrame("EscMenuBackdrop", shop.main, 0, 0)
            set main = Slot.create(frame, 0, 0.13625, - 0.030000, FRAMEPOINT_TOPRIGHT)
            set center = Slot.create(frame, 0, 0.13625, - 0.10200, FRAMEPOINT_TOPRIGHT)
            set left1 = Slot.create(frame, 0, 0.087250, - 0.10200, FRAMEPOINT_TOPRIGHT)
            set left2 = Slot.create(frame, 0, 0.038250, - 0.10200, FRAMEPOINT_TOPRIGHT)
            set right1 = Slot.create(frame, 0, 0.18525, - 0.10200, FRAMEPOINT_TOPRIGHT)
            set right2 = Slot.create(frame, 0, 0.23425, - 0.10200, FRAMEPOINT_TOPRIGHT)
            set topSeparator = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set bottomSeparator = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set usedIn = BlzCreateFrameByType("TEXT", "", frame, "", 0)
            set mainVerticalLine = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set centerVerticalLine = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set left1HorizontalLine = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set left1VerticalLine = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set left2HorizontalLine = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set left2VerticalLine = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set right1HorizontalLine = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set right1VerticalLine = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set right2HorizontalLine = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set right2VerticalLine = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set tooltip = BlzCreateFrame("DescriptionArea", frame, 0, 0)
            set center.visible = false
            set left1.visible = false
            set left2.visible = false
            set right1.visible = false
            set right2.visible = false

            call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, shop.main, FRAMEPOINT_TOPLEFT, WIDTH - DETAIL_WIDTH, 0.0000)
            call BlzFrameSetSize(frame, DETAIL_WIDTH, DETAIL_HEIGHT)

            call BlzFrameSetPoint(mainVerticalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.15600, - 0.082500)
            call BlzFrameSetSize(mainVerticalLine, 0.001, 0.01)
            call BlzFrameSetTexture(mainVerticalLine, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)

            call BlzFrameSetPoint(centerVerticalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.15600, - 0.092500)
            call BlzFrameSetSize(centerVerticalLine, 0.001, 0.01)
            call BlzFrameSetTexture(centerVerticalLine, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)

            // call BlzFrameSetPoint(left1HorizontalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.10700, - 0.091500)
            // call BlzFrameSetSize(left1HorizontalLine, 0.048, 0.001)
            call BlzFrameSetTexture(left1HorizontalLine, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)

            // call BlzFrameSetPoint(left1VerticalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.10700, - 0.092500)
            // call BlzFrameSetSize(left1VerticalLine, 0.001, 0.01)
            call BlzFrameSetTexture(left1VerticalLine, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)

            // call BlzFrameSetPoint(left2HorizontalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.057000, - 0.091500)
            // call BlzFrameSetSize(left2HorizontalLine, 0.1, 0.001)
            call BlzFrameSetTexture(left2HorizontalLine, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)

            // call BlzFrameSetPoint(left2VerticalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.057000, - 0.092500)
            // call BlzFrameSetSize(left2VerticalLine, 0.001, 0.01)
            call BlzFrameSetTexture(left2VerticalLine, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)

            // call BlzFrameSetPoint(right1HorizontalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.15700, - 0.091500)
            // call BlzFrameSetSize(right1HorizontalLine, 0.048, 0.001)
            call BlzFrameSetTexture(right1HorizontalLine, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)

            // call BlzFrameSetPoint(right1VerticalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.20500, - 0.092500)
            // call BlzFrameSetSize(right1VerticalLine, 0.001, 0.01)
            call BlzFrameSetTexture(right1VerticalLine, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)

            // call BlzFrameSetPoint(right2HorizontalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.15700, - 0.091500)
            // call BlzFrameSetSize(right2HorizontalLine, 0.1, 0.001)
            call BlzFrameSetTexture(right2HorizontalLine, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)

            // call BlzFrameSetPoint(right2VerticalLine, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.25600, - 0.092500)
            // call BlzFrameSetSize(right2VerticalLine, 0.001, 0.01)
            call BlzFrameSetTexture(right2VerticalLine, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)

            call BlzFrameSetPoint(topSeparator, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.027500, - 0.15585)
            call BlzFrameSetSize(topSeparator, 0.255, 0.001)
            call BlzFrameSetTexture(topSeparator, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)
            call BlzFrameSetPoint(bottomSeparator, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.027500, - 0.31585)
            call BlzFrameSetSize(bottomSeparator, 0.255, 0.001)
            call BlzFrameSetTexture(bottomSeparator, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)
            call BlzFrameSetPoint(usedIn, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.13750, - 0.31800)
            call BlzFrameSetSize(usedIn, 0.04, 0.012)
            call BlzFrameSetText(usedIn, "|cffFFCC00Used in:|r")
            call BlzFrameSetEnable(usedIn, false)
            call BlzFrameSetScale(usedIn, 1.00)
            call BlzFrameSetTextAlignment(usedIn, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
            call BlzFrameSetPoint(tooltip, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.027500, - 0.15950)
            call BlzFrameSetSize(tooltip, 0.31, 0.16)
            call BlzFrameSetText(tooltip, "")
            call BlzFrameSetVisible(frame, false)

            return this
        endmethod
    endstruct

    private struct Favorites
        readonly static trigger event = CreateTrigger()

        Shop shop
        integer count
        Item array item[CATEGORY_COUNT]
        framehandle array frame[CATEGORY_COUNT]
        framehandle array icon[CATEGORY_COUNT]
        framehandle array button[CATEGORY_COUNT]
        framehandle array tooltipFrame[CATEGORY_COUNT]
        framehandle array tooltipIcon[CATEGORY_COUNT]
        framehandle array tooltipName[CATEGORY_COUNT]
        framehandle array tooltip[CATEGORY_COUNT]

        method destroy takes nothing returns nothing
            local integer i = 0

            loop
                exitwhen i == CATEGORY_COUNT
                    call FlushChildHashtable(table, GetHandleId(button[i]))
                    call BlzDestroyFrame(tooltip[i])
                    call BlzDestroyFrame(tooltipFrame[i])
                    call BlzDestroyFrame(button[i])
                    call BlzDestroyFrame(icon[i])
                    call BlzDestroyFrame(frame[i])
                    set tooltip[i] = null
                    set tooltipFrame[i] = null
                    set button[i] = null
                    set icon[i] = null
                    set frame[i] = null
                set i = i + 1
            endloop

            call FlushChildHashtable(table, this)
            call deallocate()
        endmethod

        method setTooltip takes framepointtype point, framehandle parent, integer i returns framehandle
            local framehandle frame = BlzCreateFrame("TooltipBoxFrame", parent, 0, 0)
            local framehandle box = BlzGetFrameByName("TooltipBox", 0)
            local framehandle tooltipSeparator = BlzGetFrameByName("TooltipSeperator", 0)

            set tooltip[i] = BlzGetFrameByName("TooltipText", 0)
            set tooltipIcon[i] = BlzGetFrameByName("TooltipIcon", 0)
            set tooltipName[i] = BlzGetFrameByName("TooltipName", 0)

            if point == FRAMEPOINT_TOPLEFT then
                call BlzFrameSetPoint(tooltip[i], point, parent, FRAMEPOINT_TOPRIGHT, 0.005, -0.05)
            elseif point == FRAMEPOINT_TOPRIGHT then
                call BlzFrameSetPoint(tooltip[i], point, parent, FRAMEPOINT_TOPLEFT, -0.005, -0.05)
            elseif point == FRAMEPOINT_BOTTOMLEFT then
                call BlzFrameSetPoint(tooltip[i], point, parent, FRAMEPOINT_BOTTOMRIGHT, 0.005, 0.0)
            else
                call BlzFrameSetPoint(tooltip[i], point, parent, FRAMEPOINT_BOTTOMLEFT, -0.005, 0.0)
            endif

            call BlzFrameSetPoint(box, FRAMEPOINT_TOPLEFT, tooltipIcon[i], FRAMEPOINT_TOPLEFT, -0.005, 0.005)
            call BlzFrameSetPoint(box, FRAMEPOINT_BOTTOMRIGHT, tooltip[i], FRAMEPOINT_BOTTOMRIGHT, 0.005, -0.005)
            // call BlzFrameSetText(tooltip[i], item.tooltip)
            // call BlzFrameSetText(tooltipName, item.name)
            // call BlzFrameSetTexture(tooltipIcon, item.icon, 0, false)
            call BlzFrameSetSize(tooltip[i], TOOLTIP_SIZE, 0)

            return frame
        endmethod

        method has takes integer id returns boolean
            local integer i = 0

            loop
                exitwhen i > count
                    if item[i].id == id then
                        return true
                    endif
                set i = i + 1
            endloop

            return false
        endmethod

        method remove takes integer i returns nothing
            loop
                exitwhen i >= count
                    set item[i] = item[i + 1]

                    call BlzFrameSetTexture(icon[i], item[i].icon, 0, true)
                    call BlzFrameSetText(tooltip[i], item[i].tooltip)
                    call BlzFrameSetText(tooltipName[i], item[i].name)
                    call BlzFrameSetTexture(tooltipIcon[i], item[i].icon, 0, false)
                set i = i + 1
            endloop

            call BlzFrameSetVisible(frame[count], false)
            set count = count - 1
        endmethod

        method add takes Item i returns nothing
            if count < CATEGORY_COUNT - 1 then
                if not has(i.id) then
                    set count = count + 1
                    set item[count] = i
            
                    call BlzFrameSetTexture(icon[count], i.icon, 0, true)
                    call BlzFrameSetText(tooltip[count], i.tooltip)
                    call BlzFrameSetText(tooltipName[count], i.name)
                    call BlzFrameSetTexture(tooltipIcon[count], i.icon, 0, false)
                    call BlzFrameSetVisible(frame[count], true)
                endif
            endif
        endmethod

        static method create takes Shop shop returns thistype
            local thistype this = thistype.allocate()
            local integer i = 0

            set .shop = shop
            set count = -1
            
            loop
                exitwhen i == CATEGORY_COUNT
                    set frame[i] = BlzCreateFrameByType("FRAME", "", shop.rightPanel, "", 0)
                    set icon[i] = BlzCreateFrameByType("BACKDROP", "", frame[i], "", 0)    
                    set button[i] = BlzCreateFrame("IconButtonTemplate", icon[i], 0, 0)

                    if i <= 6 then
                        set tooltipFrame[i] = setTooltip(FRAMEPOINT_TOPRIGHT, button[i], i)
                    else
                        set tooltipFrame[i] = setTooltip(FRAMEPOINT_BOTTOMRIGHT, button[i], i)
                    endif

                    call BlzFrameSetPoint(frame[i], FRAMEPOINT_TOPLEFT, shop.rightPanel, FRAMEPOINT_TOPLEFT, 0.023750, - (0.021500 + CATEGORY_SIZE*i + CATEGORY_GAP))
                    call BlzFrameSetSize(frame[i], CATEGORY_SIZE, CATEGORY_SIZE)

                    call BlzFrameSetPoint(icon[i], FRAMEPOINT_TOPLEFT, frame[i], FRAMEPOINT_TOPLEFT, 0.0000, 0.0000)
                    call BlzFrameSetSize(icon[i], CATEGORY_SIZE, CATEGORY_SIZE)
                    call BlzFrameSetTexture(icon[i], "ReplaceableTextures\\CommandButtons\\BTNSteelMelee", 0, true)

                    call BlzFrameSetAllPoints(button[i], icon[i])
                    call BlzFrameSetTooltip(button[i], tooltipFrame[i])
                    call BlzFrameSetVisible(frame[i], false)

                    call SaveInteger(table, GetHandleId(button[i]), 0, this)
                    call SaveInteger(table, GetHandleId(button[i]), 1, i)
                    call BlzTriggerRegisterFrameEvent(event, button[i], FRAMEEVENT_CONTROL_CLICK)
                set i = i + 1
            endloop

            return this
        endmethod

        static method onClick takes nothing returns nothing
            local framehandle frame = BlzGetTriggerFrame()
            local thistype this = LoadInteger(table, GetHandleId(frame), 0)
            local integer i = LoadInteger(table, GetHandleId(frame), 1)

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    if Shop.tag[GetPlayerId(GetTriggerPlayer())] then
                        call remove(i)
                    endif
                endif
            endif

            set frame = null
        endmethod

        static method onInit takes nothing returns nothing
            call TriggerAddAction(event, function thistype.onClick)
        endmethod
    endstruct

    private struct Category
        readonly static trigger event = CreateTrigger()

        string array icon[CATEGORY_COUNT]
        string array description[CATEGORY_COUNT]
        integer array value[CATEGORY_COUNT]
        framehandle array button[CATEGORY_COUNT]
        framehandle array backdrop[CATEGORY_COUNT]
        framehandle array frame[CATEGORY_COUNT]
        framehandle array box[CATEGORY_COUNT]
        framehandle array tooltip[CATEGORY_COUNT]
        boolean array enabled[CATEGORY_COUNT]
        integer count
        integer active
        boolean andLogic
        Shop shop

        method destroy takes nothing returns nothing
            loop
                exitwhen count == -1
                    call FlushChildHashtable(table, GetHandleId(button[count]))
                    call BlzDestroyFrame(tooltip[count])
                    call BlzDestroyFrame(box[count])
                    call BlzDestroyFrame(frame[count])
                    call BlzDestroyFrame(button[count])
                    call BlzDestroyFrame(backdrop[count])
                    set backdrop[count] = null
                    set button[count] = null
                    set frame[count] = null
                    set box[count] = null
                    set tooltip[count] = null
                set count = count - 1
            endloop

            call deallocate()
        endmethod

        method enable takes framehandle frame, string icon, boolean flag returns nothing
            if not flag then
                if SubString(icon, 34, 35) == "\\" then
                    set icon = SubString(icon, 0, 34) + "Disabled\\DIS" + SubString(icon, 35, StringLength(icon))
                endif
            endif

            call BlzFrameSetTexture(frame, icon, 0, false)
        endmethod

        method add takes string icon, string description returns integer
            if count < CATEGORY_COUNT then
                set count = count + 1
                set value[count] = R2I(Pow(2, count))
                set .icon[count] = icon
                set .description[count] = description
                set enabled[count] = false
                set backdrop[count] = BlzCreateFrameByType("BACKDROP", "", shop.leftPanel, "", 0)
                set button[count] = BlzCreateFrameByType("GLUETEXTBUTTON", I2S(count), backdrop[count], "", 0)
                set frame[count] = BlzCreateFrameByType("FRAME", "", button[count], "", 0)
                set box[count] = BlzCreateFrame("Leaderboard", frame[count], 0, 0)
                set tooltip[count] = BlzCreateFrameByType("TEXT", "", box[count], "", 0)
                
                call BlzFrameSetPoint(backdrop[count], FRAMEPOINT_TOPLEFT, shop.leftPanel, FRAMEPOINT_TOPLEFT, 0.023750, - (0.021500 + CATEGORY_SIZE*count + CATEGORY_GAP))
                call BlzFrameSetSize(backdrop[count], CATEGORY_SIZE, CATEGORY_SIZE)
                call BlzFrameSetAllPoints(button[count], backdrop[count])
                call BlzFrameSetPoint(tooltip[count], FRAMEPOINT_BOTTOM, button[count], FRAMEPOINT_TOP, 0, 0.008)
                call BlzFrameSetPoint(box[count], FRAMEPOINT_TOPLEFT, tooltip[count], FRAMEPOINT_TOPLEFT, -0.008, 0.008)
                call BlzFrameSetPoint(box[count], FRAMEPOINT_BOTTOMRIGHT, tooltip[count], FRAMEPOINT_BOTTOMRIGHT, 0.008, -0.008)
                call BlzFrameSetText(tooltip[count], description)
                call BlzFrameSetTooltip(button[count], frame[count])
                call SaveInteger(table, GetHandleId(button[count]), 0, this)
                call BlzTriggerRegisterFrameEvent(event, button[count], FRAMEEVENT_CONTROL_CLICK)
                call enable(backdrop[count], icon, enabled[count])

                return value[count]
            else
                call BJDebugMsg("Maximum number os categories reached.")
            endif

            return 0
        endmethod

        static method create takes Shop shop returns thistype
            local thistype this = thistype.allocate()

            set count = -1
            set active = 0
            set andLogic = true
            set .shop = shop

            return this
        endmethod

        static method onClick takes nothing returns nothing
            local framehandle frame = BlzGetTriggerFrame()
            local thistype this = LoadInteger(table, GetHandleId(frame), 0)
            local integer i = S2I(BlzFrameGetName(frame))

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    set enabled[i] = not enabled[i]

                    if enabled[i] then
                        set active = active + value[i]
                    else
                        set active = active - value[i]
                    endif

                    call shop.filter(active, andLogic)
                endif

                call enable(backdrop[i], icon[i], enabled[i])
                call BlzFrameSetEnable(frame, false)
                call BlzFrameSetEnable(frame, true)
            endif

            set frame = null
        endmethod

        static method onInit takes nothing returns nothing
            call TriggerAddAction(event, function thistype.onClick)
        endmethod
    endstruct
    
    struct Shop
        private static hashtable itempool = InitHashtable()
        private static trigger trigger = CreateTrigger()
        private static trigger keyPress = CreateTrigger()
        private static trigger escPressed = CreateTrigger()
        private static integer count = -1
        readonly static timer array timer
        readonly static boolean array canScroll
        readonly static boolean array tag

        readonly framehandle base
        readonly framehandle main
        readonly framehandle leftPanel
        readonly framehandle rightPanel
        readonly Category category
        readonly Favorites favorites
        readonly Detail details
        readonly integer id
        readonly integer index
        readonly integer size
        readonly integer rows
        readonly integer columns
        readonly ShopSlot first
        readonly ShopSlot last
        readonly ShopSlot head
        readonly ShopSlot tail
        readonly boolean detailed

        method destroy takes nothing returns nothing
            local ShopSlot slot = LoadInteger(itempool, this, 0)
            local integer i = 0

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    call DestroyTimer(timer[i])
                    call FlushChildHashtable(table, GetHandleId(Player(i)))
                    set timer[i] = null
                set i = i + 1
            endloop

            loop
                exitwhen slot == 0
                    call slot.destroy()
                set slot = slot.next
            endloop

            call FlushChildHashtable(table, id)
            call FlushChildHashtable(table, this)
            call FlushChildHashtable(itempool, this)
            call BlzDestroyFrame(rightPanel)
            call BlzDestroyFrame(leftPanel)
            call BlzDestroyFrame(main)
            call BlzDestroyFrame(base)
            call category.destroy()
            call favorites.destroy()
            call details.destroy()
            call deallocate()

            set base = null
            set main = null
            set leftPanel = null
            set rightPanel = null
        endmethod

        method scroll takes boolean down, player p returns nothing
            local ShopSlot slot = first
            local integer i = GetPlayerId(GetLocalPlayer())
            local real delay = TimerGetRemaining(timer[i])
            
            if p == GetLocalPlayer() then
                if canScroll[i] then
                    set delay = SCROLL_DELAY

                    if SCROLL_DELAY > 0 then
                        set canScroll[i] = false
                    endif

                    if (down and tail != last) or (not down and head != first) then
                        loop
                            exitwhen slot == 0
                                if down then
                                    call slot.move(slot.row - 1, slot.column)
                                else
                                    call slot.move(slot.row + 1, slot.column)
                                endif

                                set slot.visible = slot.row >= 0 and slot.row <= rows - 1 and slot.column >= 0 and slot.column <= columns - 1

                                if slot.row == 0 and slot.column == 0 then
                                    set head = slot
                                endif

                                if (slot.row == rows - 1 and slot.column == columns - 1) or (slot == last and slot.visible) then
                                    set tail = slot
                                endif
                            set slot = slot.right
                        endloop
                    endif
                endif
            endif

            if SCROLL_DELAY > 0 then
                call TimerStart(timer[i], delay, false, function thistype.onExpire)
            endif
        endmethod

        method filter takes integer categories, boolean andLogic returns nothing
            local ShopSlot slot = LoadInteger(itempool, this, 0)
            local boolean process
            local integer i = -1

            set size = 0
            set first = 0
            set last = 0
            set head = 0
            set tail = 0

            loop
                exitwhen slot == 0
                    if andLogic then
                        set process = categories == 0 or BlzBitAnd(slot.item.categories, categories) >= categories
                    else
                        set process = categories == 0 or BlzBitAnd(slot.item.categories, categories) > 0
                    endif

                    if process then
                        set i = i + 1
                        set size = size + 1
                        call slot.move(R2I(i/columns), ModuloInteger(i, columns))
                        set slot.visible = slot.row >= 0 and slot.row <= rows - 1 and slot.column >= 0 and slot.column <= columns - 1
                    
                        if i > 0 then
                            set slot.left = last
                            set last.right = slot
                        else
                            set first = slot
                            set head = first
                        endif

                        if slot.visible then
                            set tail = slot
                        endif

                        set last = slot
                    else
                        set slot.visible = false
                    endif
                set slot = slot.next
            endloop
        endmethod

        method detail takes Item i returns nothing
            if i != 0 then
                set rows = DETAILED_ROWS
                set columns = DETAILED_COLUMNS

                if not detailed then
                    set detailed = true
                    call filter(category.active, category.andLogic)
                endif

                call details.show(i)
            else
                set rows = ROWS
                set columns = COLUMNS
                set detailed  = false
                call filter(category.active, category.andLogic)
                call details.hide()
            endif
        endmethod

        static method create takes integer id returns thistype
            local thistype this
            local integer i = 0

            if not HaveSavedInteger(table, id, 0) then
                set this = thistype.allocate()
                set .id = id
                set first = 0
                set last = 0
                set head = 0
                set tail = 0
                set size = 0
                set index = -1
                set rows = ROWS
                set columns = COLUMNS
                set count = count + 1
                set detailed = false
                set base = BlzCreateFrame("EscMenuBackdrop", BlzGetFrameByName("ConsoleUIBackdrop", 0), 0, 0)
                set main = BlzCreateFrameByType("BUTTON", "main", base, "", 0)
                set leftPanel = BlzCreateFrame("EscMenuBackdrop", base, 0, 0)
                set rightPanel = BlzCreateFrame("EscMenuBackdrop", base, 0, 0)
                set category = Category.create(this)
                set favorites = Favorites.create(this)
                set details = Detail.create(this)

                loop
                    exitwhen i >= bj_MAX_PLAYER_SLOTS
                        set timer[i] = CreateTimer()
                        set canScroll[i] = true
                        call SaveInteger(table, GetHandleId(Player(i)), id, this)
                        call SaveInteger(table, GetHandleId(Player(i)), count, id)
                    set i = i + 1
                endloop

                call BlzFrameSetAbsPoint(base, FRAMEPOINT_TOPLEFT, X, Y)
                call BlzFrameSetSize(base, WIDTH, HEIGHT)

                call BlzFrameSetPoint(main, FRAMEPOINT_TOPLEFT, base, FRAMEPOINT_TOPLEFT, 0.0000, 0.0000)
                call BlzFrameSetSize(main, WIDTH, HEIGHT)

                call BlzFrameSetPoint(leftPanel, FRAMEPOINT_TOPLEFT, base, FRAMEPOINT_TOPLEFT, -0.04800, 0.0000)
                call BlzFrameSetSize(leftPanel, SIDE_WIDTH, SIDE_HEIGHT)

                call BlzFrameSetPoint(rightPanel, FRAMEPOINT_TOPLEFT, base, FRAMEPOINT_TOPLEFT, 0.77300, 0.0000)
                call BlzFrameSetSize(rightPanel, SIDE_WIDTH, SIDE_HEIGHT)

                call SaveInteger(table, id, 0, this)
                call SaveInteger(table, GetHandleId(main), 0, this)
                call BlzFrameSetVisible(base, false)
                call BlzTriggerRegisterFrameEvent(trigger, main, FRAMEEVENT_MOUSE_WHEEL)
            endif

            return this
        endmethod

        static method addCategory takes integer id, string icon, string description returns integer
            local thistype this = LoadInteger(table, id, 0)

            if this != 0 then
                return category.add(icon, description)
            endif

            return 0
        endmethod

        static method addItem takes integer id, integer itemId, integer categories returns nothing
            local thistype this = LoadInteger(table, id, 0)
            local ShopSlot slot
            local Item i

            if this != 0 then
                if not HaveSavedInteger(table, this, itemId) then
                    set i = Item.create(itemId, categories)
                    
                    if i != 0 then
                        set size = size + 1
                        set index = index + 1
                        set slot = ShopSlot.create(this, i, R2I(index/COLUMNS), ModuloInteger(index, COLUMNS))
                        set slot.visible = slot.row >= 0 and slot.row <= ROWS - 1 and slot.column >= 0 and slot.column <= COLUMNS - 1

                        if index > 0 then
                            set slot.prev = last
                            set slot.left = last
                            set last.next = slot
                            set last.right = slot
                        else
                            set first = slot
                            set head = slot
                        endif

                        if slot.visible then
                            set tail = slot
                        endif

                        set last = slot

                        call SaveInteger(itempool, this, index, slot)
                        call SaveInteger(table, this, itemId, slot)
                    else
                        call BJDebugMsg("Invalid item code: " + A2S(itemId))
                    endif
                else
                    call BJDebugMsg("The item " + GetObjectName(itemId) + " is already registered for the shop " + GetObjectName(id))
                endif
            endif
        endmethod

        static method onExpire takes nothing returns nothing
            set canScroll[GetPlayerId(GetLocalPlayer())] = true
        endmethod

        static method onScroll takes nothing returns nothing
            local framehandle frame = BlzGetTriggerFrame()
            local thistype this = LoadInteger(table, GetHandleId(frame), 0)

            if this != 0 then
                call scroll(BlzGetTriggerFrameValue() < 0, GetTriggerPlayer())
            endif

            set frame = null
        endmethod

        static method onSelect takes nothing returns nothing
            local thistype this = LoadInteger(table, GetUnitTypeId(GetTriggerUnit()), 0)
            local ShopSlot slot

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    call BlzFrameSetVisible(base, GetTriggerEventId() == EVENT_PLAYER_UNIT_SELECTED)
                endif
            endif
        endmethod

        static method onKey takes nothing returns nothing
            set tag[GetPlayerId(GetTriggerPlayer())] = BlzGetTriggerPlayerIsKeyDown()
        endmethod

        static method onEsc takes nothing returns nothing
            local thistype this
            local integer i = 0
            local integer id = GetHandleId(GetTriggerPlayer())
            
            loop
                exitwhen i > count
                    set this = LoadInteger(table, id, LoadInteger(table, id, i))

                    if this != 0 then
                        if GetLocalPlayer() == GetTriggerPlayer() then
                            call BlzFrameSetVisible(base, false)
                        endif
                    endif
                set i = i + 1
            endloop
        endmethod

        static method onInit takes nothing returns nothing
            local integer i = 0

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    set tag[i] = false
                    call BlzTriggerRegisterPlayerKeyEvent(keyPress, Player(i), FAVORITE_KEY, 0, true)
                    call BlzTriggerRegisterPlayerKeyEvent(keyPress, Player(i), FAVORITE_KEY, 0, false)
                    call TriggerRegisterPlayerEventEndCinematic(escPressed, Player(i))
                set i = i + 1
            endloop

            call BlzLoadTOCFile("Shop.toc")
            call TriggerAddAction(trigger, function thistype.onScroll)
            call TriggerAddCondition(keyPress, function thistype.onKey)
            call TriggerAddCondition(escPressed, function thistype.onEsc)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, function thistype.onSelect)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DESELECTED, function thistype.onSelect)
        endmethod
    endstruct
endlibrary
    