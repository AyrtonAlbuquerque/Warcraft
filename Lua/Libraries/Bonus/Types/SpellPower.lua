OnInit(function(requires)
    requires "Class"
    requires "Bonus"

    local SpellPower = Class(Bonus)
    local bonus = {}

    function SpellPower:get(unit)
        return bonus[unit] or 0
    end

    function SpellPower:set(unit, value)
        bonus[unit] = value

        return value
    end

    function SpellPower:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    BONUS_SPELL_POWER = RegisterBonus(SpellPower.allocate())
end)