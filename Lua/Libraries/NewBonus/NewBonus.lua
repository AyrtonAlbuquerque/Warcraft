--[[ requires optional DamageInterface, optional Evasion, optional CriticalStrike, optional SpellPower, optional LifeSteal, optional SpellVamp, optional CooldownReduction, optional Tenacity
    -- ---------------------------------------- NewBonus v2.4 --------------------------------------- --
    -- Since ObjectMerger is broken and we still have no means to edit
    -- bonus values (green values) i decided to create a light weight
    -- Bonus library that works in the same way that the original Bonus Mod
    -- by Earth Fury did. NewBonus requires patch 1.31+.
    -- Credits to Earth Fury for the original Bonus idea
    -- How to Import?
    -- Importing bonus mod is really simple. Just copy the abilities with the
    -- prefix "NewBonus" from the Object Editor into your map and match their new raw
    -- code to the bonus types in the global block below. Then create a trigger called
    -- NewBonus, convert it to custom text and paste this code there. You done!
    -- ---------------------------------------- By Chopinski ---------------------------------------- --
]]--

do
    -- ---------------------------------------------------------------------------------------------- --
    --                                          Configuration                                         --
    -- ---------------------------------------------------------------------------------------------- --
    -- If true will use the extended version of the system.
    -- Make sure you have the DamageInterface and Cooldown Reduction libraries
    NewBonus_EXTENDED                = true

    -- This is the maximum recursion limit allowed by the system.
    -- Its value must be greater than or equal to 0. When equal to 0
    -- no recursion is allowed. Values too big can cause screen freezes.
    local RECURSION_LIMIT            = 8

    -- The bonus types
    BONUS_DAMAGE                     = 1
    BONUS_ARMOR                      = 2
    BONUS_AGILITY                    = 3
    BONUS_STRENGTH                   = 4
    BONUS_INTELLIGENCE               = 5
    BONUS_HEALTH                     = 6
    BONUS_MANA                       = 7
    BONUS_MOVEMENT_SPEED             = 8
    BONUS_SIGHT_RANGE                = 9
    BONUS_HEALTH_REGEN               = 10
    BONUS_MANA_REGEN                 = 11
    BONUS_ATTACK_SPEED               = 12
    BONUS_MAGIC_RESISTANCE           = 13
    BONUS_EVASION_CHANCE             = 14
    BONUS_CRITICAL_DAMAGE            = 15
    BONUS_CRITICAL_CHANCE            = 16
    BONUS_LIFE_STEAL                 = 17
    BONUS_MISS_CHANCE                = 18
    BONUS_SPELL_POWER_FLAT           = 19
    BONUS_SPELL_POWER_PERCENT        = 20
    BONUS_SPELL_VAMP                 = 21
    BONUS_COOLDOWN_REDUCTION         = 22
    BONUS_COOLDOWN_REDUCTION_FLAT    = 23
    BONUS_COOLDOWN_OFFSET            = 24
    BONUS_TENACITY                   = 25
    BONUS_TENACITY_FLAT              = 26
    BONUS_TENACITY_OFFSET            = 27

    -- The abilities codes for each bonus
    -- When pasting the abilities over to your map
    -- their raw code should match the bonus here
    local DAMAGE_ABILITY           = FourCC('Z001')
    local ARMOR_ABILITY            = FourCC('Z002')
    local STATS_ABILITY            = FourCC('Z003')
    local HEALTH_ABILITY           = FourCC('Z004')
    local MANA_ABILITY             = FourCC('Z005')
    local HEALTHREGEN_ABILITY      = FourCC('Z006')
    local MANAREGEN_ABILITY        = FourCC('Z007')
    local ATTACKSPEED_ABILITY      = FourCC('Z008')
    local MOVEMENTSPEED_ABILITY    = FourCC('Z009')
    local SIGHT_RANGE_ABILITY      = FourCC('Z00A')
    local MAGIC_RESISTANCE_ABILITY = FourCC('Z00B')
    local CRITICAL_STRIKE_ABILITY  = FourCC('Z00C')
    local EVASION_ABILITY          = FourCC('Z00D')
    local LIFE_STEAL_ABILITY       = FourCC('Z00E')

    -- The abilities fields that are modified. For the sake of readability
    local DAMAGE_FIELD             = ABILITY_ILF_ATTACK_BONUS
    local ARMOR_FIELD              = ABILITY_ILF_DEFENSE_BONUS_IDEF
    local AGILITY_FIELD            = ABILITY_ILF_AGILITY_BONUS
    local STRENGTH_FIELD           = ABILITY_ILF_STRENGTH_BONUS_ISTR
    local INTELLIGENCE_FIELD       = ABILITY_ILF_INTELLIGENCE_BONUS
    local HEALTH_FIELD             = ABILITY_ILF_MAX_LIFE_GAINED
    local MANA_FIELD               = ABILITY_ILF_MAX_MANA_GAINED
    local MOVEMENTSPEED_FIELD      = ABILITY_ILF_MOVEMENT_SPEED_BONUS
    local SIGHT_RANGE_FIELD        = ABILITY_ILF_SIGHT_RANGE_BONUS
    local HEALTHREGEN_FIELD        = ABILITY_RLF_AMOUNT_OF_HIT_POINTS_REGENERATED
    local MANAREGEN_FIELD          = ABILITY_RLF_AMOUNT_REGENERATED
    local ATTACKSPEED_FIELD        = ABILITY_RLF_ATTACK_SPEED_INCREASE_ISX1
    local MAGIC_RESISTANCE_FIELD   = ABILITY_RLF_DAMAGE_REDUCTION_ISR2
    local CRITICAL_CHANCE_FIELD    = ABILITY_RLF_CHANCE_TO_CRITICAL_STRIKE
    local CRITICAL_DAMAGE_FIELD    = ABILITY_RLF_DAMAGE_MULTIPLIER_OCR2
    local EVASION_FIELD            = ABILITY_RLF_CHANCE_TO_EVADE_EEV1
    local LIFE_STEAL_FIELD         = ABILITY_RLF_LIFE_STOLEN_PER_ATTACK

    -- ---------------------------------------------------------------------------------------------- --
    --                                             LUA API                                            --
    -- ---------------------------------------------------------------------------------------------- --
    function GetUnitBonus(unit, type)
        return NewBonus:get(unit, type)
    end

    function SetUnitBonus(unit, type, value)
        return NewBonus:set(unit, type, value, false)
    end

    function RemoveUnitBonus(unit, type)
        if type == BONUS_CRITICAL_DAMAGE then
            NewBonus:set(unit, type, 1, false)
        else
            NewBonus:set(unit, type, 0, false)
        end

        if type == BONUS_LIFE_STEAL then
            UnitRemoveAbility(unit, LIFE_STEAL_ABILITY)
        end
    end

    function AddUnitBonus(unit, type, value)
        return NewBonus:add(unit, type, value)
    end

    function RegisterBonusEvent(code)
        NewBonus:register(code, 0)
    end

    function RegisterBonusTypeEvent(type, code)
        NewBonus:register(code, type)
    end

    function GetBonusUnit()
        return NewBonus.unit[NewBonus.key]
    end

    function GetBonusType()
        return NewBonus.type[NewBonus.key]
    end

    function SetBonusType(type)
        if type >= BONUS_DAMAGE and type <= NewBonus.last then
            NewBonus.type[NewBonus.key] = type
        end
    end

    function GetBonusAmount()
        return NewBonus.amount[NewBonus.key]
    end

    function SetBonusAmount(real)
        NewBonus.amount[NewBonus.key] = real
    end

    -- ---------------------------------------------------------------------------------------------- --
    --                                             System                                             --
    -- ---------------------------------------------------------------------------------------------- --
    NewBonus = setmetatable({}, {})
    local mt = getmetatable(NewBonus)
    mt.__index = mt

    NewBonus.linkType = 0
    NewBonus.last = 0
    NewBonus.key = 0
    NewBonus.unit = {}
    NewBonus.type = {}
    NewBonus.amount = {}
    local trigger = {}
    local event = {}
    local count = 0

    function mt:checkOverflow(current, value)
        if value > 0 and current > 2147483647 - value then
            return 2147483647 - current
        elseif value < 0 and current < -2147483648 - value then
            return -2147483648 - current
        else
            return value
        end
    end

    function mt:onEvent(key)
        local i = 0
        local next = -1
        local prev = -2

        count = count + 1

        if NewBonus.amount[key] ~= 0 and (count - NewBonus.last < RECURSION_LIMIT) then
            while NewBonus.type[key] ~= next and (i - NewBonus.last < RECURSION_LIMIT) do
                next = NewBonus.type[key]

                if event[next] then
                    for j = 1, #event[next] do
                        event[next][j]()
                    end
                end

                if NewBonus.type[key] ~= next then
                    i = i + 1
                else
                    if next ~= prev then
                        for j = 1, #trigger do
                            trigger[j]()
                        end

                        if NewBonus.type[key] ~= next then
                            i = i + 1
                            prev = next
                        end
                    end
                end
            end
        end

        count = count - 1
        NewBonus.key = key
    end

    function mt:setAbility(unit, ability, field, value, integer, adding)
        if GetUnitAbilityLevel(unit, ability) == 0 then
            UnitAddAbility(unit, ability)
            UnitMakeAbilityPermanent(unit, true, ability)
        end

        if integer then
            if adding then
                if BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0, BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0) + value) then
                    IncUnitAbilityLevel(unit, ability)
                    DecUnitAbilityLevel(unit, ability)
                end
            else
                if BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0, value) then
                    IncUnitAbilityLevel(unit, ability)
                    DecUnitAbilityLevel(unit, ability)
                end
            end

            NewBonus.linkType = NewBonus.type[NewBonus.key]

            if NewBonus.key > 0 then
                NewBonus.key = NewBonus.key - 1
            end

            return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0)
        else
            if BlzSetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, 0, value) then
                IncUnitAbilityLevel(unit, ability)
                DecUnitAbilityLevel(unit, ability)
            end

            NewBonus.linkType = NewBonus.type[NewBonus.key]

            if NewBonus.key > 0 then
                NewBonus.key = NewBonus.key - 1
            end

            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, 0)
        end
    end

    function mt:get(unit, type)
        if type == BONUS_DAMAGE then
            return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, DAMAGE_ABILITY), DAMAGE_FIELD, 0)
        elseif type == BONUS_ARMOR then
            return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ARMOR_ABILITY), ARMOR_FIELD, 0)
        elseif type == BONUS_HEALTH then
            return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, HEALTH_ABILITY), HEALTH_FIELD, 0)
        elseif type == BONUS_MANA then
            return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, MANA_ABILITY), MANA_FIELD, 0)
        elseif type == BONUS_AGILITY then
            return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, STATS_ABILITY), AGILITY_FIELD, 0)
        elseif type == BONUS_STRENGTH then
            return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, STATS_ABILITY), STRENGTH_FIELD, 0)
        elseif type == BONUS_INTELLIGENCE then
            return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, STATS_ABILITY), INTELLIGENCE_FIELD, 0)
        elseif type == BONUS_MOVEMENT_SPEED then
            return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, MOVEMENTSPEED_ABILITY), MOVEMENTSPEED_FIELD, 0)
        elseif type == BONUS_SIGHT_RANGE then
            return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, SIGHT_RANGE_ABILITY), SIGHT_RANGE_FIELD, 0)
        elseif type == BONUS_HEALTH_REGEN then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, HEALTHREGEN_ABILITY), HEALTHREGEN_FIELD, 0)
        elseif type == BONUS_MANA_REGEN then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, MANAREGEN_ABILITY), MANAREGEN_FIELD, 0)
        elseif type == BONUS_ATTACK_SPEED then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ATTACKSPEED_ABILITY), ATTACKSPEED_FIELD, 0)
        elseif type == BONUS_MAGIC_RESISTANCE then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, MAGIC_RESISTANCE_ABILITY), MAGIC_RESISTANCE_FIELD, 0)
        elseif type >= BONUS_EVASION_CHANCE and type <= NewBonus.last then
            if NewBonus_EXTENDED and Damage and Evasion and Critical and SpellPower and LifeSteal and SpellVamp and Tenacity then
                if type == BONUS_EVASION_CHANCE then
                    return GetUnitEvasionChance(unit)
                elseif type == BONUS_MISS_CHANCE then
                    return GetUnitMissChance(unit)
                elseif type == BONUS_CRITICAL_CHANCE then
                    return GetUnitCriticalChance(unit)
                elseif type == BONUS_CRITICAL_DAMAGE then
                    return GetUnitCriticalMultiplier(unit)
                elseif type == BONUS_SPELL_POWER_FLAT then
                    return GetUnitSpellPowerFlat(unit)
                elseif type == BONUS_SPELL_POWER_PERCENT then
                    return GetUnitSpellPowerPercent(unit)
                elseif type == BONUS_LIFE_STEAL then
                    return GetUnitLifeSteal(unit)
                elseif type == BONUS_SPELL_VAMP then
                    return GetUnitSpellVamp(unit)
                elseif type == BONUS_COOLDOWN_REDUCTION then
                    return GetUnitCooldownReduction(unit)
                elseif type == BONUS_COOLDOWN_REDUCTION_FLAT then
                    return GetUnitCooldownReductionFlat(unit)
                elseif type == BONUS_COOLDOWN_OFFSET then
                    return GetUnitCooldownOffset(unit)
                elseif type == BONUS_TENACITY then
                    return GetUnitTenacity(unit)
                elseif type == BONUS_TENACITY_FLAT then
                    return GetUnitTenacityFlat(unit)
                elseif type == BONUS_TENACITY_OFFSET then
                    return GetUnitTenacityOffset(unit)
                end
            else
                if type == BONUS_CRITICAL_CHANCE then
                    return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, CRITICAL_STRIKE_ABILITY), CRITICAL_CHANCE_FIELD, 0)
                elseif type == BONUS_CRITICAL_DAMAGE then
                    return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, CRITICAL_STRIKE_ABILITY), CRITICAL_DAMAGE_FIELD, 0)
                elseif type == BONUS_EVASION_CHANCE then
                    return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, EVASION_ABILITY), EVASION_FIELD, 0)
                elseif type == BONUS_LIFE_STEAL then
                    return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, LIFE_STEAL_ABILITY), LIFE_STEAL_FIELD, 0)
                end
            end
        else
            print("Invalid Bonus Type")
        end

        return -1
    end

    function mt:set(unit, type, value, adding)
        if not adding then
            NewBonus.key = NewBonus.key + 1
            NewBonus.unit[NewBonus.key] = unit
            NewBonus.type[NewBonus.key] = type
            NewBonus.amount[NewBonus.key] = value

            self:onEvent(NewBonus.key)

            if NewBonus.amount[NewBonus.key] ~= value then
                value = NewBonus.amount[NewBonus.key]
            end

            if NewBonus.type[NewBonus.key] ~= type then
                return self:set(NewBonus.unit[NewBonus.key], NewBonus.type[NewBonus.key], NewBonus.amount[NewBonus.key], not adding)
            end
        else
            NewBonus.unit[NewBonus.key] = unit
            NewBonus.type[NewBonus.key] = type
            NewBonus.amount[NewBonus.key] = value
        end

        if type == BONUS_DAMAGE then
            return self:setAbility(unit, DAMAGE_ABILITY, DAMAGE_FIELD, value, true, adding)
        elseif type == BONUS_ARMOR then
            return self:setAbility(unit, ARMOR_ABILITY, ARMOR_FIELD, value, true, adding)
        elseif type == BONUS_HEALTH then
            local real = GetUnitLifePercent(unit)

            if value == 0 and not adding then
                BlzSetUnitMaxHP(unit, (BlzGetUnitMaxHP(unit) - self:get(unit, type)))
            else
                BlzSetUnitMaxHP(unit, (BlzGetUnitMaxHP(unit) + value))
            end

            self:setAbility(unit, HEALTH_ABILITY, HEALTH_FIELD, value, true, adding)
            SetUnitLifePercentBJ(unit, real)

            return value
        elseif type == BONUS_MANA then
            local real = GetUnitManaPercent(unit)

            if value == 0 and not adding then
                BlzSetUnitMaxMana(unit, (BlzGetUnitMaxMana(unit) - self:get(unit, type)))
            else
                BlzSetUnitMaxMana(unit, (BlzGetUnitMaxMana(unit) + value))
            end

            self:setAbility(unit, MANA_ABILITY, MANA_FIELD, value, true, adding)
            SetUnitManaPercentBJ(unit, real)

            return value
        elseif type == BONUS_AGILITY then
            return self:setAbility(unit, STATS_ABILITY, AGILITY_FIELD, value, true, adding)
        elseif type == BONUS_STRENGTH then
            return self:setAbility(unit, STATS_ABILITY, STRENGTH_FIELD, value, true, adding)
        elseif type == BONUS_INTELLIGENCE then
            return self:setAbility(unit, STATS_ABILITY, INTELLIGENCE_FIELD, value, true, adding)
        elseif type == BONUS_MOVEMENT_SPEED then
            return self:setAbility(unit, MOVEMENTSPEED_ABILITY, MOVEMENTSPEED_FIELD, value, true, adding)
        elseif type == BONUS_SIGHT_RANGE then
            if value == 0 and not adding then
                BlzSetUnitRealField(unit, UNIT_RF_SIGHT_RADIUS, (BlzGetUnitRealField(unit, UNIT_RF_SIGHT_RADIUS) - self:get(unit, type)))
            else
                BlzSetUnitRealField(unit, UNIT_RF_SIGHT_RADIUS, (BlzGetUnitRealField(unit, UNIT_RF_SIGHT_RADIUS) + value))
            end

            self:setAbility(unit, SIGHT_RANGE_ABILITY, SIGHT_RANGE_FIELD, value, true, adding)

            return value
        elseif type == BONUS_HEALTH_REGEN then
            return self:setAbility(unit, HEALTHREGEN_ABILITY, HEALTHREGEN_FIELD, value, false, adding)
        elseif type == BONUS_MANA_REGEN then
            return self:setAbility(unit, MANAREGEN_ABILITY, MANAREGEN_FIELD, value, false, adding)
        elseif type == BONUS_ATTACK_SPEED then
            return self:setAbility(unit, ATTACKSPEED_ABILITY, ATTACKSPEED_FIELD, value, false, adding)
        elseif type == BONUS_MAGIC_RESISTANCE then
            return self:setAbility(unit, MAGIC_RESISTANCE_ABILITY, MAGIC_RESISTANCE_FIELD, value, false, adding)
        elseif type >= BONUS_EVASION_CHANCE and type <= NewBonus.last then
            if NewBonus_EXTENDED and Damage and Evasion and Critical and SpellPower and LifeSteal and SpellVamp and Tenacity then
                if type == BONUS_EVASION_CHANCE then
                    SetUnitEvasionChance(unit, value)
                elseif type == BONUS_MISS_CHANCE then
                    SetUnitMissChance(unit, value)
                elseif type == BONUS_CRITICAL_CHANCE then
                    SetUnitCriticalChance(unit, value)
                elseif type == BONUS_CRITICAL_DAMAGE then
                    SetUnitCriticalMultiplier(unit, value)
                elseif type == BONUS_SPELL_POWER_FLAT then
                    SetUnitSpellPowerFlat(unit, value)
                elseif type == BONUS_SPELL_POWER_PERCENT then
                    SetUnitSpellPowerPercent(unit, value)
                elseif type == BONUS_LIFE_STEAL then
                    SetUnitLifeSteal(unit, value)
                elseif type == BONUS_SPELL_VAMP then
                    SetUnitSpellVamp(unit, value)
                elseif type == BONUS_COOLDOWN_REDUCTION then
                    if adding then
                        UnitAddCooldownReduction(unit, value)
                    else
                        SetUnitCooldownReduction(unit, value)
                    end
                elseif type == BONUS_COOLDOWN_REDUCTION_FLAT then
                    SetUnitCooldownReductionFlat(unit, value)
                elseif type == BONUS_COOLDOWN_OFFSET then
                    SetUnitCooldownOffset(unit, value)
                elseif type == BONUS_TENACITY then
                    if adding then
                        UnitAddTenacity(unit, value)
                    else
                        SetUnitTenacity(unit, value)
                    end
                elseif type == BONUS_TENACITY_FLAT then
                    SetUnitTenacityFlat(unit, value)
                elseif type == BONUS_TENACITY_OFFSET then
                    SetUnitTenacityOffset(unit, value)
                end

                NewBonus.linkType = type

                if NewBonus.key > 0 then
                    NewBonus.key = NewBonus.key - 1
                end

                return value
            else
                if type == BONUS_CRITICAL_CHANCE then
                    return self:setAbility(unit, CRITICAL_STRIKE_ABILITY, CRITICAL_CHANCE_FIELD, value, false, adding)
                elseif type == BONUS_CRITICAL_DAMAGE then
                    return self:setAbility(unit, CRITICAL_STRIKE_ABILITY, CRITICAL_DAMAGE_FIELD, value, false, adding)
                elseif type == BONUS_EVASION_CHANCE then
                    return self:setAbility(unit, EVASION_ABILITY, EVASION_FIELD, value, false, adding)
                elseif type == BONUS_LIFE_STEAL then
                    return self:setAbility(unit, LIFE_STEAL_ABILITY, LIFE_STEAL_FIELD, value, false, adding)
                end
            end
        else
            print("Invalid Bonus Type")
        end

        return -1
    end

    function mt:add(unit, type, value)
        if value ~= 0 then
            NewBonus.key = NewBonus.key + 1
            NewBonus.unit[NewBonus.key] = unit
            NewBonus.type[NewBonus.key] = type
            NewBonus.amount[NewBonus.key] = value

            if type <= BONUS_SIGHT_RANGE then
                NewBonus.amount[NewBonus.key] = self:checkOverflow(self:get(unit, type), R2I(value))
            end

            self:onEvent(NewBonus.key)
            value = NewBonus.amount[NewBonus.key]

            if NewBonus.type[NewBonus.key] <= BONUS_SIGHT_RANGE then
                self:set(NewBonus.unit[NewBonus.key], NewBonus.type[NewBonus.key], self:checkOverflow(self:get(NewBonus.unit[NewBonus.key], NewBonus.type[NewBonus.key]), R2I(NewBonus.amount[NewBonus.key])), true)
            else
                if NewBonus_EXTENDED and Damage and Evasion and Critical and SpellPower and LifeSteal and SpellVamp and Tenacity then
                    if NewBonus.type[NewBonus.key] == BONUS_COOLDOWN_REDUCTION or NewBonus.type[NewBonus.key] == BONUS_TENACITY then
                        self:set(NewBonus.unit[NewBonus.key], NewBonus.type[NewBonus.key], NewBonus.amount[NewBonus.key], true)
                    else
                        self:set(NewBonus.unit[NewBonus.key], NewBonus.type[NewBonus.key], self:get(NewBonus.unit[NewBonus.key], NewBonus.type[NewBonus.key]) + NewBonus.amount[NewBonus.key], true)
                    end
                else
                    self:set(NewBonus.unit[NewBonus.key], NewBonus.type[NewBonus.key], self:get(NewBonus.unit[NewBonus.key], NewBonus.type[NewBonus.key]) + NewBonus.amount[NewBonus.key], true)
                end
            end

            return value
        end

        return -1
    end

    function mt:register(code, bonus)
        if type(code) == "function" then
            if bonus >= BONUS_DAMAGE and bonus <= NewBonus.last then
                if not event[bonus] then event[bonus] = {} end
                table.insert(event[bonus], code)
            else
                table.insert(trigger, code)
            end
        end
    end

    onInit(function()
        if NewBonus_EXTENDED and Damage and Evasion and Critical and SpellPower and LifeSteal and SpellVamp and Tenacity then
            NewBonus.last = BONUS_TENACITY_OFFSET
        else
            NewBonus.last = BONUS_LIFE_STEAL
        end
    end)
end