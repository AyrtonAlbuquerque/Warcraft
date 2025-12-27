OnInit("LightningAttack", function(requires)
    requires "Class"
    requires "Spell"
    requires "Damage"
    requires "Utilities"
    requires.optional "Bonus"

    -- --------------------------- Lightning Attack v1.3 by Chopinski -------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of Lightning Attack ability
    LightningAttack_ABILITY      = S2A('ChnD')
    -- The Lightning Attack lightning model
    local LIGHTNING              = "CLSB"
    -- The Lightning Attack damage model
    local IMPACT_MODEL           = "Abilities\\Weapons\\Bolt\\BoltImpact.mdl"
    -- The Lightning Attack damage model attach point
    local ATTACH                 = "origin"

    -- The number of bounces
    local function GetBounces(level)
        return 3 + 0*level
    end

    -- The damage per bounce
    local function GetDamage(source, level)
        if Bonus then
            return 150. * level + (0.2 * level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 150. * level
        end
    end

    -- The search range of bouncing lightning
    local function GetAoE(level)
        return 300. + 0.*level
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        LightningAttack = Class(Spell)

        function LightningAttack.onTooltip(unit, level, ability)
            return "|cffffcc00Storm|r attacks creates a |cffffcc00Chain Lightning|r, bouncing up to |cffffcc00" .. N2S(GetBounces(level), 0) .. "|r targets and dealing |cff00ffff" .. N2S(GetDamage(unit, level), 0) .. "|r |cff00ffffMagic|r damage to each."
        end

        function LightningAttack.onDamage()
            local level = GetUnitAbilityLevel(Damage.source.unit, LightningAttack_ABILITY)

            if Damage.isEnemy and not Damage.target.isStructure and level > 0 then
                CreateChainLightning(Damage.source.unit, Damage.target.unit, GetDamage(Damage.source.unit, level), GetAoE(level), 0.2, 0.1, GetBounces(level), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, LIGHTNING, IMPACT_MODEL, ATTACH, false)
            end
        end

        function LightningAttack.onInit()
            RegisterSpell(LightningAttack.allocate(), LightningAttack_ABILITY)
            RegisterAttackDamageEvent(LightningAttack.onDamage)
        end
    end
end)