--[[ requires SpellEffectEvent, PluginSpellEffect, NewBonus, Indexer
    /* -------------------- Water Elemental v1.1 by Chopinski ------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY               = FourCC('A000')
    -- The raw code of the Water Elemental unit
    WaterElemental_ELEMENTAL    = FourCC('h001')
    -- The summon effect
    local MODEL                 = "WaterBurst.mdl"
    -- The summon effect scale
    local SCALE                 = 1

    -- The unit damage
    local function GetDamage(unit, level)
        return 30 + R2I((BlzGetUnitBaseDamage(unit, 0) + GetUnitBonus(unit, BONUS_DAMAGE))*0.3)
    end

    -- The unit health
    local function GetHealth(unit, level)
        return 600 + R2I(BlzGetUnitMaxHP(unit)*0.4)
    end

    -- The unit armor
    local function GetArmor(unit, level)
        return 1. + GetUnitBonus(unit, BONUS_ARMOR)
    end

    -- The unit duration
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    do
        Elemental = setmetatable({}, {})
        local mt = getmetatable(Elemental)
        mt.__index = mt

        local struct = {}

        function mt:destroy()
            for i = 0, self.size - 1 do
                struct[BlzGroupUnitAt(self.group, i)] = nil
            end

            DestroyGroup(self.group)
            self = nil
        end

        function mt:command(target, x, y, order)
            if target == nil then
                if order == "stop" or order == "holdposition" then
                    GroupImmediateOrder(self.group, order)
                elseif order == "attackground" or order == "smart" or order == "move" or order == "attack" then
                    for i = 0, self.size - 1 do
                        IssuePointOrder(BlzGroupUnitAt(self.group, i), order, x + 300*Cos(i*2*bj_PI/self.size), y + 300*Sin(i*2*bj_PI/self.size))
                    end
                end
            else
                if order == "smart" or order == "move" or order == "attack" then
                    GroupTargetOrder(self.group, order, target)
                end
            end
        end

        function mt:add(unit)
            struct[unit] = self
            GroupAddUnit(self.group, unit)
            self.size = BlzGroupGetSize(self.group)
        end

        function mt:owner(unit)
            if struct[unit] then
                local this = struct[unit]
                return this.unit
            else
                return nil
            end
        end

        function mt:onOrder()
            local unit = GetOrderedUnit()

            if GetUnitTypeId(unit) == WaterElemental_ELEMENTAL then
                if struct[unit] then
                    local this = struct[unit]

                    if GetOrderTargetUnit() == this.unit then
                        if not IsUnitInGroup(unit, this.group) then
                            GroupAddUnit(this.group, unit)
                            this.size = BlzGroupGetSize(this.group)
                        end
                    else
                        if IsUnitSelected(unit, GetOwningPlayer(unit)) and IsUnitInGroup(unit, this.group) then
                            GroupRemoveUnit(this.group, unit)
                            this.size = BlzGroupGetSize(this.group)
                        end
                    end
                end
            end
        end

        function mt:create(unit)
            local this = {}
            setmetatable(this, mt)

            this.unit = unit
            this.group = CreateGroup()
            this.size = BlzGroupGetSize(this.group)

            return this
        end

        onInit(function()
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function()
               local unit = GetTriggerUnit()

                if GetUnitTypeId(unit) == WaterElemental_ELEMENTAL then
                    if struct[unit] then
                        local this = struct[unit]

                        GroupRemoveUnit(this.group, unit)
                        this.size = BlzGroupGetSize(this.group)
                        struct[unit] = nil
                    end
                end
            end)

            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function()
                Elemental:onOrder()
            end)

            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function()
                Elemental:onOrder()
            end)

            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, function()
                Elemental:onOrder()
            end)

            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, function()
                Elemental:onOrder()
            end)
        end)
    end

    do
        local Masters = setmetatable({}, {})
        local mt = getmetatable(Masters)
        mt.__index = mt

        local struct = {}

        function mt:destroy()
            self.elementals:destroy()
            self = nil
        end

        function mt:onOrder()
            local unit = GetOrderedUnit()

            if GetUnitAbilityLevel(unit, ABILITY) > 0 and struct[unit] then
                local this = struct[unit]
                this.elementals:command(GetOrderTargetUnit(), GetOrderPointX(), GetOrderPointY(), OrderId2String(GetIssuedOrderId()))
            end
        end

        onInit(function()
            RegisterSpellEffectEvent(ABILITY, function()
                local angle = GetUnitFacing(Spell.source.unit)
                local unit = CreateUnit(Spell.source.player, WaterElemental_ELEMENTAL, Spell.source.x + 250*Cos(Deg2Rad(angle)), Spell.source.y + 250*Sin(Deg2Rad(angle)), angle)
                local this

                DestroyEffect(AddSpecialEffectEx(MODEL, GetUnitX(unit), GetUnitY(unit), 0, SCALE))

                if struct[Spell.source.unit] then
                    this = struct[Spell.source.unit]
                else
                    this = {}
                    setmetatable(this, Masters)
                    struct[Spell.source.unit] = this

                    this.elementals = Elemental:create(Spell.source.unit)
                end

                BlzSetUnitBaseDamage(unit, GetDamage(Spell.source.unit, Spell.level), 0)
                BlzSetUnitMaxHP(unit, GetHealth(Spell.source.unit, Spell.level))
                SetUnitLifePercentBJ(unit, 100)
                BlzSetUnitArmor(unit, GetArmor(Spell.source.unit, Spell.level))
                SetUnitAnimation(unit, "Birth")
                UnitApplyTimedLife(unit, FourCC('BTLF'), GetDuration(Spell.source.unit, Spell.level))
                this.elementals:add(unit)
            end)

            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function()
                Masters:onOrder()
            end)

            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function()
                Masters:onOrder()
            end)

            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, function()
                Masters:onOrder()
            end)

            RegisterUnitDeindexEvent(function()
                local unit = GetIndexUnit()

                if struct[unit] then
                    local this = struct[unit]
                    this:destroy()
                    struct[unit] = nil
                end
            end)
        end)
    end
end