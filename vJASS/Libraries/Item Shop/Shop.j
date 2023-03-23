library Shop requires Table, RegisterPlayerUnitEvent, Components
    /* --------------------------------------- Shop v1.0 --------------------------------------- */
    // Credits:
    //      Taysen: TasItemShop and FDF file
    //      Bribe: A2S funciton and Table library
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
        private constant real TOOLBAR_BUTTON_SIZE       = 0.02
        private constant integer ROWS                   = 5
        private constant integer COLUMNS                = 13
        private constant integer DETAILED_ROWS          = 5
        private constant integer DETAILED_COLUMNS       = 8
        private constant string CLOSE_ICON              = "ui\\widgets\\battlenet\\chaticons\\bnet-squelch"
        private constant string CLEAR_ICON              = "ReplaceableTextures\\CommandButtons\\BTNCancel.blp"
        private constant string HELP_ICON               = "UI\\Widgets\\EscMenu\\Human\\quest-unknown.blp"
        private constant string LOGIC_ICON              = "ReplaceableTextures\\CommandButtons\\BTNMagicalSentry.blp"

        // Buyer Panel
        private constant real BUYER_WIDTH               = WIDTH/2
        private constant real BUYER_HEIGHT              = 0.08
        private constant real BUYER_SIZE                = 0.032
        private constant real BUYER_GAP                 = 0.04
        private constant real BUYER_SHIFT_BUTTON_SIZE   = 0.012
        private constant integer BUYER_COUNT            = 8
        private constant string BUYER_RIGHT             = "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedDown.blp"
        private constant string BUYER_LEFT              = "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedUp.blp"

        // Inventory Panel
        private constant real INVENTORY_WIDTH           = 0.23780
        private constant real INVENTORY_HEIGHT          = 0.03740
        private constant real INVENTORY_SIZE            = 0.031
        private constant real INVENTORY_GAP             = 0.04
        private constant integer INVENTORY_COUNT        = 6
        private constant string INVENTORY_TEXTURE       = "Inventory.blp"
        

        // Details window
        private constant real DETAIL_WIDTH              = 0.3125
        private constant real DETAIL_HEIGHT             = HEIGHT
        private constant integer DETAIL_USED_COUNT      = 6
        private constant real DETAIL_BUTTON_SIZE        = 0.035
        private constant real DETAIL_BUTTON_GAP         = 0.044
        private constant real DETAIL_CLOSE_BUTTON_SIZE  = 0.02
        private constant real DETAIL_SHIFT_BUTTON_SIZE  = 0.012
        private constant string USED_RIGHT              = "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedDown.blp"
        private constant string USED_LEFT               = "ReplaceableTextures\\CommandButtons\\BTNReplay-SpeedUp.blp"

        // Side Panels
        private constant real SIDE_WIDTH                = 0.075
        private constant real SIDE_HEIGHT               = HEIGHT
        private constant real EDIT_WIDTH                = 0.15
        private constant real EDIT_HEIGHT               = 0.0285

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
        private constant real SLOT_GAP_X                = 0.018
        private constant real SLOT_GAP_Y                = 0.022
        private constant string GOLD_ICON               = "UI\\Feedback\\Resources\\ResourceGold.blp"

        // Scroll
        private constant real SCROLL_DELAY              = 0.01

        // Update time
        private constant real UPDATE_PERIOD             = 0.33

        // Dont touch
        private HashTable table
    endglobals 

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function CreateShop takes integer id, real aoe returns nothing
        call Shop.create(id, aoe)
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

    function UnitHasItemOfType takes unit u, integer id returns boolean
        return Item.hasType(u, id)
    endfunction

    function UnitCountItemOfType takes unit u, integer id returns integer
        return Item.countType(u, id)
    endfunction

    function ShopFilter takes unit u, player owner, unit shop returns boolean
        return IsUnitOwnedByPlayer(u, owner) and UnitInventorySize(u) > 0 and not IsUnitType(u, UNIT_TYPE_DEAD) and not IsUnitPaused(u) and not IsUnitIllusion(u) and not IsUnitHidden(u)
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
        private static trigger trigger = CreateTrigger()
        private static player player = Player(bj_PLAYER_NEUTRAL_EXTRA)
        readonly static Table itempool
        readonly static HashTable unit

        private integer componentCount

        string name
        string icon
        string tooltip
        integer id
        integer gold
        integer categories
        Table component
        Table counter
        Table relation
        
        method destroy takes nothing returns nothing
            call component.destroy()
            call relation.destroy()
            call counter.destroy()
            call deallocate()
        endmethod

        method operator components takes nothing returns integer
            return componentCount
        endmethod

        method count takes integer id returns integer
            return counter[id]
        endmethod

        static method get takes integer id returns thistype
            return itempool[id]
        endmethod

        private static method save takes integer id, integer comp returns nothing
            local thistype this
            local thistype part
            local integer i = 0

            if comp > 0 and comp != id then
                set this = create(id, 0)
                set part = create(comp, 0)
                set component[componentCount] = comp
                set componentCount = componentCount + 1
                set counter[comp] = counter[comp] + 1

                loop
                    exitwhen part.relation[i] == id
                        if not part.relation.has(i) then
                            set part.relation[i] = id
                            exitwhen true
                        endif
                    set i = i + 1
                endloop
            endif
        endmethod

        static method addComponents takes integer id, integer a, integer b, integer c, integer d, integer e returns nothing
            local thistype this

            if id > 0 then
                set this = create(id, 0)
                set componentCount = 0

                call component.flush()
                call counter.flush()
                call save(id, a)
                call save(id, b)
                call save(id, c)
                call save(id, d)
                call save(id, e)
            endif
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

        private static method clear takes nothing returns nothing
            call RemoveItem(GetEnumItem())
        endmethod

        static method hasType takes unit u, integer id returns boolean
            return unit[GetHandleId(u)][id] > 0
        endmethod

        static method countType takes unit u, integer id returns integer
            return unit[GetHandleId(u)][id]
        endmethod

        static method create takes integer id, integer category returns thistype
            local thistype this
            local item i

            if itempool.has(id) then
                set this = itempool[id]

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
                    set componentCount = 0
                    set component = Table.create()
                    set counter = Table.create()
                    set relation = Table.create()
                    set itempool[id] = this

                    call RemoveItem(i)

                    set i = null
                    return this
                else
                    return 0
                endif
            endif
        endmethod

        private static method onPickup takes nothing returns nothing
            local integer u = GetHandleId(GetManipulatingUnit())
            local integer i = GetItemTypeId(GetManipulatedItem())

            set unit[u][i] = unit[u][i] + 1
        endmethod

        private static method onDrop takes nothing returns nothing
            local integer u = GetHandleId(GetManipulatingUnit())
            local integer i = GetItemTypeId(GetManipulatedItem())

            set unit[u][i] = unit[u][i] - 1
        endmethod

        private static method onInit takes nothing returns nothing
            set rect = Rect(0, 0, 0, 0)
            set itempool = Table.create()
            set unit = HashTable.create()
            set shop = CreateUnit(player, 'nmrk', 0, 0, 0)

            call SetRect(rect, GetUnitX(shop) - 1000, GetUnitY(shop) - 1000, GetUnitX(shop) + 1000, GetUnitY(shop) + 1000)
            call UnitAddAbility(shop, 'AInv')
            call IssueNeutralTargetOrder(player, shop, "smart", shop)
            call ShowUnit(shop, false)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, function thistype.onPickup)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, function thistype.onDrop)
        endmethod
    endstruct

    struct Slot
        private boolean isVisible
        private real xPos
        private real yPos

        readonly framehandle parent
        readonly framehandle slot
        readonly framehandle gold
        readonly framehandle cost

        Item item
        Button button

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

        method operator onClick= takes code c returns nothing
            set button.onClick = c
        endmethod

        method operator onScroll= takes code c returns nothing
            set button.onScroll = c
        endmethod

        method operator onRightClick= takes code c returns nothing
            set button.onRightClick = c
        endmethod

        method operator onDoubleClick= takes code c returns nothing
            set button.onDoubleClick = c
        endmethod

        method destroy takes nothing returns nothing
            call BlzDestroyFrame(cost)
            call BlzDestroyFrame(gold)
            call BlzDestroyFrame(slot)
            call button.destroy()
            call deallocate()

            set slot = null
            set gold = null
            set cost = null
            set parent = null
        endmethod

        static method create takes framehandle parent, Item i, real x, real y, framepointtype point, boolean simpleTooltip returns thistype
            local thistype this = thistype.allocate()

            set item = i
            set xPos = x
            set yPos = y
            set .parent = parent
            set slot = BlzCreateFrameByType("FRAME", "", parent, "", 0)
            set gold = BlzCreateFrameByType("BACKDROP", "", slot, "", 0)
            set cost = BlzCreateFrameByType("TEXT", "", gold, "", 0)
            set button = Button.create(slot, ITEM_SIZE, ITEM_SIZE, 0, 0, simpleTooltip)
            set button.tooltip.point = point
            
            call BlzFrameSetPoint(slot, FRAMEPOINT_TOPLEFT, parent, FRAMEPOINT_TOPLEFT, x, y)
            call BlzFrameSetSize(slot, SLOT_WIDTH, SLOT_HEIGHT)
            call BlzFrameSetPoint(gold, FRAMEPOINT_TOPLEFT, slot, FRAMEPOINT_TOPLEFT, 0.0000, - 0.040000)
            call BlzFrameSetSize(gold, GOLD_SIZE, GOLD_SIZE)
            call BlzFrameSetTexture(gold, GOLD_ICON, 0, true)
            call BlzFrameSetPoint(cost, FRAMEPOINT_TOPLEFT, gold, FRAMEPOINT_TOPLEFT, 0.013250, - 0.0019300)
            call BlzFrameSetSize(cost, COST_WIDTH, COST_HEIGHT)
            call BlzFrameSetEnable(cost, false)
            call BlzFrameSetScale(cost, COST_SCALE)
            call BlzFrameSetTextAlignment(cost, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)

            if item != 0 then
                set button.icon = item.icon
                set button.tooltip.text = item.tooltip
                set button.tooltip.name = item.name
                set button.tooltip.icon = item.icon
                call BlzFrameSetText(cost, "|cffFFCC00" + I2S(item.gold) + "|r")
            endif

            return this
        endmethod
    endstruct

    private struct ShopSlot extends Slot
        Shop shop
        Slot next
        Slot prev
        Slot right
        Slot left
        integer row
        integer column

        method destroy takes nothing returns nothing
            call table.remove(GetHandleId(button.frame))
            call deallocate()
        endmethod

        method move takes integer row, integer column returns nothing
            set .row = row
            set .column = column
            set x = 0.030000 + ((SLOT_WIDTH + SLOT_GAP_X) * column)
            set y = - (0.030000 + ((SLOT_HEIGHT + SLOT_GAP_Y) * row))

            call update()
        endmethod

        method update takes nothing returns nothing
            if column <= (shop.columns / 2) and row < 3 then
                set button.tooltip.point = FRAMEPOINT_TOPLEFT
            elseif column >= ((shop.columns / 2) + 1) and row < 3 then
                set button.tooltip.point = FRAMEPOINT_TOPRIGHT
            elseif column <= (shop.columns / 2) and row >= 3 then
                set button.tooltip.point = FRAMEPOINT_BOTTOMLEFT
            else
                set button.tooltip.point = FRAMEPOINT_BOTTOMRIGHT
            endif
        endmethod

        static method create takes Shop shop, Item i, integer row, integer column returns thistype
            local thistype this = thistype.allocate(shop.main, i, 0.030000 + ((SLOT_WIDTH + SLOT_GAP_X) * column), - (0.030000 + ((SLOT_HEIGHT + SLOT_GAP_Y) * row)), FRAMEPOINT_TOPLEFT, false)

            set .shop = shop
            set next = 0
            set prev = 0
            set right = 0
            set left = 0
            set .row = row
            set .column = column
            set onClick = function thistype.onClicked
            set onScroll = function thistype.onScrolled
            set onDoubleClick = function thistype.onDoubleClicked
            set onRightClick = function thistype.onRightClicked
            set table[GetHandleId(button.frame)][0] = this

            call update()

            return this
        endmethod

        static method onScrolled takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())][0]

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    call shop.scroll(BlzGetTriggerFrameValue() < 0)
                endif
            endif
        endmethod

        static method onClicked takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())][0]

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    if Shop.tag[GetPlayerId(GetTriggerPlayer())] then
                        call shop.favorites.add(item)
                    else
                        call shop.detail(item)
                    endif
                endif
            endif
        endmethod

        static method onDoubleClicked takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())][0]

            if this != 0 then
                call shop.buy(item, GetTriggerPlayer())
            endif
        endmethod

        static method onRightClicked takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())][0]

            if this != 0 then
                call shop.buy(item, GetTriggerPlayer())
            endif
        endmethod
    endstruct

    private struct Detail
        readonly static trigger trigger = CreateTrigger()

        private boolean isVisible

        Shop shop
        Item item
        Button close
        Button left
        Button right
        Slot main
        Slot center
        Slot left1
        Slot left2
        Slot right1
        Slot right2
        Item array used[DETAIL_USED_COUNT]
        Button array button[DETAIL_USED_COUNT]
        integer count
        framehandle frame
        framehandle tooltip
        framehandle topSeparator
        framehandle bottomSeparator
        framehandle usedIn
        framehandle scrollFrame
        framehandle horizontalRight
        framehandle horizontalLeft
        framehandle verticalMain
        framehandle verticalCenter
        framehandle verticalLeft1
        framehandle verticalLeft2
        framehandle verticalRight1
        framehandle verticalRight2

        method operator visible= takes boolean visibility returns nothing
            set isVisible = visibility
            call BlzFrameSetVisible(frame, visibility)
        endmethod

        method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method destroy takes nothing returns nothing
            local integer i = 0

            loop
                exitwhen i == DETAIL_USED_COUNT
                    call button[i].destroy()
                set i = i + 1
            endloop

            call main.destroy()
            call center.destroy()
            call left1.destroy()
            call left2.destroy()
            call right1.destroy()
            call right2.destroy()
            call BlzDestroyFrame(topSeparator)
            call BlzDestroyFrame(bottomSeparator)
            call BlzDestroyFrame(usedIn)
            call BlzDestroyFrame(scrollFrame)
            call BlzDestroyFrame(horizontalRight)
            call BlzDestroyFrame(horizontalLeft)
            call BlzDestroyFrame(verticalMain)
            call BlzDestroyFrame(verticalCenter)
            call BlzDestroyFrame(verticalLeft1)
            call BlzDestroyFrame(verticalLeft2)
            call BlzDestroyFrame(verticalRight1)
            call BlzDestroyFrame(verticalRight2)
            call BlzDestroyFrame(tooltip)
            call BlzDestroyFrame(frame)
            call deallocate()

            set frame = null
            set tooltip = null
            set topSeparator = null
            set bottomSeparator = null
            set usedIn = null
            set scrollFrame = null
            set horizontalRight = null
            set horizontalLeft = null
            set verticalMain = null
            set verticalCenter = null
            set verticalLeft1 = null
            set verticalLeft2 = null
            set verticalRight1 = null
            set verticalRight2 = null
        endmethod

        method update takes framehandle frame, framepointtype point, framehandle parent, framepointtype relative, real width, real height, real x, real y, boolean visible returns nothing
            if visible then
                call BlzFrameClearAllPoints(frame)
                call BlzFrameSetPoint(frame, point, parent, relative, x, y)
                call BlzFrameSetSize(frame, width, height)
            endif

            call BlzFrameSetVisible(frame, visible)
        endmethod

        method shift takes boolean left returns nothing
            local Item i
            local integer j

            if left then
                if item.relation.has(count) and count >= DETAIL_USED_COUNT then
                    set j = 0

                    loop
                        exitwhen j == DETAIL_USED_COUNT - 1
                            set used[j] = used[j + 1]
                            set button[j].icon = used[j].icon
                            set button[j].tooltip.text = used[j].tooltip
                            set button[j].tooltip.name = used[j].name
                            set button[j].tooltip.icon = used[j].icon
                            set button[j].visible = true
                            set button[j].available = shop.has(used[j].id)
                            // set button[j].checked = true
                        set j = j + 1
                    endloop

                    set i = item.get(item.relation[count])

                    if i != 0 then
                        set count = count + 1
                        set used[j] = i
                        set button[j].icon = used[j].icon
                        set button[j].tooltip.text = used[j].tooltip
                        set button[j].tooltip.name = used[j].name
                        set button[j].tooltip.icon = used[j].icon
                        set button[j].visible = true
                        set button[j].available = shop.has(used[j].id)
                        // set button[j].checked = true
                    endif
                endif
            else
                if count > DETAIL_USED_COUNT then
                    set j = DETAIL_USED_COUNT - 1

                    loop
                        exitwhen j == 0
                            set used[j] = used[j - 1]
                            set button[j].icon = used[j].icon
                            set button[j].tooltip.text = used[j].tooltip
                            set button[j].tooltip.name = used[j].name
                            set button[j].tooltip.icon = used[j].icon
                            set button[j].visible = true
                            set button[j].available = shop.has(used[j].id)
                            // set button[j].checked = true
                        set j = j - 1
                    endloop
                    
                    set i = item.get(item.relation[count - DETAIL_USED_COUNT - 1])

                    if i != 0 then
                        set count = count - 1
                        set used[j] = i
                        set button[j].icon = used[j].icon
                        set button[j].tooltip.text = used[j].tooltip
                        set button[j].tooltip.name = used[j].name
                        set button[j].tooltip.icon = used[j].icon
                        set button[j].visible = true
                        set button[j].available = shop.has(used[j].id)
                        // set button[j].checked = true
                    endif
                endif
            endif
        endmethod

        method showUsed takes nothing returns nothing
            local Item i
            local integer j = 0
            
            loop
                exitwhen j == DETAIL_USED_COUNT
                    set button[j].visible = false
                set j = j + 1
            endloop

            set j = 0

            loop
                exitwhen not item.relation.has(j) or j == DETAIL_USED_COUNT
                    set i = item.get(item.relation[j])

                    if i != 0 then
                        set used[j] = i
                        set button[count].icon = i.icon
                        set button[count].tooltip.text = i.tooltip
                        set button[count].tooltip.name = i.name
                        set button[count].tooltip.icon = i.icon
                        set button[count].visible = true
                        set button[count].available = shop.has(i.id)
                        set count = count + 1
                    endif
                set j = j + 1
            endloop
        endmethod

        method refresh takes nothing returns nothing
            if isVisible and item != 0 then
                call show(item)
            endif
        endmethod

        method show takes Item i returns nothing
            local Item component
            local Slot slot
            local integer j = 0
            local integer k = 0
            local integer cost
            local integer id = GetPlayerId(GetLocalPlayer())
            local Table counter = Table.create()

            if i != 0 then
                set item = i
                set count = 0
                set cost = item.gold
                set main.item = item

                call showUsed()
                
                if item.components > 0 then
                    loop
                        exitwhen j == item.components or k == 5
                            set component = item.get(item.component[j])
                            
                            if component != 0 then
                                if item.components == 1 then
                                    set slot = center
                                    set left1.visible = false
                                    set left2.visible = false
                                    set right1.visible = false
                                    set right2.visible = false

                                    call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.13625, - 0.10200, true)
                                    call update(verticalMain, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.15600, - 0.082500, true)
                                    call update(verticalCenter, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.15600, - 0.092500, true)
                                    call BlzFrameSetVisible(horizontalLeft, false)
                                    call BlzFrameSetVisible(horizontalRight, false)
                                    call BlzFrameSetVisible(verticalLeft1, false)
                                    call BlzFrameSetVisible(verticalLeft2, false)
                                    call BlzFrameSetVisible(verticalRight1, false)
                                    call BlzFrameSetVisible(verticalRight2, false)
                                elseif item.components == 2 then
                                    if j == 0 then
                                        set slot = left1
                                        set center.visible = false
                                        set left2.visible = false
                                        set right2.visible = false

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.087250, - 0.10200, true)
                                        call update(verticalMain, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.15600, - 0.082500, true)
                                        call update(horizontalLeft, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.048, 0.001, 0.10700, - 0.091500, true)
                                        call update(verticalLeft1, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.10700, - 0.092500, true)
                                        call BlzFrameSetVisible(verticalCenter, false)
                                        call BlzFrameSetVisible(verticalLeft2, false)
                                    else
                                        set slot = right1

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.18525, - 0.10200, true)
                                        call update(horizontalRight, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.048, 0.001, 0.15700, - 0.091500, true)
                                        call update(verticalRight1, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.20500, - 0.092500, true)
                                        call BlzFrameSetVisible(verticalRight2, false)
                                    endif
                                elseif item.components == 3 then
                                    if j == 0 then
                                        set slot = left2
                                        set left1.visible = false
                                        set right1.visible = false

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.038250, - 0.10200, true)
                                        call update(verticalMain, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.15600, - 0.082500, true)
                                        call update(horizontalLeft, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.1, 0.001, 0.057000, - 0.091500, true)
                                        call update(verticalLeft2, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.057000, - 0.092500, true)
                                        call BlzFrameSetVisible(verticalLeft1, false)
                                    elseif j == 1 then
                                        set slot = center

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.13625, - 0.10200, true)
                                        call update(verticalCenter, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.15600, - 0.092500, true)
                                    else
                                        set slot = right2

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.23425, - 0.10200, true)
                                        call update(horizontalRight, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.1, 0.001, 0.15700, - 0.091500, true)
                                        call update(verticalRight2, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.25600, - 0.092500, true)
                                        call BlzFrameSetVisible(verticalRight1, false)
                                    endif
                                elseif item.components == 4 then
                                    if j == 0 then
                                        set slot = left2
                                        set right2.visible = false

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.038250, - 0.10200, true)
                                        call update(verticalMain, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.15600, - 0.082500, true)
                                        call update(horizontalLeft, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.1, 0.001, 0.057000, - 0.091500, true)
                                        call update(verticalLeft2, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.057000, - 0.092500, true)
                                    elseif j == 1 then
                                        set slot = left1

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.10350, - 0.10200, true)
                                        call update(verticalLeft1, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.12250, - 0.092500, true)
                                    elseif j == 2 then
                                        set slot = center

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.16875, - 0.10200, true)
                                        call update(verticalRight1, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.18950, - 0.092500, true)
                                        call BlzFrameSetVisible(verticalCenter, false)
                                    else
                                        set slot = right1

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.23400, - 0.10200, true)
                                        call update(horizontalRight, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.1, 0.001, 0.15700, - 0.091500, true)
                                        call update(verticalRight2, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.25600, - 0.092500, true)
                                    endif
                                else
                                    if j == 0 then
                                        set slot = left2

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.038250, - 0.10200, true)
                                        call update(verticalMain, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.15600, - 0.082500, true)
                                        call update(horizontalLeft, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.1, 0.001, 0.057000, - 0.091500, true)
                                        call update(verticalLeft2, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.057000, - 0.092500, true)
                                    elseif j == 1 then
                                        set slot = left1

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.087250, - 0.10200, true)
                                        call update(verticalLeft1, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.10700, - 0.092500, true)
                                    elseif j == 2 then
                                        set slot = center

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.13625, - 0.10200, true)
                                        call update(verticalCenter, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.15600, - 0.092500, true)
                                    elseif j == 3 then
                                        set slot = right1

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.18525, - 0.10200, true)
                                        call update(verticalRight1, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.20500, - 0.092500, true)
                                    else
                                        set slot = right2

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.23425, - 0.10200, true)
                                        call update(horizontalRight, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.1, 0.001, 0.15700, - 0.091500, true)
                                        call update(verticalRight2, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.25600, - 0.092500, true)
                                    endif
                                endif

                                set slot.item = component
                                set slot.button.icon = component.icon
                                set slot.button.tooltip.text = component.tooltip
                                set slot.button.tooltip.name = component.name
                                set slot.button.tooltip.icon = component.icon
                                set slot.button.available = shop.has(component.id)
                                call BlzFrameSetText(slot.cost, "|cffFFCC00" + I2S(component.gold) + "|r")
                                
                                if shop.buyer.selected.unit[id] != null then
                                    if UnitHasItemOfType(shop.buyer.selected.unit[id], component.id) then
                                        if UnitCountItemOfType(shop.buyer.selected.unit[id], component.id) >= item.count(component.id) then
                                            set slot.button.checked = true
                                        else
                                            set counter[component.id] = counter[component.id] + 1
                                            set slot.button.checked = counter[component.id] <= UnitCountItemOfType(shop.buyer.selected.unit[id], component.id)
                                        endif
                                    else
                                        set slot.button.checked = false
                                    endif
                                else
                                    set slot.button.checked = false
                                endif

                                if slot.button.checked then
                                    set cost = cost - component.gold
                                endif

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

                    call BlzFrameSetVisible(horizontalLeft, false)
                    call BlzFrameSetVisible(horizontalRight, false)
                    call BlzFrameSetVisible(verticalMain, false)
                    call BlzFrameSetVisible(verticalCenter, false)
                    call BlzFrameSetVisible(verticalLeft1, false)
                    call BlzFrameSetVisible(verticalLeft2, false)
                    call BlzFrameSetVisible(verticalRight1, false)
                    call BlzFrameSetVisible(verticalRight2, false)
                endif

                set main.button.icon = item.icon
                set main.button.tooltip.text = item.tooltip
                set main.button.tooltip.name = item.name
                set main.button.tooltip.icon = item.icon
                set main.button.available = shop.has(item.id)

                call BlzFrameSetText(main.cost, "|cffFFCC00" + I2S(cost) + "|r")
                call BlzFrameSetText(tooltip, item.tooltip)

                set visible = true
            endif

            call counter.destroy()
        endmethod

        static method create takes Shop shop returns thistype
            local thistype this = thistype.allocate()
            local integer i = 0

            set .shop = shop
            set count = 0
            set isVisible = false
            set frame = BlzCreateFrame("EscMenuBackdrop", shop.main, 0, 0)
            set topSeparator = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set bottomSeparator = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set tooltip = BlzCreateFrame("DescriptionArea", frame, 0, 0)
            set horizontalLeft = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set horizontalRight = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set verticalMain = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set verticalCenter = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set verticalLeft1 = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set verticalLeft2 = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set verticalRight1 = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set verticalRight2 = BlzCreateFrameByType("BACKDROP", "", frame, "", 0)
            set scrollFrame = BlzCreateFrameByType("BUTTON", "", frame, "", 0)
            set usedIn = BlzCreateFrameByType("TEXT", "", scrollFrame, "", 0)
            set close = Button.create(frame, DETAIL_CLOSE_BUTTON_SIZE, DETAIL_CLOSE_BUTTON_SIZE, 0.26676, - 0.025000, true)
            set close.icon = CLOSE_ICON
            set close.onClick = function thistype.onClick
            set close.tooltip.text = "Close"
            set left = Button.create(scrollFrame, DETAIL_SHIFT_BUTTON_SIZE, DETAIL_SHIFT_BUTTON_SIZE, 0.0050000, - 0.0025000, true)
            set left.icon = USED_LEFT
            set left.onClick = function thistype.onClick
            set left.tooltip.text = "Scroll Left"
            set right = Button.create(scrollFrame, DETAIL_SHIFT_BUTTON_SIZE, DETAIL_SHIFT_BUTTON_SIZE, 0.24800, - 0.0025000, true)
            set right.icon = USED_RIGHT
            set right.onClick = function thistype.onClick
            set right.tooltip.text = "Scroll Right"
            set main = Slot.create(frame, 0, 0.13625, - 0.030000, FRAMEPOINT_TOPRIGHT, false)
            set main.onRightClick = function thistype.onRightClick
            set main.onDoubleClick = function thistype.onDoubleClick
            set center = Slot.create(frame, 0, 0.13625, - 0.10200, FRAMEPOINT_TOPRIGHT, false)
            set center.visible = false
            set center.onClick = function thistype.onClick
            set center.onRightClick = function thistype.onRightClick
            set center.onDoubleClick = function thistype.onDoubleClick
            set left1 = Slot.create(frame, 0, 0.087250, - 0.10200, FRAMEPOINT_TOPRIGHT, false)
            set left1.visible = false
            set left1.onClick = function thistype.onClick
            set left1.onRightClick = function thistype.onRightClick
            set left1.onDoubleClick = function thistype.onDoubleClick
            set left2 = Slot.create(frame, 0, 0.038250, - 0.10200, FRAMEPOINT_TOPRIGHT, false)
            set left2.visible = false
            set left2.onClick = function thistype.onClick
            set left2.onRightClick = function thistype.onRightClick
            set left2.onDoubleClick = function thistype.onDoubleClick
            set right1 = Slot.create(frame, 0, 0.18525, - 0.10200, FRAMEPOINT_TOPRIGHT, false)
            set right1.visible = false
            set right1.onClick = function thistype.onClick
            set right1.onRightClick = function thistype.onRightClick
            set right1.onDoubleClick = function thistype.onDoubleClick
            set right2 = Slot.create(frame, 0, 0.23425, - 0.10200, FRAMEPOINT_TOPRIGHT, false)
            set right2.visible = false
            set right2.onClick = function thistype.onClick
            set right2.onRightClick = function thistype.onRightClick
            set right2.onDoubleClick = function thistype.onDoubleClick
            set table[GetHandleId(close.frame)][0] = this
            set table[GetHandleId(left.frame)][0] = this
            set table[GetHandleId(right.frame)][0] = this
            set table[GetHandleId(scrollFrame)][0] = this
            set table[GetHandleId(main.button.frame)][0] = this
            set table[GetHandleId(center.button.frame)][0] = this
            set table[GetHandleId(left1.button.frame)][0] = this
            set table[GetHandleId(left2.button.frame)][0] = this
            set table[GetHandleId(right1.button.frame)][0] = this
            set table[GetHandleId(right2.button.frame)][0] = this

            call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, shop.main, FRAMEPOINT_TOPLEFT, WIDTH - DETAIL_WIDTH, 0.0000)
            call BlzFrameSetPoint(scrollFrame, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.022500, - 0.31550)
            call BlzFrameSetPoint(topSeparator, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.027500, - 0.15585)
            call BlzFrameSetPoint(bottomSeparator, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.027500, - 0.31585)
            call BlzFrameSetPoint(usedIn, FRAMEPOINT_TOPLEFT, scrollFrame, FRAMEPOINT_TOPLEFT, 0.11500, - 0.0025000)
            call BlzFrameSetPoint(tooltip, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.027500, - 0.15950)
            call BlzFrameSetSize(frame, DETAIL_WIDTH, DETAIL_HEIGHT)
            call BlzFrameSetSize(scrollFrame, 0.26750, 0.06100)
            call BlzFrameSetSize(topSeparator, 0.255, 0.001)
            call BlzFrameSetSize(bottomSeparator, 0.255, 0.001)
            call BlzFrameSetSize(usedIn, 0.04, 0.012)
            call BlzFrameSetSize(tooltip, 0.31, 0.16)
            call BlzFrameSetText(tooltip, "")
            call BlzFrameSetText(usedIn, "|cffFFCC00 Used in|r")
            call BlzFrameSetEnable(usedIn, false)
            call BlzFrameSetScale(usedIn, 1.00)
            call BlzFrameSetTextAlignment(usedIn, TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
            call BlzFrameSetTexture(bottomSeparator, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)
            call BlzFrameSetTexture(topSeparator, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)
            call BlzFrameSetTexture(horizontalLeft, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)
            call BlzFrameSetTexture(horizontalRight, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)
            call BlzFrameSetTexture(verticalMain, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)
            call BlzFrameSetTexture(verticalCenter, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)
            call BlzFrameSetTexture(verticalLeft1, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)
            call BlzFrameSetTexture(verticalLeft2, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)
            call BlzFrameSetTexture(verticalRight1, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)
            call BlzFrameSetTexture(verticalRight2, "replaceabletextures\\teamcolor\\teamcolor08", 0, true)
            call BlzTriggerRegisterFrameEvent(trigger, scrollFrame, FRAMEEVENT_MOUSE_WHEEL)

            loop
                exitwhen i == DETAIL_USED_COUNT
                    set button[i] = Button.create(scrollFrame, DETAIL_BUTTON_SIZE, DETAIL_BUTTON_SIZE, 0.0050000 + DETAIL_BUTTON_GAP*i, - 0.019500, false)
                    set button[i].onClick = function thistype.onClick
                    set button[i].onScroll = function thistype.onScroll
                    set button[i].onRightClick = function thistype.onRightClick
                    //set button[i].onDoubleClick = function thistype.onDoubleClick
                    set button[i].tooltip.point = FRAMEPOINT_BOTTOMRIGHT
                    set button[i].visible = true
                    set table[GetHandleId(button[i].frame)][0] = this
                    set table[GetHandleId(button[i].frame)][1] = i
                set i = i + 1
            endloop

            call BlzFrameSetVisible(frame, false)

            return this
        endmethod

        static method onScroll takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())][0]

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    call shift(BlzGetTriggerFrameValue() < 0)
                endif
            endif
        endmethod

        static method onClick takes nothing returns nothing
            local framehandle frame = BlzGetTriggerFrame()
            local thistype this = table[GetHandleId(frame)][0]
            local integer i = table[GetHandleId(frame)][1]

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    if frame == close.frame then
                        call shop.detail(0)
                    elseif frame == left.frame then
                        call shift(false)
                    elseif frame == right.frame then
                        call shift(true)
                    elseif frame == center.button.frame then
                        if Shop.tag[GetPlayerId(GetTriggerPlayer())] then
                            call shop.favorites.add(center.item)
                        else
                            call shop.detail(center.item)
                        endif
                    elseif frame == left1.button.frame then
                        if Shop.tag[GetPlayerId(GetTriggerPlayer())] then
                            call shop.favorites.add(left1.item)
                        else
                            call shop.detail(left1.item)
                        endif
                    elseif frame == left2.button.frame then
                        if Shop.tag[GetPlayerId(GetTriggerPlayer())] then
                            call shop.favorites.add(left2.item)
                        else
                            call shop.detail(left2.item)
                        endif
                    elseif frame == right1.button.frame then
                        if Shop.tag[GetPlayerId(GetTriggerPlayer())] then
                            call shop.favorites.add(right1.item)
                        else
                            call shop.detail(right1.item)
                        endif
                    elseif frame == right2.button.frame then
                        if Shop.tag[GetPlayerId(GetTriggerPlayer())] then
                            call shop.favorites.add(right2.item)
                        else
                            call shop.detail(right2.item)
                        endif
                    elseif frame != main.button.frame then
                        if Shop.tag[GetPlayerId(GetTriggerPlayer())] then
                            call shop.favorites.add(used[i])
                        else
                            call shop.detail(used[i])
                        endif
                    elseif frame == main.button.frame then
                        if Shop.tag[GetPlayerId(GetTriggerPlayer())] then
                            call shop.favorites.add(main.item)
                        endif
                    endif 
                endif
            endif

            set frame = null
        endmethod

        static method onRightClick takes nothing returns nothing
            local framehandle frame = BlzGetTriggerFrame()
            local thistype this = table[GetHandleId(frame)][0]
            local integer i = table[GetHandleId(frame)][1]

            if this != 0 then
                if frame == main.button.frame then
                    call shop.buy(main.item, GetTriggerPlayer())
                elseif frame == center.button.frame then
                    call shop.buy(center.item, GetTriggerPlayer())
                elseif frame == left1.button.frame then
                    call shop.buy(left1.item, GetTriggerPlayer())
                elseif frame == left2.button.frame then
                    call shop.buy(left2.item, GetTriggerPlayer())
                elseif frame == right1.button.frame then
                    call shop.buy(right1.item, GetTriggerPlayer())
                elseif frame == right2.button.frame then
                    call shop.buy(right2.item, GetTriggerPlayer())
                else
                    call shop.buy(used[i], GetTriggerPlayer())
                endif
            endif

            set frame = null
        endmethod

        static method onDoubleClick takes nothing returns nothing
            local framehandle frame = BlzGetTriggerFrame()
            local thistype this = table[GetHandleId(frame)][0]
            local integer i = table[GetHandleId(frame)][1]

            if this != 0 then
                if frame == main.button.frame then
                    call shop.buy(main.item, GetTriggerPlayer())
                elseif frame == center.button.frame then
                    call shop.buy(center.item, GetTriggerPlayer())
                elseif frame == left1.button.frame then
                    call shop.buy(left1.item, GetTriggerPlayer())
                elseif frame == left2.button.frame then
                    call shop.buy(left2.item, GetTriggerPlayer())
                elseif frame == right1.button.frame then
                    call shop.buy(right1.item, GetTriggerPlayer())
                elseif frame == right2.button.frame then
                    call shop.buy(right2.item, GetTriggerPlayer())
                else
                    call shop.buy(used[i], GetTriggerPlayer())
                endif
            endif

            set frame = null
        endmethod

        static method onInit takes nothing returns nothing
            call TriggerAddAction(trigger, function thistype.onScroll)
        endmethod
    endstruct

    private struct Inventory
        private boolean isVisible

        Shop shop
        framehandle frame
        framehandle scrollFrame
        Item array item[INVENTORY_COUNT]
        Button array button[INVENTORY_COUNT]

        method operator visible= takes boolean visibility returns nothing
            set isVisible = visibility
            call BlzFrameSetVisible(frame, visibility)
        endmethod

        method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method destroy takes nothing returns nothing
            local integer i = 0

            loop
                exitwhen i == INVENTORY_COUNT
                    call table.remove(GetHandleId(button[i].frame))
                    call button[i].destroy()
                set i = i + 1
            endloop

            call BlzDestroyFrame(frame)
            call BlzDestroyFrame(scrollFrame)
            call deallocate()

            set frame = null
            set scrollFrame = null
        endmethod

        method move takes framepointtype point, framehandle relative, framepointtype relativePoint returns nothing
            call BlzFrameClearAllPoints(frame)
            call BlzFrameSetPoint(frame, point, relative, relativePoint, 0, 0)
        endmethod

        method show takes unit u returns nothing
            local item i
            local integer j = 0

            if u != null then
                loop
                    exitwhen j == INVENTORY_COUNT
                        set i = UnitItemInSlot(u, j)

                        if i != null then
                            set item[j] = Item.get(GetItemTypeId(i))
                            set button[j].icon = item[j].icon
                            set button[j].tooltip.icon = item[j].icon
                            set button[j].tooltip.name = item[j].name
                            set button[j].tooltip.text = item[j].tooltip
                            set button[j].visible = true
                        else
                            set button[j].visible = false
                        endif
                    set j = j + 1
                endloop
            else
                loop
                    exitwhen j == INVENTORY_COUNT
                        set item[j] = 0
                        set button[j].visible = false
                    set j = j + 1
                endloop
            endif

            set i = null
        endmethod

        static method create takes Shop shop returns thistype
            local thistype this = thistype.allocate()
            local integer i = 0

            set .shop = shop
            set isVisible = true
            set frame = BlzCreateFrameByType("BACKDROP", "", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
            set scrollFrame = BlzCreateFrameByType("BUTTON", "", frame, "", 0)

            call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, shop.buyer.frame, FRAMEPOINT_TOPLEFT, 0, 0)
            call BlzFrameSetSize(frame, INVENTORY_WIDTH, INVENTORY_HEIGHT)
            call BlzFrameSetTexture(frame, INVENTORY_TEXTURE, 0, false)
            call BlzFrameSetAllPoints(scrollFrame, frame)

            loop
                exitwhen i == INVENTORY_COUNT
                    set button[i] = Button.create(scrollFrame, INVENTORY_SIZE, INVENTORY_SIZE, 0.0033700 + INVENTORY_GAP*i, - 0.0037500, false)
                    set button[i].tooltip.point = FRAMEPOINT_BOTTOM
                    set button[i].onDoubleClick = function thistype.onDoubleClick
                    set button[i].onRightClick = function thistype.onRightClick
                    set button[i].visible = false
                    set table[GetHandleId(button[i].frame)][0] = this
                    set table[GetHandleId(button[i].frame)][1] = i
                set i = i + 1
            endloop

            return this
        endmethod

        static method onDoubleClick takes nothing returns nothing
            local framehandle frame = BlzGetTriggerFrame()
            local thistype this = table[GetHandleId(frame)][0]
            local integer i = table[GetHandleId(frame)][1]

            if this != 0 then
                call shop.sell(item[i], GetTriggerPlayer())
            endif

            set frame = null
        endmethod

        static method onRightClick takes nothing returns nothing
            local framehandle frame = BlzGetTriggerFrame()
            local thistype this = table[GetHandleId(frame)][0]
            local integer i = table[GetHandleId(frame)][1]

            if this != 0 then
                call shop.sell(item[i], GetTriggerPlayer())
            endif

            set frame = null
        endmethod
    endstruct

    private struct Buyer
        private static Table current
        readonly static trigger trigger = CreateTrigger()

        private boolean isVisible

        Shop shop
        Inventory inventory
        framehandle frame
        framehandle scrollFrame
        Button left
        Button right
        Table last
        Table index
        Table size
        Table selected
        HashTable button
        HashTable unit

        method operator visible= takes boolean visibility returns nothing
            local integer i = 0
            local integer id = GetPlayerId(GetLocalPlayer())
            local Button b

            set isVisible = visibility
            set inventory.visible = visibility

            if isVisible then
                loop
                    exitwhen i == BUYER_COUNT
                        if unit[id].unit[i] == selected.unit[id] then
                            set b = button[id][i]
                            call inventory.move(FRAMEPOINT_TOP, b.frame, FRAMEPOINT_BOTTOM)
                            call inventory.show(selected.unit[id])
                            exitwhen true
                        endif
                    set i = i + 1
                endloop
            endif

            call BlzFrameSetVisible(frame, visibility)
        endmethod

        method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method destroy takes nothing returns nothing
            local integer i = 0
            local integer j
            local Button b

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    set j = 0

                    loop
                        exitwhen j == BUYER_COUNT
                            set b = button[i][j]
                            call table.remove(GetHandleId(b.frame))
                            call b.destroy()
                        set j = j + 1
                    endloop

                    call button.remove(i)
                    call unit.remove(i)
                set i = i + 1
            endloop

            call BlzDestroyFrame(frame)
            call BlzDestroyFrame(scrollFrame)
            call last.destroy()
            call index.destroy()
            call size.destroy()
            call selected.destroy()
            call left.destroy()
            call right.destroy()
            call inventory.destroy()
            call deallocate()

            set frame = null
            set scrollFrame = null
        endmethod

        method shift takes boolean left, player p returns nothing
            local integer i
            local unit u
            local Button b
            local Button c
            local boolean flag = false
            local integer id = GetPlayerId(p)

            if left then
                if (index[id] + 1 + BUYER_COUNT) <= size[id] and size[id] > 0 then
                    set index[id] = index[id] + 1
                    set i = 0

                    loop
                        exitwhen i == BUYER_COUNT - 1
                            set unit[id].unit[i] = unit[id].unit[i + 1]

                            if GetLocalPlayer() == p then
                                set b = button[id][i]
                                set c = button[id][i + 1]
                                set b.icon = c.icon
                                set b.tooltip.text = c.tooltip.text
                                set b.visible = true
                                set b.highlighted = selected.unit[id] == unit[id].unit[i]

                                if b.highlighted then
                                    set flag = true
                                    call inventory.move(FRAMEPOINT_TOP, b.frame, FRAMEPOINT_BOTTOM)
                                endif
                            endif
                        set i = i + 1
                    endloop

                    set u = BlzGroupUnitAt(shop.group[id], index[id] + BUYER_COUNT)

                    if u != null then
                        set unit[id].unit[i] = u

                        if GetLocalPlayer() == p then
                            set b = button[id][i]
                            set b.icon = BlzGetAbilityIcon(GetUnitTypeId(u))
                            set b.tooltip.text = GetUnitName(u)
                            set b.visible = true
                            set b.highlighted = selected.unit[id] == unit[id].unit[i]

                            if b.highlighted then
                                set flag = true
                                call inventory.move(FRAMEPOINT_TOP, b.frame, FRAMEPOINT_BOTTOM)
                            endif
                        endif
                    endif

                    if GetLocalPlayer() == p then
                        set inventory.visible = flag
                    endif
                endif
            else
                if index[id] - 1 >= 0 and size[id] > 0 then
                    set index[id] = index[id] - 1
                    set i = BUYER_COUNT - 1

                    loop
                        exitwhen i == 0
                            set unit[id].unit[i] = unit[id].unit[i - 1]

                            if GetLocalPlayer() == p then
                                set b = button[id][i]
                                set c = button[id][i - 1]
                                set b.icon = c.icon
                                set b.tooltip.text = c.tooltip.text
                                set b.visible = true
                                set b.highlighted = selected.unit[id] == unit[id].unit[i]

                                if b.highlighted then
                                    set flag = true
                                    call inventory.move(FRAMEPOINT_TOP, b.frame, FRAMEPOINT_BOTTOM)
                                endif
                            endif
                        set i = i - 1
                    endloop
                    
                    set u = BlzGroupUnitAt(shop.group[id], index[id])

                    if u != null then
                        set unit[id].unit[i] = u

                        if GetLocalPlayer() == p then
                            set b = button[id][i]
                            set b.icon = BlzGetAbilityIcon(GetUnitTypeId(u))
                            set b.tooltip.text = GetUnitName(u)
                            set b.visible = true
                            set b.highlighted = selected.unit[id] == unit[id].unit[i]

                            if b.highlighted then
                                set flag = true
                                call inventory.move(FRAMEPOINT_TOP, b.frame, FRAMEPOINT_BOTTOM)
                            endif
                        endif
                    endif

                    if GetLocalPlayer() == p then
                        set inventory.visible = flag
                    endif
                endif
            endif
        endmethod

        method update takes group g, integer id returns nothing
            local integer i = 0
            local integer j
            local unit u
            local Button b
            
            set size[id] = BlzGroupGetSize(g)

            if size[id] > 0 then
                if (index.integer[id] + BUYER_COUNT) > size.integer[id] then
                    set index[id] = 0
                endif

                if not IsUnitInGroup(selected.unit[id], g) then
                    set index[id] = 0
                    call current.remove(GetHandleId(selected.unit[id]))
                    set selected.unit[id] = FirstOfGroup(g)
                    set current[GetHandleId(selected.unit[id])] = this

                    if GetLocalPlayer() == Player(id) then
                        set b = button[id][0]
                        call inventory.move(FRAMEPOINT_TOP, b.frame, FRAMEPOINT_BOTTOM)
                        call inventory.show(selected.unit[id])
                        call shop.details.refresh()
                    endif
                endif
                
                set j = index[id]

                loop
                    exitwhen i == BUYER_COUNT
                        if j >= size[id] then
                            set unit[id].unit[i] = null

                            if GetLocalPlayer() == Player(id) then
                                set b = button[id][i]
                                set b.visible = false
                            endif
                        else
                            set u = BlzGroupUnitAt(g, j)
                            set unit[id].unit[i] = u

                            if selected.unit[id] == u then
                                set last[id] = button[id][i]
                            endif

                            if GetLocalPlayer() == Player(id) then
                                set b = button[id][i]
                                set b.icon = BlzGetAbilityIcon(GetUnitTypeId(u))
                                set b.tooltip.text = GetUnitName(u)
                                set b.highlighted = selected.unit[id] == u
                                set b.visible = true

                                if b.highlighted then
                                    set inventory.visible = true
                                    call inventory.move(FRAMEPOINT_TOP, b.frame, FRAMEPOINT_BOTTOM)
                                endif
                            endif

                            set j = j + 1
                        endif
                    set i = i + 1
                endloop
            else
                call current.remove(GetHandleId(selected.unit[id]))

                set index[id] = 0
                set selected.unit[id] = null

                if GetLocalPlayer() == Player(id) then
                    set inventory.visible = false

                    loop
                        exitwhen i == BUYER_COUNT
                            set b = button[id][i]
                            set unit[id].unit[i] = null
                            set b.highlighted = false
                            set b.visible = false
                        set i = i + 1
                    endloop

                    call shop.details.refresh()
                endif
            endif
        endmethod

        static method create takes Shop shop returns thistype
            local thistype this = thistype.allocate()
            local integer i = 0
            local integer j = 0
            local Button b

            set .shop = shop
            set isVisible = true
            set last = Table.create()
            set size = Table.create()
            set index = Table.create()
            set selected = Table.create()
            set button = HashTable.create()
            set unit = HashTable.create()
            set frame = BlzCreateFrame("EscMenuBackdrop", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), 0, 0)
            set scrollFrame = BlzCreateFrameByType("BUTTON", "", frame, "", 0)
            set left = Button.create(scrollFrame, BUYER_SHIFT_BUTTON_SIZE, BUYER_SHIFT_BUTTON_SIZE, 0.027500, - 0.032500, true)
            set left.onClick = function thistype.onClick
            set left.icon = BUYER_LEFT
            set left.tooltip.text = "Scroll Left"
            set right = Button.create(scrollFrame, BUYER_SHIFT_BUTTON_SIZE, BUYER_SHIFT_BUTTON_SIZE, 0.36350, - 0.032500, true)
            set right.onClick = function thistype.onClick
            set right.icon = BUYER_RIGHT
            set right.tooltip.text = "Scroll Right"
            set inventory = Inventory.create(shop)
            set table[GetHandleId(left.frame)][0] = this
            set table[GetHandleId(right.frame)][0] = this
            set table[GetHandleId(scrollFrame)][0] = this

            call BlzFrameSetPoint(frame, FRAMEPOINT_TOP, shop.base, FRAMEPOINT_BOTTOM, 0, 0.02750)
            call BlzFrameSetSize(frame, BUYER_WIDTH, BUYER_HEIGHT)
            call BlzFrameSetAllPoints(scrollFrame, frame)
            call BlzTriggerRegisterFrameEvent(trigger, scrollFrame, FRAMEEVENT_MOUSE_WHEEL)

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    set j = 0

                    loop
                        exitwhen j == BUYER_COUNT
                            set b = Button.create(scrollFrame, BUYER_SIZE, BUYER_SIZE, 0.045000 + BUYER_GAP*j, - 0.023000, true)
                            set b.onClick = function thistype.onClick
                            set b.onScroll = function thistype.onScroll
                            set b.visible = false
                            set table[GetHandleId(b.frame)][0] = this
                            set table[GetHandleId(b.frame)][1] = j
                            set button[i][j] = b
                        set j = j + 1
                    endloop
                set i = i + 1
            endloop

            return this
        endmethod

        static method onScroll takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())][0]

            if this != 0 then
                call shift(BlzGetTriggerFrameValue() < 0, GetTriggerPlayer())
            endif
        endmethod

        static method onClick takes nothing returns nothing
            local framehandle frame = BlzGetTriggerFrame()
            local thistype this = table[GetHandleId(frame)][0]
            local integer i = table[GetHandleId(frame)][1]
            local integer id = GetPlayerId(GetTriggerPlayer())
            local Button b

            if this != 0 then
                if frame == left.frame then
                    call shift(false, GetTriggerPlayer())
                elseif frame == right.frame then
                    call shift(true, GetTriggerPlayer())
                else
                    call current.remove(GetHandleId(selected.unit[id]))
                    set selected.unit[id] = unit[id].unit[i]
                    set current[GetHandleId(selected.unit[id])] = this

                    if GetLocalPlayer() == GetTriggerPlayer() then
                        set b = last[id]
                        set b.highlighted = false
                        set b = button[id][i]
                        set b.highlighted = true
                        set last[id] = button[id][i]
                        
                        call inventory.move(FRAMEPOINT_TOP, b.frame, FRAMEPOINT_BOTTOM)
                        call inventory.show(selected.unit[id])
                        call shop.details.refresh()
                    endif
                endif 

                call BlzFrameSetEnable(frame, false)
                call BlzFrameSetEnable(frame, true)
                call BJDebugMsg(GetUnitName(selected.unit[id]))
            endif

            set frame = null
        endmethod

        private static method onPickup takes nothing returns nothing
            local unit u = GetManipulatingUnit()
            local integer i = GetPlayerId(GetOwningPlayer(u))
            local thistype this = current[GetHandleId(u)]

            if this != 0 then
                if shop.current[i] != null then
                    if GetLocalPlayer() == GetOwningPlayer(u) then
                        if selected.unit[i] == u and IsUnitInRange(u, shop.current[i], shop.aoe) then
                            call inventory.show(u)
                            call shop.details.refresh()
                            call BJDebugMsg(GetUnitName(u) + " picked up " + GetItemName(GetManipulatedItem()))
                        endif
                    endif
                endif
            endif

            set u = null
        endmethod

        private static method onDrop takes nothing returns nothing
            local unit u = GetManipulatingUnit()
            local integer i = GetPlayerId(GetOwningPlayer(u))
            local thistype this = current[GetHandleId(u)]

            if this != 0 then
                if shop.current[i] != null then
                    if GetLocalPlayer() == GetOwningPlayer(u) then
                        if selected.unit[i] == u and IsUnitInRange(u, shop.current[i], shop.aoe) then
                            call inventory.show(u)
                            call shop.details.refresh()
                            call BJDebugMsg(GetUnitName(u) + " dropped " + GetItemName(GetManipulatedItem()))
                        endif
                    endif
                endif
            endif

            set u = null
        endmethod

        static method onInit takes nothing returns nothing
            set current = Table.create()

            call TriggerAddAction(trigger, function thistype.onScroll)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, function thistype.onPickup)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, function thistype.onDrop)
        endmethod
    endstruct

    private struct Favorites
        Shop shop
        integer count
        Item array item[CATEGORY_COUNT]
        Button array button[CATEGORY_COUNT]

        method destroy takes nothing returns nothing
            local integer i = 0

            loop
                exitwhen i == CATEGORY_COUNT
                    call table.remove(GetHandleId(button[i].frame))
                    call button[i].destroy()
                set i = i + 1
            endloop

            call deallocate()
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

        method clear takes nothing returns nothing
            loop
                exitwhen count == -1
                    set button[count].visible = false
                set count = count - 1
            endloop
        endmethod

        method remove takes integer i returns nothing
            loop
                exitwhen i >= count
                    set item[i] = item[i + 1]
                    set button[i].icon = item[i].icon
                    set button[i].tooltip.text = item[i].tooltip
                    set button[i].tooltip.name = item[i].name
                    set button[i].tooltip.icon = item[i].icon
                set i = i + 1
            endloop

            set button[count].visible = false
            set count = count - 1
        endmethod

        method add takes Item i returns nothing
            if count < CATEGORY_COUNT - 1 then
                if not has(i.id) then
                    set count = count + 1
                    set item[count] = i
                    set button[count].icon = i.icon
                    set button[count].tooltip.text = i.tooltip
                    set button[count].tooltip.name = i.name
                    set button[count].tooltip.icon = i.icon
                    set button[count].visible = true
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
                    set button[i] = Button.create(shop.rightPanel, CATEGORY_SIZE, CATEGORY_SIZE, 0.023750, - (0.021500 + CATEGORY_SIZE*i + CATEGORY_GAP), false)
                    set button[i].visible = false
                    set button[i].onClick = function thistype.onClick
                    set button[i].onDoubleClick = function thistype.onDoubleClick
                    set button[i].tooltip.point = FRAMEPOINT_TOPRIGHT
                    set table[GetHandleId(button[i].frame)][0] = this
                    set table[GetHandleId(button[i].frame)][1] = i

                    if i > 6 then
                        set button[i].tooltip.point = FRAMEPOINT_BOTTOMRIGHT
                    endif
                set i = i + 1
            endloop

            return this
        endmethod

        static method onClick takes nothing returns nothing
            local framehandle frame = BlzGetTriggerFrame()
            local thistype this = table[GetHandleId(frame)][0]
            local integer i = table[GetHandleId(frame)][1]

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    if Shop.tag[GetPlayerId(GetTriggerPlayer())] then
                        call remove(i)
                    else
                        call shop.detail(item[i])
                    endif
                endif
            endif

            set frame = null
        endmethod

        static method onDoubleClick takes nothing returns nothing
            local framehandle frame = BlzGetTriggerFrame()
            local thistype this = table[GetHandleId(frame)][0]
            local integer i = table[GetHandleId(frame)][1]

            if this != 0 then
                call shop.buy(item[i], GetTriggerPlayer())
            endif

            set frame = null
        endmethod
    endstruct

    private struct Category
        Shop shop
        integer count
        integer active
        boolean andLogic
        integer array value[CATEGORY_COUNT]
        Button array button[CATEGORY_COUNT]

        method destroy takes nothing returns nothing
            loop
                exitwhen count == -1
                    call table.remove(GetHandleId(button[count].frame))
                    call button[count].destroy()
                set count = count - 1
            endloop

            call deallocate()
        endmethod

        method clear takes nothing returns nothing
            local integer i = 0

            set active = 0

            loop
                exitwhen i == CATEGORY_COUNT
                    set button[i].enabled = false
                set i = i + 1
            endloop

            call shop.filter(active, andLogic)
        endmethod

        method add takes string icon, string description returns integer
            if count < CATEGORY_COUNT then
                set count = count + 1
                set value[count] = R2I(Pow(2, count))
                set button[count] = Button.create(shop.leftPanel, CATEGORY_SIZE, CATEGORY_SIZE, 0.023750, - (0.021500 + CATEGORY_SIZE*count + CATEGORY_GAP), true)
                set button[count].icon = icon
                set button[count].enabled = false
                set button[count].onClick = function thistype.onClick
                set button[count].tooltip.text = description
                set table[GetHandleId(button[count].frame)][0] = this
                set table[GetHandleId(button[count].frame)][1] = count

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
            local thistype this = table[GetHandleId(frame)][0]
            local integer i = table[GetHandleId(frame)][1]

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    set button[i].enabled = not button[i].enabled

                    if button[i].enabled then
                        set active = active + value[i]
                    else
                        set active = active - value[i]
                    endif

                    call shop.filter(active, andLogic)
                endif

                call BlzFrameSetEnable(frame, false)
                call BlzFrameSetEnable(frame, true)
            endif

            set frame = null
        endmethod
    endstruct
    
    struct Shop
        private static trigger trigger = CreateTrigger()
        private static trigger search = CreateTrigger()
        private static trigger keyPress = CreateTrigger()
        private static trigger escPressed = CreateTrigger()
        private static timer update = CreateTimer()
        private static integer count = -1
        private static HashTable itempool
        readonly static group array group
        readonly static timer array timer
        readonly static boolean array canScroll
        readonly static boolean array tag
        readonly static unit array current
        static HashTable unit
        static HashTable item

        private boolean isVisible

        readonly framehandle base
        readonly framehandle main
        readonly framehandle edit
        readonly framehandle leftPanel
        readonly framehandle rightPanel
        readonly Category category
        readonly Favorites favorites
        readonly Detail details
        readonly Buyer buyer
        readonly Button close
        readonly Button help
        readonly Button logic
        readonly Button clearCategory
        readonly Button clearFavorites
        readonly ShopSlot first
        readonly ShopSlot last
        readonly ShopSlot head
        readonly ShopSlot tail
        readonly integer id
        readonly integer index
        readonly integer size
        readonly integer rows
        readonly integer columns
        readonly boolean detailed
        readonly real aoe

        method operator visible= takes boolean visibility returns nothing
            set isVisible = visibility
            set buyer.visible = visibility

            if not visibility then
                set buyer.index = 0
            else
                if details.visible then
                    call details.refresh()
                endif
            endif

            call BlzFrameSetVisible(base, visibility)
        endmethod

        method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method destroy takes nothing returns nothing
            local ShopSlot slot = itempool[this][0]

            loop
                exitwhen slot == 0
                    call slot.destroy()
                set slot = slot.next
            endloop

            call table.remove(id)
            call table.remove(this)
            call itempool.remove(this)
            call BlzDestroyFrame(rightPanel)
            call BlzDestroyFrame(leftPanel)
            call BlzDestroyFrame(main)
            call BlzDestroyFrame(base)
            call category.destroy()
            call favorites.destroy()
            call details.destroy()
            call buyer.destroy()
            call deallocate()

            set base = null
            set main = null
            set leftPanel = null
            set rightPanel = null
        endmethod

        method buy takes Item i, player p returns boolean
            local Item component
            local integer j = 0
            local integer k = 0
            local integer cost = i.gold
            local integer gold = GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD)
            local unit u = buyer.selected.unit[GetPlayerId(p)]
            local boolean canBuy = true

            call BJDebugMsg(i.name)
            call BJDebugMsg(GetUnitName(u))

            // if i != 0 then
            //     if has(i.id) then
            //         if i.components > 0 then
            //             loop
            //                 exitwhen j == i.components or not canBuy
            //                     set component = Item.get(i.component[j])

            //                     if UnitCountItemOfType(u, component.id) >= i.count(component.id) then
            //                         set cost = cost - component.gold
            //                     else
            //                         set canBuy = has(component.id)
            //                     endif
            //                 set j = j + 1
            //             endloop
            //         endif

            //         if canBuy and gold >= cost then
            //             call SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, gold - cost)
            //             set j = 0

            //             if i.components > 0 then
            //                 loop
            //                     exitwhen j == i.components
            //                         set k = 0
            //                         loop
            //                             exitwhen k == UnitInventorySize(u)
            //                                 if GetItemTypeId(UnitItemInSlot(u, k)) == i.component[j] then
            //                                     call RemoveItem(UnitItemInSlot(u, k))
            //                                     exitwhen true
            //                                 endif
            //                             set k = k + 1
            //                         endloop
            //                     set j = j + 1
            //                 endloop
            //             endif

            //             call UnitAddItem(u, CreateItem(i.id, GetUnitX(u), GetUnitY(u)))
            //         else
            //             set canBuy = false
            //         endif
            //     endif
            // endif

            return canBuy
        endmethod

        method sell takes Item i, player p returns nothing
            call BJDebugMsg("Sell " + i.name)
        endmethod

        method scroll takes boolean down returns nothing
            local ShopSlot slot = first
            
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
        endmethod

        method filter takes integer categories, boolean andLogic returns nothing
            local ShopSlot slot = itempool[this][0]
            local string text = BlzFrameGetText(edit)
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

                    if text != "" and text != null then
                        set process = process and find(StringCase(slot.item.name, false), StringCase(text, false))
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
                set details.visible = false
                call filter(category.active, category.andLogic)
                // call details.hide()
            endif
        endmethod

        method has takes integer id returns boolean
            return table[this].has(id)
        endmethod

        private method find takes string source, string target returns boolean
            local integer sourceLength = StringLength(source)
            local integer targetLenght = StringLength(target)
            local integer i = 0

            if targetLenght <= sourceLength then
                loop
                    exitwhen i > sourceLength - targetLenght
                        if SubString(source, i, i + targetLenght) == target then
                            return true
                        endif
                    set i = i + 1
                endloop
            endif

            return false
        endmethod

        static method addCategory takes integer id, string icon, string description returns integer
            local thistype this = table[id][0]

            if this != 0 then
                return category.add(icon, description)
            endif

            return 0
        endmethod

        static method addItem takes integer id, integer itemId, integer categories returns nothing
            local thistype this = table[id][0]
            local ShopSlot slot
            local Item i

            if this != 0 then
                if not table[this].has(itemId) then
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
                        set table[this][itemId] = slot
                        set itempool[this][index] = slot
                    else
                        call BJDebugMsg("Invalid item code: " + A2S(itemId))
                    endif
                else
                    call BJDebugMsg("The item " + GetObjectName(itemId) + " is already registered for the shop " + GetObjectName(id))
                endif
            endif
        endmethod

        static method create takes integer id, real aoe returns thistype
            local thistype this
            local integer i = 0

            if not table[id].has(0) then
                set this = thistype.allocate()
                set .id = id
                set .aoe = aoe
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
                set edit = BlzCreateFrame("EscMenuEditBoxTemplate", main, 0, 0)
                set leftPanel = BlzCreateFrame("EscMenuBackdrop", base, 0, 0)
                set rightPanel = BlzCreateFrame("EscMenuBackdrop", base, 0, 0)
                set category = Category.create(this)
                set favorites = Favorites.create(this)
                set details = Detail.create(this)
                set buyer = Buyer.create(this)
                set close = Button.create(main, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, (WIDTH - 2*TOOLBAR_BUTTON_SIZE), 0.015000, true)
                set close.icon = CLOSE_ICON
                set close.onClick = function thistype.onClose
                set close.tooltip.text = "Close"
                set clearCategory = Button.create(leftPanel, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, 0.028000, 0.015000, true)
                set clearCategory.icon = CLEAR_ICON
                set clearCategory.onClick = function thistype.onClear
                set clearCategory.tooltip.text = "Clear Category"
                set clearFavorites = Button.create(rightPanel, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, 0.027000, 0.015000, true)
                set clearFavorites.icon = CLEAR_ICON
                set clearFavorites.onClick = function thistype.onClear
                set clearFavorites.tooltip.text = "Clear Favorites"
                set logic = Button.create(leftPanel, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, 0.049000, 0.015000, true)
                set logic.icon = LOGIC_ICON
                set logic.onClick = function thistype.onLogic
                set logic.enabled = false
                set logic.tooltip.text = "AND Logic"
                set table[id][0] = this
                set table[GetHandleId(main)][0] = this
                set table[GetHandleId(close.frame)][0] = this
                set table[GetHandleId(clearCategory.frame)][0] = this
                set table[GetHandleId(clearFavorites.frame)][0] = this
                set table[GetHandleId(logic.frame)][0] = this
                set table[GetHandleId(edit)][0] = this

                loop
                    exitwhen i >= bj_MAX_PLAYER_SLOTS
                        set timer[i] = CreateTimer()
                        set group[i] = CreateGroup()
                        set canScroll[i] = true
                        set table[GetHandleId(Player(i))][id] = this
                        set table[GetHandleId(Player(i))][count] = id
                    set i = i + 1
                endloop

                call BlzFrameSetAbsPoint(base, FRAMEPOINT_TOPLEFT, X, Y)
                call BlzFrameSetSize(base, WIDTH, HEIGHT)
                call BlzFrameSetPoint(main, FRAMEPOINT_TOPLEFT, base, FRAMEPOINT_TOPLEFT, 0.0000, 0.0000)
                call BlzFrameSetSize(main, WIDTH, HEIGHT)
                call BlzFrameSetPoint(edit, FRAMEPOINT_TOPLEFT, main, FRAMEPOINT_TOPLEFT, 0.021000, 0.020000)
                call BlzFrameSetSize(edit, EDIT_WIDTH, EDIT_HEIGHT)
                call BlzFrameSetPoint(leftPanel, FRAMEPOINT_TOPLEFT, base, FRAMEPOINT_TOPLEFT, -0.04800, 0.0000)
                call BlzFrameSetSize(leftPanel, SIDE_WIDTH, SIDE_HEIGHT)
                call BlzFrameSetPoint(rightPanel, FRAMEPOINT_TOPLEFT, base, FRAMEPOINT_TOPLEFT, (WIDTH - 0.027), 0.0000)
                call BlzFrameSetSize(rightPanel, SIDE_WIDTH, SIDE_HEIGHT)
                call BlzTriggerRegisterFrameEvent(trigger, main, FRAMEEVENT_MOUSE_WHEEL)
                call BlzTriggerRegisterFrameEvent(search, edit, FRAMEEVENT_EDITBOX_TEXT_CHANGED)

                set visible = false
            endif

            return this
        endmethod

        private static method onExpire takes nothing returns nothing
            set canScroll[GetPlayerId(GetLocalPlayer())] = true
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this
            local unit shop
            local unit u
            local group g
            local integer i = 0

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    set g = CreateGroup()
                    set shop = current[i]
                    set this = table[GetUnitTypeId(shop)][0]

                    if this != 0 then
                        call GroupClear(group[i])
                        call GroupEnumUnitsInRange(g, GetUnitX(shop), GetUnitY(shop), aoe, null)
                        
                        loop
                            set u = FirstOfGroup(g)
                            exitwhen u == null
                                if ShopFilter(u, Player(i), shop) then
                                    call GroupAddUnit(group[i], u)
                                endif
                            call GroupRemoveUnit(g, u)
                        endloop

                        call buyer.update(group[i], i)
                    endif

                    call DestroyGroup(g)
                set i = i + 1
            endloop

            set g = null
            set shop = null
        endmethod

        private static method onSearch takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())][0]

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    call filter(category.active, category.andLogic)
                endif
            endif
        endmethod

        private static method onLogic takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())][0]

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    set logic.enabled = not logic.enabled
                    set category.andLogic = not category.andLogic 

                    if category.andLogic then
                        set logic.tooltip.text = "AND Logic"
                    else
                        set logic.tooltip.text = "OR Logic"
                    endif

                    call filter(category.active, category.andLogic)
                endif

                call BlzFrameSetEnable(logic.frame, false)
                call BlzFrameSetEnable(logic.frame, true)
            endif
        endmethod

        private static method onClear takes nothing returns nothing
            local framehandle frame = BlzGetTriggerFrame()
            local thistype this = table[GetHandleId(frame)][0]

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    if frame == clearCategory.frame then
                        call category.clear()
                    else
                        call favorites.clear()
                    endif
                endif

                call BlzFrameSetEnable(frame, false)
                call BlzFrameSetEnable(frame, true)
            endif

            set frame = null
        endmethod

        private static method onClose takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())][0]

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    set visible = false
                    set current[GetPlayerId(GetTriggerPlayer())] = null
                endif
            endif
        endmethod

        private static method onScroll takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())][0]
            local integer i = GetPlayerId(GetLocalPlayer())

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    if canScroll[i] then
                        if SCROLL_DELAY > 0 then
                            set canScroll[i] = false
                        endif
    
                        call scroll(BlzGetTriggerFrameValue() < 0)
                    endif
                endif
            endif

            if SCROLL_DELAY > 0 then
                call TimerStart(timer[i], TimerGetRemaining(timer[i]), false, function thistype.onExpire)
            endif
        endmethod

        private static method onSelect takes nothing returns nothing
            local thistype this = table[GetUnitTypeId(GetTriggerUnit())][0]

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    set visible = GetTriggerEventId() == EVENT_PLAYER_UNIT_SELECTED
                endif

                if GetTriggerEventId() == EVENT_PLAYER_UNIT_SELECTED then
                    set current[GetPlayerId(GetTriggerPlayer())] = GetTriggerUnit()
                else
                    set current[GetPlayerId(GetTriggerPlayer())] = null
                endif
            endif
        endmethod

        private static method onKey takes nothing returns nothing
            set tag[GetPlayerId(GetTriggerPlayer())] = BlzGetTriggerPlayerIsKeyDown()
        endmethod

        private static method onEsc takes nothing returns nothing
            local thistype this
            local integer i = 0
            local integer id = GetHandleId(GetTriggerPlayer())
            
            loop
                exitwhen i > count
                    set this = table[id][table[id][i]]

                    if this != 0 then
                        if GetLocalPlayer() == GetTriggerPlayer() then
                            set visible = false
                            set current[GetPlayerId(GetTriggerPlayer())] = null
                        endif
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onInit takes nothing returns nothing
            local integer i = 0

            set unit = HashTable.create()
            set item = HashTable.create()
            set table = HashTable.create()
            set itempool = HashTable.create()

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    set tag[i] = false
                    call BlzTriggerRegisterPlayerKeyEvent(keyPress, Player(i), FAVORITE_KEY, 0, true)
                    call BlzTriggerRegisterPlayerKeyEvent(keyPress, Player(i), FAVORITE_KEY, 0, false)
                    call TriggerRegisterPlayerEventEndCinematic(escPressed, Player(i))
                set i = i + 1
            endloop

            call BlzLoadTOCFile("Shop.toc")
            call TimerStart(update, UPDATE_PERIOD, true, function thistype.onPeriod)
            call TriggerAddAction(trigger, function thistype.onScroll)
            call TriggerAddCondition(search, Condition(function thistype.onSearch)) 
            call TriggerAddCondition(keyPress, Condition(function thistype.onKey))
            call TriggerAddCondition(escPressed, Condition(function thistype.onEsc))
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, function thistype.onSelect)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DESELECTED, function thistype.onSelect)
        endmethod
    endstruct
endlibrary