OnInit("ThunderClap", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires "CrowdControl"
    requires "TimedHandles"
    requires.optional "Bonus"
    requires.optional "Avatar"
    requires.optional "StormBolt"

    -- ----------------------------------- Thunder Clap v1.6 ----------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Thunder Clap ability
    ThunderClap_ABILITY             = S2A('Mrd2')
    -- The raw code of the Thunder Clap Recast ability
    ThunderClap_THUNDER_CLAP_RECAST = S2A('Mrd6')
    -- The model used when storm bolt refunds mana on kill
    local HEAL_EFFECT               = "Abilities\\Spells\\Items\\AIhe\\AIheTarget.mdl"
    -- The attachment point of the bonus damage model
    local ATTACH_POINT              = "origin"
    -- The slow model
    local SLOW_MODEL                = "Abilities\\Spells\\Orc\\StasisTrap\\StasisTotemTarget.mdl"
    -- The slow model attachment point
    local SLOW_POINT                = "overhead"
    -- The stun model
    local STUN_MODEL                = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
    -- The stun model attachment point
    local STUN_POINT                = "overhead"
    -- Use Storm Bolt v3
    local STORM_BOLT_V3             = true

    -- The damage dealt
    local function GetDamage(source, level)
        if Bonus then
            return 75.*level + (0.6 + 0.1*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 75.*level
        end
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

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        ThunderClap = Class(Spell)

        function ThunderClap:onTooltip(source, level, ability)
            return "|cffffcc00Muradin|r slams the ground, dealing |cff00ffff" .. N2S(GetDamage(source, level), 0) .. "|r |cff00ffffMagic|r damage and slowing the movement speed and attack rate of nearby enemy units within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. " AoE|r by |cffffcc00" .. N2S(GetAttackSlowAmount(source, level) * 100, 0) .. "%%|r. In addition, |cffffcc00Muradin|r gets healed by |cffffcc002.5%|r (|cffffcc0010%|r for |cffffcc00Heroes|r) of his maximum health for every unit hit by |cffffcc00Thunder Clap|r. If |cffffcc00Avatar|r is active, |cffffcc00Thunder Clap|r AoE is increased by |cffffcc0050%|r and the second |cffffcc00Thunder Clap|r stuns enemy units instead."
        end

        function ThunderClap:onCast()
            local id = Spell.id
            local source = Spell.source.unit
            local owner = Spell.source.player
            local level = GetUnitAbilityLevel(Spell.source.unit, ThunderClap_ABILITY)
            local damage = GetDamage(Spell.source.unit, level)
            local movement = GetMovementSlowAmount(Spell.source.unit, level)
            local attack = GetAttackSlowAmount(Spell.source.unit, level)
            local aoe = GetAoE(Spell.source.unit, level)
            local group = CreateGroup()
            local heal = 0
    
            GroupEnumUnitsInRange(group, Spell.source.x, Spell.source.y, aoe, nil)

            local u = FirstOfGroup(group)

            while u do
                if UnitFilter(owner, u) then
                    if Avatar then
                        if GetUnitAbilityLevel(source, Avatar_BUFF) > 0 then
                            if id == ThunderClap_THUNDER_CLAP_RECAST then
                                if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                                    heal = heal + GetHealAmount(source, u, level)

                                    StunUnit(u, GetDuration(source, u, level), STUN_MODEL, STUN_POINT, false)
                                end
                            else
                                if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                                    heal = heal + GetHealAmount(source, u, level)

                                    SlowUnit(u, movement, GetDuration(source, u, level), SLOW_MODEL, SLOW_POINT, false)
                                    SlowUnitAttack(u, attack, GetDuration(source, u, level), nil, nil, false)
                                end
                            end
                        else
                            if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                                heal = heal + GetHealAmount(source, u, level)

                                SlowUnit(u, movement, GetDuration(source, u, level), SLOW_MODEL, SLOW_POINT, false)
                                SlowUnitAttack(u, attack, GetDuration(source, u, level), nil, nil, false)
                            end
                        end
                    else
                        if UnitDamageTarget(source, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                            heal = heal + GetHealAmount(source, u, level)

                            SlowUnit(u, movement, GetDuration(source, u, level), SLOW_MODEL, SLOW_POINT, false)
                            SlowUnitAttack(u, attack, GetDuration(source, u, level), nil, nil, false)
                        end
                    end
                end

                GroupRemoveUnit(group, u)
                u = FirstOfGroup(group)
            end

            DestroyGroup(group)

            if heal > 0 then
                SetWidgetLife(source, GetWidgetLife(source) + (BlzGetUnitMaxHP(source)*heal))
                DestroyEffectTimed(AddSpecialEffectTarget(HEAL_EFFECT, source, ATTACH_POINT), 1.0)
            end
            
            if StormBolt and STORM_BOLT_V3 then
                StormBolt.lightning(source, damage, aoe)
            end
        end

        function ThunderClap.onInit()
            RegisterSpell(ThunderClap.allocate(), ThunderClap_ABILITY)
            RegisterSpell(ThunderClap.allocate(), ThunderClap_THUNDER_CLAP_RECAST)
        end
    end
end)