library Item requires Table, RegisterPlayerUnitEvent
    /* --------------------------------------- Item v1.0 --------------------------------------- */
    // Credits:
    //      Bribe: Table library
    //      Magtheridon: RegisterPlayerUnitEvent library
    /* -------------------------------------- By Chopinski ------------------------------------- */

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function ItemAddComponents takes integer whichItem, integer a, integer b, integer c, integer d, integer e returns nothing
        call Item.addComponents(whichItem, a, b, c, d, e)
    endfunction

    function ItemCountComponentOfType takes integer id, integer component returns integer
        return Item.countComponent(id, component)
    endfunction

    function UnitHasItemOfType takes unit u, integer id returns boolean
        return Item.hasType(u, id)
    endfunction

    function UnitCountItemOfType takes unit u, integer id returns integer
        return Item.countType(u, id)
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
            local item i
            local thistype this

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
endlibrary