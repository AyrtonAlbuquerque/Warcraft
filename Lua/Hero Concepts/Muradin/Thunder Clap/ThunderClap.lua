--[[ requires SpellEffectEvent, TimedHandles, CrowdControl optional Avatar
    -- -------------------------------------- Thunder Clap v1.4 ------------------------------------- --
    -- Credits:
    --     Blizzard       - Icon
    --     Bribe          - SpellEffectEvent
    --     TriggerHappy   - TimedHandles
    -- ---------------------------------------- By Chipinski ---------------------------------------- --
]]--

do
    -- ---------------------------------------------------------------------------------------------- --
    --                                          Configuration                                         --
    -- ---------------------------------------------------------------------------------------------- --
    -- The raw code of the Thunder Clap ability
    ThunderClap_ABILITY             = FourCC('A003')
    -- The raw code of the Thunder Clap Recast ability
    ThunderClap_THUNDER_CLAP_RECAST = FourCC('A004')
    -- The model used when storm bolt refunds mana on kill
    local HEAL_EFFECT               = "Abilities\\Spells\\Items\\AIhe\\AIheTarget.mdl"
    -- The attachment point of the bonus dmaage model
    local ATTACH_POINT              = "origin"
    -- The slow model
    local SLOW_MODEL                = "Abilities\\Spells\\Orc\\StasisTrap\\StasisTotemTarget.mdl"
    -- The slow model attachment point
    local SLOW_POINT                = "overhead"
    -- The stun model
    local STUN_MODEL                = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
    -- The stun model attachment point
    local STUN_POINT                = "overhead"

    -- The damage dealt
    local function GetDamage(unit, level)
        return 25.*(2*level + 1)
    end

    -- The movement speed slow amount
    local function GetMovementSlowAmount(unit, level)
        return 0.5 + 0*level
    end

    -- The attack speed slow amount
    local function GetAttackSlowAmount(unit, level)
        return 0.5 + 0*level
    end

    -- The duration
    local function GetDuration(source, target, level)
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ThunderClap_ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ThunderClap_ABILITY), ABILITY_RLF_DURATION_NORMAL, level - 1)
        end
    end

    -- The AoE for calculating the heal
    local function GetAoE(unit, level)
        local aoe = BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ThunderClap_ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)

        if Avatar then
            if GetUnitAbilityLevel(unit, Avatar_BUFF) > 0 then
                aoe = aoe * 1.5
            end
        end

        return aoe
    end

    -- The healing amount
    local function GetHealAmount(source, target, level)
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return 0.1
        else
            return 0.025
        end
    end

    -- Filter for units
    local function UnitFilter(player, unit)
        return IsUnitEnemy(unit, player) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- ---------------------------------------------------------------------------------------------- --
    --                                             System                                             --
    -- ---------------------------------------------------------------------------------------------- --
    ThunderClap = setmetatable({}, {})
    local mt = getmetatable(ThunderClap)
    mt.__index = mt
    
    function mt:onCast(source, ability, player, level)
        local damage = GetDamage(source, level)
        local movement = GetMovementSlowAmount(source, level)
        local attack = GetAttackSlowAmount(source, level)
        local aoe = GetAoE(source, level)
        local group = CreateGroup()
        local heal = 0

        GroupEnumUnitsInRange(group, GetUnitX(source), GetUnitY(source), aoe, nil)
        for i = 0, BlzGroupGetSize(group) - 1 do
            local unit = BlzGroupUnitAt(group, i)

            if UnitFilter(player, unit) then
                heal = heal + GetHealAmount(source, unit, level)

                if Avatar then
                    if GetUnitAbilityLevel(source, Avatar_BUFF) > 0 then
                        if ability == ThunderClap_THUNDER_CLAP_RECAST then
                            if UnitDamageTarget(source, unit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                                StunUnit(unit, GetDuration(source, unit, level), STUN_MODEL, STUN_POINT, false)
                            end
                        else
                            if UnitDamageTarget(source, unit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                                SlowUnit(unit, movement, GetDuration(source, unit, level), SLOW_MODEL, SLOW_POINT, false)
                                SlowUnitAttack(unit, attack, GetDuration(source, unit, level), nil, nil, false)
                            end
                        end
                    else
                        if UnitDamageTarget(source, unit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                            SlowUnit(unit, movement, GetDuration(source, unit, level), SLOW_MODEL, SLOW_POINT, false)
                            SlowUnitAttack(unit, attack, GetDuration(source, unit, level), nil, nil, false)
                        end
                    end
                else
                    if UnitDamageTarget(source, unit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        SlowUnit(unit, movement, GetDuration(source, unit, level), SLOW_MODEL, SLOW_POINT, false)
                        SlowUnitAttack(unit, attack, GetDuration(source, unit, level), nil, nil, false)
                    end
                end
            end
        end
        DestroyGroup(group)

        if heal > 0 then
            SetWidgetLife(source, GetWidgetLife(source) + (BlzGetUnitMaxHP(source)*heal))
            DestroyEffectTimed(AddSpecialEffectTarget(HEAL_EFFECT, source, ATTACH_POINT), 1.0)
        end
    end
    
    onInit(function()
        RegisterSpellEffectEvent(ThunderClap_ABILITY, function()
            ThunderClap:onCast(Spell.source.unit, Spell.id, Spell.source.player, Spell.level)
        end)
        
        RegisterSpellEffectEvent(ThunderClap_THUNDER_CLAP_RECAST, function()
            ThunderClap:onCast(Spell.source.unit, Spell.id, Spell.source.player, Spell.level)
        end)
    end)
end