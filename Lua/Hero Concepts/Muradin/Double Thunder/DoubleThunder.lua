--[[ requires RegisterPlayerUnitEvent, optional StormBolt, optional ThunderClap, optional Avatar
    -- ------------------------------------- Double Thunder v1.3 ------------------------------------ --
    -- Credits:
    --     Magtheridon96  - RegisterPlayerUnitEvent
    --     Blizzard       - Icon
    -- ---------------------------------------- By Chipinski ---------------------------------------- --
]]--

do
    -- ---------------------------------------------------------------------------------------------- --
    --                                          Configuration                                         --
    -- ---------------------------------------------------------------------------------------------- --
    -- The raw code of the Double Thunder ability
    local ABILITY = FourCC('A000')

    -- This updates the double thunder level at levels 10, 15 and 20
    local function GetLevel(level)
        if level < 10 then
            return 1
        elseif level >= 10 and level < 15 then
            return 2
        elseif level >= 15 and level < 20 then
            return 3
        else
            return 4
        end
    end

    -- The chance to proc double thunder
    local function GetDoubleChance(unit, level)
        if Avatar then
            if GetUnitAbilityLevel(unit, Avatar_BUFF) > 0 then
                return 100
            else
                return 25 * level
            end
        else
            return 25 * level
        end
    end

    -- ---------------------------------------------------------------------------------------------- --
    --                                             System                                             --
    -- ---------------------------------------------------------------------------------------------- --
    onInit(function()
        local trigger = CreateTrigger()
        TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddAction(trigger, function()
            local source = GetTriggerUnit()
            local target = GetSpellTargetUnit()
            local ability = GetSpellAbilityId()
            local level = GetUnitAbilityLevel(source, ABILITY)
            local chance = GetDoubleChance(source, level)
        
            if StormBolt then
                if ability == StormBolt_ABILITY then
                    if GetRandomInt(1, 100) <= chance then
                        UnitAddAbility(source,  StormBolt_STORM_BOLT_RECAST)
                        TriggerSleepAction(0.10)
                        IssueTargetOrder(source, "creepthunderbolt", target)
                        TriggerSleepAction(0.50)
                        UnitRemoveAbility(source, StormBolt_STORM_BOLT_RECAST)
                    end
                end
            end

            if ThunderClap then
                if ability == ThunderClap_ABILITY then
                    if GetRandomInt(1, 100) <= chance then
                        UnitAddAbility(source, ThunderClap_THUNDER_CLAP_RECAST)
                        SetUnitAbilityLevel(source, ThunderClap_THUNDER_CLAP_RECAST, GetUnitAbilityLevel(source, ThunderClap_ABILITY))
                        IssueImmediateOrder(source, "creepthunderclap")
                        TriggerSleepAction(0.50)
                        UnitRemoveAbility(source, ThunderClap_THUNDER_CLAP_RECAST)
                    end
                end
            end
        end)

        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function()
            local unit = GetTriggerUnit()
        
            if GetUnitAbilityLevel(unit, ABILITY) > 0 then
                SetUnitAbilityLevel(unit, ABILITY, GetLevel(GetHeroLevel(unit)))
            end
        end)
    end)
end