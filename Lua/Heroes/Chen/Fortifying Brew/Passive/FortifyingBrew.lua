--[[ requires DamageInterface, SpellEffectEvent, NewBonusUtils, Utilities
    /* -------------------- Fortifying Brew v1.3 by Chopinski ------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Fortifying Brew ability
    local ABILITY   = FourCC('A00E')
    -- The raw code of the Fortifying Brew ability
    local REDUCTION = FourCC('A00F')
    -- The raw code of the Fortifying Brew buff
    local BUFF      = FourCC('B001')

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

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function()
            local unit = GetTriggerUnit()
            local level = GetUnitAbilityLevel(unit, ABILITY)

            if level > 0 then
                local duration = GetDuration(unit, level)

                UnitAddAbilityTimed(unit, REDUCTION, duration, 1, true)
                AddUnitBonusTimed(unit, BONUS_HEALTH_REGEN, GetHealthRegen(level), duration)
                AddUnitBonusTimed(unit, BONUS_MANA_REGEN, GetManaRegen(level), duration)
            end
        end)

        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function()
            local unit = GetTriggerUnit()

            if GetLevel(GetHeroLevel(unit)) then
                IncUnitAbilityLevel(unit, ABILITY)
            end
        end)

        RegisterAttackDamageEvent(function()
            local damage = GetEventDamage()

            if damage > 0 and GetUnitAbilityLevel(Damage.target.unit, BUFF) > 0 then
                BlzSetEventDamage(damage * (1 - GetDamageReduction(GetUnitAbilityLevel(Damage.target.unit, ABILITY))))
            end
        end)
    end)
end