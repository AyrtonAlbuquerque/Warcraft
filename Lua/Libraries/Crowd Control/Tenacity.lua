--[[
    -- ---------------------------------------- Tenacity v1.0 --------------------------------------- --
    -- Intro
    --      This library intension in to introduce to warcraft an easy way to 
    --      manipulate the duration of crowd control on units.
    --
    -- How it Works?
    --      Working in conjuction with the Crowd Control Library this library allows you to control the 
    --      duration of disables provided in the Crowd Control library. It work similar to the Tenacity
    --      status in League of Legends or the Status Resistence in Dota 2.
    --
    --      The are basically 3 types of tenacity: Normal (stacks multiplicatively), 
    --      Flat and Offset (stacks additively).The formula for calculation is:
    --          newDuration = (duration - Offset) * [(1 - value1)*(1 - value2)*...] * (1 - Flat)
    --
    --      The system also allow negative values for Tenacity, resulting in increased
    --      crowd control duration. Also note that tenacity will only work on CC applied through
    --      the Crowd Control API
    --
    -- How to Import
    --      1. Copy the Indexer library into your map
    --      2. Copy this library into your map and you are done 
    -- ---------------------------------------- By Chopinski ---------------------------------------- --
]]--

do
    -- ---------------------------------------------------------------------------------------------- --
    --                                             LUA API                                            --
    -- ---------------------------------------------------------------------------------------------- --
    function GetUnitTenacity(unit)
        return Tenacity:get(unit, 0)
    end

    function GetUnitTenacityFlat(unit)
        return Tenacity:get(unit, 1)
    end

    function GetUnitTenacityOffset(unit)
        return Tenacity:get(unit, 2)
    end

    function SetUnitTenacity(unit, value)
        Tenacity:set(unit, value, 0)
    end

    function SetUnitTenacityFlat(unit, value)
        Tenacity:set(unit, value, 1)
    end

    function SetUnitTenacityOffset(unit, value)
        Tenacity:set(unit, value, 2)
    end

    function UnitAddTenacity(unit, value)
        Tenacity:add(unit, value, 0)
    end

    function UnitAddTenacityFlat(unit, value)
        Tenacity:add(unit, value, 1)
    end

    function UnitAddTenacityOffset(unit, value)
        Tenacity:add(unit, value, 2)
    end

    function UnitRemoveTenacity(unit, value)
        Tenacity:remove(unit, value)
    end

    function GetTenacityDuration(unit, duration)
        return Tenacity:calculate(unit, duration)
    end

    function RegisterTenacityUnit(unit)
        return Tenacity:register(unit)
    end

    function DisplayTenacityStatus(unit)
        Tenacity:print(unit)
    end

    -- ---------------------------------------------------------------------------------------------- --
    --                                             System                                             --
    -- ---------------------------------------------------------------------------------------------- --
    Tenacity = setmetatable({}, {})
    local mt = getmetatable(Tenacity)
    mt.__index = mt

    local list = {}

    function mt:get(unit, type)
        if list[unit] then
            if type == 0 then
                if (#list[unit].normal or 0) > 0 then
                    return 1 - list[unit].tenacity
                else
                    return 0
                end
            elseif type == 1 then
                return list[unit].flat
            else
                return list[unit].offset
            end
        end

        return 0
    end

    function mt:set(unit, value, type)
        if not list[unit] then
            self:register(unit)
        end

        if type == 0 then
            list[unit].tenacity = value
        elseif type == 1 then
            list[unit].flat = value
        else
            list[unit].offset = value
        end
    end

    function mt:add(unit, value, type)
        if not list[unit] then
            self:register(unit)
        end

        if type == 0 then
            table.insert(list[unit].normal, value)
            self:update(unit)
        elseif type == 1 then
            list[unit].flat = (list[unit].flat or 0) + value
        else
            list[unit].offset = (list[unit].offset or 0) + value
        end
    end

    function mt:update(unit)
        if list[unit] then
            for i = 1, #list[unit].normal do
                if i > 1 then
                    list[unit].tenacity = (list[unit].tenacity or 0) * (1 - list[unit].normal[i])
                else
                    list[unit].tenacity = 1 - list[unit].normal[i]
                end
            end
        end
    end

    function mt:remove(unit, value)
        if value ~= 0 and list[unit] then
            for i = 1, #list[unit].normal do
                if list[unit].normal[i] == value then
                    table.remove(list[unit].normal, i)
                    break
                end
            end
            self:update(unit)
        end
    end

    function mt:calculate(unit, duration)
        if duration ~= 0 and list[unit] then
            if #list[unit].normal > 0 then
                duration = (duration - list[unit].offset) * list[unit].tenacity * (1 - list[unit].flat)
            else
                duration = (duration - list[unit].offset) * (1 - list[unit].flat)
            end

            if duration <= 0 then
                return 0
            end
        end

        return duration
    end

    function mt:print(unit)
        if list[unit] then
            ClearTextMessages()
            print("Tenacity Status for " .. GetUnitName(unit))
            print("Tenacity List [" .. (list[unit].normal[1] or 0) .. " | " .. (list[unit].normal[2] or 0) .. " | " .. (list[unit].normal[3] or 0) .. " | " .. (list[unit].normal[4] or 0) .. " | " .. (list[unit].normal[5] or 0) .. " | " .. (list[unit].normal[6] or 0) .. " | ...] = " .. (self:get(unit, 0)))
            print("Tenacity Flat [" .. (self:get(unit, 1)) .. "]")
            print("Tenacity Offset [" .. (self:get(unit, 2)) .. "]")
        end
    end

    function mt:register(unit)
        if not list[unit] then
            list[unit] = {}
            list[unit].normal = {}
            list[unit].flat = 0
            list[unit].offset = 0
            list[unit].tenacity = 0
        end

        return list[unit]
    end

    onInit(function()
        RegisterUnitDeindexEvent(function()
            list[GetIndexUnit()] = nil
        end)
    end)
end