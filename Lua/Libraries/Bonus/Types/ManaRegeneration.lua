OnInit(function(requires)
    requires "Class"
    requires "Bonus"

    BONUS_MANA_REGEN = 0

    local ManaRegeneration = Class(Bonus)
    local ability = FourCC('Z007')
    local field = ABILITY_RLF_AMOUNT_REGENERATED

    function ManaRegeneration:get(unit)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, 0)
    end

    function ManaRegeneration:set(unit, value)
        if GetUnitAbilityLevel(unit, ability) == 0 then
            UnitAddAbility(unit, ability)
            UnitMakeAbilityPermanent(unit, true, ability)
        end

        if BlzSetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, 0, value) then
            IncUnitAbilityLevel(unit, ability)
            DecUnitAbilityLevel(unit, ability)
        end

        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, 0)
    end

    function ManaRegeneration:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    function ManaRegeneration.onInit()
        BONUS_MANA_REGEN = RegisterBonus(ManaRegeneration.allocate())
    end
end)