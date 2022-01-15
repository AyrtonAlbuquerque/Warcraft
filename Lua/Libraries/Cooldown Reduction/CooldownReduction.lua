--[[ requires RegisterPlayerUnitEvent, Indexer
    /* ------------------ Cooldown Reduction v1.9 by Chopinski ------------------ */
    Intro
        This library intension in to introduce to warcraft an easy way to 
        manipulate abilities cooldowns based on a cooldown reduction value that
        is unique for each unit.

    How it Works?
        When casting an ability, its "new" cooldown is calculated based on the 
        amount of cooldown reduction of the casting unit. the formula for 
        calculation is:
            Cooldown = (Default Cooldown - Cooldown Offset) * [(1 - source1)*(1 - source2)*...] * (1 - Cooldown Reduction Flat)

        The system also allow negative values for CDR, resulting in increased
        ability cooldown.

        It does not acumulate because the abilities are registered automatically
        on the first cast, saving its base cooldown (Object Editor values) and 
        always using this base value for calculation, so you can still edit 
        the ability via the editor and the system takes care of the rest.

    How to Import
        simply copy the CooldownReduction folder over to your map, and start 
        use the API functions

    Requirements
        CooldownReduction requires RegisterPlayerUnitEvent.
        Credits to Magtheridon96 for RegisterPlayerUnitEvent.
        It also requires patch 1.31+.

        RegisterPlayerUnitEvent: www.hiveworkshop.com/threads/snippet-registerplayerunitevent.203338/
]]--

-- -------------------------------------------------------------------------- --
--                                Configuration                               --
-- -------------------------------------------------------------------------- --
-- Use this function to filter out units you dont want to have abilities registered.
-- By default dummy units do not trigger the system.
local function UnitFilter(unit)
    return GetUnitAbilityLevel(unit, FourCC('Aloc')) == 0
end

-- -------------------------------------------------------------------------- --
--                                   System                                   --
-- -------------------------------------------------------------------------- --
do
    local units = {}
    local abilities = {}
    local defaults = {}
    local set = {}

    CDR = setmetatable({}, {})
    local mt = getmetatable(CDR)
    mt.__index = mt
    
    function mt:update(unit)
        local real

        for i = 1, #abilities[unit] do
            local k = abilities[unit][i]
            local ability = BlzGetUnitAbility(unit, k)
            local level = BlzGetAbilityIntegerField(ability, ABILITY_IF_LEVELS)

            for j = 1, level do
                if (units[unit].count or 0) > 0 then
                    real = ((defaults[k][j] - units[unit].offset) * units[unit].cooldown * (1 - units[unit].flat))
                else
                    real = ((defaults[k][j] - units[unit].offset) * (1 - units[unit].flat))
                end
                BlzSetAbilityRealLevelField(ability, ABILITY_RLF_COOLDOWN, j-1, real)
                IncUnitAbilityLevel(unit, k)
                DecUnitAbilityLevel(unit, k)
            end
        end
    end

    function mt:set(unit, real, type)
        if not units[unit] then self:create(unit) end

        if type == 0 then
            units[unit].cooldown = real
        elseif type == 1 then
            units[unit].flat = real
        else
            units[unit].offset = real
        end
        
        self:update(unit)
    end

    function mt:get(unit, type)
        if not units[unit] then self:create(unit) end

        if type == 0 then
            return units[unit].cooldown or 0
        elseif type == 1 then
            return units[unit].flat or 0
        else
            return units[unit].offset or 0
        end
    end
    
    function mt:calculate(unit)
        local real = 0
        
        if (#units[unit].cdr or 0) > 0 then
            for i = 1, #units[unit].cdr do
                if i > 1 then
                    real = real * (1 - units[unit].cdr[i])
                else
                    real = 1 - units[unit].cdr[i]
                end
            end
        end
        
        return real
    end

    function mt:calculateCooldown(unit, id, level, cooldown)
        if not units[unit] then
            self:create(unit)
        else
            local ability = BlzGetUnitAbility(unit, id)
            local real

            if (#units[unit].cdr or 0) > 0 then
                real = ((cooldown - units[unit].offset) * units[unit].cooldown * (1 - units[unit].flat))
            else
                real = ((cooldown - units[unit].offset) * (1 - units[unit].flat))
            end
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_COOLDOWN, level-1, real)
            IncUnitAbilityLevel(unit, id)
            DecUnitAbilityLevel(unit, id)
        end
    end
    
    function mt:simulateCooldown(unit, cooldown)
        if not units[unit] then 
            self:create(unit) 
            return cooldown
        else
            local real

            if (#units[unit].cdr or 0) > 0 then
                real = ((cooldown - units[unit].offset) * units[unit].cooldown * (1 - units[unit].flat))
            else
                real = ((cooldown - units[unit].offset) * (1 - units[unit].flat))
            end
            
            return real
        end
    end
    
    function mt:add(unit, real, type)
        if real ~= 0 then
            if not units[unit] then self:create(unit) end
            
            if type == 0 then
                table.insert(units[unit].cdr, real)
                units[unit].count = units[unit].count + 1
                units[unit].cooldown = self:calculate(unit)
            elseif type == 1 then
                units[unit].flat = units[unit].flat + real
            else
                units[unit].offset = units[unit].offset + real
            end
            
            self:update(unit)
        end
    end
    
    function mt:remove(unit, real)
        if real ~= 0 then
            if not units[unit] then 
                self:create(unit)
                return
            end
            
            for j = 1, #units[unit].cdr do
                if units[unit].cdr[j] == real then
                    table.remove(units[unit].cdr, j)
                    units[unit].count = units[unit].count - 1
                    units[unit].cooldown = self:calculate(unit)
                    break
                end
            end
            self:update(unit)
        end
    end
    
    function mt:create(unit)
        abilities[unit] = {}
        set[unit] = {}
        units[unit] = {}
        units[unit].cdr = {}
        units[unit].cooldown = 0
        units[unit].offset = 0
        units[unit].flat = 0
        units[unit].count = 0
    end
    
    function mt:destroy(unit)
        if abilities[unit] then
            for i = 1, #abilities[unit] do
                defaults[abilities[unit][i]] = nil
            end
        end
        abilities[unit] = nil
        set[unit] = nil
        units[unit] = nil
        units[unit].cdr = nil
        units[unit].cooldown = nil
        units[unit].offset = nil
        units[unit].flat = nil
        units[unit].count = nil
    end
    
    function mt:register(unit, id)
        if UnitFilter(unit) then
            if not units[unit] then self:create(unit) end
        
            if not set[unit][id] then
                set[unit][id] = true
                table.insert(abilities[unit], id)
                if not defaults[id] then defaults[id] = {} end
                
                local ability = BlzGetUnitAbility(unit, id)
                local levels = BlzGetAbilityIntegerField(ability, ABILITY_IF_LEVELS)
                for i = 1, levels do
                    defaults[id][i] = BlzGetAbilityRealLevelField(ability, ABILITY_RLF_COOLDOWN, i - 1)
                end
                
                if (units[unit].count or 0) > 0 or units[unit].cooldown or units[unit].offset or units[unit].flat then
                    self:update(unit)
                end
            end
        end
    end
    
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function()
            CDR:register(GetTriggerUnit(), GetSpellAbilityId())
        end)
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function()
            CDR:register(GetTriggerUnit(), GetLearnedSkill())
        end)
        
        RegisterUnitDeindexEvent(function()
            CDR:destroy(GetIndexUnit())
        end)
    end)

    -- -------------------------------------------------------------------------- --
    --                                   LUA API                                  --
    -- -------------------------------------------------------------------------- --
    function GetUnitCooldownReduction(unit)
        return 1 - CDR:get(unit, 0)
    end

    function GetUnitCooldownReductionFlat(unit)
        return CDR:get(unit, 1)
    end

    function GetUnitCooldownOffset(unit)
        return CDR:get(unit, 2)
    end

    function SetUnitCooldownReduction(unit, real)
        CDR:set(unit, real, 0)
    end

    function SetUnitCooldownReductionFlat(unit, real)
        CDR:set(unit, real, 1)
    end

    function SetUnitCooldownOffset(unit, real)
        CDR:set(unit, real, 2)
    end

    function UnitAddCooldownReduction(unit, real)
        CDR:add(unit, real, 0)
    end

    function UnitAddCooldownReductionFlat(unit, real)
        CDR:add(unit, real, 1)
    end

    function UnitAddCooldownOffset(unit, real)
        CDR:add(unit, real, 2)
    end

    function UnitRemoveCooldownReduction(unit, real)
        CDR:remove(unit, real)
    end

    function CalculateAbilityCooldown(unit, ability, level, cooldown)
        CDR:calculateCooldown(unit, ability, level, cooldown)
    end
    
    function SimulateAbilityCooldown(unit, cooldown)
        return CDR:simulateCooldown(unit, cooldown)
    end
    
    function RegisterAbility(unit, ability)
        CDR:register(unit, ability)
    end
    
    function GetAbilityTable()
        return units
    end
end