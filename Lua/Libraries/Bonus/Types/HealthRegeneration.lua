OnInit(function(requires)
    requires "Class"
    requires "Bonus"

    local HealthRegeneration = Class(Bonus)
    local ability = FourCC('Z006')
    local field = ABILITY_RLF_AMOUNT_OF_HIT_POINTS_REGENERATED

    function HealthRegeneration:get(unit)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, 0)
    end

    function HealthRegeneration:set(unit, value)
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

    function HealthRegeneration:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    BONUS_HEALTH_REGEN = RegisterBonus(HealthRegeneration.allocate())
end)