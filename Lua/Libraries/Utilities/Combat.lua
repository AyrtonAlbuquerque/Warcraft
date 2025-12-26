OnInit(function(requires)
    requires "Class"
    requires "Damage"

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    local COMBAT_TIMEOUT = 5

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function GetCombatSourceUnit()
        return Combat.source
    end

    function GetCombatTargetUnit()
        return Combat.target
    end

    function IsUnitInComba(unit)
        return Combat.inCombat(unit)
    end

    function GetUnitCombatTime(unit)
        return Combat.time(unit)
    end

    function UnitEnterCombat(source, target)
        Combat.enter(source, target)
    end

    function UnitLeaveCombat(unit)
        Combat.leave(unit)
    end

    function RegisterUnitEnterCombatEvent(code)
        Combat.registerEnter(code)
    end

    function RegisterUnitLeaveCombatEvent(code)
        Combat.registerLeave(code)
    end

    local function UnitFilter(unit)
        return IsUnitType(unit, UNIT_TYPE_HERO) and UnitAlive(unit)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    Combat = Class()

    local array = {}
    local enters = {}
    local leaves = {}

    function Combat.enter(source, target)
        local this = array[source]
        local that = array[target]

        if source and UnitFilter(source) then
            if not this then
                this = {
                    combat = false,
                    timer = CreateTimer(),
                    reset = CreateTimer(),
                }

                array[source] = this
                array[this.timer] = this
            end

            this.unit = source

            if not this.combat then
                this.combat = true
                Combat.source = source
                Combat.target = target

                for i = 1, #enters do
                    enters[i]()
                end

                TimerStart(this.timer, 9999999999, true, nil)
            end

            TimerStart(this.reset, COMBAT_TIMEOUT, false, Combat.onExpire)
        end

        if target and UnitFilter(target) then
            if not that then
                that = {
                    combat = false,
                    timer = CreateTimer(),
                    reset = CreateTimer(),
                }

                array[target] = that
                array[that.timer] = that
            end

            that.unit = target

            if not that.combat then
                that.combat = true
                Combat.source = target
                Combat.target = source

                for i = 1, #enters do
                    enters[i]()
                end

                TimerStart(that.timer, 9999999999, true, nil)
            end

            TimerStart(that.reset, COMBAT_TIMEOUT, false, Combat.onExpire)
        end
    end

    function Combat.leave(unit)
        local this = array[unit]

        if this then
            if this.combat then
                this.combat = false
                Combat.source = unit
                Combat.target = nil

                PauseTimer(this.timer)
                PauseTimer(this.reset)

                for i = 1, #leaves do
                    leaves[i]()
                end

                Combat.source = nil
            end
        end
    end

    function Combat.time(unit)
        local this = array[unit]

        if this then
            return TimerGetElapsed(this.timer)
        else
            return 0
        end
    end

    function Combat.inCombat(unit)
        local this = array[unit]

        if this then
            return this.combat
        else
            return false
        end
    end

    function Combat.registerEnter(code)
        if type(code) == "function" then
            table.insert(enters, code)
        end
    end

    function Combat.registerLeave(code)
        if type(code) == "function" then
            table.insert(leaves, code)
        end
    end

    function Combat.onExpire()
        local this = array[GetExpiredTimer()]

        if this then
            this.combat = false
            Combat.source = this.unit
            Combat.target = nil

            PauseTimer(this.timer)

            for i = 1, #leaves do
                leaves[i]()
            end

            Combat.source = nil
        end
    end

    function Combat.onDamage()
        if Damage.isEnemy then
            Combat.enter(Damage.source.unit, Damage.target.unit)
        end
    end

    function Combat.onInit()
        RegisterAnyDamageEvent(Combat.onDamage)
    end
end)