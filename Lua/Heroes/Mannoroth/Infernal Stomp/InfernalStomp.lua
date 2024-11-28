--[[ requires SpellEffectEvent, PluginSpellEffect, CrowdControl
    -- ------------------------------------- Infernal Stomp v1.0 ------------------------------------ --
    -- Credits:
    --     Bribe         - SpellEffectEvent
    -- ---------------------------------------- By Chopinksi ---------------------------------------- --
]]--

do
    -- ---------------------------------------------------------------------------------------------- --
    --                                          Configuration                                         --
    -- ---------------------------------------------------------------------------------------------- --
    -- The raw code of the Infernal Stomp ability
    local ABILITY = FourCC('A00D')
    -- The stun model
    local MODEL   = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
    -- The stun model attach point
    local POINT   = "overhead"

    -- The damage dealt
    local function GetDamage(level)
        return 200. + 0.*level
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

    -- ---------------------------------------------------------------------------------------------- --
    --                                             System                                             --
    -- ---------------------------------------------------------------------------------------------- --
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local group = CreateGroup()
            local source = Spell.source.unit
            local player = Spell.source.player
            local duration = GetDuration(Spell.source.unit, Spell.level)
            local aoe = GetAoE(Spell.source.unit, Spell.level)
            local damage = GetDamage(Spell.level)

            GroupEnumUnitsInRange(group, Spell.source.x, Spell.source.y, aoe, nil)
            for i = 0, BlzGroupGetSize(group) - 1 do
                local unit = BlzGroupUnitAt(group, i)
                if UnitFilter(player, unit) then
                    if UnitDamageTarget(source, unit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        StunUnit(unit, duration, MODEL, POINT, false)
                    end
                end
            end
            DestroyGroup(group)
        end)
    end)
end
