OnInit(function(requires)
    requires "Class"
    requires "Bonus"

    local Mana = Class(Bonus)
    local ability = FourCC('Z005')
    local field = ABILITY_ILF_MAX_MANA_GAINED

    function Mana:get(unit)
        if GetUnitAbilityLevel(unit, ability) == 0 then
            UnitAddAbility(unit, ability)
            UnitMakeAbilityPermanent(unit, true, ability)
        end

        return I2R(BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0))
    end

    function Mana:set(unit, value)
        local percentage = GetUnitManaPercent(unit)

        BlzSetUnitMaxMana(unit, R2I(BlzGetUnitMaxMana(unit) - self:get(unit)))
        BlzSetUnitMaxMana(unit, R2I(BlzGetUnitMaxMana(unit) + value))
        SetUnitManaPercentBJ(unit, percentage)

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

    function Mana:add(unit, value)
        local percentage = GetUnitManaPercent(unit)

        value = self:overflow(self:get(unit), value)

        BlzSetUnitMaxMana(unit, R2I(BlzGetUnitMaxMana(unit) + value))
        SetUnitManaPercentBJ(unit, percentage)

        if BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0, BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0) + R2I(value)) then
            IncUnitAbilityLevel(unit, ability)
            DecUnitAbilityLevel(unit, ability)

            return value
        else
            return 0.
        end
    end

    BONUS_MANA = RegisterBonus(Mana.allocate())
end)