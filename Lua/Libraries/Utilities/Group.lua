OnInit("Group", function (requires)
    requires "Class"
    requires "Modules"
    requires.optional "Item"

    -- -------------------------------- Group v1.0 by Chopinski -------------------------------- --
    local Unit = Class()

    do
        Unit:property("type", {
            get = function(self)
                if self.id <= 0 then
                    self.id = I2R(GetUnitTypeId(self.unit))
                end

                return self.id
            end
        })

        Unit:property("hero", {
            get = function(self)
                if IsUnitType(self.unit, UNIT_TYPE_HERO) then
                    return 0.
                else
                    return 1.
                end
            end
        })

        Unit:property("mana", {
            get = function(self)
                if self.mp <= -1. then
                    self.mp = GetUnitState(self.unit, UNIT_STATE_MANA)
                end

                return self.mp
            end
        })

        Unit:property("health", {
            get = function(self)
                if self.hp <= -1. then
                    self.hp = GetUnitState(self.unit, UNIT_STATE_LIFE)
                end

                return self.hp
            end
        })

        Unit:property("level", {
            get = function(self)
                if self.lvl <= -1. then
                    if IsUnitType(self.unit, UNIT_TYPE_HERO) then
                        self.lvl = I2R(GetHeroLevel(self.unit))
                    else
                        self.lvl = I2R(GetUnitLevel(self.unit))
                    end
                end

                return self.lvl
            end
        })

        Unit:property("armor", {
            get = function(self)
                if self.amr <= -1. then
                    self.amr = BlzGetUnitArmor(self.unit)
                end

                return self.amr
            end
        })

        Unit:property("speed", {
            get = function(self)
                if self.spd <= -1. then
                    self.spd = GetUnitMoveSpeed(self.unit)
                end

                return self.spd
            end
        })

        Unit:property("damage", {
            get = function(self)
                if self.dmg <= -1. then
                    self.dmg = I2R(BlzGetUnitBaseDamage(self.unit, 0))
                end

                return self.dmg
            end
        })

        Unit:property("player", {
            get = function(self)
                if self.owner <= -1. then
                    self.owner = I2R(GetPlayerId(GetOwningPlayer(self.unit)))
                end

                return self.owner
            end
        })

        Unit:property("agility", {
            get = function(self)
                if self.agi <= -1. then
                    self.agi = I2R(GetHeroAgi(self.unit, true))
                end

                return self.agi
            end
        })

        Unit:property("strength", {
            get = function(self)
                if self.str <= -1. then
                    self.str = I2R(GetHeroStr(self.unit, true))
                end

                return self.str
            end
        })

        Unit:property("intelligence", {
            get = function(self)
                if self.int <= -1. then
                    self.int = I2R(GetHeroInt(self.unit, true))
                end

                return self.int
            end
        })

        Unit:property("distance", {
            get = function(self)
                if self.dist <= -1. then
                    self.dist = SquareRoot((GetUnitX(self.unit) - self.x) * (GetUnitX(self.unit) - self.x) + (GetUnitY(self.unit) - self.y) * (GetUnitY(self.unit) - self.y))
                end

                return self.dist
            end
        })

        Unit:property("healthPercentage", {
            get = function(self)
                if self.hpPercentage <= -1. then
                    self.hpPercentage = GetUnitLifePercent(self.unit)
                end

                return self.hpPercentage
            end
        })

        Unit:property("manaPercentage", {
            get = function(self)
                if self.mpPercentage <= -1. then
                    self.mpPercentage = GetUnitManaPercent(self.unit)
                end

                return self.mpPercentage
            end
        })

        function Unit:field(order)
            if order == OrderBy.type then
                return self.type
            elseif order == OrderBy.hero then
                return self.hero
            elseif order == OrderBy.mana then
                return self.mana
            elseif order == OrderBy.level then
                return self.level
            elseif order == OrderBy.armor then
                return self.armor
            elseif order == OrderBy.speed then
                return self.speed
            elseif order == OrderBy.damage then
                return self.damage
            elseif order == OrderBy.health then
                return self.health
            elseif order == OrderBy.player then
                return self.player
            elseif order == OrderBy.agility then
                return self.agility
            elseif order == OrderBy.distance then
                return self.distance
            elseif order == OrderBy.strength then
                return self.strength
            elseif order == OrderBy.intelligence then
                return self.intelligence
            elseif order == OrderBy.healthPercentage then
                return self.healthPercentage
            elseif order == OrderBy.manaPercentage then
                return self.manaPercentage
            end

            return 0.
        end

        function Unit:destroy()
            if self.allocated then
                self.unit = nil
                self.allocated = false
            end
        end

        function Unit.create(unit, x, y)
            local self = Unit.allocate()

            self.x = x
            self.y = y
            self.id = 0
            self.mp = -1.
            self.hp = -1.
            self.lvl = -1.
            self.amr = -1.
            self.spd = -1.
            self.dmg = -1.
            self.agi = -1.
            self.str = -1.
            self.int = -1.
            self.dist = -1.
            self.hpPercentage = -1.
            self.mpPercentage = -1.
            self.owner = -1.
            self.unit = unit
            self.allocated = true

            return self
        end
    end

    local Filter = Class()

    do
        function Filter:destroy()
            self.player = nil
            self.unittype = nil
        end

        function Filter.create(player, unittype, item , buff, negate)
            local self = Filter.allocate()

            self.item = item
            self.buff = buff
            self.player = player
            self.negate = negate
            self.unittype = unittype

            return self
        end
    end

    do
        OrderBy = Class()

        OrderBy.type = 1
        OrderBy.hero = 2
        OrderBy.mana = 4
        OrderBy.level = 8 
        OrderBy.armor = 16
        OrderBy.speed = 32
        OrderBy.damage = 64
        OrderBy.health = 128
        OrderBy.player = 256
        OrderBy.agility = 512
        OrderBy.distance = 1024
        OrderBy.strength = 2048
        OrderBy.intelligence = 4096
        OrderBy.healthPercentage = 8192
        OrderBy.manaPercentage = 16384
    end

    do
        Group = Class()

        Group:property("size", {
            get = function(self)
                return BlzGroupGetSize(self.group)
            end
        })

        function Group:destroy()
            local bound = self.size
            local i = 0

            if self.ending > bound then
                bound = self.ending
            end

            if bound > 0 then
                while i < bound do
                    if self.sorted[i] then
                        self.sorted[i]:destroy()
                    end
                    
                    i = i + 1
                end
            end

            self:unfilter()
            self.temp = nil
            self.items = nil
            self.buffs = nil
            self.sorted = nil
            self.orders = nil
            self.allies = nil
            self.owners = nil
            self.enemies = nil
            self.unittype = nil
            self.descends = nil

            DestroyGroup(self.group)

            self.group = nil
        end

        function Group:first()
            self:sort()

            if self.ending > 0 then
                return self.sorted[0].unit
            else
                return nil
            end
        end

        function Group:last()
            self:sort()

            if self.ending > 0 then
                return self.sorted[self.ending - 1].unit
            else
                return nil
            end
        end

        function Group:skip(amount)
            if self.size <= 0 then
                print("inRange, inRect, ofPlayer or insert must be called before skipping units.")
            else
                if amount > 0 then
                    self.skips = amount
                    self.ordered = false
                end
            end

            return self
        end

        function Group:take(amount)
            if self.size <= 0 then
                print("inRange, inRect, ofPlayer or insert must be called before taking units.")
            else
                if amount > 0 then
                    self.takes = amount
                    self.ordered = false
                end
            end

            return self
        end

        function Group:clear()
            local bound = self.size
            local i = 0

            if self.ending > bound then
                bound = self.ending
            end

            if bound > 0 then
                while i < bound do
                    if self.sorted[i] then
                        self.sorted[i]:destroy()
                    end
                    
                    i = i + 1
                end
            end

            self:unfilter()

            GroupClear(self.group)

            self.temp = {}
            self.sorted = {}
            self.orders = {}
            self.descends = {}
            self.ending = 0
            self.takes = 0
            self.skips = 0
            self.count = 0
            self.orderings = 0
            self.negate = false
            self.dead = false
            self.alive = false
            self.ordered = false

            return self
        end

        function Group:insert(unit)
            if unit then
                if not IsUnitInGroup(unit, self.group) then
                    self.ordered = false

                    GroupAddUnit(self.group, unit)
                end
            end

            return self
        end

        function Group:remove(unit)
            if unit then
                if IsUnitInGroup(unit, self.group) then
                    self.ordered = false

                    GroupRemoveUnit(self.group, unit)
                end
            end

            return self
        end

        function Group:damage(source, amount, attacktype, damagetype, callback)
            local i = 0

            self:sort()

            while i < self.ending do
                local unit = self.sorted[i].unit

                if UnitDamageTarget(source, unit, amount, false, false, attacktype, damagetype, nil) and type(callback) == "function" then
                    callback(unit)
                end

                i = i + 1
            end

            return self
        end

        function Group:forEach(callback)
            if type(callback) == "function" then
                local i = 0

                self:sort()

                while i < self.ending do
                    callback(self.sorted[i].unit)
                    i = i + 1
                end
            end

            return self
        end

        function Group:toList()
            local list = {}

            self:sort()

            for i = 0, self.ending - 1 do
                table.insert(list, self.sorted[i].unit)
            end

            return list
        end

        function Group:toGroup()
            self:sort()

            return self.group
        end

        function Group:inRect(rect)
            local g = CreateGroup()

            self.ordered = false

            GroupEnumUnitsInRect(g, rect, nil)
            BlzGroupAddGroupFast(g, self.group)
            DestroyGroup(g)

            return self
        end

        function Group:inRange(x, y, radius)
            local g = CreateGroup()

            self.x = x
            self.y = y
            self.ordered = false
            
            GroupEnumUnitsInRange(g, x, y, radius, nil)
            BlzGroupAddGroupFast(g, self.group)
            DestroyGroup(g)
            
            return self
        end

        function Group:ofPlayer(player)
            local g = CreateGroup()

            self.ordered = false

            GroupEnumUnitsOfPlayer(g, player, nil)
            BlzGroupAddGroupFast(g, self.group)
            DestroyGroup(g)

            return self
        end

        function Group:isNot()
            self.negate = true

            return self
        end

        function Group:isAlive()
            if self.negate then
                self.dead = true
                self.negate = false
            else
                self.alive = true
            end

            return self
        end

        function Group:allyOf(player)
            if player then
                table.insert(self.allies, Filter.create(player, nil, 0, 0, self.negate))
                self.negate = false
            end

            return self
        end

        function Group:enemyOf(player)
            if player then
                table.insert(self.enemies, Filter.create(player, nil, 0, 0, self.negate))
                self.negate = false
            end

            return self
        end

        function Group:ownedBy(player)
            if player then
                table.insert(self.owners, Filter.create(player, nil, 0, 0, self.negate))
                self.negate = false
            end

            return self
        end

        function Group:ofType(unittype)
            if unittype then
                table.insert(self.unittype, Filter.create(nil, unittype, 0, 0, self.negate))
                self.negate = false
            end

            return self
        end

        function Group:hasItem(item)
            if item > 0 then
                table.insert(self.items, Filter.create(nil, nil, item, 0, self.negate))
                self.negate = false
            end

            return self
        end

        function Group:hasBuff(buff)
            if buff > 0 then
                table.insert(self.buffs, Filter.create(nil, nil, 0, buff, self.negate))
                self.negate = false
            end

            return self
        end

        function Group:hasAbility(ability)
            return self:hasBuff(ability)
        end

        function Group:orderBy(order)
            if self.negate then
                print("Only isAlive, allyOf, enemyOf, ownedBy, ofType, hasBuff, hasAbility and hasItem can be called after isNot is callled.")
            else
                if self.size <= 0 then
                    print("inRange, inRect, ofPlayer or insert must be called before setting an order.")
                else
                    self.count = 1
                    self.orders[0] = order
                    self.orderings = order
                    self.ordered = false
                    self.descends[0] = false
                end
            end

            return self
        end

        function Group:thenBy(order)
            if self.negate then
                print("Only isAlive, allyOf, enemyOf, ownedBy, ofType, hasBuff, hasAbility and hasItem can be called after isNot is callled.")
            else
                if self.count <= 0 then
                    print("An orderBy must be specified before setting a secondary order.")
                elseif BlzBitAnd(self.orderings, order) ~= 0 then
                    print("Field is already part of the ordering chain.")
                else
                    self.orderings = BlzBitOr(self.orderings, order)
                    self.descends[self.count] = false
                    self.orders[self.count] = order
                    self.count = self.count + 1
                    self.ordered = false
                end
            end

            return self
        end

        function Group:descending()
            if self.negate then
                print("Only isAlive, allyOf, enemyOf, ownedBy, ofType, hasBuff, hasAbility and hasItem can be called after isNot is callled.")
            else
                if self.count <= 0 then
                    print("An orderBy must be specified before calling descending.")
                else
                    self.descends[self.count - 1] = true
                    self.ordered = false
                end
            end

            return self
        end

        function Group:unfilter()
            if #self.items > 0 then
                for i = 1, #self.items do
                    self.items[i]:destroy()
                end

                self.items = {}
            end

            if #self.buffs > 0 then
                for i = 1, #self.buffs do
                    self.buffs[i]:destroy()
                end

                self.buffs = {}
            end

            if #self.allies > 0 then
                for i = 1, #self.allies do
                    self.allies[i]:destroy()
                end

                self.allies = {}
            end

            if #self.owners > 0 then
                for i = 1, #self.owners do
                    self.owners[i]:destroy()
                end

                self.owners = {}
            end

            if #self.enemies > 0 then
                for i = 1, #self.enemies do
                    self.enemies[i]:destroy()
                end

                self.enemies = {}
            end

            if #self.unittype > 0 then
                for i = 1, #self.unittype do
                    self.unittype[i]:destroy()
                end

                self.unittype = {}
            end
        end

        function Group:sort()
            local i = 0
            local j = 0
            local k = 0

            if self.size <= 0 or self.ordered then
                return
            end

            local g = CreateGroup()

            BlzGroupAddGroupFast(self.group, g)

            while i < self.size do
                local add = true
                local unit = BlzGroupUnitAt(g, i)

                if self.alive then
                    add = UnitAlive(unit)
                end

                if self.dead then
                    add = add and not UnitAlive(unit)
                end

                if #self.allies > 0 then
                    for index = 1, #self.allies do
                        if self.allies[index].negate then
                            add = add and not IsUnitAlly(unit, self.allies[index].player)
                        else
                            add = add and IsUnitAlly(unit, self.allies[index].player)
                        end
                    end
                end

                if #self.enemies > 0 then
                    for index = 1, #self.enemies do
                        if self.enemies[index].negate then
                            add = add and not IsUnitEnemy(unit, self.enemies[index].player)
                        else
                            add = add and IsUnitEnemy(unit, self.enemies[index].player)
                        end
                    end
                end

                if #self.owners > 0 then
                    for index = 1, #self.owners do
                        if self.owners[index].negate then
                            add = add and GetOwningPlayer(unit) ~= self.owners[index].player
                        else
                            add = add and GetOwningPlayer(unit) == self.owners[index].player
                        end
                    end
                end

                if #self.unittype > 0 then
                    for index = 1, #self.unittype do
                        if self.unittype[index].negate then
                            add = add and not IsUnitType(unit, self.unittype[index].unittype)
                        else
                            add = add and IsUnitType(unit, self.unittype[index].unittype)
                        end
                    end
                end

                if #self.items > 0 then
                    for index = 1, #self.items do
                        if self.items[index].negate then
                            if Item then
                                add = add and not UnitHasItemOfType(unit, self.items[index].item)
                            else
                                add = add and not UnitHasItemOfTypeBJ(unit, self.items[index].item)
                            end
                        else
                            if Item then
                                add = add and UnitHasItemOfType(unit, self.items[index].item)
                            else
                                add = add and UnitHasItemOfTypeBJ(unit, self.items[index].item)
                            end
                        end
                    end
                end

                if #self.buffs > 0 then
                    for index = 1, #self.buffs do
                        if self.buffs[index].negate then
                            add = add and GetUnitAbilityLevel(unit, self.buffs[index].buff) <= 0
                        else
                            add = add and GetUnitAbilityLevel(unit, self.buffs[index].buff) > 0
                        end
                    end
                end

                if add then
                    if self.sorted[j] then
                        self.sorted[j]:destroy()
                    end

                    self.sorted[j] = Unit.create(unit, self.x, self.y)
                    j = j + 1
                end

                i = i + 1
            end

            local newEnd = j

            while j < self.ending do
                if self.sorted[j] then
                    self.sorted[j]:destroy()
                    self.sorted[j] = nil
                end

                j = j + 1
            end

            self.ending = newEnd

            if self.count > 0 then
                self:mergeSort(0, self.ending - 1)
            end

            GroupClear(self.group)

            i = 0

            if self.skips > 0 then
                i = IMinBJ(self.skips, self.ending)
            end

            j = self.ending

            if self.takes > 0 then
                j = IMinBJ(i + self.takes, self.ending)
            end

            k = 0

            while k < i do
                if self.sorted[k] then
                    self.sorted[k]:destroy()
                    self.sorted[k] = nil
                end

                k = k + 1
            end

            k = j

            while k < self.ending do
                if self.sorted[k] then
                    self.sorted[k]:destroy()
                    self.sorted[k] = nil
                end

                k = k + 1
            end

            k = 0

            while i < j do
                self.sorted[k] = self.sorted[i]

                if k ~= i then
                    self.sorted[i] = nil
                end

                GroupAddUnit(self.group, self.sorted[k].unit)

                k = k + 1
                i = i + 1
            end

            self.ending = k

            DestroyGroup(g)

            self.ordered = true
        end

        function Group:compare(a, b)
            local result = 0
            local i = 0
            local va
            local vb

            while i < self.count and result == 0 do
                va = a:field(self.orders[i])
                vb = b:field(self.orders[i])

                if va < vb then
                    result = -1
                elseif va > vb then
                    result = 1
                end

                if self.descends[i] then
                    result = -result
                end

                i = i + 1
            end

            return result
        end

        function Group:merge(left, mid, right)
            local i = left
            local j = mid + 1
            local k = left

            while i <= mid and j <= right do
                if self:compare(self.sorted[i], self.sorted[j]) <= 0 then
                    self.temp[k] = self.sorted[i]
                    i = i + 1
                else
                    self.temp[k] = self.sorted[j]
                    j = j + 1
                end

                k = k + 1
            end

            while i <= mid do
                self.temp[k] = self.sorted[i]
                i = i + 1
                k = k + 1
            end

            while j <= right do
                self.temp[k] = self.sorted[j]
                j = j + 1
                k = k + 1
            end

            k = left

            while k <= right do
                self.sorted[k] = self.temp[k]
                k = k + 1
            end
        end

        function Group:mergeSort(left, right)
            local mid

            if left < right then
                mid = (left + right) // 2

                self:mergeSort(left, mid)
                self:mergeSort(mid + 1, right)
                self:merge(left, mid, right)
            end
        end

        function Group.create()
            local self = Group.allocate()

            self.x = 0.
            self.y = 0.
            self.takes = 0
            self.count = 0
            self.skips = 0
            self.ending = 0
            self.orderings = 0
            self.dead = false
            self.alive = false
            self.negate = false
            self.ordered = false
            self.temp = {}
            self.items = {}
            self.buffs = {}
            self.sorted = {}
            self.orders = {}
            self.allies = {}
            self.owners = {}
            self.enemies = {}
            self.unittype = {}
            self.descends = {}
            self.group = CreateGroup()

            return self
        end
    end
end)