library Shop requires Table, RegisterPlayerUnitEvent, Components
    /* --------------------------------------- Shop v1.2 --------------------------------------- */
    // Credits:
    //      Taysen: FDF file and A2S function
    //      Bribe: Table library
    //      Magtheridon: RegisterPlayerUnitEvent library
    //      Hate: Frame border effects
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
        private constant string UNDO_ICON               = "ReplaceableTextures\\CommandButtons\\BTNReplay-Loop.blp"
        private constant string DISMANTLE_ICON          = "UI\\Feedback\\Resources\\ResourceUpkeep.blp"

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
        
        // When true, a click in a component in the
        // detail panel will detail the clicked component
        private constant boolean DETAIL_COMPONENT       = true

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

        // ItemTable slots
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

        // Selected item highlight
        private constant string ITEM_HIGHLIGHT          = "neon_sprite.mdx"
        private constant real HIGHLIGHT_SCALE           = 0.75
        private constant real HIGHLIGHT_XOFFSET         = -0.0052
        private constant real HIGHLIGHT_YOFFSET         = -0.0048
        private constant framepointtype HIGHLIGHT_POINT = FRAMEPOINT_BOTTOMLEFT
        private constant framepointtype HIGHLIGHT_RELATIVE_POINT = FRAMEPOINT_BOTTOMLEFT

        // Tagged item highlight
        private constant string TAG_HIGHLIGHT          = "crystallid_sprite.mdx"
        private constant real TAG_HIGHLIGHT_SCALE      = 0.75
        private constant real TAG_HIGHLIGHT_XOFFSET    = -0.0052
        private constant real TAG_HIGHLIGHT_YOFFSET    = -0.0048
        private constant framepointtype TAG_HIGHLIGHT_POINT = FRAMEPOINT_BOTTOMLEFT
        private constant framepointtype TAG_HIGHLIGHT_RELATIVE_POINT = FRAMEPOINT_BOTTOMLEFT

        // Scroll
        private constant real SCROLL_DELAY              = 0.03

        // Update time
        private constant real UPDATE_PERIOD             = 0.33

        // Buy / Sell sound, model and scale
        private constant string SPRITE_MODEL            = "UI\\Feedback\\GoldCredit\\GoldCredit.mdl"
        private constant real SPRITE_SCALE              = 0.0005
        private constant string SUCCESS_SOUND           = "Abilities\\Spells\\Other\\Transmute\\AlchemistTransmuteDeath1.wav"
        private constant string ERROR_SOUND             = "Sound\\Interface\\Error.wav"

        // Dont touch
        private HashTable table
    endglobals 

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function CreateShop takes integer id, real aoe, real returnRate returns nothing
        call Shop.create(id, aoe, returnRate)
    endfunction
    
    function ShopAddCategory takes integer id, string icon, string description returns integer
        return Shop.addCategory(id, icon, description)
    endfunction

    function ShopAddItem takes integer id, integer itemId, integer categories returns nothing
        call Shop.addItem(id, itemId, categories)
    endfunction

    function ItemAddComponents takes integer whichItem, integer a, integer b, integer c, integer d, integer e returns nothing
        call ItemTable.addComponents(whichItem, a, b, c, d, e)
    endfunction

    function ItemCountComponentOfType takes integer id, integer component returns integer
        return ItemTable.countComponent(id, component)
    endfunction

    function UnitHasItemOfType takes unit u, integer id returns boolean
        return ItemTable.hasType(u, id)
    endfunction

    function UnitCountItemOfType takes unit u, integer id returns integer
        return ItemTable.countType(u, id)
    endfunction

    function ShopFilter takes unit u, player owner, unit shop returns boolean
        return IsUnitOwnedByPlayer(u, owner) and UnitInventorySize(u) > 0 and not IsUnitType(u, UNIT_TYPE_DEAD) and not IsUnitPaused(u) and not IsUnitIllusion(u) and not IsUnitHidden(u)
    endfunction

    function A2S takes integer id returns string
        local string chars = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
        local string s = ""
        local integer min = ' '
        local integer i

        if id >= min then
            loop
                exitwhen id == 0
                    set i = ModuloInteger(id, 256) - min
                    set s = SubString(chars, i, i + 1) + s
                set id = id / 256
            endloop
        endif

        return s
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    struct ItemTable
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
        integer charges
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

        method operator recipe takes nothing returns integer
            local integer i = 0
            local integer amount = gold

            if components > 0 then
                loop
                    exitwhen i == components
                        set amount = amount - get(component[i]).gold
                    set i = i + 1
                endloop

                return amount
            endif

            return 0
        endmethod

        method cost takes unit u returns integer
            local integer amount
            local integer i = 0
            local Table owned = Table.create()

            if u == null then
                set amount = gold
            else
                loop
                    exitwhen i == UnitInventorySize(u)
                        set owned[GetItemTypeId(UnitItemInSlot(u, i))] = owned[GetItemTypeId(UnitItemInSlot(u, i))] + 1
                    set i = i + 1
                endloop

                set amount = calculate(owned)
            endif

            call owned.destroy()

            return amount
        endmethod

        method count takes integer id returns integer
            return counter[id]
        endmethod

        private method calculate takes Table owned returns integer
            local thistype piece
            local integer amount
            local integer i = 0

            if components <= 0 then
                return gold
            else
                set amount = recipe

                loop
                    exitwhen i == components
                        set piece = get(component[i])
                    
                        if owned.integer[piece.id] > 0 then
                            set owned[piece.id] = owned[piece.id] - 1
                        else
                            set amount = amount + piece.calculate(owned)
                        endif
                    set i = i + 1
                endloop

                return amount
            endif
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

        static method totalCost takes integer id returns integer
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

        static method countComponent takes integer id, integer component returns integer
            local thistype this

            if itempool.has(id) then
                set this = itempool[id]
                return this.count(component)
            endif

            return 0
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
                    set charges = GetItemCharges(i)

                    if charges == 0 then
                        set charges = 1
                    endif

                    set gold = totalCost(id)
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

        ItemTable item
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

        static method create takes framehandle parent, ItemTable i, real x, real y, framepointtype point, boolean simpleTooltip returns thistype
            local thistype this = thistype.allocate()

            set item = i
            set xPos = x
            set yPos = y
            set .parent = parent
            set slot = BlzCreateFrameByType("FRAME", "", parent, "", 0)
            set gold = BlzCreateFrameByType("BACKDROP", "", slot, "", 0)
            set cost = BlzCreateFrameByType("TEXT", "", gold, "", 0)
            set button = Button.create(slot, ITEM_SIZE, ITEM_SIZE, 0, 0, simpleTooltip, false)
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
            call table.remove(button)
            call table.remove(GetHandleId(button.button))
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

        static method create takes Shop shop, ItemTable i, integer row, integer column returns thistype
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
            set table[button][0] = this
            set table[GetHandleId(button.button)][2] = shop

            call update()

            return this
        endmethod

        static method onScrolled takes nothing returns nothing
            local thistype this = table[GetTriggerButton()][0]

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    call Shop.onScroll()
                endif
            endif
        endmethod

        static method onClicked takes nothing returns nothing
            local player p = GetTriggerPlayer()
            local thistype this = table[GetTriggerButton()][0]

            if this != 0 then
                if Shop.tag[GetPlayerId(p)] then
                    call shop.favorites.add(item, p)
                else
                    call shop.detail(item, p)
                endif
            endif

            set p = null
        endmethod

        static method onDoubleClicked takes nothing returns nothing
            local thistype this = table[GetTriggerButton()][0]

            if this != 0 then
                if shop.buy(item, GetTriggerPlayer()) then
                    if GetLocalPlayer() == GetTriggerPlayer() then
                        call button.play(SPRITE_MODEL, SPRITE_SCALE, 0)
                    endif
                endif
            endif
        endmethod

        static method onRightClicked takes nothing returns nothing
            local player p = GetTriggerPlayer()
            local thistype this = table[GetTriggerButton()][0]

            if this != 0 then
                if shop.buy(item, p) then
                    if GetLocalPlayer() == p then
                        call button.play(SPRITE_MODEL, SPRITE_SCALE, 0)
                    endif
                endif
            endif
        endmethod
    endstruct

    private struct Transaction
        private integer index

        Shop shop
        ItemTable item
        unit unit
        player player
        string type
        integer gold
        Table component

        method destroy takes nothing returns nothing
            call component.destroy()
            call deallocate()

            set unit = null
            set player = null
        endmethod

        method rollback takes nothing returns nothing
            local integer i = 0
            local integer j = 0
            local integer id = GetPlayerId(player)

            if IsUnitInGroup(unit, shop.group[id]) then
                if type == "buy" then
                    if UnitHasItemOfType(unit, item.id) then
                        loop
                            exitwhen i == UnitInventorySize(unit)
                                if GetItemTypeId(UnitItemInSlot(unit, i)) == item.id then
                                    call RemoveItem(UnitItemInSlot(unit, i))
                                    exitwhen true
                                endif
                            set i = i + 1
                        endloop

                        set i = 0 

                        loop
                            exitwhen i == index
                                call UnitAddItemById(unit, ItemTable(component[i]).id)
                            set i = i + 1
                        endloop

                        call SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD) + gold)

                        if not GetSoundIsPlaying(shop.success) then
                            call StartSoundForPlayerBJ(player, shop.success)
                        endif
                    else
                        if not GetSoundIsPlaying(shop.error) then
                            call StartSoundForPlayerBJ(player, shop.error)
                        endif
                    endif
                elseif type == "sell" then
                    call UnitAddItemById(unit, item.id)
                    call SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD) - gold)

                    if not GetSoundIsPlaying(shop.success) then
                        call StartSoundForPlayerBJ(player, shop.success)
                    endif
                else
                    loop
                        exitwhen i == item.components
                            set j = 0

                            loop
                                exitwhen j == UnitInventorySize(unit)
                                    if GetItemTypeId(UnitItemInSlot(unit, j)) == ItemTable.get(item.component[i]).id then
                                        call RemoveItem(UnitItemInSlot(unit, j))
                                        exitwhen true
                                    endif
                                set j = j + 1
                            endloop
                        set i = i + 1
                    endloop

                    call UnitAddItemById(unit, item.id)

                    if not GetSoundIsPlaying(shop.success) then
                        call StartSoundForPlayerBJ(player, shop.success)
                    endif
                endif
            else
                if not GetSoundIsPlaying(shop.error) then
                    call StartSoundForPlayerBJ(player, shop.error)
                endif
            endif

            set shop.transactionCount[id] = shop.transactionCount[id] - 1
            call shop.transaction[id].remove(shop.transactionCount[id])
            call destroy()
        endmethod

        method add takes ItemTable i returns nothing
            if i != 0 then
                set component[index] = i
                set index = index + 1
            endif
        endmethod

        static method create takes Shop shop, unit u, ItemTable i, string transaction returns thistype
            local thistype this = thistype.allocate()

            set item = i
            set unit = u
            set .shop = shop
            set type = transaction
            set index = 0
            set player = GetOwningPlayer(u)
            set component = Table.create()

            return this
        endmethod
    endstruct

    private struct Detail
        readonly static trigger trigger = CreateTrigger()

        private boolean isVisible

        Shop shop
        Table item
        Table main
        Table center
        Table left1
        Table left2
        Table right1
        Table right2
        Table count
        HashTable used
        HashTable button
        Button close
        Button left
        Button right
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
            local integer j = 0

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    call table.remove(Slot(main[i]).button)
                    call table.remove(Slot(center[i]).button)
                    call table.remove(Slot(left1[i]).button)
                    call table.remove(Slot(left2[i]).button)
                    call table.remove(Slot(right1[i]).button)
                    call table.remove(Slot(right2[i]).button)
                    call Slot(main[i]).destroy()
                    call Slot(center[i]).destroy()
                    call Slot(left1[i]).destroy()
                    call Slot(left2[i]).destroy()
                    call Slot(right1[i]).destroy()
                    call Slot(right2[i]).destroy()

                    set j = 0

                    loop
                        exitwhen j == DETAIL_USED_COUNT
                            call table.remove(button[i][j])
                            call Button(button[i][j]).destroy()
                        set j = j + 1
                    endloop

                    call button.remove(i)
                    call used.remove(i)
                set i = i + 1
            endloop

            call main.destroy()
            call center.destroy()
            call left1.destroy()
            call left2.destroy()
            call right1.destroy()
            call right2.destroy()
            call count.destroy()
            call item.destroy()
            call used.destroy()
            call button.destroy()
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

        method shift takes boolean left, player p returns nothing
            local ItemTable i
            local integer j
            local integer id = GetPlayerId(p)

            if left then
                if ItemTable(item[id]).relation.has(count[id]) and count[id] >= DETAIL_USED_COUNT then
                    set j = 0

                    loop
                        exitwhen j == DETAIL_USED_COUNT - 1
                            set used[id][j] = used[id][j + 1]

                            if GetLocalPlayer() == p then
                                set Button(button[id][j]).icon = ItemTable(used[id][j]).icon
                                set Button(button[id][j]).tooltip.text = ItemTable(used[id][j]).tooltip
                                set Button(button[id][j]).tooltip.name = ItemTable(used[id][j]).name
                                set Button(button[id][j]).tooltip.icon = ItemTable(used[id][j]).icon
                                set Button(button[id][j]).available = shop.has(ItemTable(used[id][j]).id)
                                set Button(button[id][j]).visible = true
                            endif
                        set j = j + 1
                    endloop

                    set i = ItemTable.get(ItemTable(item[id]).relation[count[id]])

                    if i != 0 then
                        set count[id] = count[id] + 1
                        set used[id][j] = i

                        if GetLocalPlayer() == p then
                            set Button(button[id][j]).icon = i.icon
                            set Button(button[id][j]).tooltip.text = i.tooltip
                            set Button(button[id][j]).tooltip.name = i.name
                            set Button(button[id][j]).tooltip.icon = i.icon
                            set Button(button[id][j]).available = shop.has(i.id)
                            set Button(button[id][j]).visible = true
                        endif
                    endif
                endif
            else
                if count.integer[id] > DETAIL_USED_COUNT then
                    set j = DETAIL_USED_COUNT - 1

                    loop
                        exitwhen j == 0
                            set used[id][j] = used[id][j - 1]

                            if GetLocalPlayer() == p then
                                set Button(button[id][j]).icon = ItemTable(used[id][j]).icon
                                set Button(button[id][j]).tooltip.text = ItemTable(used[id][j]).tooltip
                                set Button(button[id][j]).tooltip.name = ItemTable(used[id][j]).name
                                set Button(button[id][j]).tooltip.icon = ItemTable(used[id][j]).icon
                                set Button(button[id][j]).available = shop.has(ItemTable(used[id][j]).id)
                                set Button(button[id][j]).visible = true
                            endif
                        set j = j - 1
                    endloop
                    
                    set i = ItemTable.get(ItemTable(item[id]).relation[count[id] - DETAIL_USED_COUNT - 1])

                    if i != 0 then
                        set count[id] = count[id] - 1
                        set used[id][j] = i

                        if GetLocalPlayer() == p then
                            set Button(button[id][j]).icon = i.icon
                            set Button(button[id][j]).tooltip.text = i.tooltip
                            set Button(button[id][j]).tooltip.name = i.name
                            set Button(button[id][j]).tooltip.icon = i.icon
                            set Button(button[id][j]).available = shop.has(i.id)
                            set Button(button[id][j]).visible = true
                        endif
                    endif
                endif
            endif
        endmethod

        method showUsed takes player p returns nothing
            local ItemTable i
            local integer j = 0
            local integer id = GetPlayerId(p)

            loop
                exitwhen j == DETAIL_USED_COUNT
                    set i = ItemTable.get(ItemTable(item[id]).relation[j])

                    if i != 0 and j < DETAIL_USED_COUNT then
                        set used[id][j] = i

                        if GetLocalPlayer() == p then
                            set Button(button[id][count[id]]).icon = i.icon
                            set Button(button[id][count[id]]).tooltip.text = i.tooltip
                            set Button(button[id][count[id]]).tooltip.name = i.name
                            set Button(button[id][count[id]]).tooltip.icon = i.icon
                            set Button(button[id][count[id]]).visible = true
                            set Button(button[id][count[id]]).available = shop.has(i.id)
                        endif

                        set count[id] = count[id] + 1
                    else
                        set Button(button[id][j]).visible = false
                    endif
                set j = j + 1
            endloop
        endmethod

        method refresh takes player p returns nothing
            local integer id = GetPlayerId(p)

            if isVisible and item[id] != 0 then
                call show(item[id], p)
            endif
        endmethod

        method show takes ItemTable i, player p returns nothing
            local ItemTable component
            local Slot slot
            local integer j = 0
            local integer k = 0
            local integer cost
            local integer id = GetPlayerId(p)
            local Table counter = Table.create()

            if i != 0 then
                set item[id] = i
                set count[id] = 0
                set cost = i.gold
                set Slot(main[id]).item = i

                call showUsed(p)
                
                if i.components > 0 then
                    loop
                        exitwhen j == i.components or k == 5
                            set component = ItemTable.get(i.component[j])

                            if component != 0 then
                                if i.components == 1 then
                                    set slot = center[id]

                                    if GetLocalPlayer() == p then
                                        set Slot(left1[id]).visible = false
                                        set Slot(left2[id]).visible = false
                                        set Slot(right1[id]).visible = false
                                        set Slot(right2[id]).visible = false

                                        call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.13625, - 0.10200, true)
                                        call update(verticalMain, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.15600, - 0.082500, true)
                                        call update(verticalCenter, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.15600, - 0.092500, true)
                                        call BlzFrameSetVisible(horizontalLeft, false)
                                        call BlzFrameSetVisible(horizontalRight, false)
                                        call BlzFrameSetVisible(verticalLeft1, false)
                                        call BlzFrameSetVisible(verticalLeft2, false)
                                        call BlzFrameSetVisible(verticalRight1, false)
                                        call BlzFrameSetVisible(verticalRight2, false)
                                    endif
                                elseif i.components == 2 then
                                    if j == 0 then
                                        set slot = left1[id]

                                        if GetLocalPlayer() == p then
                                            set Slot(center[id]).visible = false
                                            set Slot(left2[id]).visible = false
                                            set Slot(right2[id]).visible = false

                                            call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.087250, - 0.10200, true)
                                            call update(verticalMain, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.15600, - 0.082500, true)
                                            call update(horizontalLeft, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.048, 0.001, 0.10700, - 0.091500, true)
                                            call update(verticalLeft1, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.10700, - 0.092500, true)
                                            call BlzFrameSetVisible(verticalCenter, false)
                                            call BlzFrameSetVisible(verticalLeft2, false)
                                        endif
                                    else
                                        set slot = right1[id]

                                        if GetLocalPlayer() == p then
                                            call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.18525, - 0.10200, true)
                                            call update(horizontalRight, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.048, 0.001, 0.15700, - 0.091500, true)
                                            call update(verticalRight1, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.20500, - 0.092500, true)
                                            call BlzFrameSetVisible(verticalRight2, false)
                                        endif
                                    endif
                                elseif i.components == 3 then
                                    if j == 0 then
                                        set slot = left2[id]

                                        if GetLocalPlayer() == p then
                                            set Slot(left1[id]).visible = false
                                            set Slot(right1[id]).visible = false

                                            call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.038250, - 0.10200, true)
                                            call update(verticalMain, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.15600, - 0.082500, true)
                                            call update(horizontalLeft, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.1, 0.001, 0.057000, - 0.091500, true)
                                            call update(verticalLeft2, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.057000, - 0.092500, true)
                                            call BlzFrameSetVisible(verticalLeft1, false)
                                        endif
                                    elseif j == 1 then
                                        set slot = center[id]

                                        if GetLocalPlayer() == p then
                                            call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.13625, - 0.10200, true)
                                            call update(verticalCenter, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.15600, - 0.092500, true)
                                        endif
                                    else
                                        set slot = right2[id]

                                        if GetLocalPlayer() == p then
                                            call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.23425, - 0.10200, true)
                                            call update(horizontalRight, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.1, 0.001, 0.15700, - 0.091500, true)
                                            call update(verticalRight2, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.25600, - 0.092500, true)
                                            call BlzFrameSetVisible(verticalRight1, false)
                                        endif
                                    endif
                                elseif i.components == 4 then
                                    if j == 0 then
                                        set slot = left2[id]

                                        if GetLocalPlayer() == p then
                                            set Slot(right2[id]).visible = false

                                            call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.038250, - 0.10200, true)
                                            call update(verticalMain, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.15600, - 0.082500, true)
                                            call update(horizontalLeft, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.1, 0.001, 0.057000, - 0.091500, true)
                                            call update(verticalLeft2, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.057000, - 0.092500, true)
                                        endif
                                    elseif j == 1 then
                                        set slot = left1[id]

                                        if GetLocalPlayer() == p then
                                            call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.10350, - 0.10200, true)
                                            call update(verticalLeft1, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.12250, - 0.092500, true)
                                        endif
                                    elseif j == 2 then
                                        set slot = center[id]

                                        if GetLocalPlayer() == p then
                                            call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.16875, - 0.10200, true)
                                            call update(verticalRight1, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.18950, - 0.092500, true)
                                            call BlzFrameSetVisible(verticalCenter, false)
                                        endif
                                    else
                                        set slot = right1[id]

                                        if GetLocalPlayer() == p then
                                            call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.23400, - 0.10200, true)
                                            call update(horizontalRight, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.1, 0.001, 0.15700, - 0.091500, true)
                                            call update(verticalRight2, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.25600, - 0.092500, true)
                                        endif
                                    endif
                                else
                                    if j == 0 then
                                        set slot = left2[id]

                                        if GetLocalPlayer() == p then
                                            call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.038250, - 0.10200, true)
                                            call update(verticalMain, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.15600, - 0.082500, true)
                                            call update(horizontalLeft, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.1, 0.001, 0.057000, - 0.091500, true)
                                            call update(verticalLeft2, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.057000, - 0.092500, true)
                                        endif
                                    elseif j == 1 then
                                        set slot = left1[id]

                                        if GetLocalPlayer() == p then
                                            call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.087250, - 0.10200, true)
                                            call update(verticalLeft1, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.10700, - 0.092500, true)
                                        endif
                                    elseif j == 2 then
                                        set slot = center[id]

                                        if GetLocalPlayer() == p then
                                            call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.13625, - 0.10200, true)
                                            call update(verticalCenter, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.15600, - 0.092500, true)
                                        endif
                                    elseif j == 3 then
                                        set slot = right1[id]

                                        if GetLocalPlayer() == p then
                                            call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.18525, - 0.10200, true)
                                            call update(verticalRight1, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.20500, - 0.092500, true)
                                        endif
                                    else
                                        set slot = right2[id]

                                        if GetLocalPlayer() == p then
                                            call update(slot.slot, FRAMEPOINT_TOPLEFT, slot.parent, FRAMEPOINT_TOPLEFT, SLOT_WIDTH, SLOT_HEIGHT, 0.23425, - 0.10200, true)
                                            call update(horizontalRight, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.1, 0.001, 0.15700, - 0.091500, true)
                                            call update(verticalRight2, FRAMEPOINT_TOPLEFT, frame, FRAMEPOINT_TOPLEFT, 0.001, 0.01, 0.25600, - 0.092500, true)
                                        endif
                                    endif
                                endif

                                set slot.item = component
                                set slot.button.icon = component.icon
                                set slot.button.tooltip.text = component.tooltip
                                set slot.button.tooltip.name = component.name
                                set slot.button.tooltip.icon = component.icon
                                set slot.button.available = shop.has(component.id)
                                call BlzFrameSetText(slot.cost, "|cffFFCC00" + I2S(component.cost(shop.buyer.selected.unit[id])) + "|r")
                                
                                if shop.buyer.selected.unit[id] != null then
                                    if UnitHasItemOfType(shop.buyer.selected.unit[id], component.id) then
                                        if UnitCountItemOfType(shop.buyer.selected.unit[id], component.id) >= i.count(component.id) then
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

                                if GetLocalPlayer() == p then
                                    set slot.visible = true
                                endif

                                set j = j + 1
                            endif
                        set k = k + 1
                    endloop
                else
                    if GetLocalPlayer() == p then
                        set Slot(center[id]).visible = false
                        set Slot(left1[id]).visible = false
                        set Slot(left2[id]).visible = false
                        set Slot(right1[id]).visible = false
                        set Slot(right2[id]).visible = false

                        call BlzFrameSetVisible(horizontalLeft, false)
                        call BlzFrameSetVisible(horizontalRight, false)
                        call BlzFrameSetVisible(verticalMain, false)
                        call BlzFrameSetVisible(verticalCenter, false)
                        call BlzFrameSetVisible(verticalLeft1, false)
                        call BlzFrameSetVisible(verticalLeft2, false)
                        call BlzFrameSetVisible(verticalRight1, false)
                        call BlzFrameSetVisible(verticalRight2, false)
                    endif
                endif

                set Slot(main[id]).button.icon = i.icon
                set Slot(main[id]).button.tooltip.text = i.tooltip
                set Slot(main[id]).button.tooltip.name = i.name
                set Slot(main[id]).button.tooltip.icon = i.icon
                set Slot(main[id]).button.available = shop.has(i.id)

                if GetLocalPlayer() == p then
                    call BlzFrameSetText(Slot(main[id]).cost, "|cffFFCC00" + I2S(i.cost(shop.buyer.selected.unit[id])) + "|r")
                    call BlzFrameSetText(tooltip, i.tooltip)
                    set visible = true
                endif
            endif

            call counter.destroy()
        endmethod

        static method create takes Shop shop returns thistype
            local thistype this = thistype.allocate()
            local integer i = 0
            local integer j

            set .shop = shop
            set isVisible = false
            set item = Table.create()
            set count = Table.create()
            set main = Table.create()
            set center = Table.create()
            set left1 = Table.create()
            set left2 = Table.create()
            set right1 = Table.create()
            set right2 = Table.create()
            set used = HashTable.create()
            set button = HashTable.create()
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
            set close = Button.create(frame, DETAIL_CLOSE_BUTTON_SIZE, DETAIL_CLOSE_BUTTON_SIZE, 0.26676, - 0.025000, true, false)
            set close.icon = CLOSE_ICON
            set close.onClick = function thistype.onClick
            set close.tooltip.text = "Close"
            set left = Button.create(scrollFrame, DETAIL_SHIFT_BUTTON_SIZE, DETAIL_SHIFT_BUTTON_SIZE, 0.0050000, - 0.0025000, true, false)
            set left.icon = USED_LEFT
            set left.onClick = function thistype.onClick
            set left.tooltip.text = "Scroll Left"
            set right = Button.create(scrollFrame, DETAIL_SHIFT_BUTTON_SIZE, DETAIL_SHIFT_BUTTON_SIZE, 0.24800, - 0.0025000, true, false)
            set right.icon = USED_RIGHT
            set right.onClick = function thistype.onClick
            set right.tooltip.text = "Scroll Right"
            set table[close][0] = this
            set table[left][0] = this
            set table[right][0] = this
            set table[GetHandleId(scrollFrame)][0] = this

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
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    set j = 0
                    set main[i] = Slot.create(frame, 0, 0.13625, - 0.030000, FRAMEPOINT_TOPRIGHT, false)
                    set Slot(main[i]).visible = GetLocalPlayer() == Player(i)
                    set Slot(main[i]).onClick = function thistype.onClick
                    set Slot(main[i]).onRightClick = function thistype.onRightClick
                    set Slot(main[i]).onDoubleClick = function thistype.onDoubleClick
                    set center[i] = Slot.create(frame, 0, 0.13625, - 0.10200, FRAMEPOINT_TOPRIGHT, false)
                    set Slot(center[i]).visible = false
                    set Slot(center[i]).onClick = function thistype.onClick
                    set Slot(center[i]).onRightClick = function thistype.onRightClick
                    set Slot(center[i]).onDoubleClick = function thistype.onDoubleClick
                    set left1[i] = Slot.create(frame, 0, 0.087250, - 0.10200, FRAMEPOINT_TOPRIGHT, false)
                    set Slot(left1[i]).visible = false
                    set Slot(left1[i]).onClick = function thistype.onClick
                    set Slot(left1[i]).onRightClick = function thistype.onRightClick
                    set Slot(left1[i]).onDoubleClick = function thistype.onDoubleClick
                    set left2[i] = Slot.create(frame, 0, 0.038250, - 0.10200, FRAMEPOINT_TOPRIGHT, false)
                    set Slot(left2[i]).visible = false
                    set Slot(left2[i]).onClick = function thistype.onClick
                    set Slot(left2[i]).onRightClick = function thistype.onRightClick
                    set Slot(left2[i]).onDoubleClick = function thistype.onDoubleClick
                    set right1[i] = Slot.create(frame, 0, 0.18525, - 0.10200, FRAMEPOINT_TOPRIGHT, false)
                    set Slot(right1[i]).visible = false
                    set Slot(right1[i]).onClick = function thistype.onClick
                    set Slot(right1[i]).onRightClick = function thistype.onRightClick
                    set Slot(right1[i]).onDoubleClick = function thistype.onDoubleClick
                    set right2[i] = Slot.create(frame, 0, 0.23425, - 0.10200, FRAMEPOINT_TOPRIGHT, false)
                    set Slot(right2[i]).visible = false
                    set Slot(right2[i]).onClick = function thistype.onClick
                    set Slot(right2[i]).onRightClick = function thistype.onRightClick
                    set Slot(right2[i]).onDoubleClick = function thistype.onDoubleClick
                    set table[Slot(main[i]).button][0] = this
                    set table[Slot(center[i]).button][0] = this
                    set table[Slot(left1[i]).button][0] = this
                    set table[Slot(left2[i]).button][0] = this
                    set table[Slot(right1[i]).button][0] = this
                    set table[Slot(right2[i]).button][0] = this

                    loop
                        exitwhen j == DETAIL_USED_COUNT
                            set button[i][j] = Button.create(scrollFrame, DETAIL_BUTTON_SIZE, DETAIL_BUTTON_SIZE, 0.0050000 + DETAIL_BUTTON_GAP*j, - 0.019500, false, false)
                            set Button(button[i][j]).onClick = function thistype.onClick
                            set Button(button[i][j]).onScroll = function thistype.onScroll
                            set Button(button[i][j]).onRightClick = function thistype.onRightClick
                            set Button(button[i][j]).tooltip.point = FRAMEPOINT_BOTTOMRIGHT
                            set Button(button[i][j]).visible = false
                            set table[button[i][j]][0] = this
                            set table[button[i][j]][1] = j
                        set j = j + 1
                    endloop
                set i = i + 1
            endloop

            call BlzFrameSetVisible(frame, false)

            return this
        endmethod

        static method onScroll takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())][0]

            if this == 0 then
                set this = table[GetTriggerButton()][0]
            endif

            if this != 0 then
                call shift(BlzGetTriggerFrameValue() < 0, GetTriggerPlayer())
            endif
        endmethod

        static method onClick takes nothing returns nothing
            local Button b = GetTriggerButton()
            local thistype this = table[b][0]
            local integer i = table[b][1]
            local integer id = GetPlayerId(GetTriggerPlayer())

            if this != 0 then
                if b == close then
                    call shop.detail(0, GetTriggerPlayer())
                elseif b == left then
                    call shift(false, GetTriggerPlayer())
                elseif b == right then
                    call shift(true, GetTriggerPlayer())
                elseif b == Slot(center[id]).button then
                    if Shop.tag[id] then
                        call shop.favorites.add(Slot(center[id]).item, GetTriggerPlayer())
                    else
                        static if DETAIL_COMPONENT then
                            call shop.detail(Slot(center[id]).item, GetTriggerPlayer())
                        endif
                    endif
                elseif b == Slot(left1[id]).button then
                    if Shop.tag[id] then
                        call shop.favorites.add(Slot(left1[id]).item, GetTriggerPlayer())
                    else
                        static if DETAIL_COMPONENT then
                            call shop.detail(Slot(left1[id]).item, GetTriggerPlayer())
                        endif
                    endif
                elseif b == Slot(left2[id]).button then
                    if Shop.tag[id] then
                        call shop.favorites.add(Slot(left2[id]).item, GetTriggerPlayer())
                    else
                        static if DETAIL_COMPONENT then
                            call shop.detail(Slot(left2[id]).item, GetTriggerPlayer())
                        endif
                    endif
                elseif b == Slot(right1[id]).button then
                    if Shop.tag[id] then
                        call shop.favorites.add(Slot(right1[id]).item, GetTriggerPlayer())
                    else
                        static if DETAIL_COMPONENT then
                            call shop.detail(Slot(right1[id]).item, GetTriggerPlayer())
                        endif
                    endif
                elseif b == Slot(right2[id]).button then
                    if Shop.tag[id] then
                        call shop.favorites.add(Slot(right2[id]).item, GetTriggerPlayer())
                    else
                        static if DETAIL_COMPONENT then
                            call shop.detail(Slot(right2[id]).item, GetTriggerPlayer())
                        endif
                    endif
                elseif b != Slot(main[id]).button then
                    if Shop.tag[id] then
                        call shop.favorites.add(used[id][i], GetTriggerPlayer())
                    else
                        call shop.detail(used[id][i], GetTriggerPlayer())
                    endif
                elseif b == Slot(main[id]).button then
                    if Shop.tag[id] then
                        call shop.favorites.add(Slot(main[id]).item, GetTriggerPlayer())
                    else
                        call shop.select(Slot(main[id]).item, GetTriggerPlayer())
                    endif
                endif
            endif
        endmethod

        static method onRightClick takes nothing returns nothing
            local player p = GetTriggerPlayer()
            local Button b = GetTriggerButton()
            local thistype this = table[b][0]
            local integer i = table[b][1]
            local integer id = GetPlayerId(p)

            if this != 0 then
                if b == Slot(main[id]).button then
                    if shop.buy(Slot(main[id]).item, p) then
                        if GetLocalPlayer() == p then
                            call Slot(main[id]).button.play(SPRITE_MODEL, SPRITE_SCALE, 0)
                        endif
                    endif
                elseif b == Slot(center[id]).button then
                    if shop.buy(Slot(center[id]).item, p) then
                        if GetLocalPlayer() == p then
                            call Slot(center[id]).button.play(SPRITE_MODEL, SPRITE_SCALE, 0)
                        endif
                    endif
                elseif b == Slot(left1[id]).button then
                    if shop.buy(Slot(left1[id]).item, p) then
                        if GetLocalPlayer() == p then
                            call Slot(left1[id]).button.play(SPRITE_MODEL, SPRITE_SCALE, 0)
                        endif
                    endif
                elseif b == Slot(left2[id]).button then
                    if shop.buy(Slot(left2[id]).item, p) then
                        if GetLocalPlayer() == p then
                            call Slot(left2[id]).button.play(SPRITE_MODEL, SPRITE_SCALE, 0)
                        endif
                    endif
                elseif b == Slot(right1[id]).button then
                    if shop.buy(Slot(right1[id]).item, p) then
                        if GetLocalPlayer() == p then
                            call Slot(right1[id]).button.play(SPRITE_MODEL, SPRITE_SCALE, 0)
                        endif
                    endif
                elseif b == Slot(right2[id]).button then
                    if shop.buy(Slot(right2[id]).item, p) then
                        if GetLocalPlayer() == p then
                            call Slot(right2[id]).button.play(SPRITE_MODEL, SPRITE_SCALE, 0)
                        endif
                    endif
                else
                    if shop.buy(used[id][i], p) then
                        if GetLocalPlayer() == p then
                            call Button(button[id][i]).play(SPRITE_MODEL, SPRITE_SCALE, 0)
                        endif
                    endif
                endif
            endif

            set p =null
        endmethod

        static method onDoubleClick takes nothing returns nothing
            local Button b = GetTriggerButton()
            local player p = GetTriggerPlayer()
            local thistype this = table[b][0]
            local integer i = table[b][1]
            local integer id = GetPlayerId(p)

            if this != 0 then
                if b == Slot(main[id]).button then
                    if shop.buy(Slot(main[id]).item, p) then
                        if GetLocalPlayer() == p then
                            call Slot(main[id]).button.play(SPRITE_MODEL, SPRITE_SCALE, 0)
                        endif
                    endif
                elseif b == Slot(center[id]).button then
                    if shop.buy(Slot(center[id]).item, p) then
                        if GetLocalPlayer() == p then
                            call Slot(center[id]).button.play(SPRITE_MODEL, SPRITE_SCALE, 0)
                        endif
                    endif
                elseif b == Slot(left1[id]).button then
                    if shop.buy(Slot(left1[id]).item, p) then
                        if GetLocalPlayer() == p then
                            call Slot(left1[id]).button.play(SPRITE_MODEL, SPRITE_SCALE, 0)
                        endif
                    endif
                elseif b == Slot(left2[id]).button then
                    if shop.buy(Slot(left2[id]).item, p) then
                        if GetLocalPlayer() == p then
                            call Slot(left2[id]).button.play(SPRITE_MODEL, SPRITE_SCALE, 0)
                        endif
                    endif
                elseif b == Slot(right1[id]).button then
                    if shop.buy(Slot(right1[id]).item, p) then
                        if GetLocalPlayer() == p then
                            call Slot(right1[id]).button.play(SPRITE_MODEL, SPRITE_SCALE, 0)
                        endif
                    endif
                elseif b == Slot(right2[id]).button then
                    if shop.buy(Slot(right2[id]).item, p) then
                        if GetLocalPlayer() == p then
                            call Slot(right2[id]).button.play(SPRITE_MODEL, SPRITE_SCALE, 0)
                        endif
                    endif
                else
                    if shop.buy(used[id][i], p) then
                        if GetLocalPlayer() == p then
                            call Button(button[id][i]).play(SPRITE_MODEL, SPRITE_SCALE, 0)
                        endif
                    endif
                endif
            endif

            set p =null
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
        Table selected
        HashTable item
        HashTable button

        method operator visible= takes boolean visibility returns nothing
            set isVisible = visibility
            call BlzFrameSetVisible(frame, visibility)
        endmethod

        method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method destroy takes nothing returns nothing
            local integer i = 0
            local integer j

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    set j = 0

                    loop
                        exitwhen j == INVENTORY_COUNT
                            call table.remove(button[i][j])
                            call Button(button[i][j]).destroy()
                        set j = j + 1
                    endloop

                    call button.remove(i)
                    call item.remove(i)
                set i = i + 1
            endloop

            call BlzDestroyFrame(frame)
            call BlzDestroyFrame(scrollFrame)
            call selected.destroy()
            call button.destroy()
            call item.destroy()
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
            local integer id = GetPlayerId(GetOwningPlayer(u))

            if u != null then
                loop
                    exitwhen j == INVENTORY_COUNT
                        set i = UnitItemInSlot(u, j)

                        if i != null then
                            set item[id][j] = ItemTable.get(GetItemTypeId(i))

                            if GetLocalPlayer() == GetOwningPlayer(u) then
                                set Button(button[id][j]).icon = ItemTable(item[id][j]).icon
                                set Button(button[id][j]).tooltip.icon = ItemTable(item[id][j]).icon
                                set Button(button[id][j]).tooltip.name = ItemTable(item[id][j]).name
                                set Button(button[id][j]).tooltip.text = ItemTable(item[id][j]).tooltip
                                set Button(button[id][j]).visible = true
                                set Button(button[id][j]).highlighted = false
                            endif
                        else
                            set item[id][j] = 0

                            if GetLocalPlayer() == GetOwningPlayer(u) then
                                set Button(button[id][j]).highlighted = false
                                set Button(button[id][j]).visible = false
                            endif
                        endif
                    set j = j + 1
                endloop
            else
                loop
                    exitwhen j == INVENTORY_COUNT
                        set item[id][j] = 0

                        if GetLocalPlayer() == GetOwningPlayer(u) then
                            set Button(button[id][j]).highlighted = false
                            set Button(button[id][j]).visible = false
                        endif
                    set j = j + 1
                endloop
            endif

            set i = null
        endmethod

        method removeComponents takes ItemTable i, unit u, Transaction t returns nothing
            local integer j = 0
            local integer k = 0
            local ItemTable component

            loop
                exitwhen j == i.components
                    set component = ItemTable.get(i.component[j])

                    if UnitHasItemOfType(u, component.id) then
                        set k = 0

                        loop
                            exitwhen k == UnitInventorySize(u)
                                if GetItemTypeId(UnitItemInSlot(u, k)) == component.id then
                                    call RemoveItem(UnitItemInSlot(u, k))
                                    exitwhen true
                                endif
                            set k = k + 1
                        endloop

                        call t.add(component)
                    else
                        call removeComponents(component, u, t)
                    endif
                set j = j + 1
            endloop
        endmethod

        static method create takes Shop shop returns thistype
            local thistype this = thistype.allocate()
            local integer i = 0
            local integer j = 0

            set .shop = shop
            set isVisible = true
            set selected = Table.create()
            set item = HashTable.create()
            set button = HashTable.create()
            set frame = BlzCreateFrameByType("BACKDROP", "", BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "", 0)
            set scrollFrame = BlzCreateFrameByType("BUTTON", "", frame, "", 0)

            call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, shop.buyer.frame, FRAMEPOINT_TOPLEFT, 0, 0)
            call BlzFrameSetSize(frame, INVENTORY_WIDTH, INVENTORY_HEIGHT)
            call BlzFrameSetTexture(frame, INVENTORY_TEXTURE, 0, false)
            call BlzFrameSetAllPoints(scrollFrame, frame)

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    set j = 0

                    loop
                        exitwhen j == INVENTORY_COUNT
                            set button[i][j] = Button.create(scrollFrame, INVENTORY_SIZE, INVENTORY_SIZE, 0.0033700 + INVENTORY_GAP*j, - 0.0037500, false, true)
                            set Button(button[i][j]).tooltip.point = FRAMEPOINT_BOTTOM
                            set Button(button[i][j]).onClick = function thistype.onClick
                            set Button(button[i][j]).onDoubleClick = function thistype.onDoubleClick
                            set Button(button[i][j]).onRightClick = function thistype.onRightClick
                            set Button(button[i][j]).visible = false
                            set table[button[i][j]][0] = this
                            set table[button[i][j]][1] = j
                        set j = j + 1
                    endloop
                set i = i + 1
            endloop

            return this
        endmethod

        static method onClick takes nothing returns nothing
            local player p = GetTriggerPlayer()
            local Button b = GetTriggerButton()
            local integer id = GetPlayerId(p)
            local integer i = table[b][1]
            local thistype this = table[b][0]

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    set Button(button[id][selected[id]]).highlighted = false
                    set Button(button[id][i]).highlighted = true
                endif

                set selected[id] = i
            endif
        endmethod

        static method onDoubleClick takes nothing returns nothing
            local Button b = GetTriggerButton()
            local player p = GetTriggerPlayer()
            local thistype this = table[b][0]
            local integer i = table[b][1]
            local integer id = GetPlayerId(p)

            if this != 0 then
                if shop.sell(item[id][i], p, i) then
                    call show(shop.buyer.selected.unit[id])
                endif
            endif

            set p = null
        endmethod

        static method onRightClick takes nothing returns nothing
            local player p = GetTriggerPlayer()
            local integer id = GetPlayerId(p)
            local Button b = GetTriggerButton()
            local thistype this = table[b][0]
            local integer i = table[b][1]

            if this != 0 then
                if shop.sell(item[id][i], p, i) then
                    call show(shop.buyer.selected.unit[id])
                endif
            endif

            set p = null
        endmethod
    endstruct

    private struct Buyer
        private static Table current
        readonly static trigger trigger = CreateTrigger()

        private boolean isVisible

        Shop shop
        Inventory inventory
        Button left
        Button right
        Table last
        Table index
        Table size
        Table selected
        HashTable button
        HashTable unit
        framehandle frame
        framehandle scrollFrame

        method operator visible= takes boolean visibility returns nothing
            local integer i = 0
            local integer id = GetPlayerId(GetLocalPlayer())

            set isVisible = visibility
            set inventory.visible = visibility

            if isVisible then
                loop
                    exitwhen i == BUYER_COUNT
                        if unit[id].unit[i] == selected.unit[id] then
                            call inventory.move(FRAMEPOINT_TOP, Button(button[id][i]).frame, FRAMEPOINT_BOTTOM)
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

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    set j = 0

                    loop
                        exitwhen j == BUYER_COUNT
                            call table.remove(button[i][j])
                            call Button(button[i][j]).destroy()
                        set j = j + 1
                    endloop

                    call button.remove(i)
                    call unit.remove(i)
                set i = i + 1
            endloop

            call BlzDestroyFrame(frame)
            call BlzDestroyFrame(scrollFrame)
            call button.destroy()
            call unit.destroy()
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
            local integer id = GetPlayerId(p)
            local boolean flag = false
            local integer i
            local unit u
            
            if left then
                if (index[id] + 1 + BUYER_COUNT) <= size[id] and size[id] > 0 then
                    set index[id] = index[id] + 1
                    set i = 0

                    loop
                        exitwhen i == BUYER_COUNT - 1
                            set unit[id].unit[i] = unit[id].unit[i + 1]

                            if GetLocalPlayer() == p then
                                set Button(button[id][i]).icon = Button(button[id][i + 1]).icon
                                set Button(button[id][i]).tooltip.text = Button(button[id][i + 1]).tooltip.text
                                set Button(button[id][i]).highlighted = selected.unit[id] == unit[id].unit[i]
                                set Button(button[id][i]).visible = true

                                if Button(button[id][i]).highlighted then
                                    set flag = true
                                    call inventory.move(FRAMEPOINT_TOP, Button(button[id][i]).frame, FRAMEPOINT_BOTTOM)
                                endif
                            endif
                        set i = i + 1
                    endloop

                    set u = BlzGroupUnitAt(shop.group[id], index[id] + BUYER_COUNT)

                    if u != null then
                        set unit[id].unit[i] = u

                        if GetLocalPlayer() == p then
                            set Button(button[id][i]).icon = BlzGetAbilityIcon(GetUnitTypeId(u))
                            set Button(button[id][i]).tooltip.text = GetUnitName(u)
                            set Button(button[id][i]).visible = true
                            set Button(button[id][i]).highlighted = selected.unit[id] == unit[id].unit[i]

                            if Button(button[id][i]).highlighted then
                                set flag = true
                                call inventory.move(FRAMEPOINT_TOP, Button(button[id][i]).frame, FRAMEPOINT_BOTTOM)
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
                                set Button(button[id][i]).icon = Button(button[id][i - 1]).icon
                                set Button(button[id][i]).tooltip.text = Button(button[id][i - 1]).tooltip.text
                                set Button(button[id][i]).highlighted = selected.unit[id] == unit[id].unit[i]
                                set Button(button[id][i]).visible = true

                                if Button(button[id][i]).highlighted then
                                    set flag = true
                                    call inventory.move(FRAMEPOINT_TOP, Button(button[id][i]).frame, FRAMEPOINT_BOTTOM)
                                endif
                            endif
                        set i = i - 1
                    endloop
                    
                    set u = BlzGroupUnitAt(shop.group[id], index[id])

                    if u != null then
                        set unit[id].unit[i] = u

                        if GetLocalPlayer() == p then
                            set Button(button[id][i]).icon = BlzGetAbilityIcon(GetUnitTypeId(u))
                            set Button(button[id][i]).tooltip.text = GetUnitName(u)
                            set Button(button[id][i]).visible = true
                            set Button(button[id][i]).highlighted = selected.unit[id] == unit[id].unit[i]

                            if Button(button[id][i]).highlighted then
                                set flag = true
                                call inventory.move(FRAMEPOINT_TOP, Button(button[id][i]).frame, FRAMEPOINT_BOTTOM)
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
                    call IssueNeutralTargetOrder(Player(id), shop.current[id], "smart", selected.unit[id])
                    call inventory.show(selected.unit[id])

                    if GetLocalPlayer() == Player(id) then
                        call inventory.move(FRAMEPOINT_TOP, Button(button[id][0]).frame, FRAMEPOINT_BOTTOM)
                        call shop.details.refresh(Player(id))
                    endif
                endif
                
                set j = index[id]

                loop
                    exitwhen i == BUYER_COUNT
                        if j >= size[id] then
                            set unit[id].unit[i] = null

                            if GetLocalPlayer() == Player(id) then
                                set Button(button[id][i]).visible = false
                            endif
                        else
                            set u = BlzGroupUnitAt(g, j)
                            set unit[id].unit[i] = u

                            if selected.unit[id] == u then
                                set last[id] = button[id][i]
                            endif

                            if GetLocalPlayer() == Player(id) then
                                set Button(button[id][i]).icon = BlzGetAbilityIcon(GetUnitTypeId(u))
                                set Button(button[id][i]).tooltip.text = GetUnitName(u)
                                set Button(button[id][i]).highlighted = selected.unit[id] == u
                                set Button(button[id][i]).visible = true

                                if Button(button[id][i]).highlighted then
                                    set inventory.visible = true
                                    call inventory.move(FRAMEPOINT_TOP, Button(button[id][i]).frame, FRAMEPOINT_BOTTOM)
                                endif
                            endif

                            set j = j + 1
                        endif
                    set i = i + 1
                endloop
            else
                call current.remove(GetHandleId(selected.unit[id]))

                set index[id] = 0
                call selected.unit.remove(id)

                if GetLocalPlayer() == Player(id) then
                    set inventory.visible = false

                    loop
                        exitwhen i == BUYER_COUNT
                            set unit[id].unit[i] = null
                            set Button(button[id][i]).highlighted = false
                            set Button(button[id][i]).visible = false
                        set i = i + 1
                    endloop

                    call shop.details.refresh(Player(id))
                endif
            endif
        endmethod

        static method create takes Shop shop returns thistype
            local thistype this = thistype.allocate()
            local integer i = 0
            local integer j = 0

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
            set left = Button.create(scrollFrame, BUYER_SHIFT_BUTTON_SIZE, BUYER_SHIFT_BUTTON_SIZE, 0.027500, - 0.032500, true, false)
            set left.onClick = function thistype.onClick
            set left.icon = BUYER_LEFT
            set left.tooltip.text = "Scroll Left"
            set right = Button.create(scrollFrame, BUYER_SHIFT_BUTTON_SIZE, BUYER_SHIFT_BUTTON_SIZE, 0.36350, - 0.032500, true, false)
            set right.onClick = function thistype.onClick
            set right.icon = BUYER_RIGHT
            set right.tooltip.text = "Scroll Right"
            set inventory = Inventory.create(shop)
            set table[left][0] = this
            set table[right][0] = this
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
                            set button[i][j] = Button.create(scrollFrame, BUYER_SIZE, BUYER_SIZE, 0.045000 + BUYER_GAP*j, - 0.023000, true, false)
                            set Button(button[i][j]).onClick = function thistype.onClick
                            set Button(button[i][j]).onScroll = function thistype.onScroll
                            set Button(button[i][j]).visible = false
                            set table[button[i][j]][0] = this
                            set table[button[i][j]][1] = j
                        set j = j + 1
                    endloop
                set i = i + 1
            endloop

            return this
        endmethod

        static method onScroll takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())][0]

            if this == 0 then
                set this = table[GetTriggerButton()][0]
            endif

            if this != 0 then
                call shift(BlzGetTriggerFrameValue() < 0, GetTriggerPlayer())
            endif
        endmethod

        static method onClick takes nothing returns nothing
            local Button b = GetTriggerButton()
            local thistype this = table[b][0]
            local integer i = table[b][1]
            local integer id = GetPlayerId(GetTriggerPlayer())

            if this != 0 then
                if b == left then
                    call shift(false, GetTriggerPlayer())
                elseif b == right then
                    call shift(true, GetTriggerPlayer())
                else
                    call current.remove(GetHandleId(selected.unit[id]))
                    set selected.unit[id] = unit[id].unit[i]
                    set current[GetHandleId(selected.unit[id])] = this
                    call IssueNeutralTargetOrder(GetTriggerPlayer(), shop.current[id], "smart", selected.unit[id])
                    call inventory.show(selected.unit[id])
                    call inventory.selected.remove(id)

                    if GetLocalPlayer() == GetTriggerPlayer() then
                        set Button(last[id]).highlighted = false
                        set Button(button[id][i]).highlighted = true
                        set last[id] = button[id][i]
                        
                        call inventory.move(FRAMEPOINT_TOP, Button(button[id][i]).frame, FRAMEPOINT_BOTTOM)
                        call shop.details.refresh(GetTriggerPlayer())
                    endif
                endif
            endif
        endmethod

        private static method onPickup takes nothing returns nothing
            local unit u = GetManipulatingUnit()
            local integer i = GetPlayerId(GetOwningPlayer(u))
            local thistype this = current[GetHandleId(u)]

            if this != 0 then
                if shop.current[i] != null then
                    if selected.unit[i] == u and IsUnitInRange(u, shop.current[i], shop.aoe) then
                        call inventory.show(u)
                        call shop.details.refresh(GetOwningPlayer(u))
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
                    if selected.unit[i] == u and IsUnitInRange(u, shop.current[i], shop.aoe) then
                        call shop.details.refresh(GetOwningPlayer(u))
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
        Table count
        HashTable item
        HashTable button

        method destroy takes nothing returns nothing
            local integer i = 0
            local integer j

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    set j = 0

                    loop
                        exitwhen j == CATEGORY_COUNT
                            call table.remove(button[i][j])
                            call Button(button[i][j]).destroy()
                        set j = j + 1
                    endloop

                    call button.remove(i)
                    call item.remove(i)
                set i = i + 1
            endloop

            call count.destroy()
            call item.destroy()
            call button.destroy()
            call deallocate()
        endmethod

        method has takes integer id, player p returns boolean
            local integer i = 0
            local integer pid = GetPlayerId(p)

            loop
                exitwhen i > count.integer[pid]
                    if ItemTable(item[pid][i]).id == id then
                        return true
                    endif
                set i = i + 1
            endloop

            return false
        endmethod

        method clear takes player p returns nothing
            local integer id = GetPlayerId(p)

            loop
                exitwhen count[id] == -1
                    if GetLocalPlayer() == p then
                        set Button(button[id][count[id]]).visible = false
                        call ShopSlot(table[shop][ItemTable(item[id][count[id]]).id]).button.tag(null, 0, null, null, 0, 0)
                    endif
                set count[id] = count[id] - 1
            endloop
        endmethod

        method remove takes integer i, player p returns nothing
            local integer id = GetPlayerId(p)

            if GetLocalPlayer() == p then
                call ShopSlot(table[shop][ItemTable(item[id][i]).id]).button.tag(null, 0, null, null, 0, 0)
            endif

            loop
                exitwhen i >= count[id]
                    set item[id][i] = item[id][i + 1]

                    if GetLocalPlayer() == p then
                        set Button(button[id][i]).icon = ItemTable(item[id][i]).icon
                        set Button(button[id][i]).tooltip.text = ItemTable(item[id][i]).tooltip
                        set Button(button[id][i]).tooltip.name = ItemTable(item[id][i]).name
                        set Button(button[id][i]).tooltip.icon = ItemTable(item[id][i]).icon
                    endif
                set i = i + 1
            endloop

            if GetLocalPlayer() == p then
                set Button(button[id][count[id]]).visible = false
            endif
            
            set count[id] = count[id] - 1
        endmethod

        method add takes ItemTable i, player p returns nothing
            local integer id = GetPlayerId(p)

            if count.integer[id] < CATEGORY_COUNT - 1 then
                if not has(i.id, p) then
                    set count[id] = count[id] + 1
                    set item[id][count[id]] = i

                    if GetLocalPlayer() == p then
                        set Button(button[id][count[id]]).icon = i.icon
                        set Button(button[id][count[id]]).tooltip.text = i.tooltip
                        set Button(button[id][count[id]]).tooltip.name = i.name
                        set Button(button[id][count[id]]).tooltip.icon = i.icon
                        set Button(button[id][count[id]]).visible = true
                        call ShopSlot(table[shop][i.id]).button.tag(TAG_HIGHLIGHT, TAG_HIGHLIGHT_SCALE, TAG_HIGHLIGHT_POINT, TAG_HIGHLIGHT_RELATIVE_POINT, TAG_HIGHLIGHT_XOFFSET, TAG_HIGHLIGHT_YOFFSET)
                    endif
                endif
            endif
        endmethod

        static method create takes Shop shop returns thistype
            local thistype this = thistype.allocate()
            local integer i = 0
            local integer j

            set .shop = shop
            set count = Table.create()
            set item = HashTable.create()
            set button = HashTable.create()
            
            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS   
                    set j = 0
                    set count[i] = -1

                    loop
                        exitwhen j == CATEGORY_COUNT
                            set button[i][j] = Button.create(shop.rightPanel, CATEGORY_SIZE, CATEGORY_SIZE, 0.023750, - (0.021500 + CATEGORY_SIZE*j + CATEGORY_GAP), false, false)
                            set Button(button[i][j]).visible = false
                            set Button(button[i][j]).onClick = function thistype.onClick
                            set Button(button[i][j]).onDoubleClick = function thistype.onDoubleClick
                            set Button(button[i][j]).onRightClick = function thistype.onRightClick
                            set Button(button[i][j]).tooltip.point = FRAMEPOINT_TOPRIGHT
                            set table[button[i][j]][0] = this
                            set table[button[i][j]][1] = j
        
                            if j > 6 then
                                set Button(button[i][j]).tooltip.point = FRAMEPOINT_BOTTOMRIGHT
                            endif
                        set j = j + 1
                    endloop
                set i = i + 1
            endloop

            return this
        endmethod

        static method onClick takes nothing returns nothing
            local Button b = GetTriggerButton()
            local thistype this = table[b][0]
            local integer i = table[b][1]
            local integer id = GetPlayerId(GetTriggerPlayer())

            if this != 0 then
                if Shop.tag[id] then
                    call remove(i, GetTriggerPlayer())
                else
                    call shop.detail(item[id][i], GetTriggerPlayer())
                endif
            endif
        endmethod

        static method onDoubleClick takes nothing returns nothing
            local Button b = GetTriggerButton()
            local player p = GetTriggerPlayer()
            local thistype this = table[b][0]
            local integer i = table[b][1]
            local integer id = GetPlayerId(p)

            if this != 0 then
                if shop.buy(item[id][i], p) then
                    if GetLocalPlayer() == p then
                        call Button(button[id][i]).play(SPRITE_MODEL, SPRITE_SCALE, 0)
                    endif
                endif
            endif

            set p = null
        endmethod

        static method onRightClick takes nothing returns nothing
            local player p = GetTriggerPlayer()
            local Button b = GetTriggerButton()
            local integer id = GetPlayerId(p)
            local thistype this = table[b][0]
            local integer i = table[b][1]

            if this != 0 then
                if shop.buy(item[id][i], p) then
                    if GetLocalPlayer() == p then
                        call Button(button[id][i]).play(SPRITE_MODEL, SPRITE_SCALE, 0)
                    endif
                endif
            endif

            set p = null
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
                    call table.remove(button[count])
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
                set button[count] = Button.create(shop.leftPanel, CATEGORY_SIZE, CATEGORY_SIZE, 0.023750, - (0.021500 + CATEGORY_SIZE*count + CATEGORY_GAP), true, false)
                set button[count].icon = icon
                set button[count].enabled = false
                set button[count].onClick = function thistype.onClick
                set button[count].tooltip.text = description
                set table[button[count]][0] = this
                set table[button[count]][1] = count

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
            local Button b = GetTriggerButton()
            local thistype this = table[b][0]
            local integer i = table[b][1]

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
            endif
        endmethod
    endstruct
    
    struct Shop
        private static trigger trigger = CreateTrigger()
        private static trigger search = CreateTrigger()
        private static trigger keyPress = CreateTrigger()
        private static trigger escPressed = CreateTrigger()
        private static trigger enter = CreateTrigger()
        private static timer update = CreateTimer()
        private static timer timer = CreateTimer()
        private static integer count = -1
        private static HashTable itempool
        private static ItemTable array selected
        readonly static sound success
        readonly static sound error
        readonly static sound array noGold
        readonly static group array group
        readonly static boolean array tag
        readonly static unit array current

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
        readonly Button break
        readonly Button revert
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
        readonly real tax
        Table scrollCount
        Table scrollFlag
        Table lastClicked
        HashTable transaction
        Table transactionCount

        method operator visible= takes boolean visibility returns nothing
            set isVisible = visibility
            set buyer.visible = visibility

            if not visibility then
                set buyer.index = 0
            else
                if details.visible then
                    call details.refresh(GetLocalPlayer())
                endif
            endif

            call BlzFrameSetVisible(base, visibility)
        endmethod

        method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method destroy takes nothing returns nothing
            local integer i = 0
            local ShopSlot slot = itempool[this][0]

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    call transaction[i].flush()
                set i = i + 1
            endloop

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
            call lastClicked.destroy()
            call transaction.destroy()
            call transactionCount.destroy()
            call break.destroy()
            call revert.destroy()
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

        method canBuy takes ItemTable i, player p returns boolean
            local ItemTable component
            local boolean flag = true
            local integer j = 0


            if i != 0 and has(i.id) and buyer.selected.unit.has(GetPlayerId(p)) then
                if i.components > 0 then
                    loop
                        exitwhen j == i.components or not flag
                            set flag = canBuy(ItemTable.get(i.component[j]), p)
                        set j = j + 1
                    endloop
                endif

                return flag
            endif

            return false
        endmethod

        method buy takes ItemTable i, player p returns boolean
            local item new
            local Transaction t
            local integer id = GetPlayerId(p)
            local unit u = buyer.selected.unit[id]
            local integer cost = i.cost(u)
            
            if canBuy(i, p) and cost <= GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) then
                set t = Transaction.create(this, u, i, "buy")
                set t.gold = cost
                set transaction[id][transactionCount[id]] = t
                set transactionCount[id] = transactionCount[id] + 1
                set new = CreateItem(i.id, GetUnitX(u), GetUnitY(u))

                call buyer.inventory.removeComponents(i, u, t)

                if not UnitAddItem(u, new) then
                    call IssueTargetItemOrder(u, "smart", new)
                endif

                call buyer.inventory.show(u)
                call details.refresh(p)
                call SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) - t.gold)

                if not GetSoundIsPlaying(success) then
                    call StartSoundForPlayerBJ(p, success)
                endif

                set u = null
                set new = null

                return true
            else
                if cost > GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) then
                    if not GetSoundIsPlaying(noGold[GetHandleId(GetPlayerRace(p))]) then
                        call StartSoundForPlayerBJ(p, noGold[GetHandleId(GetPlayerRace(p))])
                    endif
                else
                    if not GetSoundIsPlaying(error) then
                        call StartSoundForPlayerBJ(p, error)
                    endif
                endif

                return false
            endif

            return false
        endmethod

        method sell takes ItemTable i, player p, integer slot returns boolean
            local unit u
            local Transaction t
            local integer cost
            local integer gold
            local integer charges
            local integer id = GetPlayerId(p)
            local boolean sold = false

            if i != 0 and buyer.selected.unit.has(id) then
                set u = buyer.selected.unit[id]
                set charges = GetItemCharges(UnitItemInSlot(u, slot))

                if charges == 0 then
                    set charges = 1
                endif

                set gold = GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD)
                set cost = R2I(R2I(i.gold / i.charges) * charges * tax)

                if GetItemTypeId(UnitItemInSlot(u, slot)) == i.id then
                    set sold = true
                    set t = Transaction.create(this, u, i, "sell")
                    set t.gold = cost
                    set transaction[id][transactionCount[id]] = t
                    set transactionCount[id] = transactionCount[id] + 1

                    call RemoveItem(UnitItemInSlot(u, slot))
                    call SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, gold + cost)
                    call buyer.inventory.show(u)
                    call details.refresh(p)
                endif

                if not GetSoundIsPlaying(success) then
                    call StartSoundForPlayerBJ(p, success)
                endif
            else
                if not GetSoundIsPlaying(error) then
                    call StartSoundForPlayerBJ(p, error)
                endif
            endif

            return sold
        endmethod

        method dismantle takes ItemTable i, player p, integer slot returns nothing
            local unit u
            local Transaction t
            local integer slots = 0
            local integer j = 0
            local integer id = GetPlayerId(p)

            if i != 0 and buyer.selected.unit.has(id) then
                if i.components > 0 then
                    set u = buyer.selected.unit[id]

                    loop
                        exitwhen j == UnitInventorySize(u)
                            if UnitItemInSlot(u, j) == null then
                                set slots = slots + 1
                            endif
                        set j = j + 1
                    endloop

                    if (slots + 1) >= i.components then
                        set j = 0
                        set t = Transaction.create(this, u, i, "dismantle")
                        set transaction[id][transactionCount[id]] = t
                        set transactionCount[id] = transactionCount[id] + 1

                        call RemoveItem(UnitItemInSlot(u, slot))

                        loop
                            exitwhen j == i.components
                                call UnitAddItemById(u, ItemTable.get(i.component[j]).id)
                            set j = j + 1
                        endloop

                        if not GetSoundIsPlaying(success) then
                            call StartSoundForPlayerBJ(p, success)
                        endif

                        call buyer.inventory.show(u)
                        call details.refresh(p)
                    else
                        if not GetSoundIsPlaying(error) then
                            call StartSoundForPlayerBJ(p, error)
                        endif
                    endif
                else
                    if not GetSoundIsPlaying(error) then
                        call StartSoundForPlayerBJ(p, error)
                    endif
                endif
            else
                if not GetSoundIsPlaying(error) then
                    call StartSoundForPlayerBJ(p, error)
                endif
            endif

            set u = null
        endmethod

        method undo takes player p returns nothing
            local integer id = GetPlayerId(p)

            if transactionCount[id] > 0 then
                call Transaction(transaction[id][transactionCount[id] - 1]).rollback()
                call buyer.inventory.show(buyer.selected.unit[id])
                call details.refresh(p)
            else
                if not GetSoundIsPlaying(error) then
                    call StartSoundForPlayerBJ(p, error)
                endif
            endif
        endmethod

        method scroll takes boolean down returns boolean
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

                return true
            endif

            return false
        endmethod

        method scrollTo takes ItemTable i, player p returns nothing
            local ShopSlot slot

            if i != 0 and GetLocalPlayer() == p then
                set slot = ShopSlot(table[this][i.id])
    
                loop
                    exitwhen slot.visible or not scroll(true)
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

        method select takes ItemTable i, player p returns nothing
            local integer id = GetPlayerId(p)

            if i != 0 and GetLocalPlayer() == p then
                if lastClicked[id] != 0 then
                    call Button(lastClicked[id]).display(null, 0, null, null, 0, 0)
                endif

                set selected[id] = i
                set lastClicked[id] = ShopSlot(table[this][i.id]).button
                call Button(lastClicked[id]).display(ITEM_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_POINT, HIGHLIGHT_RELATIVE_POINT, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
            endif
        endmethod

        method detail takes ItemTable i, player p returns nothing
            if i != 0 then
                if GetLocalPlayer() == p then
                    set rows = DETAILED_ROWS
                    set columns = DETAILED_COLUMNS

                    if not detailed then
                        set detailed = true
                        call filter(category.active, category.andLogic)
                    endif
                endif

                if not details.visible then
                    call scrollTo(i, p)
                endif

                call select(i, p)
                call details.show(i, p)
            else
                if GetLocalPlayer() == p then
                    set rows = ROWS
                    set columns = COLUMNS
                    set detailed  = false
                    set details.visible = false
                    call filter(category.active, category.andLogic)
                    call scrollTo(selected[GetPlayerId(p)], p)
                endif
            endif
        endmethod

        method has takes integer id returns boolean
            return table[this].has(id)
        endmethod

        method clearTransactions takes player p returns nothing
            local integer i = 0
            local integer id = GetPlayerId(p)

            loop
                exitwhen i == transactionCount[id]
                    call Transaction(transaction[id][i]).destroy()
                set i = i + 1
            endloop

            set transactionCount[id] = 0
            call transaction[id].flush()
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
            local ItemTable i

            if this != 0 then
                if not table[this].has(itemId) then
                    set i = ItemTable.create(itemId, categories)
                    
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

        static method create takes integer id, real aoe, real returnRate returns thistype
            local thistype this
            local integer i = 0

            if not table[id].has(0) then
                set this = thistype.allocate()
                set .id = id
                set .aoe = aoe
                set tax = returnRate
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
                set scrollCount = Table.create()
                set scrollFlag = Table.create()
                set lastClicked = Table.create()
                set transactionCount = Table.create()
                set transaction = HashTable.create()
                set base = BlzCreateFrame("EscMenuBackdrop", BlzGetFrameByName("ConsoleUIBackdrop", 0), 0, 0)
                set main = BlzCreateFrameByType("BUTTON", "main", base, "", 0)
                set edit = BlzCreateFrame("EscMenuEditBoxTemplate", main, 0, 0)
                set leftPanel = BlzCreateFrame("EscMenuBackdrop", base, 0, 0)
                set rightPanel = BlzCreateFrame("EscMenuBackdrop", base, 0, 0)
                set category = Category.create(this)
                set favorites = Favorites.create(this)
                set details = Detail.create(this)
                set buyer = Buyer.create(this)
                set close = Button.create(main, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, (WIDTH - 2*TOOLBAR_BUTTON_SIZE), 0.015000, true, false)
                set close.icon = CLOSE_ICON
                set close.onClick = function thistype.onClose
                set close.tooltip.text = "Close"
                set break = Button.create(main, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, (WIDTH - 2*TOOLBAR_BUTTON_SIZE - 0.0205), 0.015000, true, false)
                set break.icon = DISMANTLE_ICON
                set break.onClick = function thistype.onDismantle
                set break.tooltip.text = "Dismantle"
                set revert = Button.create(main, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, (WIDTH - 2*TOOLBAR_BUTTON_SIZE - 0.0410), 0.015000, true, false)
                set revert.icon = UNDO_ICON
                set revert.onClick = function thistype.onUndo
                set revert.tooltip.text = "Undo"
                set clearCategory = Button.create(leftPanel, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, 0.028000, 0.015000, true, false)
                set clearCategory.icon = CLEAR_ICON
                set clearCategory.onClick = function thistype.onClear
                set clearCategory.tooltip.text = "Clear Category"
                set clearFavorites = Button.create(rightPanel, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, 0.027000, 0.015000, true, false)
                set clearFavorites.icon = CLEAR_ICON
                set clearFavorites.onClick = function thistype.onClear
                set clearFavorites.tooltip.text = "Clear Favorites"
                set logic = Button.create(leftPanel, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, 0.049000, 0.015000, true, false)
                set logic.icon = LOGIC_ICON
                set logic.onClick = function thistype.onLogic
                set logic.enabled = false
                set logic.tooltip.text = "AND Logic"
                set table[id][0] = this
                set table[GetHandleId(main)][0] = this
                set table[GetHandleId(main)][2] = this
                set table[close][0] = this
                set table[break][0] = this
                set table[revert][0] = this
                set table[clearCategory][0] = this
                set table[clearFavorites][0] = this
                set table[logic][0] = this
                set table[GetHandleId(edit)][0] = this

                loop
                    exitwhen i >= bj_MAX_PLAYER_SLOTS
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

        static method onScroll takes nothing returns nothing
            local thistype this = table[GetHandleId(BlzGetTriggerFrame())][2]
            local integer i = GetPlayerId(GetTriggerPlayer())
            local boolean direction = BlzGetTriggerFrameValue() < 0

            if this != 0 then
                if scrollFlag.boolean[i] != direction then
                    set scrollFlag.boolean[i] = direction
                    set scrollCount[i] = 0
                else
                    set scrollCount[i] = scrollCount[i] + 1
                endif

                if GetLocalPlayer() == GetTriggerPlayer() then
                    if scrollCount[i] == 1 then
                        call scroll(direction)
                    else
                        call scroll(direction)
                    endif
                endif
            endif
        endmethod

        private static method onExpire takes nothing returns nothing
            local integer id = GetPlayerId(GetLocalPlayer())
            local thistype this = table[GetUnitTypeId(current[id])][0]

            if this != 0 then
                set scrollCount[id] = scrollCount[id] - 1

                if scrollCount[id] > 0 then
                    call scroll(scrollFlag.boolean[id])
                else
                    set scrollCount[id] = 0
                endif
            endif
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
            local thistype this = table[GetTriggerButton()][0]

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
            endif
        endmethod

        private static method onClear takes nothing returns nothing
            local Button b = GetTriggerButton()
            local thistype this = table[b][0]

            if this != 0 then
                if b == clearCategory then
                    if GetLocalPlayer() == GetTriggerPlayer() then
                        call category.clear()
                    endif
                else
                    call favorites.clear(GetTriggerPlayer())
                endif
            endif
        endmethod

        private static method onClose takes nothing returns nothing
            local thistype this = table[GetTriggerButton()][0]
            local player p = GetTriggerPlayer()
            local integer id = GetPlayerId(p)

            if this != 0 then
                if GetLocalPlayer() == p then
                    set visible = false
                endif

                set selected[id] = 0
                set current[id] = null
                call clearTransactions(p)
            endif

            set p = null
        endmethod

        private static method onDismantle takes nothing returns nothing
            local thistype this = table[GetTriggerButton()][0]
            local player p = GetTriggerPlayer()
            local integer id = GetPlayerId(p)

            if this != 0 then
                if buyer.inventory.selected.has(id) then
                    call dismantle(ItemTable(buyer.inventory.item[id][buyer.inventory.selected[id]]), p, buyer.inventory.selected[id])
                else
                    if not GetSoundIsPlaying(error) then
                        call StartSoundForPlayerBJ(p, error)
                    endif
                endif
            endif

            set p = null
        endmethod

        private static method onUndo takes nothing returns nothing
            local thistype this = table[GetTriggerButton()][0]

            if this != 0 then
                call undo(GetTriggerPlayer())
            endif
        endmethod

        private static method onSelect takes nothing returns nothing
            local thistype this = table[GetUnitTypeId(GetTriggerUnit())][0]
            local player p = GetTriggerPlayer()
            local integer id = GetPlayerId(p)

            if this != 0 then
                if GetLocalPlayer() == p then
                    set visible = GetTriggerEventId() == EVENT_PLAYER_UNIT_SELECTED
                endif

                if GetTriggerEventId() == EVENT_PLAYER_UNIT_SELECTED then
                    set current[id] = GetTriggerUnit()
                    call buyer.inventory.show(buyer.selected.unit[id])
                else
                    set current[id] = null
                    call clearTransactions(p)
                endif
            endif

            set p = null
        endmethod

        private static method onKey takes nothing returns nothing
            set tag[GetPlayerId(GetTriggerPlayer())] = BlzGetTriggerPlayerIsKeyDown()
        endmethod

        private static method onEsc takes nothing returns nothing
            local thistype this
            local player p = GetTriggerPlayer()
            local integer i = 0
            local integer id = GetHandleId(p)
            
            loop
                exitwhen i > count
                    set this = table[id][table[id][i]]

                    if this != 0 then
                        if GetLocalPlayer() == p then
                            set visible = false
                        endif

                        set selected[id] = 0
                        set current[GetPlayerId(p)] = null
                        call clearTransactions(p)
                    endif
                set i = i + 1
            endloop

            set p = null
        endmethod

        private static method onInit takes nothing returns nothing
            local integer i = 0
            local integer id

            set table = HashTable.create()
            set itempool = HashTable.create()

            set success = CreateSound(SUCCESS_SOUND, false, false, false, 10, 10, "")
            call SetSoundDuration(success, 1600)
            set error = CreateSound(ERROR_SOUND, false, false, false, 10, 10, "")
            call SetSoundDuration(error, 614)
            set id = GetHandleId(RACE_HUMAN)
            set noGold[id] = CreateSound("Sound\\Interface\\Warning\\Human\\KnightNoGold1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noGold[id], "NoGoldHuman")
            call SetSoundDuration(noGold[id], 1618)
            set id = GetHandleId(RACE_ORC)
            set noGold[id] = CreateSound("Sound\\Interface\\Warning\\Orc\\GruntNoGold1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noGold[id], "NoGoldOrc")
            call SetSoundDuration(noGold[id], 1450)
            set id = GetHandleId(RACE_NIGHTELF)
            set noGold[id] = CreateSound("Sound\\Interface\\Warning\\NightElf\\SentinelNoGold1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noGold[id], "NoGoldNightElf")
            call SetSoundDuration(noGold[id], 1229)
            set id = GetHandleId(RACE_UNDEAD)
            set noGold[id] = CreateSound("Sound\\Interface\\Warning\\Undead\\NecromancerNoGold1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noGold[id], "NoGoldUndead")
            call SetSoundDuration(noGold[id], 2005)
            set id = GetHandleId(ConvertRace(11))
            set noGold[id] = CreateSound("Sound\\Interface\\Warning\\Naga\\NagaNoGold1.wav", false, false, false, 10, 10, "")
            call SetSoundParamsFromLabel(noGold[id], "NoGoldNaga")
            call SetSoundDuration(noGold[id], 2690)

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    set tag[i] = false
                    set group[i] = CreateGroup()
                    call BlzTriggerRegisterPlayerKeyEvent(keyPress, Player(i), FAVORITE_KEY, 0, true)
                    call BlzTriggerRegisterPlayerKeyEvent(keyPress, Player(i), FAVORITE_KEY, 0, false)
                    call TriggerRegisterPlayerEventEndCinematic(escPressed, Player(i))
                set i = i + 1
            endloop

            if SCROLL_DELAY > 0 then
                call TimerStart(timer, SCROLL_DELAY, true, function thistype.onExpire)
            endif

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