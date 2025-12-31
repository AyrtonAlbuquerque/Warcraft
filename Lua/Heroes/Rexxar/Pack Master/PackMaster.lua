OnInit("PackMaster", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "RegisterPlayerUnitEvent"

    -- ----------------------------- Pack Master v1.2 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The ability raw code
    local ABILITY   = S2A('Rex3')
    -- The wolf unit raw code
    local WOLF      = S2A('rex1')

    -- The maximum number of wolfs per level
    local function GetMaxWolfCount(level)
        return level
    end

    -- The wolf damage
    local function GetWolfDamage(unit, level)
        return R2I((BlzGetUnitBaseDamage(unit, 0) + GetUnitBonus(unit, BONUS_DAMAGE)) * (0.25 + 0. * level))
    end

    -- The wolf critical chance
    local function GetWolfCriticalChance(level)
        return 0.3 + 0.*level
    end

    -- The wolf critical damage bonus (1 base)
    local function GetWolfCriticalDamage(level)
        return 1. + 0. * level
    end

    -- The wolf duration
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The max distance a wolf can be from Rexxar
    local function GetMaxDistance(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The Unit Filter
    local function UnitFilter(player, unit)
        return IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Unselect = Class()

        function Unselect:destroy()
            IssueImmediateOrder(self.unit, "stop")

            self.unit = nil
        end

        function Unselect.onOrder()
            local source = GetOrderedUnit()
            local owner = GetOwningPlayer(source)
            local order = OrderId2String(GetIssuedOrderId())
            
            if order == "smart" and IsUnitSelected(source, owner) and GetUnitTypeId(source) == WOLF then
                local self = { destroy = Unselect.destroy }
                
                self.unit = source
                
                TimerStart(CreateTimer(), 0, false, function ()
                    DestroyTimer(GetExpiredTimer())
                    self:destroy()
                end)
            end
        end

        function Unselect.onSelect()
            local unit = GetTriggerUnit()
            
            if GetUnitTypeId(unit) == WOLF then
                SelectUnit(unit, false)
            end
        end

        function Unselect.onInit()
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, Unselect.onSelect)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, Unselect.onOrder)
        end
    end

    do
        Wolf = Class()

        local array = {}

        Wolf:property("size", { get = function(self) return BlzGroupGetSize(self.group) end })

        function Wolf:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyGroup(self.group)

            array[self.timer] = nil

            self.unit = nil
            self.timer = nil
            self.group = nil
            self.player = nil
        end

        function Wolf.onPeriod()
            local self = array[GetExpiredTimer()]

            if self then
                for i = 0, self.size - 1 do
                    local u = BlzGroupUnitAt(self.group, i)

                    if not IsUnitInRange(u, self.unit, GetMaxDistance(self.unit, GetUnitAbilityLevel(self.unit, ABILITY))) then
                        IssueTargetOrder(u, "smart", self.unit)
                    end
                end
            end
        end

        function Wolf:add(target)
            local wolf = CreateUnit(self.player, WOLF, GetUnitX(target), GetUnitY(target), 0)
            local level = GetUnitAbilityLevel(self.unit, ABILITY)
            
            array[wolf] = self
            
            SetUnitBonus(wolf, BONUS_CRITICAL_CHANCE, GetWolfCriticalChance(level))
            SetUnitBonus(wolf, BONUS_CRITICAL_DAMAGE, GetWolfCriticalDamage(level))
            BlzSetUnitBaseDamage(wolf, GetWolfDamage(self.unit, level), 0)
            UnitApplyTimedLife(wolf, S2A('BTLF'), GetDuration(self.unit, level))
            GroupAddUnit(self.group, wolf)
            
            if self.size == 1 then
                TimerStart(self.timer, 1, true, Wolf.onPeriod)
            end
        end

        function Wolf:command(target, x, y, order)
            if not target then
                if self.shadow then
                    for i = 0, self.size - 1 do
                        IssuePointOrder(BlzGroupUnitAt(self.group, i), order, x + 200*Cos(i*2*bj_PI/self.size), y + 200*Sin(i*2*bj_PI/self.size))
                    end
                else
                    GroupPointOrder(self.group, order, x, y)
                end
            else
                if target == self.unit then
                    for i = 0, self.size - 1 do
                        IssuePointOrder(BlzGroupUnitAt(self.group, i), order, x + 200*Cos(i*2*bj_PI/self.size), y + 200*Sin(i*2*bj_PI/self.size))
                    end
                else
                    GroupTargetOrder(self.group, order, target)
                end
            end
        end

        function Wolf.onDeath()
            local target = GetTriggerUnit()
            
            if GetUnitTypeId(target) == WOLF then
                if array[target] then
                    local self = array[target]
                    
                    if self then
                        GroupRemoveUnit(self.group, target)

                        if self.size == 0 then
                            self.shadow = true
                            PauseTimer(self.timer)
                        end
                    end
                end
            end
        end

        function Wolf.create(owner)
            local self = { destroy = Wolf.destroy }
            
            self.unit = owner
            self.shadow = true
            self.group = CreateGroup()
            self.timer = CreateTimer()
            self.player = GetOwningPlayer(owner)
            array[self.timer] = self
            
            return self
        end

        function Wolf.onInit()
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, Wolf.onDeath)
        end
    end

    do
        PackMaster = Class(Spell)

        local array = {}
        local holding = {}
        local registered = {}
        local trigger = CreateTrigger()

        function PackMaster:destroy()
            self.pack:destroy()
        end

        function PackMaster.get(source)
            local self = array[source]
            
            if not self then
                self = PackMaster.create(source)
                array[source] = self
            end
            
            return self
        end

        function PackMaster.add(player)
            local id = GetPlayerId(player)
            
            if not registered[id] then
                registered[id] = true
                BlzTriggerRegisterPlayerKeyEvent(trigger, player, OSKEY_TAB, 0, true)
                BlzTriggerRegisterPlayerKeyEvent(trigger, player, OSKEY_TAB, 0, false)
            end
        end

        function PackMaster.create(source)
            local self = { destroy = PackMaster.destroy }
            
            self.pack = Wolf.create(source)
            
            return self
        end

        function PackMaster:onTooltip(source, level, ability)
            return "When |cffffcc00Rexxar|r kills an enemy unit a wolf is created at the target location. |cffffcc00Rexxar's|r wolfs cannot be selected, are invulnerable and can only be controlled through this ability. Initially the wolfs shadow |cffffcc00Rexxar's|r movements and commands. Casting this ability gives commands to the wolfs and make them stop shadowing |cffffcc00Rexxar|r. Max |cffffcc00" .. N2S(GetMaxWolfCount(level), 0) .. "|r wolf, deals |cffffcc00" .. N2S(25, 0) .. "%%|r of |cffffcc00Rexxar|r Max Damage and has |cffffcc00" .. N2S(GetWolfCriticalChance(level)*100, 0) .. "%%|r chance to hit a |cffffcc00Critical Strike|r from |cffffcc00" .. N2S(1 + GetWolfCriticalDamage(level), 0) .. "x|r normal damage.\n\n- When targeting an enemy unit the wolfs are commanded to attack the targeted unit.\n\n- When targeting the ground, the wolfs are commanded to move to the postion. Holding the |cffffcc00TAB|r key and targeting the ground commands the wolfs to attack any enemy unit in the way.\n\n- Casting this ability on |cffffcc00Rexxar|r makes the wolfs shadow his movements again.\n\nFinnaly, |cffffcc00Rexxar's|r wolfs can only be at a maximum |cffffcc00" .. N2S(GetMaxDistance(source, level), 0) .. "|r distance from him and when exceeding this distance the wolfs runs back to |cffffcc00Rexxar|r.\n\nLasts for |cffffcc00" .. N2S(GetDuration(source, level), 0) .. "|r seconds."
        end

        function PackMaster:onLearn(source, skill, level)
            PackMaster.add(GetOwningPlayer(source))
        end

        function PackMaster.onKey()
            if BlzGetTriggerPlayerIsKeyDown() then
                holding[GetPlayerId(GetTriggerPlayer())] = true
            else
                holding[GetPlayerId(GetTriggerPlayer())] = false
            end
        end

        function PackMaster.onDeath()
            local source = GetKillingUnit()
            local level = GetUnitAbilityLevel(source, ABILITY)
            
            if level > 0 and IsUnitEnemy(GetTriggerUnit(), GetOwningPlayer(source)) then
                local self = PackMaster.get(source)
                
                if self then
                    if self.pack.size < GetMaxWolfCount(level) then
                        self.pack:add(GetTriggerUnit())
                    end
                end
            end
        end

        function PackMaster.onOrder()
            local source = GetOrderedUnit()
            local target = GetOrderTargetUnit()
            local order = OrderId2String(GetIssuedOrderId())
            
            if GetUnitAbilityLevel(source, ABILITY) > 0 then
                local self = PackMaster.get(source)
                local owner = GetOwningPlayer(source)
                
                PackMaster.add(owner)
                
                if self.pack.size > 0 then
                    if order == "attackground" then
                        if not (source == target) then
                            self.pack.shadow = false
                            
                            if holding[GetPlayerId(owner)] then
                                self.pack:command(target, GetOrderPointX(), GetOrderPointY(), "attack")
                            else
                                self.pack:command(target, GetOrderPointX(), GetOrderPointY(), "smart")
                            end
                        else
                            self.pack.shadow = true
                            self.pack:command(target, GetUnitX(source), GetUnitY(source), "smart")
                        end
                    elseif self.pack.shadow then
                        if order == "smart" or order == "move" or order == "attack" then
                            if not target then
                                self.pack:command(target, GetOrderPointX(), GetOrderPointY(), "smart")
                            else
                                GroupTargetOrder(self.pack.group, order, target)
                            end
                        elseif order == "stop" or order == "holdposition" then
                            GroupImmediateOrder(self.pack.group, order)
                        end
                    end
                end
            end
        end

        function PackMaster.onInit()
            RegisterSpell(PackMaster.allocate(), ABILITY)
            TriggerAddCondition(trigger, Condition(PackMaster.onKey))
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, PackMaster.onDeath)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, PackMaster.onOrder)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, PackMaster.onOrder)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, PackMaster.onOrder)
        end
    end
end)