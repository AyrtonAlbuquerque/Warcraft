library Shop requires Table, RegisterPlayerUnitEvent, Components, Item
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

        // Side Panels
        private constant real SIDE_WIDTH                = 0.075
        private constant real SIDE_HEIGHT               = HEIGHT
        private constant real EDIT_WIDTH                = 0.15
        private constant real EDIT_HEIGHT               = 0.0285

        // Category and Favorite buttons
        private constant integer CATEGORY_COUNT         = 13
        private constant real CATEGORY_SIZE             = 0.02750
        private constant real CATEGORY_GAP              = 0.0

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

        // Tagged item highlight
        private constant string TAG_MODEL               = "crystallid_sprite.mdx"
        private constant real TAG_SCALE                 = 0.75
        private constant real TAG_XOFFSET               = -0.0052
        private constant real TAG_YOFFSET               = -0.0048

        // Scroll
        private constant real SCROLL_DELAY              = 0.075

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
        call TriggerSleepAction(0) // This is here to ensure that any Item inheritance is initialized before the Shop is created
        call Shop.create(id, aoe, returnRate)
    endfunction
    
    function ShopAddCategory takes integer id, string icon, string description returns integer
        return Shop.addCategory(id, icon, description)
    endfunction

    function ShopAddItem takes integer id, integer itemId, integer categories returns nothing
        call Shop.addItem(id, itemId, categories)
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
    private struct Sound
        private static sound success_sound
        private static sound error_sound
        private static sound array noGold

        static method gold takes player p returns nothing
            if not GetSoundIsPlaying(noGold[GetHandleId(GetPlayerRace(p))]) then
                call StartSoundForPlayerBJ(p, noGold[GetHandleId(GetPlayerRace(p))])
            endif
        endmethod

        static method success takes player p returns nothing
            if not GetSoundIsPlaying(success_sound) then
                call StartSoundForPlayerBJ(p, success_sound)
            endif
        endmethod

        static method error takes player p returns nothing
            if not GetSoundIsPlaying(error_sound) then
                call StartSoundForPlayerBJ(p, error_sound)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            local integer id

            set success_sound = CreateSound(SUCCESS_SOUND, false, false, false, 10, 10, "")
            call SetSoundDuration(success_sound, 1600)
            set error_sound = CreateSound(ERROR_SOUND, false, false, false, 10, 10, "")
            call SetSoundDuration(error_sound, 614)
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
        endmethod
    endstruct
    
    private struct Transaction
        private static HashTable counter
        private static HashTable transactions

        private integer index

        Shop shop
        Item item
        unit unit
        string type
        integer id
        integer gold
        player player
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
                                call UnitAddItemById(unit, Item(component[i]).id)
                            set i = i + 1
                        endloop

                        call SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD) + gold)
                        call Sound.success(player)
                    else
                        call Sound.error(player)
                    endif
                elseif type == "sell" then
                    call UnitAddItemById(unit, item.id)
                    call SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD) - gold)
                    call Sound.success(player)
                else
                    loop
                        exitwhen i == item.components
                            set j = 0

                            loop
                                exitwhen j == UnitInventorySize(unit)
                                    if GetItemTypeId(UnitItemInSlot(unit, j)) == Item.get(item.component[i]).id then
                                        call RemoveItem(UnitItemInSlot(unit, j))
                                        exitwhen true
                                    endif
                                set j = j + 1
                            endloop
                        set i = i + 1
                    endloop

                    call UnitAddItemById(unit, item.id)
                    call Sound.success(player)
                endif
            else
                call Sound.error(player)
            endif

            set counter[shop][id] = counter[shop][id] - 1
            call Table(transactions[shop][id]).remove(counter[shop][id])
            call destroy()
        endmethod

        method add takes Item i returns nothing
            if i != 0 then
                set component[index] = i
                set index = index + 1
            endif
        endmethod

        static method last takes Shop shop, integer id returns thistype
            if count(shop, id) > 0 then
                return Transaction(Table(transactions[shop][id])[counter[shop][id] - 1])
            endif

            return 0
        endmethod

        static method count takes Shop shop, integer id returns integer
            return counter[shop][id]
        endmethod

        static method clear takes Shop shop, integer id returns nothing
            local integer i = 0

            loop
                exitwhen i == counter[shop][id]
                    call Transaction(Table(transactions[shop][id])[i]).destroy()
                set i = i + 1
            endloop

            set counter[shop][id] = 0
            call Table(transactions[shop][id]).flush()
        endmethod

        static method create takes Shop shop, unit u, Item i, integer gold, string transaction returns thistype
            local thistype this = thistype.allocate()

            set item = i
            set unit = u
            set .shop = shop
            set .gold = gold
            set type = transaction
            set index = 0
            set player = GetOwningPlayer(u)
            set id = GetPlayerId(player)
            set component = Table.create()

            if not transactions[shop].has(id) then
                set transactions[shop][id] = Table.create()
            endif

            set Table(transactions[shop][id])[counter[shop][id]] = this
            set counter[shop][id] = counter[shop][id] + 1

            return this
        endmethod

        private static method onInit takes nothing returns nothing
            set counter = HashTable.create()
            set transactions = HashTable.create()
        endmethod
    endstruct

    private struct Inventory
        private boolean isVisible

        Shop shop
        Table selected
        HashTable item
        HashTable button
        framehandle frame

        method operator visible= takes boolean visibility returns nothing
            set isVisible = visibility
            call BlzFrameSetVisible(frame, visibility)
        endmethod

        method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method operator [] takes integer id returns integer
            return selected[id]
        endmethod

        method destroy takes nothing returns nothing
            local integer i = 0
            local integer j

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                        set j = 0

                        loop
                            exitwhen j == INVENTORY_COUNT
                                call table.remove(button[i][j])
                                call Button(button[i][j]).destroy()
                            set j = j + 1
                        endloop

                        call button.remove(i)
                        call item.remove(i)
                    endif
                set i = i + 1
            endloop

            call BlzDestroyFrame(frame)
            call selected.destroy()
            call button.destroy()
            call item.destroy()
            call deallocate()

            set frame = null
        endmethod

        method has takes integer id returns boolean
            return selected.has(id)
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
                            set item[id][j] = Item.get(GetItemTypeId(i))

                            if GetLocalPlayer() == GetOwningPlayer(u) then
                                set Button(button[id][j]).texture = Item(item[id][j]).icon
                                set Button(button[id][j]).tooltip.icon = Item(item[id][j]).icon
                                set Button(button[id][j]).tooltip.name = Item(item[id][j]).name
                                set Button(button[id][j]).tooltip.text = Item(item[id][j]).tooltip
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

        method remove takes integer id returns nothing
            call selected.remove(id)
        endmethod

        method removeComponents takes Item i, Transaction transaction returns nothing
            local integer j = 0
            local integer k = 0
            local Item component

            loop
                exitwhen j == i.components
                    set component = Item.get(i.component[j])

                    if UnitHasItemOfType(transaction.unit, component.id) then
                        set k = 0

                        loop
                            exitwhen k == UnitInventorySize(transaction.unit)
                                if GetItemTypeId(UnitItemInSlot(transaction.unit, k)) == component.id then
                                    call RemoveItem(UnitItemInSlot(transaction.unit, k))
                                    exitwhen true
                                endif
                            set k = k + 1
                        endloop

                        call transaction.add(component)
                    else
                        call removeComponents(component, transaction)
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

            call BlzFrameSetPoint(frame, FRAMEPOINT_TOPLEFT, shop.buyer.frame, FRAMEPOINT_TOPLEFT, 0, 0)
            call BlzFrameSetSize(frame, INVENTORY_WIDTH, INVENTORY_HEIGHT)
            call BlzFrameSetTexture(frame, INVENTORY_TEXTURE, 0, false)

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                        set j = 0

                        loop
                            exitwhen j == INVENTORY_COUNT
                                set button[i][j] = Button.create(0.0033700 + INVENTORY_GAP*j, - 0.0037500, INVENTORY_SIZE, INVENTORY_SIZE, frame, false)
                                set Button(button[i][j]).tooltip.point = FRAMEPOINT_BOTTOM
                                set Button(button[i][j]).onClick = function thistype.onClick
                                set Button(button[i][j]).onDoubleClick = function thistype.onDoubleClick
                                set Button(button[i][j]).onRightClick = function thistype.onRightClick
                                set Button(button[i][j]).visible = false
                                set table[button[i][j]][0] = this
                                set table[button[i][j]][1] = j
                            set j = j + 1
                        endloop
                    endif
                set i = i + 1
            endloop

            return this
        endmethod

        private static method onClick takes nothing returns nothing
            local player p = GetTriggerPlayer()
            local Button b = GetTriggerComponent()
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

        private static method onDoubleClick takes nothing returns nothing
            local Button b = GetTriggerComponent()
            local player p = GetTriggerPlayer()
            local thistype this = table[b][0]
            local integer i = table[b][1]
            local integer id = GetPlayerId(p)

            if this != 0 then
                if shop.sell(item[id][i], p, i) then
                    call show(shop.buyer[id])
                endif
            endif

            set p = null
        endmethod

        private static method onRightClick takes nothing returns nothing
            local player p = GetTriggerPlayer()
            local integer id = GetPlayerId(p)
            local Button b = GetTriggerComponent()
            local thistype this = table[b][0]
            local integer i = table[b][1]

            if this != 0 then
                if shop.sell(item[id][i], p, i) then
                    call show(shop.buyer[id])
                endif
            endif

            set p = null
        endmethod
    endstruct

    private struct Slot extends Button
        Shop shop
        Item item
        Text cost
        Backdrop gold

        thistype next
        thistype prev
        thistype left
        thistype right

        private integer current_row
        private integer current_column

        method operator row= takes integer newRow returns nothing
            set current_row = newRow
            set y = - (0.030000 + ((SLOT_HEIGHT + SLOT_GAP_Y) * newRow))

            call update()
        endmethod

        method operator row takes nothing returns integer
            return current_row
        endmethod

        method operator column= takes integer newColumn returns nothing
            set current_column = newColumn
            set x = 0.030000 + ((SLOT_WIDTH + SLOT_GAP_X) * newColumn)

            call update()
        endmethod

        method operator column takes nothing returns integer
            return current_column
        endmethod

        method destroy takes nothing returns nothing
            call cost.destroy()
            call gold.destroy()
        endmethod

        method update takes nothing returns nothing
            if column <= (shop.columns / 2) and row < 3 then
                set tooltip.point = FRAMEPOINT_TOPLEFT
            elseif column >= ((shop.columns / 2) + 1) and row < 3 then
                set tooltip.point = FRAMEPOINT_TOPRIGHT
            elseif column <= (shop.columns / 2) and row >= 3 then
                set tooltip.point = FRAMEPOINT_BOTTOMLEFT
            else
                set tooltip.point = FRAMEPOINT_BOTTOMRIGHT
            endif
        endmethod

        method move takes integer row, integer column returns nothing
            set .row = row
            set .column = column
        endmethod

        static method create takes Shop shop, Item i, real x, real y, framehandle parent returns thistype
            local thistype this = thistype.allocate(x, y, ITEM_SIZE, ITEM_SIZE, parent, false)

            set .x = x
            set .y = y
            set item = i
            set .shop = shop
            set next = 0
            set prev = 0
            set right = 0
            set left = 0
            set tooltip.point = FRAMEPOINT_TOPRIGHT
            set gold = Backdrop.create(0, - 0.04, GOLD_SIZE, GOLD_SIZE, frame, GOLD_ICON)
            set cost = Text.create(0.01325, - 0.00193, COST_WIDTH, COST_HEIGHT, COST_SCALE, false, gold.frame, null, TEXT_JUSTIFY_CENTER, TEXT_JUSTIFY_LEFT)

            if item != 0 then
                set texture = item.icon
                set tooltip.text = item.tooltip
                set tooltip.name = item.name
                set tooltip.icon = item.icon
                set cost.text = "|cffFFCC00" + I2S(item.gold) + "|r"
            endif

            return this
        endmethod

        private method onScroll takes nothing returns nothing
            if GetLocalPlayer() == GetTriggerPlayer() then
                call shop.onScroll()
            endif
        endmethod

        private method onClick takes nothing returns nothing
            call shop.detail(item, GetTriggerPlayer())
        endmethod

        private method onMiddleClick takes nothing returns nothing
            if shop.favorites.has(item.id, GetTriggerPlayer()) then
                call shop.favorites.remove(item, GetTriggerPlayer())
            else
                call shop.favorites.add(item, GetTriggerPlayer())
            endif
        endmethod

        private method onDoubleClick takes nothing returns nothing
            if shop.buy(item, GetTriggerPlayer()) then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    call play(SPRITE_MODEL, SPRITE_SCALE, 0)
                endif
            endif
        endmethod

        private method onRightClick takes nothing returns nothing
            if shop.buy(item, GetTriggerPlayer()) then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    call play(SPRITE_MODEL, SPRITE_SCALE, 0)
                endif
            endif
        endmethod
    endstruct

    private struct Detail extends Panel
        Shop shop
        Panel uses
        Button left
        Button right
        Button close
        Table item
        Table main
        Table count
        Text usedText
        Line separator
        Line vertical
        Line horizontal
        HashTable used
        HashTable lines
        HashTable button
        HashTable components
        TextArea array description[4]

        method destroy takes nothing returns nothing
            local integer i = 0
            local integer j = 0

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                        call table.remove(main[i])

                        loop
                            exitwhen j == 5
                                call table.remove(components[i][j])
                                call Line(lines[i][j]).destroy()
                                call Slot(components[i][j]).destroy()
                            set j = j + 1
                        endloop

                        set j = 0

                        loop
                            exitwhen j == DETAIL_USED_COUNT
                                call table.remove(button[i][j])
                                call Button(button[i][j]).destroy()
                            set j = j + 1
                        endloop

                        call used.remove(i)
                        call lines.remove(i)
                        call button.remove(i)
                        call components.remove(i)
                    endif
                set i = i + 1
            endloop

            call main.destroy()
            call count.destroy()
            call item.destroy()
            call close.destroy()
            call left.destroy()
            call right.destroy()
            call used.destroy()
            call lines.destroy()
            call button.destroy()
            call usedText.destroy()
            call components.destroy()
            call separator.destroy()
            call vertical.destroy()
            call horizontal.destroy()
            call description[0].destroy()
            call description[1].destroy()
            call description[2].destroy()
            call description[3].destroy()
        endmethod

        method shift takes boolean left, player p returns nothing
            local Item i
            local integer j
            local integer id = GetPlayerId(p)

            if left then
                if Item(item[id]).relation.has(count[id]) and count[id] >= DETAIL_USED_COUNT then
                    set j = 0

                    loop
                        exitwhen j == DETAIL_USED_COUNT - 1
                            set used[id][j] = used[id][j + 1]

                            if GetLocalPlayer() == p then
                                set Button(button[id][j]).texture = Item(used[id][j]).icon
                                set Button(button[id][j]).tooltip.text = Item(used[id][j]).tooltip
                                set Button(button[id][j]).tooltip.name = Item(used[id][j]).name
                                set Button(button[id][j]).tooltip.icon = Item(used[id][j]).icon
                                set Button(button[id][j]).available = shop.has(Item(used[id][j]).id)
                                set Button(button[id][j]).visible = true
                            endif
                        set j = j + 1
                    endloop

                    set i = Item.get(Item(item[id]).relation[count[id]])

                    if i != 0 then
                        set count[id] = count[id] + 1
                        set used[id][j] = i

                        if GetLocalPlayer() == p then
                            set Button(button[id][j]).texture = i.icon
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
                                set Button(button[id][j]).texture = Item(used[id][j]).icon
                                set Button(button[id][j]).tooltip.text = Item(used[id][j]).tooltip
                                set Button(button[id][j]).tooltip.name = Item(used[id][j]).name
                                set Button(button[id][j]).tooltip.icon = Item(used[id][j]).icon
                                set Button(button[id][j]).available = shop.has(Item(used[id][j]).id)
                                set Button(button[id][j]).visible = true
                            endif
                        set j = j - 1
                    endloop
                    
                    set i = Item.get(Item(item[id]).relation[count[id] - DETAIL_USED_COUNT - 1])

                    if i != 0 then
                        set count[id] = count[id] - 1
                        set used[id][j] = i

                        if GetLocalPlayer() == p then
                            set Button(button[id][j]).texture = i.icon
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
            local Item i
            local integer j = 0
            local integer id = GetPlayerId(p)

            loop
                exitwhen j == DETAIL_USED_COUNT
                    set i = Item.get(Item(item[id]).relation[j])

                    if i != 0 and j < DETAIL_USED_COUNT then
                        set used[id][j] = i

                        if GetLocalPlayer() == p then
                            set Button(button[id][count[id]]).texture = i.icon
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

            if visible and item[id] != 0 then
                call show(item[id], p)
            endif
        endmethod

        method show takes Item i, player p returns nothing
            local Table counter = Table.create()
            local integer id = GetPlayerId(p)
            local integer j = 0
            local integer cost
            local Item component
            local Slot slot

            if i != 0 then
                set cost = i.gold
                set Slot(main[id]).item = i
                set Slot(main[id]).texture = i.icon
                set Slot(main[id]).tooltip.text = i.tooltip
                set Slot(main[id]).tooltip.name = i.name
                set Slot(main[id]).tooltip.icon = i.icon
                set Slot(main[id]).available = shop.has(i.id)

                if i != item[id] then
                    set item[id] = i
                    set count[id] = 0

                    call showUsed(p)
                endif

                if GetLocalPlayer() == p then
                    set visible = true
                    set uses.visible = count[id] > 0
                    set vertical.visible = i.components > 0
                    set horizontal.visible = i.components > 1
                    set description[0].text = i.tooltip
                    set description[1].text = i.tooltip
                    set description[2].text = i.tooltip
                    set description[3].text = i.tooltip
                    set description[0].visible = uses.visible and i.components > 0
                    set description[1].visible = uses.visible and i.components == 0
                    set description[2].visible = not uses.visible and i.components > 0
                    set description[3].visible = not uses.visible and i.components == 0
                    set Slot(main[id]).cost.text = "|cffFFCC00" + I2S(i.cost(shop.buyer[id])) + "|r"
                endif

                if i.components > 0 then
                    loop
                        exitwhen j == 5
                            set component = Item.get(i.component[j])

                            if component != 0 then
                                set slot = components[id][j]

                                if GetLocalPlayer() == p then
                                    if i.components == 1 then
                                        set slot.x = 0.13725
                                    elseif i.components == 2 then
                                        set slot.x = 0.08725 + 0.1*j
                                    elseif i.components == 3 then
                                        set slot.x = 0.03725 + 0.1*j
                                    elseif i.components == 4 then
                                        set slot.x = 0.03725 + 0.06525*j
                                    else
                                        set slot.x = 0.03725 + 0.05*j
                                    endif

                                    set slot.visible = true
                                endif

                                set slot.item = component
                                set slot.texture = component.icon
                                set slot.tooltip.text = component.tooltip
                                set slot.tooltip.name = component.name
                                set slot.tooltip.icon = component.icon
                                set slot.available = shop.has(component.id)
                                set slot.cost.text = "|cffFFCC00" + I2S(component.cost(shop.buyer[id])) + "|r"
                                
                                if shop.buyer[id] != null then
                                    if UnitHasItemOfType(shop.buyer[id], component.id) then
                                        if UnitCountItemOfType(shop.buyer[id], component.id) >= i.count(component.id) then
                                            set slot.checked = true
                                        else
                                            set counter[component.id] = counter[component.id] + 1
                                            set slot.checked = counter[component.id] <= UnitCountItemOfType(shop.buyer[id], component.id)
                                        endif
                                    else
                                        set slot.checked = false
                                    endif
                                else
                                    set slot.checked = false
                                endif

                                if slot.checked then
                                    set cost = cost - component.gold
                                endif
                            else
                                if GetLocalPlayer() == p then
                                    set Slot(components[id][j]).visible = false
                                endif
                            endif
                        set j = j + 1
                    endloop

                    if GetLocalPlayer() == p then
                        set horizontal.width = 0.2
                        set horizontal.x = Slot(components[id][0]).x + ITEM_SIZE/2

                        if i.components == 2 then
                            set horizontal.width = 0.1
                        elseif i.components == 4 then
                            set horizontal.width = 0.19575
                        endif
                    endif
                else
                    loop
                        exitwhen j == 5
                            if GetLocalPlayer() == p then
                                set Slot(components[id][j]).visible = false
                            endif
                        set j = j + 1
                    endloop
                endif
            endif

            call counter.destroy()
        endmethod

        static method create takes Shop shop returns thistype
            local thistype this = thistype.allocate(WIDTH - DETAIL_WIDTH, 0, DETAIL_WIDTH, DETAIL_HEIGHT, shop.frame, "EscMenuBackdrop")
            local integer i = 0
            local integer j = 0

            set .shop = shop
            set item = Table.create()
            set count = Table.create()
            set main = Table.create()
            set used = HashTable.create()
            set lines = HashTable.create()
            set button = HashTable.create()
            set components = HashTable.create()
            set description[0] = TextArea.create(0.0275, - 0.16, 0.31, 0.16, frame, "DescriptionArea")
            set description[1] = TextArea.create(0.0275, - 0.09, 0.31, 0.23, frame, "DescriptionArea")
            set description[2] = TextArea.create(0.0275, - 0.16, 0.31, 0.22, frame, "DescriptionArea")
            set description[3] = TextArea.create(0.0275, - 0.09, 0.31, 0.29, frame, "DescriptionArea")
            set horizontal = Line.create(0.03725 + ITEM_SIZE/2, - 0.09, 0.05, 0.001, frame, "replaceabletextures\\teamcolor\\teamcolor08")
            set horizontal.visible = false
            set vertical = Line.create(0.13725 + ITEM_SIZE/2, - 0.08, 0.001, 0.01, frame, "replaceabletextures\\teamcolor\\teamcolor08")
            set vertical.visible = false
            set uses = Panel.create(0.0225, - 0.3155,  0.2675, 0.061, frame, "TransparentBackdrop")
            set uses.onScroll = function thistype.onScrolled
            set separator = Line.create(0, 0, uses.width, 0.001, uses.frame, "replaceabletextures\\teamcolor\\teamcolor08")
            set usedText = Text.create(0.115, - 0.0025, 0.04, 0.012, 1, false, uses.frame, "|cffFFCC00 Used in|r", TEXT_JUSTIFY_TOP, TEXT_JUSTIFY_LEFT)
            set close = Button.create(0.26676, - 0.025, DETAIL_CLOSE_BUTTON_SIZE, DETAIL_CLOSE_BUTTON_SIZE, frame, true)
            set close.texture = CLOSE_ICON
            set close.tooltip.text = "Close"
            set close.onClick = function thistype.onClicked
            set left = Button.create(0.005, - 0.0025, DETAIL_SHIFT_BUTTON_SIZE, DETAIL_SHIFT_BUTTON_SIZE, uses.frame, true)
            set left.texture = USED_LEFT
            set left.tooltip.text = "Scroll Left"
            set left.onClick = function thistype.onClicked
            set right = Button.create(0.248, - 0.0025, DETAIL_SHIFT_BUTTON_SIZE, DETAIL_SHIFT_BUTTON_SIZE, uses.frame, true)
            set right.texture = USED_RIGHT
            set right.tooltip.text = "Scroll Right"
            set right.onClick = function thistype.onClicked
            set table[close][0] = this
            set table[left][0] = this
            set table[right][0] = this
            set table[uses][0] = this

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                        set j = 0
                        set main[i] = Slot.create(shop, 0, 0.13725, - 0.03, frame)
                        set Slot(main[i]).visible = GetLocalPlayer() == Player(i)
                        set table[main[i]][0] = this

                        loop
                            exitwhen j == 5
                                set components[i][j] = Slot.create(shop, 0, 0.03725 + 0.05*j, - 0.1, frame)
                                set lines[i][j] = Line.create(Slot(components[i][j]).width/2, 0.01, 0.001, 0.01, Slot(components[i][j]).frame, "replaceabletextures\\teamcolor\\teamcolor08")
                                set Slot(components[i][j]).visible = false   
                                set table[components[i][j]][0] = this                     
                            set j = j + 1
                        endloop

                        set j = 0

                        loop
                            exitwhen j == DETAIL_USED_COUNT
                                set button[i][j] = Button.create(0.0050000 + DETAIL_BUTTON_GAP*j, - 0.019500, DETAIL_BUTTON_SIZE, DETAIL_BUTTON_SIZE, uses.frame, false)
                                set Button(button[i][j]).visible = false
                                set Button(button[i][j]).tooltip.point = FRAMEPOINT_BOTTOMRIGHT
                                set Button(button[i][j]).onClick = function thistype.onClicked
                                set Button(button[i][j]).onScroll = function thistype.onScrolled
                                set Button(button[i][j]).onRightClick = function thistype.onRightClicked
                                set Button(button[i][j]).onMiddleClick = function thistype.onMiddleClicked
                                set table[button[i][j]][0] = this
                                set table[button[i][j]][1] = j
                            set j = j + 1
                        endloop
                    endif
                set i = i + 1
            endloop

            set visible = false

            return this
        endmethod

        private method onScroll takes nothing returns nothing
            if GetLocalPlayer() == GetTriggerPlayer() then
                call shop.onScroll()
            endif
        endmethod

        private static method onClicked takes nothing returns nothing
            local Button b = GetTriggerComponent()
            local player p = GetTriggerPlayer()
            local integer id = GetPlayerId(p)
            local thistype this = table[b][0]

            if this != 0 then
                if b == close then
                    call shop.detail(0, p)
                elseif b == left or b == right then
                    call shift(b == right, p)
                else
                    call shop.detail(used[id][table[b][1]], p)
                endif
            endif

            set p = null
        endmethod

        private static method onScrolled takes nothing returns nothing
            local thistype this = table[GetTriggerComponent()][0]

            if this != 0 then
                call shift(BlzGetTriggerFrameValue() < 0, GetTriggerPlayer())
            endif
        endmethod

        private static method onMiddleClicked takes nothing returns nothing
            local Button b = GetTriggerComponent()
            local player p = GetTriggerPlayer()
            local integer id = GetPlayerId(p)
            local thistype this = table[b][0]

            if this != 0 then
                if shop.favorites.has(Item(used[id][table[b][1]]).id, p) then
                    call shop.favorites.remove(used[id][table[b][1]], p)
                else
                    call shop.favorites.add(used[id][table[b][1]], p)
                endif
            endif

            set p = null
        endmethod

        private static method onRightClicked takes nothing returns nothing
            local Button b = GetTriggerComponent()
            local player p = GetTriggerPlayer()
            local integer id = GetPlayerId(p)
            local thistype this = table[b][0]

            if this != 0 then
                if shop.buy(used[id][table[b][1]], p) then
                    if GetLocalPlayer() == GetTriggerPlayer() then
                        call Button(button[id][table[b][1]]).play(SPRITE_MODEL, SPRITE_SCALE, 0)
                    endif
                endif
            endif

            set p = null
        endmethod
    endstruct

    private struct Buyer extends Panel 
        private static Table current

        private boolean isVisible

        Shop shop
        Button left
        Button right
        Inventory inventory
        Table last
        Table index
        Table size
        Table selected
        HashTable unit
        HashTable button

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

        method operator [] takes integer id returns unit
            return selected.unit[id]
        endmethod

        method destroy takes nothing returns nothing
            local integer i = 0
            local integer j

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                        set j = 0

                        loop
                            exitwhen j == BUYER_COUNT
                                call table.remove(button[i][j])
                                call Button(button[i][j]).destroy()
                            set j = j + 1
                        endloop

                        call button.remove(i)
                        call unit.remove(i)
                    endif
                set i = i + 1
            endloop

            call button.destroy()
            call unit.destroy()
            call last.destroy()
            call index.destroy()
            call size.destroy()
            call selected.destroy()
            call left.destroy()
            call right.destroy()
            call inventory.destroy()
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
                                set Button(button[id][i]).texture = Button(button[id][i + 1]).texture
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
                            set Button(button[id][i]).texture = BlzGetAbilityIcon(GetUnitTypeId(u))
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
                                set Button(button[id][i]).texture = Button(button[id][i - 1]).texture
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
                            set Button(button[id][i]).texture = BlzGetAbilityIcon(GetUnitTypeId(u))
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
                    call IssueNeutralTargetOrder(Player(id), shop.unit[id], "smart", selected.unit[id])
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
                                set Button(button[id][i]).texture = BlzGetAbilityIcon(GetUnitTypeId(u))
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
            local thistype this = thistype.allocate(WIDTH/2 - BUYER_WIDTH/2, HEIGHT/2 - 0.015, BUYER_WIDTH, BUYER_HEIGHT, BlzGetOriginFrame(ORIGIN_FRAME_GAME_UI, 0), "EscMenuBackdrop")
            local integer i = 0
            local integer j = 0

            set .shop = shop
            set last = Table.create()
            set size = Table.create()
            set index = Table.create()
            set selected = Table.create()
            set button = HashTable.create()
            set unit = HashTable.create()
            set inventory = Inventory.create(shop)
            set left = Button.create(0.027500, - 0.032500, BUYER_SHIFT_BUTTON_SIZE, BUYER_SHIFT_BUTTON_SIZE, frame, true)
            set left.texture = BUYER_LEFT
            set left.tooltip.text = "Scroll Left"
            set left.onClick = function thistype.onClicked
            set right = Button.create(0.36350, - 0.032500, BUYER_SHIFT_BUTTON_SIZE, BUYER_SHIFT_BUTTON_SIZE, frame, true)
            set right.texture = BUYER_RIGHT
            set right.tooltip.text = "Scroll Right"
            set right.onClick = function thistype.onClicked
            set table[left][0] = this
            set table[right][0] = this

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                        set j = 0

                        loop
                            exitwhen j == BUYER_COUNT
                                set button[i][j] = Button.create(0.045000 + BUYER_GAP*j, - 0.023000, BUYER_SIZE, BUYER_SIZE, frame, true)
                                set Button(button[i][j]).visible = false
                                set Button(button[i][j]).onClick = function thistype.onClicked
                                set Button(button[i][j]).onScroll = function thistype.onScrolled
                                set table[button[i][j]][0] = this
                                set table[button[i][j]][1] = j
                            set j = j + 1
                        endloop
                    endif
                set i = i + 1
            endloop

            return this
        endmethod

        private method onScroll takes nothing returns nothing
            call shift(BlzGetTriggerFrameValue() < 0, GetTriggerPlayer())
        endmethod

        private static method onScrolled takes nothing returns nothing
            local thistype this = table[GetTriggerComponent()][0]

            if this != 0 then
                call shift(BlzGetTriggerFrameValue() < 0, GetTriggerPlayer())
            endif
        endmethod

        private static method onClicked takes nothing returns nothing
            local Button b = GetTriggerComponent()
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
                    call IssueNeutralTargetOrder(GetTriggerPlayer(), shop.unit[id], "smart", selected.unit[id])
                    call inventory.show(selected.unit[id])
                    call inventory.remove(id)

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
                if shop.unit[i] != null then
                    if selected.unit[i] == u and IsUnitInRange(u, shop.unit[i], shop.aoe) then
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
                if shop.unit[i] != null then
                    if selected.unit[i] == u and IsUnitInRange(u, shop.unit[i], shop.aoe) then
                        call shop.details.refresh(GetOwningPlayer(u))
                    endif
                endif
            endif

            set u = null
        endmethod

        private static method onInit takes nothing returns nothing
            set current = Table.create()

            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, function thistype.onPickup)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, function thistype.onDrop)
        endmethod
    endstruct

    private struct Favorites extends Panel
        Shop shop
        Button clear
        Table count
        HashTable item
        HashTable button

        method destroy takes nothing returns nothing
            local integer i = 0
            local integer j

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                        set j = 0

                        loop
                            exitwhen j == CATEGORY_COUNT
                                call table.remove(button[i][j])
                                call Button(button[i][j]).destroy()
                            set j = j + 1
                        endloop

                        call button.remove(i)
                        call item.remove(i)
                    endif
                set i = i + 1
            endloop

            call clear.destroy()
            call count.destroy()
            call item.destroy()
            call button.destroy()
        endmethod

        method has takes integer id, player p returns boolean
            local integer i = 0
            local integer pid = GetPlayerId(p)

            loop
                exitwhen i > count.integer[pid]
                    if Item(item[pid][i]).id == id then
                        return true
                    endif
                set i = i + 1
            endloop

            return false
        endmethod

        method reset takes player p returns nothing
            local integer id = GetPlayerId(p)

            loop
                exitwhen count[id] == -1
                    if GetLocalPlayer() == p then
                        set Button(button[id][count[id]]).visible = false
                        call Slot(table[shop][Item(item[id][count[id]]).id]).tag(null, 0, 0, 0)
                    endif
                set count[id] = count[id] - 1
            endloop
        endmethod

        method remove takes Item i, player p returns nothing
            local integer j = 0
            local integer k = 0
            local integer id = GetPlayerId(p)

            if has(i.id, p) then
                loop
                    exitwhen j > count.integer[id]
                        if Item(item[id][j]).id == i.id then
                            set k = j

                            if GetLocalPlayer() == p then
                                call Slot(table[shop][i.id]).tag(null, 0, 0, 0)
                            endif
                
                            loop
                                exitwhen k >= count[id]
                                    set item[id][k] = item[id][k + 1]
                
                                    if GetLocalPlayer() == p then
                                        set Button(button[id][k]).texture = Item(item[id][k]).icon
                                        set Button(button[id][k]).tooltip.text = Item(item[id][k]).tooltip
                                        set Button(button[id][k]).tooltip.name = Item(item[id][k]).name
                                        set Button(button[id][k]).tooltip.icon = Item(item[id][k]).icon
                                    endif
                                set k = k + 1
                            endloop
                
                            if GetLocalPlayer() == p then
                                set Button(button[id][count[id]]).visible = false
                            endif
                            
                            set count[id] = count[id] - 1
                            exitwhen true
                        endif
                    set j = j + 1
                endloop
            endif
        endmethod

        method add takes Item i, player p returns nothing
            local integer id = GetPlayerId(p)

            if count.integer[id] < CATEGORY_COUNT - 1 then
                if not has(i.id, p) then
                    set count[id] = count[id] + 1
                    set item[id][count[id]] = i

                    if GetLocalPlayer() == p then
                        set Button(button[id][count[id]]).texture = i.icon
                        set Button(button[id][count[id]]).tooltip.text = i.tooltip
                        set Button(button[id][count[id]]).tooltip.name = i.name
                        set Button(button[id][count[id]]).tooltip.icon = i.icon
                        set Button(button[id][count[id]]).visible = true
                        call Slot(table[shop][i.id]).tag(TAG_MODEL, TAG_SCALE, TAG_XOFFSET, TAG_YOFFSET)
                    endif
                endif
            endif
        endmethod

        static method create takes Shop shop returns thistype
            local thistype this = thistype.allocate(X + (WIDTH - 0.027), 0, SIDE_WIDTH, SIDE_HEIGHT, shop.frame, "EscMenuBackdrop")
            local integer i = 0
            local integer j
            
            set .shop = shop
            set count = Table.create()
            set item = HashTable.create()
            set button = HashTable.create()
            set clear = Button.create(0.027, 0.015, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, frame, true)
            set clear.texture = CLEAR_ICON
            set clear.tooltip.text = "Clear"
            set clear.onClick = function thistype.onClear
            set table[clear][0] = this
            
            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS   
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                        set j = 0
                        set count[i] = -1

                        loop
                            exitwhen j == CATEGORY_COUNT
                                set button[i][j] = Button.create(0.023750, - (0.021500 + CATEGORY_SIZE*j + CATEGORY_GAP), CATEGORY_SIZE, CATEGORY_SIZE, frame, false)
                                set Button(button[i][j]).visible = false
                                set Button(button[i][j]).tooltip.point = FRAMEPOINT_TOPRIGHT
                                set Button(button[i][j]).onClick = function thistype.onClicked
                                set Button(button[i][j]).onRightClick = function thistype.onRightClicked
                                set Button(button[i][j]).onMiddleClick = function thistype.onMiddleClicked
                                set Button(button[i][j]).onDoubleClick = function thistype.onDoubleClicked
                                set table[button[i][j]][0] = this
                                set table[button[i][j]][1] = j
            
                                if j > 6 then
                                    set Button(button[i][j]).tooltip.point = FRAMEPOINT_BOTTOMRIGHT
                                endif
                            set j = j + 1
                        endloop
                    endif
                set i = i + 1
            endloop

            return this
        endmethod

        private static method onClear takes nothing returns nothing
            local thistype this = table[GetTriggerComponent()][0]

            if this != 0 then
                call reset(GetTriggerPlayer())
            endif
        endmethod

        private static method onClicked takes nothing returns nothing
            local thistype this = table[GetTriggerComponent()][0]

            if this != 0 then
                call shop.detail(item[GetPlayerId(GetTriggerPlayer())][table[GetTriggerComponent()][1]], GetTriggerPlayer())
            endif
        endmethod

        private static method onMiddleClicked takes nothing returns nothing
            local thistype this = table[GetTriggerComponent()][0]

            if this != 0 then
                call remove(item[GetPlayerId(GetTriggerPlayer())][table[GetTriggerComponent()][1]], GetTriggerPlayer())
            endif
        endmethod

        private static method onDoubleClicked takes nothing returns nothing
            local thistype this = table[GetTriggerComponent()][0]

            if this != 0 then
                if shop.buy(item[GetPlayerId(GetTriggerPlayer())][table[GetTriggerComponent()][1]], GetTriggerPlayer()) then
                    if GetLocalPlayer() == GetTriggerPlayer() then
                        call Button(button[GetPlayerId(GetTriggerPlayer())][table[GetTriggerComponent()][1]]).play(SPRITE_MODEL, SPRITE_SCALE, 0)
                    endif
                endif
            endif
        endmethod

        private static method onRightClicked takes nothing returns nothing
            local thistype this = table[GetTriggerComponent()][0]

            if this != 0 then
                if shop.buy(item[GetPlayerId(GetTriggerPlayer())][table[GetTriggerComponent()][1]], GetTriggerPlayer()) then
                    if GetLocalPlayer() == GetTriggerPlayer() then
                        call Button(button[GetPlayerId(GetTriggerPlayer())][table[GetTriggerComponent()][1]]).play(SPRITE_MODEL, SPRITE_SCALE, 0)
                    endif
                endif
            endif
        endmethod
    endstruct

    private struct Category extends Panel
        Shop shop
        Button clear
        Button logic
        integer count
        integer active
        boolean andLogic
        integer array value[CATEGORY_COUNT]
        Button array button[CATEGORY_COUNT]

        method destroy takes nothing returns nothing
            call clear.destroy()
            call logic.destroy()

            loop
                exitwhen count == -1
                    call table.remove(button[count])
                    call button[count].destroy()
                set count = count - 1
            endloop
        endmethod

        method reset takes nothing returns nothing
            local integer i = 0

            set active = 0

            loop
                exitwhen i == CATEGORY_COUNT
                    set button[i].active = false
                set i = i + 1
            endloop

            call shop.filter(active, andLogic)
        endmethod

        method add takes string icon, string description returns integer
            if count < CATEGORY_COUNT then
                set count = count + 1
                set value[count] = R2I(Pow(2, count))
                set button[count] = Button.create(0.023750, - (0.021500 + CATEGORY_SIZE*count + CATEGORY_GAP), CATEGORY_SIZE, CATEGORY_SIZE, frame, true)
                set button[count].texture = icon
                set button[count].active = false
                set button[count].tooltip.text = description
                set button[count].onClick = function thistype.onClicked
                set table[button[count]][0] = this
                set table[button[count]][1] = count

                return value[count]
            else
                call BJDebugMsg("Maximum number os categories reached.")
            endif

            return 0
        endmethod

        static method create takes Shop shop returns thistype
            local thistype this = thistype.allocate(X - 0.048, 0, SIDE_WIDTH, SIDE_HEIGHT, shop.frame, "EscMenuBackdrop")

            set count = -1
            set active = 0
            set .shop = shop
            set andLogic = true
            set clear = Button.create(0.028, 0.015, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, frame, true)
            set clear.texture = CLEAR_ICON
            set clear.tooltip.text = "Clear"
            set clear.onClick = function thistype.onClear
            set logic = Button.create(X + 0.048, 0.015, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, frame, true)
            set logic.texture = LOGIC_ICON
            set logic.active = false
            set logic.tooltip.text = "AND"
            set logic.onClick = function thistype.onLogic
            set table[clear][0] = this
            set table[logic][0] = this

            return this
        endmethod

        private static method onClicked takes nothing returns nothing
            local Button category = GetTriggerComponent()
            local thistype this = table[category][0]

            if this != 0 and GetLocalPlayer() == GetTriggerPlayer() then
                set category.active = not category.active

                if category.active then
                    set active = active + value[table[category][1]]
                else
                    set active = active - value[table[category][1]]
                endif

                call shop.filter(active, andLogic)
            endif
        endmethod

        private static method onClear takes nothing returns nothing
            local thistype this = table[GetTriggerComponent()][0]

            if this != 0 and GetLocalPlayer() == GetTriggerPlayer() then
                call reset()
            endif
        endmethod

        private static method onLogic takes nothing returns nothing
            local thistype this = table[GetTriggerComponent()][0]

            if this != 0 and GetLocalPlayer() == GetTriggerPlayer() then
                set logic.active = not logic.active
                set andLogic = not andLogic 

                if andLogic then
                    set logic.tooltip.text = "AND"
                else
                    set logic.tooltip.text = "OR"
                endif

                call shop.filter(active, andLogic)
            endif
        endmethod
    endstruct
    
    struct Shop extends Panel
        private static integer count = -1
        private static HashTable itempool
        readonly static unit array unit
        readonly static group array group

        private boolean isVisible

        readonly real aoe
        readonly real tax
        readonly integer id
        readonly integer size
        readonly integer index
        readonly integer rows
        readonly integer columns
        readonly boolean detailed
        readonly Slot first
        readonly Slot last
        readonly Slot head
        readonly Slot tail
        readonly EditBox edit
        readonly Button close
        readonly Button break
        readonly Button revert
        readonly Buyer buyer
        readonly Detail details
        readonly Category category
        readonly Favorites favorites
        readonly HashTable scrolls

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
            
            call BlzFrameSetVisible(frame, visibility)
        endmethod

        method operator visible takes nothing returns boolean
            return isVisible
        endmethod

        method destroy takes nothing returns nothing
            local integer i = 0
            local Slot slot = itempool[this][0]

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                        call Transaction.clear(this, i)
                    endif
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
            call break.destroy()
            call revert.destroy()
            call category.destroy()
            call favorites.destroy()
            call details.destroy()
            call buyer.destroy()
        endmethod

        method canBuy takes Item i, player p returns boolean
            local Item component
            local boolean flag = true
            local integer j = 0


            if i != 0 and has(i.id) and buyer[GetPlayerId(p)] != null then
                if i.components > 0 then
                    loop
                        exitwhen j == i.components or not flag
                            set flag = canBuy(Item.get(i.component[j]), p)
                        set j = j + 1
                    endloop
                endif

                return flag
            endif

            return false
        endmethod

        method buy takes Item i, player p returns boolean
            local integer id = GetPlayerId(p)
            local integer cost = i.cost(buyer[id])
            local item new
            
            if canBuy(i, p) and cost <= GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) then
                set new = CreateItem(i.id, GetUnitX(buyer[id]), GetUnitY(buyer[id]))

                call buyer.inventory.removeComponents(i, Transaction.create(this, buyer[id], i, cost, "buy"))

                if not UnitAddItem(buyer[id], new) then
                    call IssueTargetItemOrder(buyer[id], "smart", new)
                endif

                call buyer.inventory.show(buyer[id])
                call details.refresh(p)
                call SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) - cost)
                call Sound.success(p)

                set new = null

                return true
            else
                if cost > GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD) then
                    call Sound.gold(p)
                else
                    call Sound.error(p)
                endif

                return false
            endif

            return false
        endmethod

        method sell takes Item i, player p, integer slot returns boolean
            local integer cost
            local integer gold
            local integer charges
            local integer id = GetPlayerId(p)
            local boolean sold = false

            if i != 0 and buyer[id] != null then
                set charges = GetItemCharges(UnitItemInSlot(buyer[id], slot))

                if charges == 0 then
                    set charges = 1
                endif

                set gold = GetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD)
                set cost = R2I(R2I(i.gold / i.charges) * charges * tax)

                if GetItemTypeId(UnitItemInSlot(buyer[id], slot)) == i.id then
                    set sold = true

                    call Transaction.create(this, buyer[id], i, cost, "sell")
                    call RemoveItem(UnitItemInSlot(buyer[id], slot))
                    call SetPlayerState(p, PLAYER_STATE_RESOURCE_GOLD, gold + cost)
                    call buyer.inventory.show(buyer[id])
                    call details.refresh(p)
                endif

                call Sound.success(p)
            else
                call Sound.error(p)
            endif

            return sold
        endmethod

        method dismantle takes Item i, player p, integer slot returns nothing
            local integer j = 0
            local integer slots = 0
            local integer id = GetPlayerId(p)

            if i != 0 and buyer[id] != null then
                if i.components > 0 then
                    loop
                        exitwhen j == UnitInventorySize(buyer[id])
                            if UnitItemInSlot(buyer[id], j) == null then
                                set slots = slots + 1
                            endif
                        set j = j + 1
                    endloop

                    if (slots + 1) >= i.components then
                        set j = 0

                        call Transaction.create(this, buyer[id], i, 0, "dismantle")
                        call RemoveItem(UnitItemInSlot(buyer[id], slot))

                        loop
                            exitwhen j == i.components
                                call UnitAddItemById(buyer[id], Item.get(i.component[j]).id)
                            set j = j + 1
                        endloop

                        call Sound.success(p)
                        call buyer.inventory.show(buyer[id])
                        call details.refresh(p)
                    else
                        call Sound.error(p)
                    endif
                else
                    call Sound.error(p)
                endif
            else
                call Sound.error(p)
            endif
        endmethod

        method undo takes player p returns nothing
            local integer id = GetPlayerId(p)

            if Transaction.count(this, id) > 0 then
                call Transaction.last(this, id).rollback()
                call buyer.inventory.show(buyer[id])
                call details.refresh(p)
            else
                call Sound.error(p)
            endif
        endmethod

        method scroll takes boolean down returns boolean
            local Slot slot = first
            
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

        method scrollTo takes Item i, player p returns nothing
            local Slot slot

            if i != 0 and GetLocalPlayer() == p then
                set slot = Slot(table[this][i.id])
    
                loop
                    exitwhen slot.visible or not scroll(true)
                endloop
            endif
        endmethod

        method filter takes integer categories, boolean andLogic returns nothing
            local Slot slot = itempool[this][0]
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

                    if edit.text != "" and edit.text != null then
                        set process = process and find(StringCase(slot.item.name, false), StringCase(edit.text, false))
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

        method select takes Item i, player p returns nothing
            local integer id = GetPlayerId(p)

            if i != 0 and GetLocalPlayer() == p then
                if table[this].has(id) then
                    call Slot(table[this][id]).display(null, 0, 0, 0)
                endif

                set table[this][id] = Slot(table[this][i.id])
                call Slot(table[this][id]).display(ITEM_HIGHLIGHT, HIGHLIGHT_SCALE, HIGHLIGHT_XOFFSET, HIGHLIGHT_YOFFSET)
            endif
        endmethod

        method detail takes Item i, player p returns nothing
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
                    call scrollTo(Slot(table[this][GetPlayerId(p)]).item, p)
                endif
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
            local Slot slot
            local Item i

            if this != 0 then
                if not table[this].has(itemId) then
                    set i = Item.get(itemId)

                    if i != 0 then
                        set size = size + 1
                        set index = index + 1
                        set i.categories = categories
                        set slot = Slot.create(this, i, 0, 0, frame)
                        set slot.row = R2I(index/COLUMNS)
                        set slot.column = ModuloInteger(index, COLUMNS)
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

        static method create takes integer id, real aoe, real tax returns thistype
            local thistype this
            local integer i = 0

            if not table[id].has(0) then
                set this = thistype.allocate(X, Y, WIDTH, HEIGHT, BlzGetFrameByName("ConsoleUIBackdrop", 0), "EscMenuBackdrop")
                set .id = id
                set .aoe = aoe
                set .tax = tax
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
                set scrolls = HashTable.create()
                set buyer = Buyer.create(this)
                set details = Detail.create(this)
                set category = Category.create(this)
                set favorites = Favorites.create(this)
                set edit = EditBox.create(0.021, 0.02, EDIT_WIDTH, EDIT_HEIGHT, frame, "EscMenuEditBoxTemplate")
                set edit.onText = function thistype.onSearch
                set close = Button.create((WIDTH - 2*TOOLBAR_BUTTON_SIZE), 0.015000, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, frame, true)
                set close.texture = CLOSE_ICON
                set close.tooltip.text = "Close"
                set close.onClick = function thistype.onClose
                set break = Button.create((WIDTH - 2*TOOLBAR_BUTTON_SIZE - 0.0205), 0.015000, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, frame, true)
                set break.texture = DISMANTLE_ICON
                set break.tooltip.text = "Dismantle"
                set break.onClick = function thistype.onDismantle
                set revert = Button.create((WIDTH - 2*TOOLBAR_BUTTON_SIZE - 0.0410), 0.015000, TOOLBAR_BUTTON_SIZE, TOOLBAR_BUTTON_SIZE, frame, true)
                set revert.texture = UNDO_ICON
                set revert.tooltip.text = "Undo"
                set revert.onClick = function thistype.onUndo
                set table[id][0] = this
                set table[edit][0] = this
                set table[close][0] = this
                set table[break][0] = this
                set table[revert][0] = this

                loop
                    exitwhen i >= bj_MAX_PLAYER_SLOTS
                        if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                            set table[GetHandleId(Player(i))][id] = this
                            set table[GetHandleId(Player(i))][count] = id
                        endif
                    set i = i + 1
                endloop

                set visible = false
            endif

            return this
        endmethod

        method onScroll takes nothing returns nothing
            local integer id = GetPlayerId(GetTriggerPlayer())
            local integer direction = R2I(BlzGetTriggerFrameValue())

            if scrolls[id][0] != direction then
                set scrolls[id][0] = direction
                set scrolls[id][1] = 0
            else
                set scrolls[id][1] = scrolls[id][1] + 1
            endif

            if GetLocalPlayer() == GetTriggerPlayer() then
                if scrolls[id][1] == 1 then
                    call scroll(direction < 0)
                else
                    call scroll(direction < 0)
                endif
            endif
        endmethod

        private static method onExpire takes nothing returns nothing
            local integer id = GetPlayerId(GetLocalPlayer())
            local thistype this = table[GetUnitTypeId(unit[id])][0]

            if this != 0 then
                set scrolls[id][1] = scrolls[id][1] - 1

                if scrolls[id][1] > 0 then
                    call scroll(scrolls[id][0] < 0)
                else
                    set scrolls[id][1] = 0
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
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                        set g = CreateGroup()
                        set shop = unit[i]
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
                    endif
                set i = i + 1
            endloop

            set g = null
            set shop = null
        endmethod

        private static method onSearch takes nothing returns nothing
            local thistype this = table[GetTriggerEditBox()][0]

            if this != 0 and GetLocalPlayer() == GetTriggerPlayer() then
                call filter(category.active, category.andLogic)
            endif
        endmethod

        private static method onClose takes nothing returns nothing
            local thistype this = table[GetTriggerComponent()][0]
            local integer id = GetPlayerId(GetTriggerPlayer())

            if this != 0 then
                set unit[id] = null

                if GetLocalPlayer() == GetTriggerPlayer() then
                    set visible = false
                endif

                call Transaction.clear(this, id)
            endif
        endmethod

        private static method onDismantle takes nothing returns nothing
            local integer id = GetPlayerId(GetTriggerPlayer())
            local thistype this = table[GetTriggerComponent()][0]

            if this != 0 then
                if buyer.inventory.has(id) then
                    call dismantle(Item(buyer.inventory.item[id][buyer.inventory[id]]), GetTriggerPlayer(), buyer.inventory[id])
                else
                    call Sound.error(GetTriggerPlayer())
                endif
            endif
        endmethod

        private static method onUndo takes nothing returns nothing
            local thistype this = table[GetTriggerComponent()][0]

            if this != 0 then
                call undo(GetTriggerPlayer())
            endif
        endmethod

        private static method onSelect takes nothing returns nothing
            local thistype this = table[GetUnitTypeId(GetTriggerUnit())][0]
            local integer id = GetPlayerId(GetTriggerPlayer())

            if this != 0 then
                if GetLocalPlayer() == GetTriggerPlayer() then
                    set visible = GetTriggerEventId() == EVENT_PLAYER_UNIT_SELECTED
                endif

                if GetTriggerEventId() == EVENT_PLAYER_UNIT_SELECTED then
                    set unit[id] = GetTriggerUnit()
                    call buyer.inventory.show(buyer[id])
                else
                    set unit[id] = null
                    call Transaction.clear(this, id)
                endif
            endif
        endmethod

        private static method onEsc takes nothing returns nothing
            local player p = GetTriggerPlayer()
            local integer id = GetPlayerId(p)
            local integer i = GetHandleId(p)
            local integer j = 0
            local thistype this

            loop
                exitwhen j > count
                    set this = table[i][table[i][j]]

                    if this != 0 then
                        set unit[id] = null

                        if GetLocalPlayer() == GetTriggerPlayer() then
                            set visible = false
                        endif

                        call Transaction.clear(this, id)
                    endif
                set j = j + 1
            endloop

            set p = null
        endmethod

        private static method onInit takes nothing returns nothing
            local integer i = 0
            local trigger escape = CreateTrigger()

            set table = HashTable.create()
            set itempool = HashTable.create()

            loop
                exitwhen i >= bj_MAX_PLAYER_SLOTS
                    if GetPlayerController(Player(i)) == MAP_CONTROL_USER then
                        set group[i] = CreateGroup()
                        call TriggerRegisterPlayerEventEndCinematic(escape, Player(i))
                    endif
                set i = i + 1
            endloop

            if SCROLL_DELAY > 0 then
                call TimerStart(CreateTimer(), SCROLL_DELAY, true, function thistype.onExpire)
            endif

            call TriggerAddCondition(escape, Condition(function thistype.onEsc))
            call TimerStart(CreateTimer(), UPDATE_PERIOD, true, function thistype.onPeriod)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, function thistype.onSelect)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DESELECTED, function thistype.onSelect)
        endmethod
    endstruct
endlibrary