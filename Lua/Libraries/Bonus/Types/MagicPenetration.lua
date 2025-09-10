OnInit("MagicPenetration", function(requires)
    requires "Class"
    requires "Bonus"
    requires "Damage"
    requires "MagicResistance"

    MAGIC_MULTIPLIER = 0.06

    local MagicPenetration = Class(Bonus)

    MagicPenetration.bonus = {}

    function MagicPenetration:get(unit)
        return MagicPenetration.bonus[unit] or 0
    end

    function MagicPenetration:set(unit, value)
        MagicPenetration.bonus[unit] = value

        return value
    end

    function MagicPenetration:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    function MagicPenetration.onDamage()
        if Damage.isSpell and Damage.premitigation > 0 then
            Damage.amount = Damage.premitigation * (1 - GetMagicReduction(Damage.source.unit, Damage.target.unit))
        end
    end

    function MagicPenetration.onInit()
        RegisterAttackDamageEvent(MagicPenetration.onDamage)
    end

    BONUS_MAGIC_PENETRATION = RegisterBonus(MagicPenetration.allocate())

    local MagicPenetrationFlat = Class(Bonus)

    MagicPenetrationFlat.bonus = {}

    function MagicPenetrationFlat:get(unit)
        return MagicPenetrationFlat.bonus[unit] or 0
    end

    function MagicPenetrationFlat:set(unit, value)
        MagicPenetrationFlat.bonus[unit] = value

        return value
    end

    function MagicPenetrationFlat:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    BONUS_MAGIC_PENETRATION_FLAT = RegisterBonus(MagicPenetrationFlat.allocate())

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function GetUnitMagicPenetration(unit, flat)
        if flat then
            return MagicPenetrationFlat:get(unit)
        else
            return MagicPenetration:get(unit)
        end
    end

    function SetUnitMagicPenetration(unit, value, flat)
        if flat then
            MagicPenetrationFlat:set(unit, value)
        else
            MagicPenetration:set(unit, value)
        end

        return value
    end

    function UnitAddMagicPenetration(unit, value, flat)
        if flat then
            return MagicPenetrationFlat:add(unit, value)
        else
            return MagicPenetration:add(unit, value)
        end
    end

    function GetMagicReduction(source, target)
        local magic = GetUnitMagicResistance(target) - GetUnitMagicPenetration(source, true)

        if magic > 0 then
            magic = magic * (1 - GetUnitMagicPenetration(source, false))
        end

        return (magic * MAGIC_MULTIPLIER) / (1 + (magic * MAGIC_MULTIPLIER))
    end
end)