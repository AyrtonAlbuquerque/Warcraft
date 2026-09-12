OnInit("Fear", function(requires)
    requires "Class"
    requires "Dummy"
    requires "Utilities"
    requires "CrowdControl"
    requires "RegisterPlayerUnitEvent"

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function FearUnit(source, target, duration, model, point, stack)
        CrowdControl.apply(CROWD_CONTROL_FEAR, source, target, 0, 0, duration, model, point, stack)
    end

    function IsUnitFeared(target)
        return CrowdControl.applied(target, CROWD_CONTROL_FEAR)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    local Fear = Class(CrowdControl)

    local buff = S2A('BU12')
    local ability = S2A('U012')
    local order = "drunkenhaze"

    local UPDATE = 0.2
    local MAX_CHANGE = 200.
    local DIRECTION_CHANGE = 5

    local dummy
    local spell
    local timer = {}

    local key = 0
    local x = {}
    local y = {}
    local flag = {}
    local array = {}
    local struct = {}
    local periodic = CreateTimer()

    function Fear:start(source, target, value, angle, duration, model, point, stack)
        local this

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
                if struct[target] then
                    this = struct[target]
                else
                    this = {
                        change = 0,
                        target = target,
                        remove = Fear.remove
                    }
                    key = key + 1
                    array[key] = this
                    struct[target] = this

                    if model and point then
                        this.effect = AddSpecialEffectTarget(model, target, point)
                    end

                    if key == 1 then
                        TimerStart(periodic, UPDATE, true, function()
                            local i = 1
                            local this

                            while i <= key do
                                this = array[i]

                                if GetUnitAbilityLevel(this.target, buff) > 0 then
                                    this.change = this.change + 1

                                    if this.change == DIRECTION_CHANGE then
                                        this.change = 0
                                        flag[this.target] = true
                                        x[this.target] = GetRandomReal(GetUnitX(this.target) - MAX_CHANGE, GetUnitX(this.target) + MAX_CHANGE)
                                        y[this.target] = GetRandomReal(GetUnitY(this.target) - MAX_CHANGE, GetUnitY(this.target) + MAX_CHANGE)
                                        IssuePointOrder(this.target, "move", x[this.target], y[this.target])
                                    end
                                else
                                    i = this:remove(i)
                                end

                                i = i + 1
                            end
                        end)
                    end
                end

                flag[target] = true
                x[target] = GetRandomReal(GetUnitX(target) - MAX_CHANGE, GetUnitX(target) + MAX_CHANGE)
                y[target] = GetRandomReal(GetUnitY(target) - MAX_CHANGE, GetUnitY(target) + MAX_CHANGE)

                IssuePointOrder(target, "move", x[target], y[target])
                TimerStart(timer[target], duration, false, nil)
            else
                return false
            end

            return true
        end

        return false
    end

    function Fear:finish(unit)
        if timer[unit] then
            DestroyTimer(timer[unit])
            timer[unit] = nil
        end

        return UnitRemoveAbility(unit, buff)
    end

    function Fear:isApplied(unit)
        return GetUnitAbilityLevel(unit, buff) > 0
    end

    function Fear:getRemaining(unit)
        if timer[unit] then
            return TimerGetRemaining(timer[unit])
        end

        return 0
    end

    function Fear:remove(i)
        flag[self.target] = true
        IssueImmediateOrder(self.target, "stop")
        DestroyEffect(self.effect)

        array[i] = array[key]
        key = key - 1
        struct[self.target] = nil
        self = nil

        if key == 0 then
            PauseTimer(periodic)
        end

        return i - 1
    end

    function Fear.onOrder()
        local unit = GetOrderedUnit()

        if GetUnitAbilityLevel(unit, buff) > 0 and GetIssuedOrderId() ~= 851973 then
            if not flag[unit] then
                flag[unit] = true
                IssuePointOrder(unit, "move", x[unit], y[unit])
            else
                flag[unit] = false
            end
        end
    end

    function Fear.onInit()
        dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetRectCenterX(GetWorldBounds()), GetRectCenterY(GetWorldBounds()), 0, 0)

        UnitAddAbility(dummy, ability)
        UnitAddAbility(dummy, CrowdControl_TRUE_SIGHT)
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, Fear.onOrder)
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, Fear.onOrder)
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, Fear.onOrder)
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, Fear.onOrder)
        
        spell = BlzGetUnitAbility(dummy, ability)
    end

    CROWD_CONTROL_FEAR = RegisterCrowdControl(Fear.allocate())
end)