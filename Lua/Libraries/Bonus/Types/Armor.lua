OnInit(function(requires)
    requires "Class"
    requires "Bonus"

    BONUS_ARMOR = 0

    local Armor = Class(Bonus)
    local ability = FourCC('Z002')
    local field = ABILITY_ILF_DEFENSE_BONUS_IDEF

    function Armor:get(unit)
        if GetUnitAbilityLevel(unit, ability) == 0 then
            UnitAddAbility(unit, ability)
            UnitMakeAbilityPermanent(unit, true, ability)
        end

        return I2R(BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0))
    end

    function Armor:set(unit, value)
        if BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0, R2I(value)) then
            IncUnitAbilityLevel(unit, ability)
            DecUnitAbilityLevel(unit, ability)
        end

        return I2R(BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0))
    end

    function Armor:add(unit, value)
        value = self:overflow(self:get(unit), value)

        if BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0, BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, ability), field, 0) + R2I(value)) then
            IncUnitAbilityLevel(unit, ability)
            DecUnitAbilityLevel(unit, ability)

            return value
        else
            return 0.
        end
    end

    function Armor.onInit()
        BONUS_ARMOR = RegisterBonus(Armor.allocate())
    end
end)