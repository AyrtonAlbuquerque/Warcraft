OnInit("DragonBurst", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "Bonus"

    -- ----------------------------- Dragon Burst v1.3 by Chopinski ---------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY          = S2A('Yul1')
    -- The Model
    local MODEL            = "DragonBurst.mdl"
    -- The model scale
    local SCALE            = 0.75
    -- The knock back model
    local KNOCKBACK_MODEL  = "WindBlow.mdl"
    -- The knock back attachment point
    local ATTACH_POINT     = "origin"

    -- The AOE
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The Center AOE for Knock Up
    local function GetCenterAoE(unit, level)
        return 150. + 0.*level
    end

    -- The Damage dealt
    local function GetDamage(source, level)
        if Bonus then
            return 100. + 50.*level + (0.8 + 0.1*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 100. + 50.*level
        end
    end

    -- The bonus damage taken from the center
    local function GetBonusDamage(source, level)
        return 0.2 + 0.2*level
    end

    -- The Knock Up duration
    local function GetKnockUpDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end
    
    -- The Knock Up height
    local function GetKnockUpHeight(level)
        return 300. + 0.*level
    end

    -- The Knock Back duration
    local function GetKnockBackDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The Damage Filter.
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        DragonBurst = Class(Spell)

        function DragonBurst:onTooltip(source, level, ability)
            return "|cffffcc00Yu'lon|r creates an eruption at the target location, dealing |cff00ffff" .. N2S(GetDamage(source, level), 0) .. " Magic|r damage to all enemy units within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. " AoE|r and |cffffcc00Knocking Back|r. Units at the center of the eruption are |cffffcc00Knocked Up|r for |cffffcc00" .. N2S(GetKnockUpDuration(source, level), 2) .. "|r seconds and take |cffffcc00" .. N2S(GetBonusDamage(source, level)*100, 0) .. "%%|r more damage."
        end

        function DragonBurst:onCast()
            local group = CreateGroup()
            local height = GetKnockUpHeight(Spell.level)
            local aoe = GetAoE(Spell.source.unit, Spell.level)
            local damage = GetDamage(Spell.source.unit, Spell.level)
            local center = GetCenterAoE(Spell.source.unit, Spell.level)
            local bonus = GetBonusDamage(Spell.source.unit, Spell.level)
            
            DestroyEffect(AddSpecialEffectEx(MODEL, Spell.x, Spell.y, 0, SCALE))
            GroupEnumUnitsInRange(group, Spell.x, Spell.y, aoe, nil)

            local u = FirstOfGroup(group)

            while u do
                if DamageFilter(Spell.source.player, u) then
                    local x = GetUnitX(u)
                    local y = GetUnitY(u)
                    local angle = AngleBetweenCoordinates(Spell.x, Spell.y, x, y)
                    local distance = DistanceBetweenCoordinates(Spell.x, Spell.y, x, y)
                    
                    if distance > center then
                        if UnitDamageTarget(Spell.source.unit, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                            KnockbackUnit(u, angle, aoe - distance, GetKnockBackDuration(Spell.source.unit, Spell.level), KNOCKBACK_MODEL, ATTACH_POINT, true, true, false, false)
                        end
                    else
                        if UnitDamageTarget(Spell.source.unit, u, damage * (1 + bonus), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                            KnockupUnit(u, height, GetKnockUpDuration(Spell.source.unit, Spell.level), nil, nil, false)
                        end
                    end
                end

                GroupRemoveUnit(group, u)
                u = FirstOfGroup(group)
            end

            DestroyGroup(group)
        end

        function DragonBurst.onInit()
            RegisterSpell(DragonBurst.allocate(), ABILITY)
        end
    end
end)