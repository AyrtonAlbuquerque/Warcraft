OnInit(function(requires)
    requires "Class"
    requires "Bonus"

    local AttackSpeed = Class(Bonus)
    local ability = FourCC('Z008')
    local field = ABILITY_RLF_ATTACK_SPEED_INCREASE_ISX1

    function AttackSpeed:get(unit)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, 0)
    end

    function AttackSpeed:set(unit, value)
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

    function AttackSpeed:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    BONUS_ATTACK_SPEED = RegisterBonus(AttackSpeed.allocate())
end)