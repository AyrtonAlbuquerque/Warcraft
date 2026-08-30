OnInit(function(requires)
    requires "Class"
    requires "Bonus"
    requires "Damage"
    requires.optional "Heal"

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
            if Heal then
                HealUnit(Damage.source.unit, Damage.source.unit, Damage.amount * (bonus[Damage.source.unit] or 0), HEALTH, false)
            else
                SetWidgetLife(Damage.source.unit, (GetWidgetLife(Damage.source.unit) + (Damage.amount * (bonus[Damage.source.unit] or 0))))
            end
        end
    end

    function SpellVamp.onInit()
        RegisterAnyDamageEvent(SpellVamp.onDamage)
    end

    BONUS_SPELL_VAMP = RegisterBonus(SpellVamp.allocate())
end)