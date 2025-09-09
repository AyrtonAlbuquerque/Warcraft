OnInit(function(requires)
    requires "Class"
    requires "Bonus"

    BONUS_DAMAGE = 0

    local DamageBonus = Class(Bonus)
    local ability = FourCC('Z001')
    local field = ABILITY_ILF_ATTACK_BONUS

    function DamageBonus:get(unit)
        if GetUnitAbilityLevel(unit, ability) == 0 then
            UnitAddAbility(unit, ability)
            UnitMakeAbilityPermanent(unit, true, ability)
        end

        return I2R(BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0))
    end

    function DamageBonus:set(unit, value)
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

    function DamageBonus:add(unit, value)
        value = self:overflow(self:get(unit), value)

        if BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0, BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0) + R2I(value)) then
            IncUnitAbilityLevel(unit, ability)
            DecUnitAbilityLevel(unit, ability)

            return value
        else
            return 0.
        end
    end

    function DamageBonus.onInit()
        BONUS_DAMAGE = RegisterBonus(DamageBonus.allocate())
    end
end)