OnInit(function(requires)
    requires "Class"
    requires "Bonus"
    requires "Heal"

    local Healing = Class(Bonus)

    function Healing:get(unit)
        return GetUnitHealingIncrease(unit)
    end

    function Healing:set(unit, value)
        SetUnitHealingIncrease(unit, value)

        return value
    end

    function Healing:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    BONUS_HEALING = RegisterBonus(Healing.allocate())

    local HealingReduction = Class(Bonus)

    function HealingReduction:get(unit)
        return GetUnitHealingDecrease(unit)
    end

    function HealingReduction:set(unit, value)
        SetUnitHealingDecrease(unit, value)

        return value
    end

    function HealingReduction:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    BONUS_HEALING_REDUCTION = RegisterBonus(HealingReduction.allocate())
end)