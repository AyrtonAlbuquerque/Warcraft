OnInit(function(requires)
    requires "Class"
    requires "Bonus"
    requires.optional "Damage"

    BONUS_DAMAGE_BLOCK = 0

    local Block = Class(Bonus)
    local USE_DAMAGE = true
    local bonus = {}
    local ability = FourCC('Z00F')
    local field = ABILITY_RLF_IGNORED_DAMAGE

    function Block:get(unit)
        if Damage and USE_DAMAGE then
            return bonus[unit] or 0.
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, 0)
        end
    end

    function Block:set(unit, value)
        if Damage and USE_DAMAGE then
            bonus[unit] = value

            return value
        else
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
    end

    function Block:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    function Block.onDamage()
        if Damage then
            if Damage.isAttack and Damage.amount > 0 and (bonus[Damage.target.unit] or 0) > 0 then
                if Damage.amount > (bonus[Damage.target.unit] or 0) then
                    Damage.amount = Damage.amount - (bonus[Damage.target.unit] or 0)
                else
                    Damage.amount = 0
                end
            end
        end
    end

    function Block.onInit()
        BONUS_DAMAGE_BLOCK = RegisterBonus(Block.allocate())

        if Damage and USE_DAMAGE then
            RegisterAnyDamageEvent(Block.onDamage)
        end
    end
end)