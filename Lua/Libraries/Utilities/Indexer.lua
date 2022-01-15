--[[
    -- ------------------------ Indexer v1.1 by Chopinski ----------------------- --
        Simple Unit Indexer for LUA.
        Simply copya nd paste to import
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    local ability = FourCC('Adef')
    local onIndex = {}
    local onDeindex = {}
    local id = 0
    local source
    
    local SetUnitId = SetUnitUserData
    function SetUnitUserData(unit, id) end
    
    local function IndexUnit(unit)
        if GetUnitUserData(unit) == 0 then
            id = id + 1
            source = unit
    
            if GetUnitAbilityLevel(unit, ability) == 0 then
                UnitAddAbility(unit, ability)
                UnitMakeAbilityPermanent(unit, true, ability)
                BlzUnitDisableAbility(unit, ability, true, true)
            end
            SetUnitId(unit, id)
            
            for i = 1, #onIndex do
                onIndex[i]()
            end
            
            source = nil
        end
    end
    
    onInit(function()
        local trigger = CreateTrigger()
        local region = CreateRegion()
        local rect = GetWorldBounds()
        
        RegionAddRect(region, rect)
        RemoveRect(rect)
        
        TriggerRegisterEnterRegion(CreateTrigger(), region, Filter(function()
            IndexUnit(GetFilterUnit())
        end))
        
        for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
            GroupEnumUnitsOfPlayer(bj_lastCreatedGroup, Player(i), Filter(function()
                IndexUnit(GetFilterUnit())
            end))
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_ISSUED_ORDER, null)
        end
        
        TriggerAddCondition(trigger, Filter(function()
            if GetIssuedOrderId() == 852056 then
                if GetUnitAbilityLevel(GetTriggerUnit(), ability) == 0 then
                    source = GetTriggerUnit()
                    for i = 1, #onDeindex do
                        onDeindex[i]()
                    end
                    source = nil
                end
            end
        end))
    end)
    
    -- -------------------------------------------------------------------------- --
    --                                   LUA API                                  --
    -- -------------------------------------------------------------------------- --
    function RegisterUnitIndexEvent(code)
        if type(code) == "function" then
            table.insert(onIndex, code)
        end
    end
    
    function RegisterUnitDeindexEvent(code)
        if type(code) == "function" then
            table.insert(onDeindex, code)
        end
    end
    
    function GetIndexUnit()
        return source
    end
end