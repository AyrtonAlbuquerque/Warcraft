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

        // Side Panels
        private constant real SIDE_WIDTH                = 0.075
        private constant real SIDE_HEIGHT               = 0.4

        // Category buttons
        private constant integer CATEGORY_COUNT         = 13
        private constant real CATEGORY_SIZE             = 0.02750
        private constant real CATEGORY_GAP              = 0.0

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
    private struct Item
        private static unit shop
        private static rect rect
        private static player player = Player(bj_PLAYER_NEUTRAL_EXTRA)

        string name
        string icon
        string tooltip
        integer id
        integer gold
        integer index
        integer categories
        
        method destroy takes nothing returns nothing
            call deallocate()
        endmethod

        static method create takes item i, integer idx, integer category returns thistype
            local thistype this = thistype.allocate()

            set id = GetItemTypeId(i)
            set index = idx
            set categories = category
            set name = GetItemName(i)
            set icon = BlzGetItemIconPath(i)
            set tooltip = BlzGetItemExtendedTooltip(i)
            set gold = cost(id)

            return this
        endmethod

        static method clear takes nothing returns nothing
            call RemoveItem(GetEnumItem())
        endmethod

        static method cost takes integer itemId returns integer
            local integer old

            call AddItemToStock(shop, itemId, 1, 1)
            call SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, 9999999)
            set old = GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD)
            call IssueNeutralImmediateOrderById(player, shop, itemId)
            call RemoveItemFromStock(shop, itemId)
            call EnumItemsInRect(rect, null, function thistype.clear)

            return old - GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD)
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
        readonly static trigger click = CreateTrigger()
        readonly static trigger scroll = CreateTrigger()

        private boolean isVisible = true

        Shop shop
        Item item
        Slot next
        Slot prev
        Slot right
        Slot left
        integer row
        integer column
        framehandle slot
        framehandle icon
        framehandle gold
        framehandle cost
        framehandle button
        framehandle tooltipFrame
        framehandle tooltip

        method operator visible= takes boolean visibility returns nothing
            set isVisible = visibility
            call BlzFrameSetVisible(slot, visibility)
        endmethod

        method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method operator position takes nothing returns integer 
            return (COLUMNS * row) + (column + 1)
        endmethod

        method destroy takes nothing returns nothing
            call FlushChildHashtable(table, GetHandleId(button))
            call BlzDestroyFrame(tooltip)
            call BlzDestroyFrame(tooltipFrame)
            call BlzDestroyFrame(cost)
            call BlzDestroyFrame(gold)
            call BlzDestroyFrame(button)
            call BlzDestroyFrame(icon)
            call BlzDestroyFrame(slot)
            call item.destroy()
            call deallocate()

            set slot = null
            set icon = null
            set gold = null
            set cost = null
            set button = null
            set tooltip = null
            set tooltipFrame = null
        endmethod

        method move takes integer row, integer column returns nothing
            set .row = row
            set .column = column

            call BlzFrameClearAllPoints(slot)
            call BlzFrameSetPoint(slot, FRAMEPOINT_TOPLEFT, shop.main, FRAMEPOINT_TOPLEFT, 0.030000 + ((SLOT_WIDTH + SLOT_GAP_X) * column), - (0.030000 + ((SLOT_HEIGHT + SLOT_GAP_Y) * row)))
            call updateTooltip(button)
        endmethod

        method setTooltip takes framepointtype point, framehandle parent returns framehandle
            local framehandle frame = BlzCreateFrame("TooltipBoxFrame", parent, 0, 0)
            local framehandle box = BlzGetFrameByName("TooltipBox", 0)
            local framehandle tooltipIcon = BlzGetFrameByName("TooltipIcon", 0)
            local framehandle tooltipName = BlzGetFrameByName("TooltipName", 0)
            local framehandle tooltipSeparator = BlzGetFrameByName("TooltipSeperator", 0)

            set tooltip = BlzGetFrameByName("TooltipText", 0)

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
            call BlzFrameSetText(tooltip, item.tooltip)
            call BlzFrameSetText(tooltipName, item.name)
            call BlzFrameSetTexture(tooltipIcon, item.icon, 0, false)
            call BlzFrameSetSize(tooltip, TOOLTIP_SIZE, 0)

            return frame
        endmethod

        method updateTooltip takes framehandle frame returns nothing
            call BlzFrameClearAllPoints(tooltip)

            if column <= 6 and row < 3 then
                call BlzFrameSetPoint(tooltip, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPRIGHT, 0.005, -0.05)
            elseif column >= 7 and row < 3 then
                call BlzFrameSetPoint(tooltip, FRAMEPOINT_TOPRIGHT, frame, FRAMEPOINT_TOPLEFT, -0.005, -0.05)
            elseif column <= 6 and row >= 3 then
                call BlzFrameSetPoint(tooltip, FRAMEPOINT_BOTTOMLEFT, frame, FRAMEPOINT_BOTTOMRIGHT, 0.005, 0.0)
            else
                call BlzFrameSetPoint(tooltip, FRAMEPOINT_BOTTOMRIGHT, frame, FRAMEPOINT_BOTTOMLEFT, -0.005, 0.0)
            endif
        endmethod

        static method create takes Shop shop, Item i, integer row, integer column returns thistype
            local thistype this = thistype.allocate()

            set .shop = shop
            set item = i
            set next = 0
            set prev = 0
            set right = 0
            set left = 0
            set .row = row
            set .column = column
            set slot = BlzCreateFrameByType("FRAME", "", shop.main, "", 0)
            set icon = BlzCreateFrameByType("BACKDROP", "", slot, "", 0)    
            set button = BlzCreateFrame("IconButtonTemplate", icon, 0, 0)
            set gold = BlzCreateFrameByType("BACKDROP", "", slot, "", 0)
            set cost = BlzCreateFrameByType("TEXT", "", gold, "", 0)
            set tooltipFrame = setTooltip(FRAMEPOINT_TOPLEFT, button)

            call BlzFrameSetPoint(slot, FRAMEPOINT_TOPLEFT, shop.main, FRAMEPOINT_TOPLEFT, 0.030000 + ((SLOT_WIDTH + SLOT_GAP_X) * column), - (0.030000 + ((SLOT_HEIGHT + SLOT_GAP_Y) * row)))
            call BlzFrameSetSize(slot, SLOT_WIDTH, SLOT_HEIGHT)
            call BlzFrameSetPoint(icon, FRAMEPOINT_TOPLEFT, slot, FRAMEPOINT_TOPLEFT, 0.0000, 0.0000)
            call BlzFrameSetSize(icon, ITEM_SIZE, ITEM_SIZE)
            call BlzFrameSetTexture(icon, item.icon, 0, true)
            call BlzFrameSetPoint(gold, FRAMEPOINT_TOPLEFT, slot, FRAMEPOINT_TOPLEFT, 0.0000, - 0.040000)
            call BlzFrameSetSize(gold, GOLD_SIZE, GOLD_SIZE)
            call BlzFrameSetTexture(gold, GOLD_ICON, 0, true)
            call BlzFrameSetPoint(cost, FRAMEPOINT_TOPLEFT, gold, FRAMEPOINT_TOPLEFT, 0.013250, - 0.0019300)
            call BlzFrameSetSize(cost, COST_WIDTH, COST_HEIGHT)
            call BlzFrameSetText(cost, "|cffFFCC00" + I2S(item.gold) + "|r")
            call BlzFrameSetEnable(cost, false)
            call BlzFrameSetScale(cost, COST_SCALE)
            call BlzFrameSetTextAlignment(cost, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)
            call BlzFrameSetAllPoints(button, icon)
            call BlzFrameSetTooltip(button, tooltipFrame)
            call SaveInteger(table, GetHandleId(button), 0, this)
            call BlzTriggerRegisterFrameEvent(click, button, FRAMEEVENT_CONTROL_CLICK)
            call BlzTriggerRegisterFrameEvent(scroll, button, FRAMEEVENT_MOUSE_WHEEL)
            call updateTooltip(button)

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
                    //
                endif
            endif

            set frame = null
        endmethod

        static method onInit takes nothing returns nothing
            call TriggerAddAction(click, function thistype.onClick)
            call TriggerAddAction(scroll, function thistype.onScroll)
        endmethod
    endstruct

    private struct Category
        readonly static trigger event = CreateTrigger()

        string array icon[CATEGORY_COUNT]
        string array description[CATEGORY_COUNT]
        integer array value[CATEGORY_COUNT]
        trigger array trigger[CATEGORY_COUNT]
        framehandle array button[CATEGORY_COUNT]
        framehandle array backdrop[CATEGORY_COUNT]
        framehandle array frame[CATEGORY_COUNT]
        framehandle array box[CATEGORY_COUNT]
        framehandle array tooltip[CATEGORY_COUNT]
        boolean array enabled[CATEGORY_COUNT]
        integer count
        Shop shop

        method destroy takes nothing returns nothing
            loop
                exitwhen count == -1
                    call DestroyTrigger(trigger[count])
                    call BlzDestroyFrame(tooltip[count])
                    call BlzDestroyFrame(box[count])
                    call BlzDestroyFrame(frame[count])
                    call BlzDestroyFrame(button[count])
                    call BlzDestroyFrame(backdrop[count])
                    set trigger[count] = null
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
                set trigger[count] = CreateTrigger()
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
                call BJDebugMsg("Maximun number os categories reached.")
            endif

            return 0
        endmethod

        static method create takes Shop shop returns thistype
            local thistype this = thistype.allocate()

            set count = -1
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
                    // call shop.filter(value[i], true)
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
        readonly static timer array timer
        readonly static boolean array canScroll

        readonly framehandle base
        readonly framehandle main
        readonly framehandle leftPanel
        readonly framehandle rightPanel
        readonly Category category
        readonly integer id
        readonly integer index
        readonly integer size
        readonly Slot first
        readonly Slot last
        readonly Slot head
        readonly Slot tail

        method destroy takes nothing returns nothing
            local Slot slot = LoadInteger(itempool, this, 0)
            local integer i = 0

            loop
                exitwhen i > bj_MAX_PLAYER_SLOTS
                    call DestroyTimer(timer[i])
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
            call deallocate()

            set base = null
            set main = null
            set leftPanel = null
            set rightPanel = null
        endmethod

        method scroll takes boolean down, player p returns nothing
            local Slot slot = first
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

                                set slot.visible = slot.row >= 0 and slot.row <= ROWS - 1 and slot.column >= 0 and slot.column <= COLUMNS - 1

                                if slot.row == 0 and slot.column == 0 then
                                    set head = slot
                                endif

                                if (slot.row == ROWS - 1 and slot.column == COLUMNS - 1) or (slot == last and slot.visible) then
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

        method filter takes integer value, boolean andLogic returns nothing
            local Slot slot = LoadInteger(itempool, this, 0)
            local integer i = -1

            set size = 0
            set first = 0
            set last = 0
            set head = 0
            set tail = 0

            loop
                exitwhen slot == 0
                    if value == 0 or ((andLogic or (not (BlzBitAnd(value, slot.item.categories) >= value))) and (not andLogic or (not (BlzBitAnd(value, slot.item.categories) > 0)))) then
                        set i = i + 1
                        set size = size + 1
                        set slot.visible = slot.row >= 0 and slot.row <= ROWS - 1 and slot.column >= 0 and slot.column <= COLUMNS - 1
                    
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

                        call slot.move(R2I(i/COLUMNS), ModuloInteger(i, COLUMNS))
                    else
                        set slot.visible = false
                    endif
                set slot = slot.next
            endloop
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
                set category = Category.create(this)

                loop
                    exitwhen i > bj_MAX_PLAYER_SLOTS
                        set timer[i] = CreateTimer()
                        set canScroll[i] = true
                    set i = i + 1
                endloop

                set base = BlzCreateFrame("EscMenuBackdrop", BlzGetFrameByName("ConsoleUIBackdrop", 0), 0, 0)
                call BlzFrameSetAbsPoint(base, FRAMEPOINT_TOPLEFT, X, Y)
                call BlzFrameSetSize(base, WIDTH, HEIGHT)

                set main = BlzCreateFrameByType("BUTTON", "main", base, "", 0) //BlzCreateFrame("EscMenuBackdrop", base, 0, 0)
                call BlzFrameSetPoint(main, FRAMEPOINT_TOPLEFT, base, FRAMEPOINT_TOPLEFT, 0.0000, 0.0000)
                call BlzFrameSetSize(main, WIDTH, HEIGHT)

                set leftPanel = BlzCreateFrame("EscMenuBackdrop", base, 0, 0)
                call BlzFrameSetPoint(leftPanel, FRAMEPOINT_TOPLEFT, base, FRAMEPOINT_TOPLEFT, -0.065000, 0.0000)
                call BlzFrameSetSize(leftPanel, SIDE_WIDTH, SIDE_HEIGHT)

                set rightPanel = BlzCreateFrame("EscMenuBackdrop", base, 0, 0)
                call BlzFrameSetPoint(rightPanel, FRAMEPOINT_TOPLEFT, base, FRAMEPOINT_TOPLEFT, 0.79000, 0.0000)
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
            local Slot slot
            local item i

            if this != 0 then
                if not HaveSavedInteger(table, this, itemId) then
                    set i = CreateItem(itemId, 0, 0)
                    
                    if i != null then
                        set size = size + 1
                        set index = index + 1
                        set slot = Slot.create(this, Item.create(i, index, categories), R2I(index/COLUMNS), ModuloInteger(index, COLUMNS))
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
                        call RemoveItem(i)
                    else
                        call BJDebugMsg("Invalid item code: " + A2S(itemId))
                    endif
                else
                    call BJDebugMsg("The item " + GetObjectName(itemId) + " is already registered for the shop " + GetObjectName(id))
                endif
            endif

            set i = null
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

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    call BlzFrameSetVisible(base, GetTriggerEventId() == EVENT_PLAYER_UNIT_SELECTED)
                endif
            endif
        endmethod

        static method onInit takes nothing returns nothing
            call BlzLoadTOCFile("Shop.toc")
            call TriggerAddAction(trigger, function thistype.onScroll)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, function thistype.onSelect)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DESELECTED, function thistype.onSelect)
        endmethod
    endstruct
endlibrary
    