OnInit(function(requires)
    requires "Class"
    requires "Bonus"
    requires "Damage"

    BONUS_SPELL_VAMP = 0

    local SpellVamp = Class(Bonus)
    local bonus = {}

    function SpellVamp:get(unit)
        return bonus[unit] or 0
    end

    function SpellVamp:set(unit, value)
        bonus[unit] = value

        return value
    end

    function SpellVamp:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    function SpellVamp.onDamage()
        if Damage.amount > 0 and Damage.isSpell and (bonus[Damage.source.unit] or 0) > 0 and not Damage.target.isStructure then
            SetWidgetLife(Damage.source.unit, (GetWidgetLife(Damage.source.unit) + (Damage.amount * (bonus[Damage.source.unit] or 0))))
        end
    end

    function SpellVamp.onInit()
        BONUS_SPELL_VAMP = RegisterBonus(SpellVamp.allocate())

        RegisterAnyDamageEvent(SpellVamp.onDamage)
    end
end)