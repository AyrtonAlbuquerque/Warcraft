OnInit(function(requires)
    requires "Class"
    requires "Bonus"
    requires "CDR"

    BONUS_COOLDOWN_OFFSET = 0
    BONUS_COOLDOWN_REDUCTION = 0
    BONUS_COOLDOWN_REDUCTION_FLAT = 0

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

    function CooldownOffset.onInit()
        BONUS_COOLDOWN_OFFSET = RegisterBonus(CooldownOffset.allocate())
    end

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

    function CooldownReduction.onInit()
        BONUS_COOLDOWN_REDUCTION = RegisterBonus(CooldownReduction.allocate())
    end

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

    function CooldownReductionFlat.onInit()
        BONUS_COOLDOWN_REDUCTION_FLAT = RegisterBonus(CooldownReductionFlat.allocate())
    end
end)