OnInit("Item", function(requires)
    requires "Class"
    requires "RegisterPlayerUnitEvent"
    requires.optional "Bonus"

    Item = Class()

    local period = 1
    local shop = nil
    local items = {}
    local array = {}
    local itempool = {}
    local counters = {}
    local itemtype = {}
    local relations = {}
    local timer = CreateTimer()
    local rect = Rect(0, 0, 0, 0)
    local player = Player(bj_PLAYER_NEUTRAL_EXTRA)

    Item:property("mana", { get = function (self) return 0 end })
    Item:property("armor", { get = function (self) return 0 end })
    Item:property("block", { get = function (self) return 0 end })
    Item:property("damage", { get = function (self) return 0 end })
    Item:property("health", { get = function (self) return 0 end })
    Item:property("evasion", { get = function (self) return 0 end })
    Item:property("agility", { get = function (self) return 0 end })
    Item:property("strength", { get = function (self) return 0 end })
    Item:property("tenacity", { get = function (self) return 0 end })
    Item:property("lifeSteal", { get = function (self) return 0 end })
    Item:property("spellVamp", { get = function (self) return 0 end })
    Item:property("manaRegen", { get = function (self) return 0 end })
    Item:property("sightRange", { get = function (self) return 0 end })
    Item:property("missChance", { get = function (self) return 0 end })
    Item:property("spellPower", { get = function (self) return 0 end })
    Item:property("healthRegen", { get = function (self) return 0 end })
    Item:property("attackSpeed", { get = function (self) return 0 end })
    Item:property("intelligence", { get = function (self) return 0 end })
    Item:property("tenacityFlat", { get = function (self) return 0 end })
    Item:property("movementSpeed", { get = function (self) return 0 end })
    Item:property("criticalDamage", { get = function (self) return 0 end })
    Item:property("criticalChance", { get = function (self) return 0 end })
    Item:property("cooldownOffset", { get = function (self) return 0 end })
    Item:property("tenacityOffset", { get = function (self) return 0 end })
    Item:property("magicResistance", { get = function (self) return 0 end })
    Item:property("armorPenetration", { get = function (self) return 0 end })
    Item:property("magicPenetrationFlat", { get = function (self) return 0 end })
    Item:property("cooldownReductionFlat", { get = function (self) return 0 end })

    Item:property("gold", {
        get = function (self) return itempool[self.id][1] end,
        set = function (self, value) itempool[self.id][1] = value end
    })

    Item:property("wood", {
        get = function (self) return itempool[self.id][8] end,
        set = function (self, value) itempool[self.id][8] = value end
    })

    Item:property("charges", {
        get = function (self) return itempool[self.id][2] end,
        set = function (self, value)
            if value <= 0 then
                itempool[self.id][2] = 1
            else
                itempool[self.id][2] = value
            end
        end
    })

    Item:property("name", {
        get = function (self) return itempool[self.id][3] end,
        set = function (self, value) itempool[self.id][3] = value end
    })

    Item:property("icon", {
        get = function (self) return itempool[self.id][4] end,
        set = function (self, value) itempool[self.id][4] = value end
    })

    Item:property("tooltip", {
        get = function (self) return itempool[self.id][5] end,
        set = function (self, value) itempool[self.id][5] = value end
    })

    Item:property("categories", {
        get = function (self) return itempool[self.id][6] end,
        set = function (self, value) itempool[self.id][6] = value end
    })

    Item:property("components", {
        get = function (self) return itempool[self.id][7] end,
        set = function (self, value) itempool[self.id][7] = value end
    })

    Item:property("component", { get = function (self) return itemtype[self.id] end })
    Item:property("counter", { get = function (self) return counters[self.id] end })
    Item:property("relation", { get = function (self) return relations[self.id] end })

    function Item:recipe(lumber)
        local amount = self.gold

        if lumber then
            amount = amount + self.wood
        end

        if self.components > 0 then
            for i = 1, #self.component do
                if lumber then
                    amount = amount - Item.get(self.component[i]).wood
                else
                    amount = amount - Item.get(self.component[i]).gold
                end
            end
        end

        return 0
    end

    function Item:cost(unit, lumber)
        local amount
        local owned = {}

        if not unit then
            if lumber then
                amount = self.wood
            else
                amount = self.gold
            end
        else
            local size = UnitInventorySize(unit)

            for i = 0, size do
                owned[GetItemTypeId(UnitItemInSlot(unit, i))] = (owned[GetItemTypeId(UnitItemInSlot(unit, i))] or 0) + 1
            end

            amount = self:calculate(owned, lumber)
        end

        owned = nil

        return amount
    end

    function Item:count(id)
        return self.counter[id] or 0
    end

    function Item:calculate(owned, lumber)
        if self.components <= 0 then
            if lumber then
                return self.wood
            end

            return self.gold
        else
            local amount = self:recipe(lumber)

            for i = 1, #self.component do
                local piece = Item.get(self.component[i])

                if (owned[piece.id] or 0) > 0 then
                    owned[piece.id] = owned[piece.id] - 1
                else
                    amount = amount + piece:calculate(owned, lumber)
                end
            end

            return amount
        end
    end

    function Item:costs(id)
        AddItemToStock(shop, id, 1, 1)
        SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, 9999999)
        SetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER, 9999999)
        local coin = GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD)
        local lumber = GetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER)
        IssueNeutralImmediateOrderById(player, shop, id)
        RemoveItemFromStock(shop, id)
        EnumItemsInRect(rect, nil, function() RemoveItem(GetEnumItem()) end)

        self.gold = coin - GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD)
        self.wood = lumber - GetPlayerState(player, PLAYER_STATE_RESOURCE_LUMBER)
    end

    function Item.get(id)
        if id and id > 0 then
            if itempool[id] then
                return itempool[id][0]
            else
                return Item.create(id)
            end
        end

        return nil
    end

    function Item.addComponents(id, a, b, c, d, e)
        if id > 0 then
            local this = Item.get(id)

            this.components = 0
            this.component = {}
            this.counter = {}

            Item.save(id, a)
            Item.save(id, b)
            Item.save(id, c)
            Item.save(id, d)
            Item.save(id, e)
        end
    end

    function Item.hasType(unit, id)
        return (items[unit] and (items[unit][id] or 0) > 0) or false
    end

    function Item.countType(unit, id)
        return (items[unit] and (items[unit][id] or 0)) or 0
    end

    function Item.countComponent(id, component)
        if itempool[id] then
            local this = itempool[id][0]
            return this:count(component)
        end

        return 0
    end

    function Item.save(id, component)
        if component > 0 and component ~= id then
            local i = 0
            local this = Item.get(id)
            local part = Item.get(component)

            table.insert(this.component, component)
            this.components = (this.components or 0) + 1
            this.conuter[component] = (this.counter[component] or 0) + 1

            while (part.ralation[i] or 0) ~= id do
                if not part.relation[i] then
                    part.relation[i] = id
                    break
                end

                i = i + 1
            end
        end
    end

    function Item.create(id)
        local this = Item.allocate()

        if id > 0 and not itempool[id] then
            local item = CreateItem(id, 0, 0)

            if item then
                itempool[id] = {}
                itemtype[id] = {}
                counters[id] = {}
                relations[id] = {}

                this.id = id
                this.components = 0
                this.name = GetItemName(item)
                this.icon = BlzGetItemIconPath(item)
                this.tooltip  = BlzGetItemExtendedTooltip(item)
                this.charges = GetItemCharges(item)
                itempool[id][0] = this

                this:costs(id)
                RemoveItem(item)
            end
        end

        return this
    end

    function Item.onPickupItem()
        local unit = GetManipulatingUnit()
        local item = GetManipulatedItem()
        local id = GetItemTypeId(item)

        if not items[unit] then items[unit] = {} end

        items[unit][id] = (items[unit][id] or 0) + 1

        if itempool[id] then
            local this = itempool[id][0]

            if Bonus then
                LinkBonusToItem(unit, BONUS_DAMAGE, this.damage, item)
                LinkBonusToItem(unit, BONUS_ARMOR, this.armor, item)
                LinkBonusToItem(unit, BONUS_DAMAGE_BLOCK, this.block, item)
                LinkBonusToItem(unit, BONUS_AGILITY, this.agility, item)
                LinkBonusToItem(unit, BONUS_STRENGTH, this.strength, item)
                LinkBonusToItem(unit, BONUS_INTELLIGENCE, this.intelligence, item)
                LinkBonusToItem(unit, BONUS_HEALTH, this.health, item)
                LinkBonusToItem(unit, BONUS_MANA, this.mana, item)
                LinkBonusToItem(unit, BONUS_MOVEMENT_SPEED, this.movementSpeed, item)
                LinkBonusToItem(unit, BONUS_SIGHT_RANGE, this.sightRange, item)
                LinkBonusToItem(unit, BONUS_HEALTH_REGEN, this.healthRegen, item)
                LinkBonusToItem(unit, BONUS_MANA_REGEN, this.manaRegen, item)
                LinkBonusToItem(unit, BONUS_ATTACK_SPEED, this.attackSpeed, item)
                LinkBonusToItem(unit, BONUS_MAGIC_RESISTANCE, this.magicResistance, item)
                LinkBonusToItem(unit, BONUS_EVASION_CHANCE, this.evasion, item)
                LinkBonusToItem(unit, BONUS_CRITICAL_DAMAGE, this.criticalDamage, item)
                LinkBonusToItem(unit, BONUS_CRITICAL_CHANCE, this.criticalChance, item)
                LinkBonusToItem(unit, BONUS_LIFE_STEAL, this.lifeSteal, item)
                LinkBonusToItem(unit, BONUS_MISS_CHANCE, this.missChance, item)
                LinkBonusToItem(unit, BONUS_SPELL_POWER, this.spellPower, item)
                LinkBonusToItem(unit, BONUS_SPELL_VAMP, this.spellVamp, item)
                LinkBonusToItem(unit, BONUS_COOLDOWN_REDUCTION, this.cooldownReduction, item)
                LinkBonusToItem(unit, BONUS_COOLDOWN_REDUCTION_FLAT, this.cooldownReductionFlat, item)
                LinkBonusToItem(unit, BONUS_COOLDOWN_OFFSET, this.cooldownOffset, item)
                LinkBonusToItem(unit, BONUS_TENACITY, this.tenacity, item)
                LinkBonusToItem(unit, BONUS_TENACITY_FLAT, this.tenacityFlat, item)
                LinkBonusToItem(unit, BONUS_TENACITY_OFFSET, this.tenacityOffset, item)
                LinkBonusToItem(unit, BONUS_ARMOR_PENETRATION, this.armorPenetration, item)
                LinkBonusToItem(unit, BONUS_ARMOR_PENETRATION_FLAT, this.armorPenetrationFlat, item)
                LinkBonusToItem(unit, BONUS_MAGIC_PENETRATION, this.magicPenetration, item)
                LinkBonusToItem(unit, BONUS_MAGIC_PENETRATION_FLAT, this.magicPenetrationFlat, item)
            end

            if this.onTooltip then
                table.insert(array, {
                    unit = unit,
                    item = item,
                    type = this
                })

                if #array == 1 then
                    TimerStart(timer, period, true, function()
                        for i = #array, 1, -1 do
                            local this = array[i]

                            if UnitHasItem(this.unit, this.item) then
                                BlzSetItemExtendedTooltip(this.item, this.type:onTooltip(this.unit, this.item))
                            else
                                table.remove(array, i)

                                if #array == 0 then
                                    PauseTimer(timer)
                                end
                            end
                        end
                    end)
                end
            end

            if this.onPickup then
                this:onPickup(unit, item)
            end
        end
    end

    function Item.onDropItem()
        local unit = GetManipulatingUnit()
        local item = GetManipulatedItem()
        local id = GetItemTypeId(item)

        if not items[unit] then items[unit] = {} end

        items[unit][id] = (items[unit][id] or 0) - 1

        if itempool[id] then
            local this = itempool[id][0]

            if this.onDrop then
                this:onDrop(unit, item)
            end
        end
    end

    function Item.onInit()
        shop = CreateUnit(player, FourCC('hpea'), 0, 0, 0)

        SetUnitUseFood(shop, false)
        UnitAddAbility(shop, FourCC('Asid'))
        UnitAddAbility(shop, FourCC('Asud'))
        UnitAddAbility(shop, FourCC('Aloc'))
        UnitRemoveAbility(shop, FourCC('Awan'))
        UnitRemoveAbility(shop, FourCC('Aneu'))
        UnitRemoveAbility(shop, FourCC('Ane2'))
        SetUnitAcquireRange(shop, 0)
        ShowUnit(shop, false)
        SetRect(rect, GetUnitX(shop) - 1000, GetUnitY(shop) - 1000, GetUnitX(shop) + 1000, GetUnitY(shop) + 1000)
        UnitAddAbility(shop, FourCC('AInv'))
        IssueNeutralTargetOrder(player, shop, "smart", shop)
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, Item.onPickupItem)
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, Item.onDropItem)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function RegisterItem (item, a, b, c, d, e)
        Item.addComponents(item.id, a, b, c, d, e)
    end

    function ItemAddComponents (id, a, b, c, d, e)
        Item.addComponents(id, a, b, c, d, e)
    end

    function ItemCountComponentOfType(id, component)
        return Item.countComponent(id, component)
    end

    function UnitHasItemOfType(unit, id)
        return Item.hasType(unit, id)
    end

    function UnitCountItemOfType(unit, id)
        return Item.countType(unit, id)
    end
end)