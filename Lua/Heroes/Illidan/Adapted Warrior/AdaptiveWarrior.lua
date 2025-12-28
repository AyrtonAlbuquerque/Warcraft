OnInit("AdaptedWarrior", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"
    requires "Evasion"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- --------------------------- Adapted Warrior v1.3 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Adapted Warrior ability
    local ABILITY       = S2A('Idn0')
    -- The Mana Burn model
    local MODEL         = "Abilities\\Spells\\Human\\Feedback\\SpellBreakerAttack.mdl"
    -- The Mana Burn bonus model
    local BONUS_MODEL   = "ManaBurn.mdl"
    -- The Mana Burn attachment point
    local ATTACH_POINT  = "origin"

    -- The Attack Speed bonus amount
    local function GetAttackSpeedBonus(level)
        return 0.05 + 0.*level
    end

    -- The Attack Speed bonus duration
    local function GetAttackSpeedDuration(level)
        return 10. + 0.*level
    end

    -- The Movement Speed bonus amount
    local function GetMovementSpeedBonus(level)
        return 5 + 0*level
    end

    -- The Movement Speed bonus duration
    local function GetMovementSpeedDuration(level)
        return 10. + 0.*level
    end

    -- The amount of mana burned in each attack
    local function GetManaBurned(level)
        return 10.*level
    end

    -- The mana percentage for bonus damage
    local function GetManaPercent(level)
        return 40. + 0.*level
    end

    -- The Auto Level up
    local function GetLevel(level)
        return level == 5 or level == 10 or level == 15 or level == 20
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        AdaptedWarrior = Class(Spell)

        function AdaptedWarrior:onTooltip(unit, level, ability)
            return "When |cffffcc00Illidan|r evades an attack, his |cffffcc00Attack Speed|r is increased by |cffffcc00" .. N2S(GetAttackSpeedBonus(level), 0) .. "%%|r and |cffffcc00Movement Speed|r is increased by |cffffcc00" .. N2S(GetMovementSpeedBonus(level), 0) .. "|r for |cffffcc00" .. N2S(GetMovementSpeedDuration(level), 0) .. "|r seconds. Additionally |cffffcc00Illidan|r attacks destroy |cff00ffff" .. N2S(GetManaBurned(level), 0) .. " Mana|r per hit. The mana combusts, dealing |cff00ffffMagic|r damage to the attacked unit. If the attacked unit mana is below |cffffcc00" .. N2S(GetManaPercent(level), 0) .. "%%|r, the combusted mana deals |cffd45e19Pure|r damage instead."
        end

        function AdaptedWarrior.onEvade()
            local source = GetMissingUnit()
            local target = GetEvadingUnit()
            local level = GetUnitAbilityLevel(target, ABILITY)
            local enemy = IsUnitEnemy(target, GetOwningPlayer(source))
        
            if level > 0 and enemy then
                AddUnitBonusTimed(target, BONUS_ATTACK_SPEED, GetAttackSpeedBonus(level), GetAttackSpeedDuration(level))
                AddUnitBonusTimed(target, BONUS_MOVEMENT_SPEED, GetMovementSpeedBonus(level), GetMovementSpeedDuration(level))
            end
        end

        function AdaptedWarrior.onDamage()
            local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if Damage.isEnemy and not Damage.target.isMagicImmune and level > 0 and BlzGetUnitMaxMana(Damage.target.unit) > 0 then
                local burn = GetManaBurned(level)

                AddUnitMana(Damage.target.unit, -burn)

                if GetUnitManaPercent(Damage.target.unit) < GetManaPercent(level) then
                    DestroyEffect(AddSpecialEffectTarget(BONUS_MODEL, Damage.target.unit, ATTACH_POINT))
                    UnitDamageTarget(Damage.source.unit, Damage.target.unit, burn, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, nil)
                else
                    DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.target.unit, ATTACH_POINT))
                    UnitDamageTarget(Damage.source.unit, Damage.target.unit, burn, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                end
            end
        end

        function AdaptedWarrior.onLevel()
            local source = GetTriggerUnit()

            if GetLevel(GetHeroLevel(source)) then
                IncUnitAbilityLevel(source, ABILITY)
            end
        end

        function AdaptedWarrior.onInit()
            RegisterSpell(AdaptedWarrior.allocate(), ABILITY)
            RegisterEvasionEvent(AdaptedWarrior.onEvade)
            RegisterAttackDamageEvent(AdaptedWarrior.onDamage)
            RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, AdaptedWarrior.onLevel)
        end
    end
end)