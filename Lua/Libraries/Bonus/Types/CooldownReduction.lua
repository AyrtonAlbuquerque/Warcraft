OnInit(function(requires)
    requires "Class"
    requires "Bonus"
    requires "CDR"

    local CooldownOffset = Class(Bonus)

    function CooldownOffset:get(unit)
        return GetUnitCooldownOffset(unit)
    end

    function CooldownOffset:set(unit, value)
        SetUnitCooldownOffset(unit, value)

        return value
    end

    function CooldownOffset:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    BONUS_COOLDOWN_OFFSET = RegisterBonus(CooldownOffset.allocate())

    local CooldownReduction = Class(Bonus)

    function CooldownReduction:get(unit)
        return GetUnitCooldownReduction(unit)
    end

    function CooldownReduction:set(unit, value)
        SetUnitCooldownReduction(unit, value)

        return value
    end

    function CooldownReduction:add(unit, value)
        if not UnitRemoveCooldownReduction(unit, -value) then
            UnitAddCooldownReduction(unit, value)
        end

        return value
    end

    BONUS_COOLDOWN_REDUCTION = RegisterBonus(CooldownReduction.allocate())

    local CooldownReductionFlat = Class(Bonus)

    function CooldownReductionFlat:get(unit)
        return GetUnitCooldownReductionFlat(unit)
    end

    function CooldownReductionFlat:set(unit, value)
        SetUnitCooldownReductionFlat(unit, value)

        return value
    end

    function CooldownReductionFlat:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    BONUS_COOLDOWN_REDUCTION_FLAT = RegisterBonus(CooldownReductionFlat.allocate())
end)