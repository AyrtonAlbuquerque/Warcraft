OnInit("Knockup", function(requires)
    requires "Class"
    requires "Utilities"
    requires "CrowdControl"

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function KnockupUnit(source, target, maxHeight, duration, model, point, stack)
        CrowdControl.apply(CROWD_CONTROL_KNOCKUP, source, target, maxHeight, 0, duration, model, point, stack)
    end

    function IsUnitKnockedUp(target)
        return CrowdControl.applied(target, CROWD_CONTROL_KNOCKUP)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    local Knockup = Class(CrowdControl)

    local timer = {}
    local knocked = {}

    function Knockup:start(source, target, value, angle, duration, model, point, stack)
        if duration > 0 and target then
            if not timer[target] then
                timer[target] = CreateTimer()
            end

            if stack then
                duration = duration + self:getRemaining(target)
            end

            local periodic = CreateTimer()
            local rate = value/duration
            local effect

            knocked[target] = (knocked[target] or 0) + 1

            if model and point then
                effect = AddSpecialEffectTarget(model, target, point)
            end

            if knocked[target] == 1 then
                BlzPauseUnitEx(target, true)
            end

            UnitAddAbility(target, S2A('Amrf'))
            UnitRemoveAbility(target, S2A('Amrf'))
            SetUnitFlyHeight(target, (GetUnitDefaultFlyHeight(target) + value), rate)
            TimerStart(periodic, duration/2, false, function()
                SetUnitFlyHeight(target, GetUnitDefaultFlyHeight(target), rate)
                TimerStart(periodic, duration/2, false, function()
                    DestroyEffect(effect)
                    PauseTimer(periodic)
                    DestroyTimer(periodic)

                    knocked[target] = knocked[target] - 1

                    if knocked[target] == 0 then
                        BlzPauseUnitEx(target, false)
                    end
                end)
            end)
            TimerStart(timer[target], duration, false, nil)

            return true
        end

        return false
    end

    function Knockup:finish(unit)
        if timer[unit] then
            DestroyTimer(timer[unit])
            timer[unit] = nil
        end

        return false
    end

    function Knockup:isApplied(unit)
        return (knocked[unit] or 0) > 0
    end

    function Knockup:getRemaining(unit)
        if timer[unit] then
            return TimerGetRemaining(timer[unit])
        end

        return 0
    end

    CROWD_CONTROL_KNOCKUP = RegisterCrowdControl(Knockup.allocate())
end)