OnInit("OrbWalking", function(requires)
    requires "Class"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    local OrbWalking = Class()

    local function UnitFilter(unit)
        return IsUnitType(unit, UNIT_TYPE_HERO)
    end

    function OrbWalking.onOrder()
        local source = GetOrderedUnit()
        local order = OrderId2String(GetIssuedOrderId())

        if order == "smart" or order == "attack" and UnitFilter(source) then
            local target = GetOrderTargetUnit()
            local owner = GetOwningPlayer(source)
            local range = BlzGetUnitWeaponRealField(source, UNIT_WEAPON_RF_ATTACK_RANGE, 0)

            if (order == "smart" or order == "attack") and IsUnitEnemy(target, owner) and IsUnitInRange(source, target, range) then
                BlzSetUnitWeaponRealField(source, UNIT_WEAPON_RF_ATTACK_DAMAGE_POINT, 0, 0)
                BlzSetUnitFacingEx(source, AngleBetweenCoordinates(GetUnitX(source), GetUnitY(source), GetUnitX(target), GetUnitY(target))*bj_RADTODEG)
            elseif order == "attack" and target == nil then
                local group = CreateGroup()

                GroupEnumUnitsInRange(group, GetUnitX(source), GetUnitY(source), range + 50, nil)

                local size = BlzGroupGetSize(group)

                for i = 0, size - 1 do
                    local unit = BlzGroupUnitAt(group, i)

                    if UnitAlive(unit) and IsUnitEnemy(unit, owner) and IsUnitInRange(source, unit, range) and not BlzIsUnitInvulnerable(unit) then
                        BlzSetUnitWeaponRealField(source, UNIT_WEAPON_RF_ATTACK_DAMAGE_POINT, 0, 0)
                        BlzSetUnitFacingEx(source, AngleBetweenCoordinates(GetUnitX(source), GetUnitY(source), GetUnitX(unit), GetUnitY(unit))*bj_RADTODEG)
                        break
                    end
                end

                DestroyGroup(group)
            end
        end
    end

    function OrbWalking.onInit()
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, OrbWalking.onOrder)
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, OrbWalking.onOrder)
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, OrbWalking.onOrder)
    end
end)
