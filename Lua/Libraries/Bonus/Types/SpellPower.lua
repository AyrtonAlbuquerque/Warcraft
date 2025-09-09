OnInit(function(requires)
    requires "Class"
    requires "Bonus"

    BONUS_SPELL_POWER = 0

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

    function SpellPower.onInit()
        BONUS_SPELL_POWER = RegisterBonus(SpellPower.allocate())
    end
end)