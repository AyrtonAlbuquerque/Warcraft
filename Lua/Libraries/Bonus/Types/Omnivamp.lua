---@beginFile Omnivamp
---@debug
---@diagnostic disable: need-check-nil
OnInit("Omnivamp", function(requires)
    requires "Class"
    requires "Bonus"
    requires "Damage"

    local Omnivamp = Class(Bonus)
    local bonus = {}

    function Omnivamp:get(unit)
        return bonus[unit] or 0
    end

    function Omnivamp:set(unit, value)
        bonus[unit] = value

        return value
    end

    function Omnivamp:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    function Omnivamp.onDamage()
        if Damage.amount > 0 and (bonus[Damage.source.unit] or 0) > 0 and not Damage.target.isStructure then
            SetWidgetLife(Damage.source.unit, (GetWidgetLife(Damage.source.unit) + (Damage.amount * (bonus[Damage.source.unit] or 0))))
        end
    end

    function Omnivamp.onInit()
        RegisterAnyDamageEvent(Omnivamp.onDamage)
    end

    BONUS_OMNIVAMP = RegisterBonus(Omnivamp.allocate())
end)