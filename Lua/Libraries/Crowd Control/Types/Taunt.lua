OnInit("Taunt", function(requires)
    requires "Class"
    requires "Dummy"
    requires "Utilities"
    requires "CrowdControl"
    requires "RegisterPlayerUnitEvent"

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function TauntUnit(source, target, duration, model, point, stack)
        CrowdControl.apply(CROWD_CONTROL_TAUNT, source, target, 0, 0, duration, model, point, stack)
    end

    function IsUnitTaunted(target)
        return CrowdControl.applied(target, CROWD_CONTROL_TAUNT)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    local Taunt = Class(CrowdControl)

    local buff = S2A('BU13')
    local ability = S2A('U013')
    local order = "drunkenhaze"

    local PERIOD = 0.2

    local dummy
    local spell
    local timer = {}

    local key = 0
    local array = {}
    local struct = {}
    local sources = {}
    local periodic = CreateTimer()

    function Taunt:start(source, target, value, angle, duration, model, point, stack)
        local this

        if duration > 0 and UnitAlive(source) and UnitAlive(target) then
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
                        target = target,
                        selected = IsUnitSelected(target, GetOwningPlayer(target)),
                        finish = Taunt.finish,
                        remove = Taunt.remove
                    }
                    key = key + 1
                    array[key] = this
                    struct[target] = this

                    if this.selected then
                        SelectUnit(target, false)
                    end

                    if model and point then
                        this.effect = AddSpecialEffectTarget(model, target, point)
                    end

                    if key == 1 then
                        TimerStart(periodic, PERIOD, true, function()
                            local i = 1
                            local this

                            while i <= key do
                                this = array[i]

                                if GetUnitAbilityLevel(this.target, buff) > 0 and UnitAlive(sources[this.target]) and UnitAlive(this.target) then
                                    if IsUnitVisible(sources[this.target], GetOwningPlayer(this.target)) then
                                        IssueTargetOrderById(this.target, 851983, sources[this.target])
                                    else
                                        IssuePointOrderById(this.target, 851986, GetUnitX(sources[this.target]), GetUnitY(sources[this.target]))
                                    end
                                else
                                    i = this:remove(i)
                                end
                                i = i + 1
                            end
                        end)
                    end
                end

                sources[target] = source

                if IsUnitVisible(source, GetOwningPlayer(target)) then
                    IssueTargetOrderById(target, 851983, source)
                else
                    IssuePointOrderById(target, 851986, GetUnitX(source), GetUnitY(source))
                end

                TimerStart(timer[target], duration, false, nil)
            else
                return false
            end

            return true
        end

        return false
    end

    function Taunt:finish(unit)
        if timer[unit] then
            DestroyTimer(timer[unit])
            timer[unit] = nil
        end

        return UnitRemoveAbility(unit, buff)
    end

    function Taunt:isApplied(unit)
        return GetUnitAbilityLevel(unit, buff) > 0
    end

    function Taunt:getRemaining(unit)
        if timer[unit] then
            return TimerGetRemaining(timer[unit])
        end

        return 0
    end

    function Taunt:remove(i)
        self:finish(self.target)
        IssueImmediateOrder(self.target, "stop")
        DestroyEffect(self.effect)

        if self.selected and UnitAlive(self.target) then
            SelectUnitAddForPlayer(self.target, GetOwningPlayer(self.target))
        end

        array[i] = array[key]
        key = key - 1
        struct[self.target] = nil
        sources[self.target] = nil
        self = nil

        if key == 0 then
            PauseTimer(periodic)
        end

        return i - 1
    end

    function Taunt.onOrder()
        local unit = GetOrderedUnit()
        local order = GetIssuedOrderId()

        if GetUnitAbilityLevel(unit, buff) > 0 and order ~= 851973 then
            if order ~= 851983 and order ~= 851986 then
                if IsUnitVisible(sources[unit],  GetOwningPlayer(unit)) then
                    IssueTargetOrderById(unit, 851983, sources[unit])
                else
                    IssuePointOrderById(unit, 851986, GetUnitX(sources[unit]), GetUnitY(sources[unit]))
                end
            else
                if GetOrderTargetUnit() ~= sources[unit] and GetOrderTargetUnit() ~= nil then
                    if IsUnitVisible(sources[unit],  GetOwningPlayer(unit)) then
                        IssueTargetOrderById(unit, 851983, sources[unit])
                    else
                        IssuePointOrderById(unit, 851986, GetUnitX(sources[unit]), GetUnitY(sources[unit]))
                    end
                end
            end
        end
    end

    function Taunt.onSelect()
        local unit = GetTriggerUnit()

        if GetUnitAbilityLevel(unit, buff) > 0 then
            if IsUnitSelected(unit, GetOwningPlayer(unit)) then
                SelectUnit(unit, false)
            end
        end
    end

    function Taunt.onInit()
        dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetRectCenterX(GetWorldBounds()), GetRectCenterY(GetWorldBounds()), 0, 0)

        UnitAddAbility(dummy, ability)
        UnitAddAbility(dummy, CrowdControl_TRUE_SIGHT)
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, Taunt.onOrder)
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, Taunt.onOrder)
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, Taunt.onOrder)
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, Taunt.onOrder)
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, Taunt.onSelect)
        
        spell = BlzGetUnitAbility(dummy, ability)
    end

    CROWD_CONTROL_TAUNT = RegisterCrowdControl(Taunt.allocate())
end)