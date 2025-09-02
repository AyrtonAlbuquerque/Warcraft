OnInit("Dummy", function(requires)
    requires "Class"
    requires "WorldBounds"

    Dummy = Class()

    Dummy.type = FourCC('dumi')

    local group = CreateGroup()
    local location = Location(0, 0)
    local player = Player(PLAYER_NEUTRAL_PASSIVE)

    function Dummy.recycle(dummy)
        if GetUnitTypeId(dummy) == Dummy.type then
            GroupAddUnit(group, dummy)
            SetUnitX(dummy, WorldBounds.maxX)
            SetUnitY(dummy, WorldBounds.maxY)
            SetUnitOwner(dummy, player, false)
            SetUnitScale(dummy, 1, 1, 1)
            SetUnitTimeScale(dummy, 1)
            PauseUnit(dummy, true)
        end
    end

    function Dummy.retrieve(owner, x, y, z, face)
        if not owner then
            owner = player
        end

        if BlzGroupGetSize(group) > 0 then
            bj_lastCreatedUnit = FirstOfGroup(group)

            PauseUnit(bj_lastCreatedUnit, false)
            GroupRemoveUnit(group, bj_lastCreatedUnit)
            SetUnitX(bj_lastCreatedUnit, x)
            SetUnitY(bj_lastCreatedUnit, y)
            MoveLocation(location, x, y)
            SetUnitFlyHeight(bj_lastCreatedUnit, z - GetLocationZ(location), 0)
            SetUnitFacing(bj_lastCreatedUnit, face*bj_RADTODEG)
            SetUnitOwner(bj_lastCreatedUnit, owner, false)
        else
            bj_lastCreatedUnit = CreateUnit(owner, Dummy.type, x, y, face*bj_RADTODEG)

            MoveLocation(location, x, y)
            SetUnitFlyHeight(bj_lastCreatedUnit, z - GetLocationZ(location), 0)
            UnitRemoveAbility(bj_lastCreatedUnit, FourCC('Amrf'))
        end

        return bj_lastCreatedUnit
    end

    function Dummy.recycleTimed(dummy, delay)
        if GetUnitTypeId(dummy) ~= Dummy.type then
            BJDebugMsg("[DummyPool] Error: Trying to recycle a non dummy unit")
        else
            TimerStart(CreateTimer(), delay, false, function()
                Dummy.recycle(dummy)
                DestroyTimer(GetExpiredTimer())
            end)
        end
    end

    function Dummy.onInit()
        for i = 0, 150 do
            local unit = CreateUnit(player, Dummy.type, WorldBounds.maxX, WorldBounds.maxY, 0)

            PauseUnit(unit, false)
            GroupAddUnit(group, unit)
            UnitRemoveAbility(unit, FourCC('Amrf'))
        end
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function DummyRetrieve(owner, x, y, z, facing)
        return Dummy.retrieve(owner, x, y, z, facing)
    end

    function DummyRecycle(unit)
        Dummy.recycle(unit)
    end

    function DummyRecycleTimed(unit, delay)
        Dummy.recycleTimed(unit, delay)
    end
end)