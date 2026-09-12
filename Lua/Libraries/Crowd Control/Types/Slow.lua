OnInit("Slow", function(requires)
    requires "Class"
    requires "Dummy"
    requires "Utilities"
    requires "CrowdControl"

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function SlowUnit(source, target, amount, duration, model, point, stack)
        CrowdControl.apply(CROWD_CONTROL_SLOW, source, target, amount, 0, duration, model, point, stack)
    end

    function IsUnitSlowed(target)
        return CrowdControl.applied(target, CROWD_CONTROL_SLOW)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    local Slow = Class(CrowdControl)

    local buff = S2A('BU03')
    local ability = S2A('U003')
    local order = "cripple"

    local dummy
    local spell
    local timer = {}

    function Slow:start(source, target, value, angle, duration, model, point, stack)
        if duration > 0 and target then
            if not timer[target] then
                timer[target] = CreateTimer()
            end

            if stack then
                duration = duration + self:getRemaining(target)
            end

            BlzSetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_HERO, 0, duration)
            BlzSetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            BlzSetAbilityRealLevelField(spell, ABILITY_RLF_MOVEMENT_SPEED_REDUCTION_PERCENT_CRI1, 0, value)
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

    function Slow:finish(unit)
        if timer[unit] then
            DestroyTimer(timer[unit])
            timer[unit] = nil
        end

        return UnitRemoveAbility(unit, buff)
    end

    function Slow:isApplied(unit)
        return GetUnitAbilityLevel(unit, buff) > 0
    end

    function Slow:getRemaining(unit)
        if timer[unit] then
            return TimerGetRemaining(timer[unit])
        end

        return 0
    end

    function Slow.onInit()
        dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetRectCenterX(GetWorldBounds()), GetRectCenterY(GetWorldBounds()), 0, 0)

        UnitAddAbility(dummy, ability)
        UnitAddAbility(dummy, CrowdControl_TRUE_SIGHT)
        
        spell = BlzGetUnitAbility(dummy, ability)
    end

    CROWD_CONTROL_SLOW = RegisterCrowdControl(Slow.allocate())
end)