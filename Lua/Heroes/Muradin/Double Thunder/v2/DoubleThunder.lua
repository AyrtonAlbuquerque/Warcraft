OnInit("DoubleThunder", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"
    requires.optional "Avatar"
    requires.optional "StormBolt"
    requires.optional "ThunderClap"

    -- ---------------------------------- Double Thunder v1.6 ---------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Double Thunder ability
    local ABILITY           = S2A('Mrd0')
    -- Enable or disable double storm bolt (use to control behavior in versions v1, v2 ans v3)
    local DOUBLE_STORM_BOLT = false

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

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        DoubleThunder = Class(Spell)

        function DoubleThunder.onLevel()
            local source = GetTriggerUnit()
        
            if GetUnitAbilityLevel(source, ABILITY) > 0 then
                SetUnitAbilityLevel(source, ABILITY, GetLevel(GetHeroLevel(source)))
            end
        end

        function DoubleThunder.onSpell()
            local source = GetTriggerUnit()
            local skill = GetSpellAbilityId()
        
            if StormBolt and DOUBLE_STORM_BOLT then
                if skill == StormBolt_ABILITY then
                    if GetRandomInt(1, 100) <= GetDoubleChance(source, GetUnitAbilityLevel(source, ABILITY)) then
                        UnitAddAbility(source,  StormBolt_STORM_BOLT_RECAST)
                        TriggerSleepAction(0.10)
                        IssuePointOrder(source, "creepthunderbolt", StormBolt.x[source], StormBolt.y[source])
                        TriggerSleepAction(0.50)
                        UnitRemoveAbility(source, StormBolt_STORM_BOLT_RECAST)
                    end
                end
            end

            if ThunderClap then
                if skill == ThunderClap_ABILITY then
                    if GetRandomInt(1, 100) <= GetDoubleChance(source, GetUnitAbilityLevel(source, ABILITY)) then
                        UnitAddAbility(source, ThunderClap_THUNDER_CLAP_RECAST)
                        SetUnitAbilityLevel(source, ThunderClap_THUNDER_CLAP_RECAST, GetUnitAbilityLevel(source, ThunderClap_ABILITY))
                        IssueImmediateOrder(source, "creepthunderclap")
                        TriggerSleepAction(0.50)
                        UnitRemoveAbility(source, ThunderClap_THUNDER_CLAP_RECAST)
                    end
                end
            end
        end
        
        function DoubleThunder.onInit()
            local trigger = CreateTrigger()

            TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_SPELL_EFFECT)
            TriggerAddAction(trigger, DoubleThunder.onSpell)
            RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, DoubleThunder.onLevel)
        end
    end
end)