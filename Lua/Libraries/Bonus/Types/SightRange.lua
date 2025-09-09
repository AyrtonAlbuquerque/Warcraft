OnInit(function(requires)
    requires "Class"
    requires "Bonus"

    BONUS_SIGHT_RANGE = 0

    local SightRange = Class(Bonus)
    local ability = FourCC('Z00A')
    local field = ABILITY_ILF_SIGHT_RANGE_BONUS

    function SightRange:get(unit)
        if GetUnitAbilityLevel(unit, ability) == 0 then
            UnitAddAbility(unit, ability)
            UnitMakeAbilityPermanent(unit, true, ability)
        end

        return I2R(BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0))
    end

    function SightRange:set(unit, value)
        BlzSetUnitRealField(unit, UNIT_RF_SIGHT_RADIUS, (BlzGetUnitRealField(unit, UNIT_RF_SIGHT_RADIUS) - self:get(unit)))
        BlzSetUnitRealField(unit, UNIT_RF_SIGHT_RADIUS, (BlzGetUnitRealField(unit, UNIT_RF_SIGHT_RADIUS) + value))

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

    function SightRange:add(unit, value)
        value = self:overflow(self:get(unit), value)

        BlzSetUnitRealField(unit, UNIT_RF_SIGHT_RADIUS, (BlzGetUnitRealField(unit, UNIT_RF_SIGHT_RADIUS) + value))

        if BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0, BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0) + R2I(value)) then
            IncUnitAbilityLevel(unit, ability)
            DecUnitAbilityLevel(unit, ability)

            return value
        else
            return 0.
        end
    end

    function SightRange.onInit()
        BONUS_SIGHT_RANGE = RegisterBonus(SightRange.allocate())
    end
end)