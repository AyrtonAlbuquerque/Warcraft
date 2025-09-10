OnInit(function(requires)
    requires "Class"
    requires "Bonus"

    local Intelligence = Class(Bonus)
    local ability = FourCC('Z003')
    local field = ABILITY_ILF_INTELLIGENCE_BONUS

    function Intelligence:get(unit)
        if GetUnitAbilityLevel(unit, ability) == 0 then
            UnitAddAbility(unit, ability)
            UnitMakeAbilityPermanent(unit, true, ability)
        end

        return I2R(BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0))
    end

    function Intelligence:set(unit, value)
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

    function Intelligence:add(unit, value)
        value = self:overflow(self:get(unit), value)

        if BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0, BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0) + R2I(value)) then
            IncUnitAbilityLevel(unit, ability)
            DecUnitAbilityLevel(unit, ability)

            return value
        else
            return 0.
        end
    end

    BONUS_INTELLIGENCE = RegisterBonus(Intelligence.allocate())
end)