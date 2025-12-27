OnInit("FortifyingBrew", function(requires)
    requires "Class"
    requires "Bonus"
    requires "Spell"
    requires "Damage"
    requires "Utilities"

    -- --------------------------- Fortifying Brew v1.4 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Fortifying Brew ability
    local ABILITY   = S2A('Chn0')
    -- The raw code of the Fortifying Brew ability
    local REDUCTION = S2A('Chn1')
    -- The raw code of the Fortifying Brew buff
    local BUFF      = S2A('BCh0')

    -- The Fortifying Brew health/mana regen bonus duration per cast
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The Fortifying Brew health regen bonus
    local function GetHealthRegen(level)
        return 2.*level
    end

    -- The Fortifying Brew mana regen bonus
    local function GetManaRegen(level)
        return 1.*level
    end

    -- The Fortifying Brew damage reduction
    local function GetDamageReduction(level)
        return 0.075 + 0.025*level
    end

    -- The Fortifying Brew level up base on hero level
    local function GetLevel(level)
        return level == 5 or level == 10 or level == 15 or level == 20
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        FortifyingBrew = Class(Spell)

        function FortifyingBrew:onTooltip(unit, level, ability)
            return "Whenever |cffffcc00Chen|r uses an ability he drinks from his keg, increasing his |cff00ff00Health Regeneration|r by |cff00ff00" .. N2S(GetHealthRegen(level), 1) .. "|r, |cff00ffffMana Regeneration|r by |cff00ffff" .. N2S(GetManaRegen(level), 1) .. "|r and takes |cffffcc00" .. N2S(GetDamageReduction(level) * 100, 1) .. "%|r reduced damage from auto attacks for |cffffcc00" .. N2S(GetDuration(unit, level), 1) .. "|r seconds. Regeneration stacks with each cast."
        end

        function FortifyingBrew.onSpell()
            local source = GetTriggerUnit()
            local level = GetUnitAbilityLevel(source, ABILITY)

            if level > 0 then
                local duration = GetDuration(source, level)

                UnitAddAbilityTimed(source, REDUCTION, duration, 1, true)
                AddUnitBonusTimed(source, BONUS_MANA_REGEN, GetManaRegen(level), duration)
                AddUnitBonusTimed(source, BONUS_HEALTH_REGEN, GetHealthRegen(level), duration)
            end
        end

        function FortifyingBrew.onLevel()
            local source = GetTriggerUnit()

            if GetLevel(GetHeroLevel(source)) then
                IncUnitAbilityLevel(source, ABILITY)
            end
        end

        function FortifyingBrew.onDamage()
            if Damage.amount > 0 and GetUnitAbilityLevel(Damage.target.unit, BUFF) > 0 then
                Damage.amount = Damage.amount * (1 - GetDamageReduction(GetUnitAbilityLevel(Damage.target.unit, ABILITY)))
            end
        end

        function FortifyingBrew.onInit()
            RegisterSpell(FortifyingBrew.allocate(), ABILITY)
            RegisterAttackDamageEvent(FortifyingBrew.onDamage)
            RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, FortifyingBrew.onLevel)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, FortifyingBrew.onSpell)
        end
    end
end)