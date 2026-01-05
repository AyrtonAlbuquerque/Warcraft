OnInit("DragonScale", function (requires)
    requires "Class"
    requires "Spell"
    requires "Damage"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"
    requires.optional "Bonus"

    -- ----------------------------- Dragon Scale v1.3 by Chopinski ---------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY        = S2A('Yul0')
    -- The model
    local MODEL          = "GreenFlare.mdl"
    -- The attachment point
    local ATTACH_POINT   = "origin"

    -- The maximum bonus damage per level
    local function GetBonus(source, level)
        if Bonus then
            return 25.*level + (0.05 * level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 25.*level
        end
    end

    -- The damage reduction per level
    local function GetDamageReduction(level)
        return 0.2 + 0.*level
    end

    -- The Dragon Scale level up base on hero level
    local function GetLevel(level)
        return level == 5 or level == 10 or level == 15
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        DragonScale = Class(Spell)

        local energy = {}

        function DragonScale:onTooltip(source, level, ability)
            return "|cffffcc00Yu'lon|r dragon scales reduced all damage taken by |cffffcc00" .. N2S(GetDamageReduction(level) * 100, 0) .. "%%|r. All damage reduced is stored as |cff00ffffMagic|r energy. Whenever |cffffcc00Yu'lon|r deals |cff00ffffMagic|r damage, a portion of the energy stored is used to increase the damage dealt. Maximum |cff00ffff" .. N2S(GetBonus(source, level), 0) .. " Magic|r damage bonus per damage instance.\n\nEnergy Stored: |cff00ffff" .. N2S(energy[GetUnitUserData(source)], 0) .. "|r"
        end

        function DragonScale.onSpellDamage()
            local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if Damage.amount > 0 and level > 0 and Damage.isEnemy and (energy[Damage.source.unit] or 0) > 0 then
                local amount = GetBonus(Damage.source.unit, level)
                
                if amount >= energy[Damage.source.unit] then
                    amount = energy[Damage.source.unit]
                end
                
                Damage.amount = Damage.amount + amount
                energy[Damage.source.unit] = energy[Damage.source.unit] - amount
                
                DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.target.unit, ATTACH_POINT))
            end
        end

        function DragonScale.onDamage()
            local level = GetUnitAbilityLevel(Damage.target.unit, ABILITY)

            if Damage.amount > 0 and level > 0 and Damage.isEnemy then
                local amount = Damage.amount * GetDamageReduction(level)

                Damage.amount = Damage.amount - amount
                energy[Damage.target.unit] = (energy[Damage.target.unit] or 0) + amount
            end
        end

        function DragonScale.onLevel()
            local source = GetTriggerUnit()

            if GetLevel(GetHeroLevel(source)) then
                IncUnitAbilityLevel(source, ABILITY)
            end
        end

        function DragonScale.onInit()
            RegisterSpell(DragonScale.allocate(), ABILITY)
            RegisterAnyDamageEvent(DragonScale.onDamage)
            RegisterSpellDamageEvent(DragonScale.onSpellDamage)
            RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, DragonScale.onLevel)
        end
    end
end)
