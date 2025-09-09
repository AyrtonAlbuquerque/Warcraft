OnInit("ArmorPenetration", function(requires)
    requires "Class"
    requires "Bonus"
    requires "Damage"

    ARMOR_MULTIPLIER = 0.06
    BONUS_ARMOR_PENETRATION = 0
    BONUS_ARMOR_PENETRATION_FLAT = 0

    local ArmorPenetration = Class(Bonus)

    ArmorPenetration.bonus = {}

    function ArmorPenetration:get(unit)
        return ArmorPenetration.bonus[unit] or 0.
    end

    function ArmorPenetration:set(unit, value)
        ArmorPenetration.bonus[unit] = value

        return value
    end

    function ArmorPenetration:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    function ArmorPenetration.onDamage()
        if Damage.isAttack and Damage.premitigation > 0 then
            Damage.amount = Damage.premitigation * (1 - GetArmorReduction(Damage.source.unit, Damage.target.unit))
        end
    end

    function ArmorPenetration.onInit()
        BONUS_ARMOR_PENETRATION = RegisterBonus(ArmorPenetration.allocate())

        RegisterAttackDamageEvent(ArmorPenetration.onDamage)
    end

    local ArmorPenetrationFlat = Class(Bonus)

    ArmorPenetrationFlat.bonus = {}

    function ArmorPenetrationFlat:get(unit)
        return ArmorPenetrationFlat.bonus[unit] or 0.
    end

    function ArmorPenetrationFlat:set(unit, value)
        ArmorPenetrationFlat.bonus[unit] = value

        return value
    end

    function ArmorPenetrationFlat:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    function ArmorPenetrationFlat.onInit()
        BONUS_ARMOR_PENETRATION_FLAT = RegisterBonus(ArmorPenetrationFlat.allocate())
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function GetUnitArmorPenetration(unit, flat)
        if flat then
            return ArmorPenetrationFlat:get(unit)
        else
            return ArmorPenetration:get(unit)
        end
    end

    function SetUnitArmorPenetration(unit, value, flat)
        if flat then
            ArmorPenetrationFlat:set(unit, value)
        else
            ArmorPenetration:set(unit, value)
        end

        return value
    end

    function UnitAddArmorPenetration(unit, value, flat)
        if flat then
            return ArmorPenetrationFlat:add(unit, value)
        else
            return ArmorPenetration:add(unit, value)
        end
    end

    function GetArmorReduction(source, target)
        local armor = BlzGetUnitArmor(target) - GetUnitArmorPenetration(source, true)

        if armor > 0 then
            armor = armor * (1 - GetUnitArmorPenetration(source, false))
        end

        return (armor * ARMOR_MULTIPLIER) / (1 + (armor * ARMOR_MULTIPLIER))
    end
end)