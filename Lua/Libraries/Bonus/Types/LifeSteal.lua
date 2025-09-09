OnInit(function(requires)
    requires "Class"
    requires "Bonus"
    requires.optional "Damage"

    BONUS_LIFE_STEAL = 0

    local LifeSteal = Class(Bonus)
    local USE_DAMAGE = true
    local steal = {}
    local ability = FourCC('Z00E')
    local field = ABILITY_RLF_LIFE_STOLEN_PER_ATTACK
    local effect = "Abilities\\Spells\\Undead\\VampiricAura\\VampiricAuraTarget.mdl"

    function LifeSteal:get(unit)
        if Damage and USE_DAMAGE then
            return steal[unit] or 0.
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, 0)
        end
    end

    function LifeSteal:set(unit, value)
        if Damage and USE_DAMAGE then
            steal[unit] = value

            return value
        else
            if value == 0 then
                UnitRemoveAbility(unit, ability)
                return 0.
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
    end

    function LifeSteal:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    function LifeSteal.onDamage()
        if Damage then
            if Damage.amount > 0 and Damage.isAttack and (steal[Damage.source.unit] or 0) > 0 and not Damage.target.isStructure then
                SetWidgetLife(Damage.source.unit, (GetWidgetLife(Damage.source.unit) + (Damage.amount * (steal[Damage.source.unit] or 0))))
                DestroyEffect(AddSpecialEffectTarget(effect, Damage.source.unit, "origin"))
            end
        end
    end

    function LifeSteal.onInit()
        BONUS_LIFE_STEAL = RegisterBonus(LifeSteal.allocate())

        if Damage and USE_DAMAGE then
            RegisterAnyDamageEvent(LifeSteal.onDamage)
        end
    end
end)