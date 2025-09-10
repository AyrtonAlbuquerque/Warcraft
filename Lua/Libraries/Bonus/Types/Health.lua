OnInit(function(requires)
    requires "Class"
    requires "Bonus"

    local Health = Class(Bonus)
    local ability = FourCC('Z004')
    local field = ABILITY_ILF_MAX_LIFE_GAINED

    function Health:get(unit)
        if GetUnitAbilityLevel(unit, ability) == 0 then
            UnitAddAbility(unit, ability)
            UnitMakeAbilityPermanent(unit, true, ability)
        end

        return I2R(BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0))
    end

    function Health:set(unit, value)
        local percentage = GetUnitLifePercent(unit)

        BlzSetUnitMaxHP(unit, R2I(BlzGetUnitMaxHP(unit) - self:get(unit)))
        BlzSetUnitMaxHP(unit, R2I(BlzGetUnitMaxHP(unit) + value))
        SetUnitLifePercentBJ(unit, percentage)

        if GetUnitAbilityLevel(unit, ability) == 0 then
            UnitAddAbility(unit, ability)
            UnitMakeAbilityPermanent(unit, true, ability)
        end

        if BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0, R2I(value)) then
            IncUnitAbilityLevel(unit, ability)
            DecUnitAbilityLevel(unit, ability)
        end

        return I2R(BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0))
    end

    function Health:add(unit, value)
        local percentage = GetUnitLifePercent(unit)

        value = self:overflow(self:get(unit), value)

        BlzSetUnitMaxHP(unit, R2I(BlzGetUnitMaxHP(unit) + value))
        SetUnitLifePercentBJ(unit, percentage)

        if BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0, BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0) + R2I(value)) then
            IncUnitAbilityLevel(unit, ability)
            DecUnitAbilityLevel(unit, ability)

            return value
        else
            return 0.
        end
    end

    BONUS_HEALTH = RegisterBonus(Health.allocate())
end)