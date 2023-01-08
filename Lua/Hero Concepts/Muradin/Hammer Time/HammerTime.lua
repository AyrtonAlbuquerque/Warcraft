--[[ requires DamageInterface, optional StormBolt, optional ThunderClap, optional Avatar
    /* ---------------------- HammerTime v1.3 by Chopinski ---------------------- */
    // Credits:
    //     Blizzard       - Icon
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Hammer Time ability
    local ABILITY       = FourCC('A009')
    -- The raw code of the Muradin unit in the editor
    local MURADIN_ID    = FourCC('H000')
    -- The GAIN_AT_LEVEL is greater than 0
    -- Muradin will gain Hammer Time at this level 
    local GAIN_AT_LEVEL = 20

    -- The cooldown reduced for the storm bolt ability
    local function GetStormBoltCooldown(level)
        return 0.5 + 0.*level
    end

    -- The cooldown reduced for the thunder clap ability
    local function GetThunderClapCooldown(level)
        return 0.5 + 0.*level
    end

    -- The cooldown reduced for the Avatar ability
    local function GetAvatarCooldown(level)
        return 1. + 0.*level
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function()
            if GAIN_AT_LEVEL > 0 then
                local unit = GetTriggerUnit()
                if GetUnitTypeId(unit) == MURADIN_ID and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                    UnitAddAbility(unit, ABILITY)
                    UnitMakeAbilityPermanent(unit, true, ABILITY)
                end
            end
        end)
        
        RegisterAttackDamageEvent(function()
            local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)
            local cooldown
            local reduction

            if level > 0 and Damage.isEnemy then
                if StormBolt then
                    cooldown = BlzGetUnitAbilityCooldownRemaining(Damage.source.unit, StormBolt_ABILITY)
                    reduction = GetStormBoltCooldown(level)
                    if cooldown > 0 then
                        if cooldown - reduction <= 0 then
                            ResetUnitAbilityCooldown(Damage.source.unit, StormBolt_ABILITY)
                        else
                            BlzStartUnitAbilityCooldown(Damage.source.unit, StormBolt_ABILITY, cooldown - reduction)
                        end
                    end
                end

                if ThunderClap then
                    cooldown = BlzGetUnitAbilityCooldownRemaining(Damage.source.unit, ThunderClap_ABILITY)
                    reduction = GetThunderClapCooldown(level)
                    if cooldown > 0 then
                        if cooldown - reduction <= 0 then
                            ResetUnitAbilityCooldown(Damage.source.unit, ThunderClap_ABILITY)
                        else
                            BlzStartUnitAbilityCooldown(Damage.source.unit, ThunderClap_ABILITY, cooldown - reduction)
                        end
                    end
                end

                if Avatar then
                    cooldown = BlzGetUnitAbilityCooldownRemaining(Damage.source.unit, Avatar_ABILITY)
                    reduction = GetAvatarCooldown(level)
                    if cooldown > 0 then
                        if cooldown - reduction <= 0 then
                            ResetUnitAbilityCooldown(Damage.source.unit, Avatar_ABILITY)
                        else
                            BlzStartUnitAbilityCooldown(Damage.source.unit, Avatar_ABILITY, cooldown - reduction)
                        end
                    end
                end
            end
        end)
    end)
end