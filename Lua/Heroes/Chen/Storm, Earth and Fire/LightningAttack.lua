--[[ requires DamageInterface, Utilities
    /* ------------------- Lightning Attack v1.2 by Chopinski ------------------- */
    // Credits:
    //     CRAZYRUSSIAN    - Icon
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of Lightning Attack ability
    LightningAttack_ABILITY      = FourCC('A009')
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
    local function GetDamage(level)
        return 50.*level
    end

    -- The search range of bouncing lightning
    local function GetAoE(level)
        return 300. + 0.*level
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterAttackDamageEvent(function()
            local level = GetUnitAbilityLevel(Damage.source.unit, LightningAttack_ABILITY)

            if Damage.isEnemy and not Damage.target.isStructure and level > 0 then
                CreateChainLightning(Damage.source.unit, Damage.target.unit, GetDamage(level), GetAoE(level), 0.2, 0.1, GetBounces(level), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, LIGHTNING, IMPACT_MODEL, ATTACH, false)
            end
        end)
    end)
end