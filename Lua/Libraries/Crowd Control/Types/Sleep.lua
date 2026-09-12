OnInit("Sleep", function(requires)
    requires "Class"
    requires "Dummy"
    requires "Utilities"
    requires "CrowdControl"

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function SleepUnit(source, target, duration, model, point, stack)
        CrowdControl.apply(CROWD_CONTROL_SLEEP, source, target, 0, 0, duration, model, point, stack)
    end

    function IsUnitSleeping(target)
        return CrowdControl.applied(target, CROWD_CONTROL_SLEEP)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    local Sleep = Class(CrowdControl)

    local buff = S2A('BU08')
    local ability = S2A('U008')
    local order = "sleep"

    local dummy
    local spell
    local timer = {}

    function Sleep:start(source, target, value, angle, duration, model, point, stack)
        if duration > 0 and target then
            if not timer[target] then
                timer[target] = CreateTimer()
            end

            if stack then
                duration = duration + self:getRemaining(target)
            end

            BlzSetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_HERO, 0, duration)
            BlzSetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            IncUnitAbilityLevel(dummy, ability)
            DecUnitAbilityLevel(dummy, ability)

            if IssueTargetOrder(dummy, order, target) then
                UnitRemoveAbility(target, buff)
                IssueTargetOrder(dummy, order, target)
                TimerStart(timer[target], duration, false, nil)

                if model and model ~= "" then
                    if point and point ~= "" then
                        LinkEffectToBuff(target, buff, model, point)
                    else
                        DestroyEffect(AddSpecialEffect(model, GetUnitX(target), GetUnitY(target)))
                    end
                end
            else
                return false
            end

            return true
        end

        return false
    end

    function Sleep:finish(unit)
        if timer[unit] then
            DestroyTimer(timer[unit])
            timer[unit] = nil
        end

        return UnitRemoveAbility(unit, buff)
    end

    function Sleep:isApplied(unit)
        return GetUnitAbilityLevel(unit, buff) > 0
    end

    function Sleep:getRemaining(unit)
        if timer[unit] then
            return TimerGetRemaining(timer[unit])
        end

        return 0
    end

    function Sleep.onInit()
        dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetRectCenterX(GetWorldBounds()), GetRectCenterY(GetWorldBounds()), 0, 0)

        UnitAddAbility(dummy, ability)
        UnitAddAbility(dummy, CrowdControl_TRUE_SIGHT)
        
        spell = BlzGetUnitAbility(dummy, ability)
    end

    CROWD_CONTROL_SLEEP = RegisterCrowdControl(Sleep.allocate())
end)