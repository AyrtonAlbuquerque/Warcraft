OnInit("Heal", function(requires)
    requires "Unit"
    requires "Class"
    requires "Indexer"
    requires "ArcingFloatingText"

    -- The healing types
    HEALTH = 0
    MANA = 1

    -- The text size
    local TEXT_SIZE = 0.02

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function RegisterHealingEvent(code)
        Heal.register(code)
    end

    function HealUnit(source, target, amount, healtype, showText)
        return Heal.heal(source, target, amount, healtype, showText)
    end

    function GetHealingSource()
        return Heal.source.unit
    end

    function GetHealingTarget()
        return Heal.target.unit
    end

    function GetHealingAmount()
        return Heal.amount
    end

    function SetHealingAmount(value)
        Heal.amount = value
    end

    function GetHealingType()
        return Heal.type
    end

    function SetHealingType(value)
        Heal.type = value
    end

    function GetUnitHealingIncrease(unit)
        return Heal.getIncrease(unit)
    end

    function GetUnitHealingDecrease(unit)
        return Heal.getDecrease(unit)
    end

    function SetUnitHealingIncrease(unit, value)
        return Heal.setIncrease(unit, value)
    end

    function SetUnitHealingDecrease(unit, value)
        return Heal.setDecrease(unit, value)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    Heal = Class()

    Heal.type = 0
    Heal.amount = 0
    Heal.source = Unit.create(nil)
    Heal.target = Unit.create(nil)

    local event = {}
    local increase = {}
    local decrease = {}

    function Heal.getIncrease(unit)
        return increase[unit] or 0
    end

    function Heal.getDecrease(unit)
        return decrease[unit] or 0
    end

    function Heal.setIncrease(unit, value)
        increase[unit] = value

        return value
    end

    function Heal.setDecrease(unit, value)
        decrease[unit] = value

        return value
    end

    function Heal.heal(source, target, amount, healtype, showText)
        if amount > 0 and (healtype == HEALTH or healtype == MANA) then
            Heal.type = healtype
            Heal.source.unit = source
            Heal.target.unit = target
            Heal.amount = (amount * (1 + (increase[Heal.target.unit] or 0))) * (1 - (decrease[Heal.target.unit] or 0))

            for i = 1, #event do
                event[i]()
            end

            if UnitAlive(Heal.target.unit) and Heal.amount > 0 then
                if Heal.type == HEALTH then
                    SetWidgetLife(Heal.target.unit, Heal.target.health + Heal.amount)
                else
                    SetUnitState(Heal.target.unit, UNIT_STATE_MANA, Heal.target.mana + Heal.amount)
                end

                if showText then
                    if Heal.type == HEALTH then
                        ArcingTextTag.create("|cff00ff00+" .. (I2S(R2I(Heal.amount))) .. "|r", Heal.target.unit, TEXT_SIZE)
                    else
                        ArcingTextTag.create("|cff00ffff+" .. (I2S(R2I(Heal.amount))) .. "|r", Heal.target.unit, TEXT_SIZE)
                    end
                end

                return true
            end
        end

        return false
    end

    function Heal.register(code)
        if type(code) == "function" then
            table.insert(event, code)
        end
    end

    function Heal.onDeindex()
        increase[GetIndexUnit()] = 0
        decrease[GetIndexUnit()] = 0
    end

    function Heal.onInit()
        RegisterUnitDeindexEvent(Heal.onDeindex)
    end
end)