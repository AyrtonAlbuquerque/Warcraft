OnInit("Disarm", function(requires)
    requires "Class"
    requires "Dummy"
    requires "Utilities"
    requires "CrowdControl"

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function DisarmUnit(source, target, duration, model, point, stack)
        CrowdControl.apply(CROWD_CONTROL_DISARM, source, target, 0, 0, duration, model, point, stack)
    end

    function IsUnitDisarmed(target)
        return CrowdControl.applied(target, CROWD_CONTROL_DISARM)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    local Disarm = Class(CrowdControl)

    local buff = S2A('BU11')
    local ability = S2A('U011')
    local order = "drunkenhaze"

    local dummy
    local spell
    local timer = {}

    function Disarm:start(source, target, value, angle, duration, model, point, stack)
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

    function Disarm:finish(unit)
        if timer[unit] then
            DestroyTimer(timer[unit])
            timer[unit] = nil
        end

        return UnitRemoveAbility(unit, buff)
    end

    function Disarm:isApplied(unit)
        return GetUnitAbilityLevel(unit, buff) > 0
    end

    function Disarm:getRemaining(unit)
        if timer[unit] then
            return TimerGetRemaining(timer[unit])
        end

        return 0
    end

    function Disarm.onInit()
        dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetRectCenterX(GetWorldBounds()), GetRectCenterY(GetWorldBounds()), 0, 0)

        UnitAddAbility(dummy, ability)
        UnitAddAbility(dummy, CrowdControl_TRUE_SIGHT)
        
        spell = BlzGetUnitAbility(dummy, ability)
    end

    CROWD_CONTROL_DISARM = RegisterCrowdControl(Disarm.allocate())
end)