OnInit(function(requires)
    requires "Class"
    requires "Bonus"
    requires "Shield"

    local Shielding = Class(Bonus)

    function Shielding:get(unit)
        return GetUnitShieldingIncrease(unit)
    end

    function Shielding:set(unit, value)
        SetUnitShieldingIncrease(unit, value)

        return value
    end

    function Shielding:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    BONUS_SHIELDING = RegisterBonus(Shielding.allocate())

    local ShieldingReduction = Class(Bonus)

    function ShieldingReduction:get(unit)
        return GetUnitShieldingDecrease(unit)
    end

    function ShieldingReduction:set(unit, value)
        SetUnitShieldingDecrease(unit, value)

        return value
    end

    function ShieldingReduction:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    BONUS_SHIELDING_REDUCTION = RegisterBonus(ShieldingReduction.allocate())
end)