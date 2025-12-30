OnInit("Bash", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"
    requires "Utilities"
    requires "CrowdControl"

    -- --------------------------------------- Bash v1.2 --------------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the bash ability
    local ABILITY = S2A('Mrd3')
    -- The stun model
    local MODEL   = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
    -- The stun model attachment point
    local POINT   = "overhead"

    -- The damage dealt
    local function GetDamage(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DAMAGE_BONUS_HBH3, level - 1) + 0.25 * GetUnitBonus(source, BONUS_SPELL_POWER)
    end

    -- The Attack Speed bonus
    local function GetBonusAttackSpeed(source, level)
        if level == 1 then
            return 0.15
        else
            return 0.05 + 0.*level
        end
    end

    -- The proc chance
    local function GetChance(unit, level)
        return 0.1 + 0.05*level
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

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Bash = Class(Spell)

        function Bash:onTooltip(source, level, ability)
            return "Gives a |cffffcc00" .. N2S(GetChance(source, level), 0) .. "%%|r chance that an attack will do |cff00ffff" .. N2S(GetDamage(source, level), 0) .. "|r bonus |cff00ffffMagic|r damage and stun an opponent for |cffffcc001|r (|cffffcc000.5|r for |cffffcc00Heroes|r) second. Additionally Muradin gains |cffffcc00" .. N2S(GetBonusAttackSpeed(source, level) * 100, 0) .. "%% Attack Speed|r"
        end

        function Bash:onLearn(source, skill, level)
            AddUnitBonus(source, BONUS_ATTACK_SPEED, GetBonusAttackSpeed(source, level))
        end

        function Bash.onDamage()
            local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if level > 0 then
                if UnitFilter(Damage.source.player, Damage.target.unit) then
                    if GetRandomReal(0, 1) <= GetChance(Damage.source.unit, level) then
                        if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(Damage.source.unit, level), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                            StunUnit(Damage.target.unit, GetDuration(Damage.source.unit, Damage.target.unit, level), MODEL, POINT, false)
                        end
                    end
                end
            end
        end

        function Bash.onInit()
            RegisterSpell(Bash.allocate(), ABILITY)
            RegisterAttackDamageEvent(Bash.onDamage)
        end
    end
end)