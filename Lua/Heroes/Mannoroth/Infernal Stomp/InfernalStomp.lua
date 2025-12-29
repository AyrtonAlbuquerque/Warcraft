OnInit("InfernalStomp", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "Bonus"

    -- ---------------------------------- Infernal Stomp v1.1 ---------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Infernal Stomp ability
    local ABILITY = S2A('Mnr9')
    -- The stun model
    local MODEL   = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
    -- The stun model attach point
    local POINT   = "overhead"

    -- The damage dealt
    local function GetDamage(source, level)
        if Bonus then
            return 200. + 0. * level + 1. * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 200. + 0. * level
        end
    end

    -- The stun duration
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The stomp aoe
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The unit filter
    local function UnitFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        InfernalStomp = Class(Spell)

        function InfernalStomp:onTooltip(source, level, ability)
            return "Slams the ground, dealing |cff00ffff" .. N2S(GetDamage(source, level), 0) .. "|r |cff00ffffMagic|r damage to nearby enemy land units and stunning them for |cffffcc00" .. N2S(GetDuration(source, level), 0) .. "|r second."
        end

        function InfernalStomp:onCast()
            local group = CreateGroup()
            local source = Spell.source.unit
            local owner = Spell.source.player
            local aoe = GetAoE(Spell.source.unit, Spell.level)
            local duration = GetDuration(Spell.source.unit, Spell.level)
            local damage = GetDamage(Spell.source.unit, Spell.level)

            GroupEnumUnitsInRange(group, Spell.source.x, Spell.source.y, aoe, nil)

            local u = FirstOfGroup(group)

            while u do
                if UnitFilter(owner, u) then
                    if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        StunUnit(u, duration, MODEL, POINT, false)
                    end
                end

                GroupRemoveUnit(group, u)
                u = FirstOfGroup(group)
            end

            DestroyGroup(group)
        end

        function InfernalStomp.onInit()
            RegisterSpell(InfernalStomp.allocate(), ABILITY)
        end
    end
end)
