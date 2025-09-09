OnInit(function(requires)
    requires "Class"
    requires "Bonus"
    requires "Tenacity"

    BONUS_TENACITY = 0
    BONUS_TENACITY_FLAT = 0
    BONUS_TENACITY_OFFSET = 0

    local TenacityBonus = Class(Bonus)

    function TenacityBonus:get(unit)
        return GetUnitTenacity(unit)
    end

    function TenacityBonus:set(unit, value)
        SetUnitTenacity(unit, value)

        return value
    end

    function TenacityBonus:add(unit, value)
        if not UnitRemoveTenacity(unit, -value) then
            UnitAddTenacity(unit, value)
        end

        return value
    end

    function TenacityBonus.onInit()
        BONUS_TENACITY = RegisterBonus(TenacityBonus.allocate())
    end

    local TenacityFlat = Class(Bonus)

    function TenacityFlat:get(unit)
        return GetUnitTenacityFlat(unit)
    end

    function TenacityFlat:set(unit, value)
        SetUnitTenacityFlat(unit, value)

        return value
    end

    function TenacityFlat:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    function TenacityFlat.onInit()
        BONUS_TENACITY_FLAT = RegisterBonus(TenacityFlat.allocate())
    end

    local TenacityOffset = Class(Bonus)

    function TenacityOffset:get(unit)
        return GetUnitTenacityOffset(unit)
    end

    function TenacityOffset:set(unit, value)
        SetUnitTenacityOffset(unit, value)

        return value
    end

    function TenacityOffset:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    function TenacityOffset.onInit()
        BONUS_TENACITY_OFFSET = RegisterBonus(TenacityOffset.allocate())
    end
end)