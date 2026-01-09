library Item requires Table, RegisterPlayerUnitEvent, optional NewBonus, optional Indexer
    /* --------------------------------------- Item v1.0 --------------------------------------- */
    // Credits:
    //      Bribe: Table library
    //      Magtheridon: RegisterPlayerUnitEvent library
    /* -------------------------------------- By Chopinski ------------------------------------- */

    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    globals
        // Tooltip update period
        private constant real PERIOD = 1.
    endglobals

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private interface IItem
        real mana = 0
        real armor = 0
        real block = 0
        real pierce = 0
        real damage = 0
        real health = 0
        real evasion = 0
        real agility = 0
        real strength = 0
        real tenacity = 0
        real omnivamp = 0
        real lifeSteal = 0
        real spellVamp = 0
        real manaRegen = 0
        real sightRange = 0
        real missChance = 0
        real spellPower = 0
        real healthRegen = 0
        real attackSpeed = 0
        real intelligence = 0
        real tenacityFlat = 0
        real movementSpeed = 0
        real criticalDamage = 0
        real criticalChance = 0
        real cooldownOffset = 0
        real tenacityOffset = 0
        real magicResistance = 0
        real armorPenetration = 0
        real magicPenetration = 0
        real cooldownReduction = 0
        real armorPenetrationFlat = 0
        real magicPenetrationFlat = 0
        real cooldownReductionFlat = 0

        method onTooltip takes unit u, item i, integer id returns string defaults null
        method onPickup takes unit u, item i returns nothing defaults nothing
        method onDrop takes unit u, item i returns nothing defaults nothing
    endinterface
    
    struct Item extends IItem
        private static unit shop
        private static rect rect
        private static integer key = -1
        private static HashTable table
        private static HashTable itempool
        private static HashTable itemtype
        private static HashTable counters
        private static HashTable relations
        private static thistype array array
        private static timer timer = CreateTimer()
        private static trigger trigger = CreateTrigger()
        private static player player = Player(bj_PLAYER_NEUTRAL_EXTRA)

        private unit unit
        private item item
        private integer index
        private thistype type

        readonly integer id

        private method operator gold= takes integer value returns nothing
            set itempool[id][1] = value
        endmethod

        method operator gold takes nothing returns integer
            return itempool[id][1]
        endmethod

        private method operator wood= takes integer value returns nothing
            set itempool[id][8] = value
        endmethod

        method operator wood takes nothing returns integer
            return itempool[id][8]
        endmethod

        private method operator charges= takes integer value returns nothing
            if value <= 0 then
                set itempool[id][2] = 1
            else
                set itempool[id][2] = value
            endif
        endmethod

        method operator charges takes nothing returns integer
            return itempool[id][2]
        endmethod

        private method operator name= takes string value returns nothing
            set itempool[id].string[3] = value
        endmethod

        method operator name takes nothing returns string
            return itempool[id].string[3]
        endmethod

        private method operator icon= takes string value returns nothing
            set itempool[id].string[4] = value
        endmethod

        method operator icon takes nothing returns string
            return itempool[id].string[4]
        endmethod

        private method operator tooltip= takes string value returns nothing
            set itempool[id].string[5] = value
        endmethod

        method operator tooltip takes nothing returns string
            return itempool[id].string[5]
        endmethod

        private method operator components= takes integer value returns nothing
            set itempool[id][7] = value
        endmethod

        method operator components takes nothing returns integer
            return itempool[id][7]
        endmethod

        method operator categories= takes integer category returns nothing
            set itempool[id][6] = category
        endmethod 

        method operator categories takes nothing returns integer
            return itempool[id][6]
        endmethod

        method operator component takes nothing returns Table
            return itemtype[id]
        endmethod

        method operator counter takes nothing returns Table
            return counters[id]
        endmethod

        method operator relation takes nothing returns Table
            return relations[id]
        endmethod

        method recipe takes boolean lumber returns integer
            local integer i = 0
            local integer amount = gold

            if lumber then
                set amount = wood
            endif

            if components > 0 then
                loop
                    exitwhen i == components
                        if lumber then
                            set amount = amount - get(component[i]).wood
                        else
                            set amount = amount - get(component[i]).gold
                        endif
                    set i = i + 1
                endloop

                return amount
            endif

            return 0
        endmethod

        method cost takes unit u, boolean lumber returns integer
            local integer amount
            local integer i = 0
            local Table owned = Table.create()

            if u == null then
                if lumber then
                    set amount = wood
                else
                    set amount = gold
                endif
            else
                loop
                    exitwhen i == UnitInventorySize(u)
                        set owned[GetItemTypeId(UnitItemInSlot(u, i))] = owned[GetItemTypeId(UnitItemInSlot(u, i))] + 1
                    set i = i + 1
                endloop

                set amount = calculate(owned, lumber)
            endif

            call owned.destroy()

            return amount
        endmethod

        method count takes integer id returns integer
            return counter[id]
        endmethod

        private method remove takes integer i returns integer
            set array[i] = array[key]
            set key = key - 1
            set unit = null
            set item = null

            if key == -1 then
                call PauseTimer(timer)
            endif
            
            call deallocate()

            return i - 1
        endmethod

        private method calculate takes Table owned, boolean lumber returns integer
            local thistype piece
            local integer amount
            local integer i = 0

            if components <= 0 then
                if lumber then
                    return wood
                endif

                return gold
            else
                set amount = recipe(lumber)

                loop
                    exitwhen i == components
                        set piece = get(component[i])
                    
                        if owned.integer[piece.id] > 0 then
                            set owned[piece.id] = owned[piece.id] - 1
                        else
                            set amount = amount + piece.calculate(owned, lumber)
                        endif
                    set i = i + 1
                endloop

                return amount
            endif
        endmethod

        method costs takes integer id returns nothing
            local integer coin
            local integer lumber

            call AddItemToStock(shop, id, 1, 1)
            call SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, 9999999)
            call SetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER, 9999999)
            set coin = GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD)
            set lumber = GetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER)
            call IssueNeutralImmediateOrderById(player, shop, id)
            call RemoveItemFromStock(shop, id)
            call EnumItemsInRect(rect, null, function thistype.clear)

            set gold = coin - GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD)
            set wood = lumber - GetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER)
        endmethod

        static method get takes integer id returns thistype
            if id > 0 then
                if itempool[id].has(0) then
                    return Item(itempool[id][0])
                else
                    return create(id)
                endif
            endif

            return 0
        endmethod

        static method addComponents takes integer id, integer a, integer b, integer c, integer d, integer e returns nothing
            local thistype this

            if id > 0 then
                set this = get(id)
                set components = 0

                call component.flush()
                call counter.flush()
                call save(id, a)
                call save(id, b)
                call save(id, c)
                call save(id, d)
                call save(id, e)
            endif
        endmethod

        static method hasType takes unit u, integer id returns boolean
            return table[GetHandleId(u)][id] > 0
        endmethod

        static method countType takes unit u, integer id returns integer
            return table[GetHandleId(u)][id]
        endmethod

        static method countComponent takes integer id, integer component returns integer
            local thistype this

            if itempool[id].has(0) then
                set this = itempool[id][0]
                return count(component)
            endif

            return 0
        endmethod

        static method create takes integer id returns thistype
            local thistype this = thistype.allocate()
            local item i

            if id > 0 and not itempool[id].has(0) then
                set i = CreateItem(id, 0, 0)

                if i != null then
                    set this.id = id
                    set components = 0
                    set name = GetItemName(i)
                    set icon = BlzGetItemIconPath(i)
                    set tooltip = BlzGetItemExtendedTooltip(i)
                    set charges = GetItemCharges(i)
                    set itempool[id][0] = this

                    call costs(id)
                    call RemoveItem(i)

                    set i = null
                endif
            endif

            return this
        endmethod

        private static method save takes integer id, integer comp returns nothing
            local thistype this
            local thistype part
            local integer i = 0

            if comp > 0 and comp != id then
                set this = get(id)
                set part = get(comp)
                set component[components] = comp
                set components = components + 1
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

        private static method clear takes nothing returns nothing
            call RemoveItem(GetEnumItem())
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this
            local integer i = 0

            loop
                exitwhen i > key
                    set this = array[i]

                    if UnitHasItem(unit, item) then
                        call BlzSetItemExtendedTooltip(item, type.onTooltip(unit, item, index))
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onPickupItem takes nothing returns nothing
            local unit u = GetManipulatingUnit()
            local item i = GetManipulatedItem()
            local thistype this = itempool[GetItemTypeId(i)][0]
            local thistype self

            set table[GetHandleId(u)][GetItemTypeId(i)] = table[GetHandleId(u)][GetItemTypeId(i)] + 1

            if this != 0 then
                static if LIBRARY_NewBonus then
                    call LinkBonusToItem(u, BONUS_DAMAGE, damage, i)
                    call LinkBonusToItem(u, BONUS_ARMOR, armor, i)
                    call LinkBonusToItem(u, BONUS_DAMAGE_BLOCK, block, i)
                    call LinkBonusToItem(u, BONUS_AGILITY, agility, i)
                    call LinkBonusToItem(u, BONUS_STRENGTH, strength, i)
                    call LinkBonusToItem(u, BONUS_INTELLIGENCE, intelligence, i)
                    call LinkBonusToItem(u, BONUS_HEALTH, health, i)
                    call LinkBonusToItem(u, BONUS_MANA, mana, i)
                    call LinkBonusToItem(u, BONUS_MOVEMENT_SPEED, movementSpeed, i)
                    call LinkBonusToItem(u, BONUS_SIGHT_RANGE, sightRange, i)
                    call LinkBonusToItem(u, BONUS_HEALTH_REGEN, healthRegen, i)
                    call LinkBonusToItem(u, BONUS_MANA_REGEN, manaRegen, i)
                    call LinkBonusToItem(u, BONUS_ATTACK_SPEED, attackSpeed, i)
                    call LinkBonusToItem(u, BONUS_MAGIC_RESISTANCE, magicResistance, i)
                    call LinkBonusToItem(u, BONUS_PIERCE_CHANCE, pierce, i)
                    call LinkBonusToItem(u, BONUS_EVASION_CHANCE, evasion, i)
                    call LinkBonusToItem(u, BONUS_CRITICAL_DAMAGE, criticalDamage, i)
                    call LinkBonusToItem(u, BONUS_CRITICAL_CHANCE, criticalChance, i)
                    call LinkBonusToItem(u, BONUS_LIFE_STEAL, lifeSteal, i)
                    call LinkBonusToItem(u, BONUS_MISS_CHANCE, missChance, i)
                    call LinkBonusToItem(u, BONUS_SPELL_POWER, spellPower, i)
                    call LinkBonusToItem(u, BONUS_SPELL_VAMP, spellVamp, i)
                    call LinkBonusToItem(u, BONUS_OMNIVAMP, omnivamp, i)
                    call LinkBonusToItem(u, BONUS_COOLDOWN_REDUCTION, cooldownReduction, i)
                    call LinkBonusToItem(u, BONUS_COOLDOWN_REDUCTION_FLAT, cooldownReductionFlat, i)
                    call LinkBonusToItem(u, BONUS_COOLDOWN_OFFSET, cooldownOffset, i)
                    call LinkBonusToItem(u, BONUS_TENACITY, tenacity, i)
                    call LinkBonusToItem(u, BONUS_TENACITY_FLAT, tenacityFlat, i)
                    call LinkBonusToItem(u, BONUS_TENACITY_OFFSET, tenacityOffset, i)
                    call LinkBonusToItem(u, BONUS_ARMOR_PENETRATION, armorPenetration, i)
                    call LinkBonusToItem(u, BONUS_ARMOR_PENETRATION_FLAT, armorPenetrationFlat, i)
                    call LinkBonusToItem(u, BONUS_MAGIC_PENETRATION, magicPenetration, i)
                    call LinkBonusToItem(u, BONUS_MAGIC_PENETRATION_FLAT, magicPenetrationFlat, i)
                endif

                static if LIBRARY_Indexer then
                    if onTooltip.exists then
                        set self = thistype.allocate()
                        set self.unit = u
                        set self.item = i
                        set self.index = GetUnitUserData(self.unit)
                        set self.type = this
                        set key = key + 1
                        set array[key] = self
    
                        if key == 0 then
                            call TimerStart(timer, PERIOD, true, function thistype.onPeriod)
                        endif
                    endif
                endif

                if onPickup.exists then
                    call onPickup(u, i)
                endif
            endif
        endmethod

        private static method onDropItem takes nothing returns nothing
            local integer u = GetHandleId(GetManipulatingUnit())
            local integer i = GetItemTypeId(GetManipulatedItem())
            local thistype this = itempool[GetItemTypeId(GetManipulatedItem())][0]

            set table[u][i] = table[u][i] - 1

            if this != 0 then
                if onDrop.exists then
                    call onDrop(GetManipulatingUnit(), GetManipulatedItem())
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set rect = Rect(0, 0, 0, 0)
            set table = HashTable.create()
            set itempool = HashTable.create()
            set counters = HashTable.create()
            set itemtype = HashTable.create()
            set relations = HashTable.create()
            set shop = CreateUnit(player, 'hpea', 0, 0, 0)

            call SetUnitUseFood(shop, false)
            call UnitAddAbility(shop,'Asid')
            call UnitAddAbility(shop,'Asud')
            call UnitAddAbility(shop, 'Aloc')
            call UnitRemoveAbility(shop, 'Awan')
            call UnitRemoveAbility(shop, 'Aneu')
            call UnitRemoveAbility(shop, 'Ane2')
            call SetUnitAcquireRange(shop, 0)
            call ShowUnit(shop, false)
            call SetRect(rect, GetUnitX(shop) - 1000, GetUnitY(shop) - 1000, GetUnitX(shop) + 1000, GetUnitY(shop) + 1000)
            call UnitAddAbility(shop, 'AInv')
            call IssueNeutralTargetOrder(player, shop, "smart", shop)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, function thistype.onPickupItem)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, function thistype.onDropItem)
        endmethod
    endstruct

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function RegisterItem takes Item i, integer a, integer b, integer c, integer d, integer e returns nothing
        call Item.addComponents(i.id, a, b, c, d, e)
    endfunction

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
endlibrary