--[[
    /* ----------------------- NewBonus v2.3 by Chopinski ----------------------- */
    Since ObjectMerger is broken and we still have no means to edit
    bonus values (green values) i decided to create a light weight
    Bonus library that works in the same way that the original Bonus Mod
    by Earth Fury did. NewBonus requires patch 1.31+.
    Credits to Earth Fury for the original Bonus idea

    How to Import?
    Importing bonus mod is really simple. Just copy the abilities with the
    prefix "NewBonus" from the Object Editor into your map and match their new raw
    code to the bonus types in the global block below. Then create a trigger called
    NewBonus, convert it to custom text and paste this code there. You done!
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
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
    
    
    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    NewBonus = setmetatable({}, {})
    local mt = getmetatable(NewBonus)
    mt.__index = mt
    
    NewBonus.linkType = 0
    NewBonus.last = 0
    NewBonus.event = 0
    NewBonus.unit = {}
    NewBonus.type = {}
    NewBonus.real = {}
    local trigger = {}
    local event = {}
    
    function mt:checkOverflow(current, amount)
        if amount > 0 and current > 2147483647 - amount then
            return 2147483647 - current
        elseif amount < 0 and current < -2147483648 - amount then
            return -2147483648 - current
        else
            return amount
        end
    end
    
    function mt:onEvent(type, i)
        if NewBonus.real[NewBonus.event] ~= 0 then
            if NewBonus.event + 1 - NewBonus.last < RECURSION_LIMIT then
                if event[type] then
                    for j = 1, #event[type] do
                        event[type][j]()
                    end
                end
                
                if NewBonus.type[i] ~= type and event[NewBonus.type[i]] then
                    for j = 1, #event[NewBonus.type[i]] do
                        event[NewBonus.type[i]][j]()
                    end
                end
                
                for j = 1, #trigger do
                    trigger[j]()
                end
            else
                print("[NewBonus] Recursion limit reached: " .. RECURSION_LIMIT)
            end
        end
        
        NewBonus.event = i
    end
    
    function mt:setAbility(unit, ability, field, amount, integer, adding)
        if GetUnitAbilityLevel(unit, ability) == 0 then
            UnitAddAbility(unit, ability)
            UnitMakeAbilityPermanent(unit, true, ability)
        end
        
        if integer then
            if adding then
                if BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0, BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0) + amount) then
                    IncUnitAbilityLevel(unit, ability)
                    DecUnitAbilityLevel(unit, ability)
                end
            else
                if BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0, amount) then
                    IncUnitAbilityLevel(unit, ability)
                    DecUnitAbilityLevel(unit, ability)
                end
            end
            
            NewBonus.linkType = NewBonus.type[NewBonus.event]
            
            if NewBonus.event > 0 then
                NewBonus.event = NewBonus.event - 1
            end
            
            return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0)
        else
            if BlzSetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, 0, amount) then
                IncUnitAbilityLevel(unit, ability)
                DecUnitAbilityLevel(unit, ability)
            end
            
            NewBonus.linkType = NewBonus.type[NewBonus.event]
            
            if NewBonus.event > 0 then
                NewBonus.event = NewBonus.event - 1
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
            if NewBonus_EXTENDED and Damage and Evasion and Critical and SpellPower and LifeSteal and SpellVamp then
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

    function mt:set(unit, type, amount, adding)
        local real
        
        if not adding then
            NewBonus.event = NewBonus.event + 1
            NewBonus.unit[NewBonus.event] = unit
            NewBonus.type[NewBonus.event] = type
            NewBonus.real[NewBonus.event] = amount
            
            self:onEvent(type, NewBonus.event)
            
            if NewBonus.real[NewBonus.event] ~= amount then
                amount = NewBonus.real[NewBonus.event]
            end
            
            if NewBonus.type[NewBonus.event] ~= type then
                return self:set(NewBonus.unit[NewBonus.event], NewBonus.type[NewBonus.event], NewBonus.real[NewBonus.event], not adding)
            end
        else
            NewBonus.unit[NewBonus.event] = unit
            NewBonus.type[NewBonus.event] = type
            NewBonus.real[NewBonus.event] = amount
        end
        
        if type == BONUS_DAMAGE then
            return self:setAbility(unit, DAMAGE_ABILITY, DAMAGE_FIELD, amount, true, adding)
        elseif type == BONUS_ARMOR then
            return self:setAbility(unit, ARMOR_ABILITY, ARMOR_FIELD, amount, true, adding)
        elseif type == BONUS_HEALTH then
            real = GetUnitLifePercent(unit)
            if amount == 0 and not adding then
                BlzSetUnitMaxHP(unit, (BlzGetUnitMaxHP(unit) - self:get(unit, type)))
            else
                BlzSetUnitMaxHP(unit, (BlzGetUnitMaxHP(unit) + amount))
            end
            self:setAbility(unit, HEALTH_ABILITY, HEALTH_FIELD, amount, true, adding)
            SetUnitLifePercentBJ(unit, real)
            return amount
        elseif type == BONUS_MANA then
            real = GetUnitManaPercent(unit)
            if amount == 0 and not adding then
                BlzSetUnitMaxMana(unit, (BlzGetUnitMaxMana(unit) - self:get(unit, type)))
            else
                BlzSetUnitMaxMana(unit, (BlzGetUnitMaxMana(unit) + amount))
            end
            self:setAbility(unit, MANA_ABILITY, MANA_FIELD, amount, true, adding)
            SetUnitManaPercentBJ(unit, real)
            return amount
        elseif type == BONUS_AGILITY then
            return self:setAbility(unit, STATS_ABILITY, AGILITY_FIELD, amount, true, adding)
        elseif type == BONUS_STRENGTH then
            return self:setAbility(unit, STATS_ABILITY, STRENGTH_FIELD, amount, true, adding)
        elseif type == BONUS_INTELLIGENCE then
            return self:setAbility(unit, STATS_ABILITY, INTELLIGENCE_FIELD, amount, true, adding)
        elseif type == BONUS_MOVEMENT_SPEED then
            return self:setAbility(unit, MOVEMENTSPEED_ABILITY, MOVEMENTSPEED_FIELD, amount, true, adding)
        elseif type == BONUS_SIGHT_RANGE then
            if amount == 0 and not adding then
                BlzSetUnitRealField(unit, UNIT_RF_SIGHT_RADIUS, (BlzGetUnitRealField(unit, UNIT_RF_SIGHT_RADIUS) - self:get(unit, type)))
            else
                BlzSetUnitRealField(unit, UNIT_RF_SIGHT_RADIUS, (BlzGetUnitRealField(unit, UNIT_RF_SIGHT_RADIUS) + amount))
            end
            self:setAbility(unit, SIGHT_RANGE_ABILITY, SIGHT_RANGE_FIELD, amount, true, adding)
            return amount
        elseif type == BONUS_HEALTH_REGEN then
            return self:setAbility(unit, HEALTHREGEN_ABILITY, HEALTHREGEN_FIELD, amount, false, adding)
        elseif type == BONUS_MANA_REGEN then
            return self:setAbility(unit, MANAREGEN_ABILITY, MANAREGEN_FIELD, amount, false, adding)
        elseif type == BONUS_ATTACK_SPEED then
            return self:setAbility(unit, ATTACKSPEED_ABILITY, ATTACKSPEED_FIELD, amount, false, adding)
        elseif type == BONUS_MAGIC_RESISTANCE then
            return self:setAbility(unit, MAGIC_RESISTANCE_ABILITY, MAGIC_RESISTANCE_FIELD, amount, false, adding)
        elseif type >= BONUS_EVASION_CHANCE and type <= NewBonus.last then
            if NewBonus_EXTENDED and Damage and Evasion and Critical and SpellPower and LifeSteal and SpellVamp then
                if type == BONUS_EVASION_CHANCE then
                    SetUnitEvasionChance(unit, amount)
                elseif type == BONUS_MISS_CHANCE then
                    SetUnitMissChance(unit, amount)
                elseif type == BONUS_CRITICAL_CHANCE then
                    SetUnitCriticalChance(unit, amount)
                elseif type == BONUS_CRITICAL_DAMAGE then
                    SetUnitCriticalMultiplier(unit, amount)
                elseif type == BONUS_SPELL_POWER_FLAT then
                    SetUnitSpellPowerFlat(unit, amount)
                elseif type == BONUS_SPELL_POWER_PERCENT then
                    SetUnitSpellPowerPercent(unit, amount)
                elseif type == BONUS_LIFE_STEAL then
                    SetUnitLifeSteal(unit, amount)
                elseif type == BONUS_SPELL_VAMP then
                    SetUnitSpellVamp(unit, amount)
                elseif type == BONUS_COOLDOWN_REDUCTION then
                    if adding then
                        UnitAddCooldownReduction(unit, amount)
                    else
                        SetUnitCooldownReduction(unit, amount)
                    end
                elseif type == BONUS_COOLDOWN_REDUCTION_FLAT then
                    SetUnitCooldownReductionFlat(unit, amount)
                elseif type == BONUS_COOLDOWN_OFFSET then
                    SetUnitCooldownOffset(unit, amount)
                end
                
                NewBonus.linkType = type
                
                if NewBonus.event > 0 then
                    NewBonus.event = NewBonus.event - 1
                end
                
                return amount
            else
                if type == BONUS_CRITICAL_CHANCE then
                    return self:setAbility(unit, CRITICAL_STRIKE_ABILITY, CRITICAL_CHANCE_FIELD, amount, false, adding)
                elseif type == BONUS_CRITICAL_DAMAGE then
                    return self:setAbility(unit, CRITICAL_STRIKE_ABILITY, CRITICAL_DAMAGE_FIELD, amount, false, adding)
                elseif type == BONUS_EVASION_CHANCE then
                    return self:setAbility(unit, EVASION_ABILITY, EVASION_FIELD, amount, false, adding)
                elseif type == BONUS_LIFE_STEAL then
                    return self:setAbility(unit, LIFE_STEAL_ABILITY, LIFE_STEAL_FIELD, amount, false, adding)
                end
            end
        else
            print("Invalid Bonus Type")
        end

        return -1
    end

    function mt:add(unit, type, amount)
        local current
    
        if type <= BONUS_SIGHT_RANGE then
            amount = R2I(amount)
            NewBonus.event = NewBonus.event + 1
            NewBonus.unit[NewBonus.event] = unit
            NewBonus.type[NewBonus.event] = type
            current = self:get(NewBonus.unit[NewBonus.event], NewBonus.type[NewBonus.event])
            NewBonus.real[NewBonus.event] = self:checkOverflow(current, amount)

            self:onEvent(type, NewBonus.event)
            
            if NewBonus.type[NewBonus.event] <= BONUS_SIGHT_RANGE then
                current = self:get(NewBonus.unit[NewBonus.event], NewBonus.type[NewBonus.event])
                NewBonus.real[NewBonus.event] = self:checkOverflow(current, NewBonus.real[NewBonus.event])
                local value = NewBonus.real[NewBonus.event]
                
                self:set(NewBonus.unit[NewBonus.event], NewBonus.type[NewBonus.event], NewBonus.real[NewBonus.event], true)
            
                return value
            else
                return self:add(NewBonus.unit[NewBonus.event], NewBonus.type[NewBonus.event], NewBonus.real[NewBonus.event])
            end
        elseif type >= BONUS_HEALTH_REGEN and type <= NewBonus.last then
            NewBonus.event = NewBonus.event + 1
            NewBonus.unit[NewBonus.event] = unit
            NewBonus.type[NewBonus.event] = type
            NewBonus.real[NewBonus.event] = amount
        
            self:onEvent(type, NewBonus.event)
        
            if NewBonus.type[NewBonus.event] >= BONUS_HEALTH_REGEN then
                local value = NewBonus.real[NewBonus.event]
                current = self:get(NewBonus.unit[NewBonus.event], NewBonus.type[NewBonus.event])
                
                if NewBonus_EXTENDED and Damage and Evasion and Critical and SpellPower and LifeSteal and SpellVamp then
                    if NewBonus.type[NewBonus.event] == BONUS_COOLDOWN_REDUCTION then
                        self:set(NewBonus.unit[NewBonus.event], NewBonus.type[NewBonus.event], NewBonus.real[NewBonus.event], true)
                    else
                        self:set(NewBonus.unit[NewBonus.event], NewBonus.type[NewBonus.event], current + NewBonus.real[NewBonus.event], true)
                    end
                else
                    self:set(NewBonus.unit[NewBonus.event], NewBonus.type[NewBonus.event], current + NewBonus.real[NewBonus.event], true)
                end
                
                return value
            else
                return self:add(NewBonus.unit[NewBonus.event], NewBonus.type[NewBonus.event], NewBonus.real[NewBonus.event])
            end
        else
            print("Invalid Bonus Type")
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
        if NewBonus_EXTENDED and Damage and Evasion and Critical and SpellPower and LifeSteal and SpellVamp then
            NewBonus.last = BONUS_COOLDOWN_OFFSET
        else
            NewBonus.last = BONUS_LIFE_STEAL
        end
    end)
    
    -- -------------------------------------------------------------------------- --
    --                                   LUA API                                  --
    -- -------------------------------------------------------------------------- --
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
        return NewBonus.unit[NewBonus.event]
    end
    
    function GetBonusType()
        return NewBonus.type[NewBonus.event]
    end
    
    function SetBonusType(type)
        if type >= BONUS_DAMAGE and type <= NewBonus.last then
            NewBonus.type[NewBonus.event] = type
        end
    end
    
    function GetBonusAmount()
        return NewBonus.real[NewBonus.event]
    end
    
    function SetBonusAmount(real)
        NewBonus.real[NewBonus.event] = real
    end
end