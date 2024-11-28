--[[ requires DamageInterface, CrowdControl
    -- ------------------------------------------ Bash v1.0 ----------------------------------------- --
    -- Credits:
    --     PrinceYaser - Icon
    -- ---------------------------------------- By Chipinski ---------------------------------------- --
]]--

do
    -- ---------------------------------------------------------------------------------------------- --
    --                                          Configuration                                         --
    -- ---------------------------------------------------------------------------------------------- --
    -- The raw code of the bash ability
    local ABILITY = FourCC('A006')
    -- The stun model
    local MODEL   = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
    -- The stun model attachment point
    local POINT   = "overhead"

    -- The damage dealt
    local function GetDamage(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DAMAGE_BONUS_HBH3, level - 1)
    end

    -- The proc chance
    local function GetChance(unit, level)
        return 10. + 5*level
    end

    -- The duration
    local function GetDuration(source, target, level)
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_NORMAL, level - 1)
        end
    end

    -- Filter for units
    local function UnitFilter(player, unit)
        return IsUnitEnemy(unit, player) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- ---------------------------------------------------------------------------------------------- --
    --                                             System                                             --
    -- ---------------------------------------------------------------------------------------------- --
    onInit(function()
        RegisterAttackDamageEvent(function()
            local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if level > 0 then
                if UnitFilter(Damage.source.player, Damage.target.unit) then
                    if GetRandomReal(0, 100) <= GetChance(Damage.source.unit, level) then
                        if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(Damage.source.unit, level), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                            StunUnit(Damage.target.unit, GetDuration(Damage.source.unit, Damage.target.unit, level), MODEL, POINT, false)
                        end
                    end
                end
            end
        end)
    end)
end