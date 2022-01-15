--[[ requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, TimerUtils, NewBonus
    /* ---------------------- Pack Master v1.0 by Chopinski --------------------- */
    // Credits:
    //     Bribe           - SpellEffectEvent
    //     Vexorian        - TimerUtils
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The ability raw code
    local ABILITY = FourCC('A003')
    -- The wolf unit raw code
    local WOLF = FourCC('o001')

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
        return 30. + 0. * level
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

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    do
        Wolf = setmetatable({}, {})
        local mt = getmetatable(Wolf)
        mt.__index = mt

        local struct = {}

        function mt:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyGroup(self.group)
            self = nil
        end

        function mt:add(unit)
            local wolf = CreateUnit(self.player, WOLF, GetUnitX(unit), GetUnitY(unit), 0)
            local level = GetUnitAbilityLevel(self.unit, ABILITY)

            struct[wolf] = self

            SetUnitBonus(wolf, BONUS_CRITICAL_CHANCE, GetWolfCriticalChance(level))
            SetUnitBonus(wolf, BONUS_CRITICAL_DAMAGE, GetWolfCriticalDamage(level))
            BlzSetUnitBaseDamage(wolf, GetWolfDamage(self.unit, level), 0)
            UnitApplyTimedLife(wolf, FourCC('BTLF'), GetDuration(self.unit, level))
            GroupAddUnit(self.group, wolf)
            self.size = BlzGroupGetSize(self.group)

            if self.size == 1 then
                TimerStart(self.timer, 1, true, function()
                    for i = 0, self.size - 1 do
                        local u = BlzGroupUnitAt(self.group, i)
                        if not IsUnitInRange(u, self.unit, GetMaxDistance(self.unit, level)) then
                            IssueTargetOrder(u, "smart", self.unit)
                        end
                    end
                end)
            end
        end

        function mt:command(unit, x, y, order)
            if unit == nil then
                if self.shadow then
                    for i = 0, self.size - 1 do
                        IssuePointOrder(BlzGroupUnitAt(self.group, i), order, x + 200 * Cos(i * 2 * bj_PI / self.size), y + 200 * Sin(i * 2 * bj_PI / self.size))
                    end
                else
                    GroupPointOrder(self.group, order, x, y)
                end
            else
                if unit == self.unit then
                    for i = 0, self.size - 1 do
                        IssuePointOrder(BlzGroupUnitAt(self.group, i), order, x + 200 * Cos(i * 2 * bj_PI / self.size), y + 200 * Sin(i * 2 * bj_PI / self.size))
                    end
                else
                    GroupTargetOrder(self.group, order, unit)
                end
            end
        end

        function mt:create(unit)
            local this = {}
            setmetatable(this, mt)

            this.unit = unit
            this.shadow = true
            this.group = CreateGroup()
            this.timer = CreateTimer()
            this.player = GetOwningPlayer(unit)
            this.size = BlzGroupGetSize(this.group)

            return this
        end

        onInit(function()
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function()
                local unit = GetTriggerUnit()

                if GetUnitTypeId(unit) == WOLF then
                    if struct[unit] then
                        local this = struct[unit]

                        GroupRemoveUnit(this.group, unit)
                        this.size = BlzGroupGetSize(this.group)
                        if this.size == 0 then
                            this.shadow = true
                            PauseTimer(this.timer)
                        end
                    end
                end
            end)
        end)
    end

    do
        Master = setmetatable({}, {})
        local mt = getmetatable(Master)
        mt.__index = mt

        local trigger = CreateTrigger()
        local holding = {}
        local registered = {}
        local struct = {}

        function mt:destroy()
            self.pack:destroy()
            self = nil
        end

        function mt:create(unit)
            local this = {}
            setmetatable(this, mt)

            this.pack = Wolf:create(unit)

            return this
        end

        function mt:register(player)
            if not registered[player] then
                registered[player] = true
                BlzTriggerRegisterPlayerKeyEvent(trigger, player, OSKEY_TAB, 0, true)
                BlzTriggerRegisterPlayerKeyEvent(trigger, player, OSKEY_TAB, 0, false)
            end
        end

        function mt:instance(unit)
            local this

            if struct[unit] then
                this = struct[unit]
            else
                this = self:create(unit)
                struct[unit] = this
            end

            return this
        end

        function mt:onOrder()
            local source = GetOrderedUnit()
            local target = GetOrderTargetUnit()
            local order = OrderId2String(GetIssuedOrderId())

            if GetUnitAbilityLevel(source, ABILITY) > 0 then
                local this = Master:instance(source)
                local player = GetOwningPlayer(source)

                this:register(player)

                if this.pack.size > 0 then
                    if order == "attackground" then
                        if not (source == target) then
                            this.pack.shadow = false

                            if holding[player] then
                                this.pack:command(target, GetOrderPointX(), GetOrderPointY(), "attack")
                            else
                                this.pack:command(target, GetOrderPointX(), GetOrderPointY(), "smart")
                            end
                        else
                            this.pack.shadow = true
                            this.pack:command(target, GetUnitX(source), GetUnitY(source), "smart")
                        end
                    elseif this.pack.shadow then
                        if order == "smart" or order == "move" or order == "attack" then
                            if target == nil then
                                this.pack:command(target, GetOrderPointX(), GetOrderPointY(), "smart")
                            else
                                GroupTargetOrder(this.pack.group, order, target)
                            end
                        elseif order == "stop" or order == "holdposition" then
                            GroupImmediateOrder(this.pack.group, order)
                        end
                    end
                end
            end
        end

        onInit(function()
            TriggerAddCondition(trigger, Condition(function()
                if BlzGetTriggerPlayerIsKeyDown() then
                    holding[GetTriggerPlayer()] = true
                else
                    holding[GetTriggerPlayer()] = false
                end
            end))

            RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function()
                Master:register(GetOwningPlayer(GetTriggerUnit()))
            end)

            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function()
                local unit = GetKillingUnit()
                local level = GetUnitAbilityLevel(unit, ABILITY)

                if level > 0 then
                    local this = Master:instance(unit)

                    if this.pack.size < GetMaxWolfCount(level) then
                        this.pack:add(GetTriggerUnit())
                    end
                end
            end)

            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function()
                Master:onOrder()
            end)

            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function()
                Master:onOrder()
            end)

            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, function()
                Master:onOrder()
            end)
        end)
    end

    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function()
            local unit = GetOrderedUnit()
            local player = GetOwningPlayer(unit)
            local order = OrderId2String(GetIssuedOrderId())

            if order == "smart" and IsUnitSelected(unit, player) and GetUnitTypeId(unit) == WOLF then
                local timer = CreateTimer()

                TimerStart(timer, 0, false, function()
                    IssueImmediateOrder(unit, "stop")
                    PauseTimer(timer)
                    DestroyTimer(timer)
                end)
            end
        end)

        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, function()
            local unit = GetTriggerUnit()

            if GetUnitTypeId(unit) == WOLF then
                SelectUnit(unit, false)
            end
        end)
    end)
end