OnInit("HammerTime", function (requires)
    requires "Class"
    requires "Spell"
    requires "Damage"
    requires "Utilities"
    requires.optional "Avatar"
    requires.optional "StormBolt"
    requires.optional "ThunderClap"

    -- ------------------------------ HammerTime v1.3 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Hammer Time ability
    local ABILITY       = S2A('Mrd7')
    -- The raw code of the Muradin unit in the editor
    local MURADIN_ID    = S2A('Mrdn')
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

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        HammerTime = Class(Spell)

        function HammerTime:onTooltip(source, level, ability)
            return "|cffffcc00Muradin|r basic attacks against enemy units reduce the cooldown of |cffffcc00Storm Bolt|r by |cffffcc00" .. N2S(GetStormBoltCooldown(level), 1) .. "|r seconds and |cffffcc00Thunder Clap|r by |cffffcc00" .. N2S(GetThunderClapCooldown(level), 1) .. "|r seconds and |cffffcc00Avatar|r cooldown by |cffffcc00" .. N2S(GetAvatarCooldown(level), 1) .. "|r second."
        end

        function HammerTime.onLevelUp()
            local unit = GetTriggerUnit()
        
            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(unit) == MURADIN_ID and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                    UnitAddAbility(unit, ABILITY)
                    UnitMakeAbilityPermanent(unit, true, ABILITY)
                end
            end
        end

        function HammerTime.onDamage()
            local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)
            local cooldown
            local reduction

            if level > 0 and Damage.isEnemy then
                if StormBolt then
                    cooldown  = BlzGetUnitAbilityCooldownRemaining(Damage.source.unit, StormBolt_ABILITY)
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
                    cooldown  = BlzGetUnitAbilityCooldownRemaining(Damage.source.unit, ThunderClap_ABILITY)
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
                    cooldown  = BlzGetUnitAbilityCooldownRemaining(Damage.source.unit, Avatar_ABILITY)
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
        end

        function HammerTime.onInit()
            RegisterSpell(HammerTime.allocate(), ABILITY)
            RegisterAttackDamageEvent(HammerTime.onDamage)
            RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, HammerTime.onLevelUp)
        end
    end
end)