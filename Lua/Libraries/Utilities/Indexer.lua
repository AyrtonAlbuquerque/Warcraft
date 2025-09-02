OnInit("Indexer", function(requires)
    requires "Class"

    local id = 0
    local onIndex = {}
    local onDeindex = {}
    local ability = FourCC('Adef')
    local rect = GetWorldBounds()
    local region = CreateRegion()
    local trigger = CreateTrigger()
    local SetUnitId = SetUnitUserData

    function SetUnitUserData(unit, id) end

    Indexer = Class()

    Indexer.source = nil

    function Indexer.__index()
        local unit = GetFilterUnit()

        if GetUnitUserData(unit) == 0 then
            id = id + 1
            Indexer.source = unit
    
            if GetUnitAbilityLevel(unit, ability) == 0 then
                UnitAddAbility(unit, ability)
                UnitMakeAbilityPermanent(unit, true, ability)
                BlzUnitDisableAbility(unit, ability, true, true)
            end

            SetUnitId(unit, id)

            for i = 1, #onIndex do
                onIndex[i]()
            end

            Indexer.source = nil
        end
    end

    function Indexer.__deindex()
        local unit = GetTriggerUnit()

        if GetIssuedOrderId() == 852056 then
            if GetUnitAbilityLevel(unit, ability) == 0 then
                Indexer.source = unit

                for i = 1, #onDeindex do
                    onDeindex[i]()
                end

                Indexer.source = nil
            end
        end
    end

    function Indexer.onInit()
        RegionAddRect(region, rect)
        RemoveRect(rect)

        TriggerRegisterEnterRegion(CreateTrigger(), region, Filter(Indexer.__index))

        for i = 0, bj_MAX_PLAYER_SLOTS - 1 do
            GroupEnumUnitsOfPlayer(bj_lastCreatedGroup, Player(i), Filter(Indexer.__index))
            TriggerRegisterPlayerUnitEvent(trigger, Player(i), EVENT_PLAYER_UNIT_ISSUED_ORDER, nil)
        end
        
        TriggerAddCondition(trigger, Filter(Indexer.__deindex))
    end
    
    -- -------------------------------------------------------------------------- --
    --                                   Lua API                                  --
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
        return Indexer.source
    end
end)