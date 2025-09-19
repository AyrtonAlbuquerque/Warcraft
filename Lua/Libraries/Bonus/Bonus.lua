OnInit("Bonus", function(requires)
    requires "Class"
    requires "RegisterPlayerUnitEvent"

    Bonus = Class()

    local RECURSION_LIMIT = 8

    local key = 0
    local index = 0
    local unit = {}
    local items = {}
    local bonus = {}
    local event = {}
    local array = {}
    local amount = {}
    local struct = {}
    local trigger = {}
    local period = 0.03125
    local timer = CreateTimer()

    function Bonus:overflow(current, value)
        if value > 0 and current > 2147483647 - value then
            return 2147483647 - current
        elseif value < 0 and current < -2147483648 - value then
            return -2147483648 - current
        else
            return value
        end
    end

    function Bonus.getter(source, type)
        local this = struct[type]

        if this then
            if this.get then
                return this:get(source)
            end
        else
            print("Invalid Bonus Type")
        end

        return 0.
    end

    function Bonus.setter(source, type, value)
        local this = struct[type]

        value = value or 0

        if this then
            if this.set then
                bonus[key] = type
                unit[key] = source
                amount[key] = value

                Bonus.__onEvent(key)

                if bonus[key] ~= type then
                    return Bonus.setter(unit[key], bonus[key], amount[key])
                end

                return this:set(unit[key], amount[key])
            end
        else
            print("Invalid Bonus Type")
        end

        return 0.
    end

    function Bonus.adder(source, type, value)
        local this = struct[type]

        value = value or 0

        if this then
            if this.add then
                bonus[key] = type
                unit[key] = source
                amount[key] = value

                Bonus.__onEvent(key)

                if bonus[key] ~= type then
                    return Bonus.adder(unit[key], bonus[key], amount[key])
                end

                return this:add(unit[key], amount[key])
            end
        else
            print("Invalid Bonus Type")
        end

        return 0.
    end

    function Bonus.copy(source, target)
        for i = 1, index do
            if Bonus.getter(source, i) ~= 0 then
                Bonus.adder(target, i, Bonus.getter(source, i))
            end
        end
    end

    function Bonus.mirror(source, target)
        for i = 1, index do
            Bonus.setter(target, i, Bonus.getter(source, i))
        end
    end

    function Bonus.linkTimer(source, type, value, duration)
        if value ~= 0 then
            local this = {
                value = Bonus.adder(source, type, value),
                source = unit[key],
                type = bonus[key],
            }

            TimerStart(CreateTimer(), duration, false, function()
                Bonus.adder(this.source, this.type, -this.value)
                DestroyTimer(GetExpiredTimer())
            end)
        end
    end

    function Bonus.linkBuff(source, type, value, buff)
        if value ~= 0 then
            table.insert(array, {
                value = Bonus.adder(source, type, value),
                source = unit[key],
                type = bonus[key],
                buff = buff
            })

            if #array == 1 then
                TimerStart(timer, period, true, function()
                    for i = #array, 1, -1 do
                        local this = array[i]

                        if GetUnitAbilityLevel(this.source, this.buff) == 0 then
                            Bonus.adder(this.source, this.type, -this.value)
                            table.remove(array, i)

                            if #array == 0 then
                                PauseTimer(timer)
                            end
                        end
                    end
                end)
            end
        end
    end

    function Bonus.linkItem(source, type, value, item)
        if value ~= 0 then
            if not items[item] then items[item] = {} end

            table.insert(items[item], {
                value = Bonus.adder(source, type, value),
                source = unit[key],
                type = bonus[key],
                item = item
            })
        end
    end

    function Bonus.register(type)
        index = index + 1
        struct[index] = type

        return index
    end

    function Bonus.registerEvent(code, bonusType)
        if type(code) == "function" then
            if bonusType > 0 then
                if not event[bonusType] then event[bonusType] = {} end
                table.insert(event[bonusType], code)
            else
                table.insert(trigger, code)
            end
        end
    end

    function Bonus.__onEvent(k)
        key = key + 1

        if k <= RECURSION_LIMIT then
            if event[bonus[k]] then
                for i = 1, #event[bonus[k]] do
                    event[bonus[k]][i]()
                end
            end

            for i = 1, #trigger do
                trigger[i]()
            end
        end

        key = key - 1
    end

    function Bonus.__onDrop()
        local item = GetManipulatedItem()

        if items[item] then
            for i = #items[item], 1, -1 do
                local this = items[item][i]

                Bonus.adder(this.source, this.type, -this.value)
                table.remove(items[item], i)
            end
        end
    end

    function Bonus.onInit()
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, Bonus.__onDrop)
    end

    -- ---------------------------------------------------------------------------------------------- --
    --                                             LUA API                                            --
    -- ---------------------------------------------------------------------------------------------- --
    function RegisterBonus(type)
        return Bonus.register(type)
    end

    function RegisterBonusEvent(code)
        Bonus.registerEvent(code, 0)
    end

    function RegisterBonusTypeEvent(type, code)
        Bonus.registerEvent(code, type)
    end

    function GetBonusUnit()
        return unit[key - 1]
    end

    function GetBonusType()
        return bonus[key - 1]
    end

    function SetBonusType(type)
        bonus[key - 1] = type
    end

    function GetBonusAmount()
        return amount[key - 1]
    end

    function SetBonusAmount(value)
        amount[key - 1] = value
    end

    function GetUnitBonus(source, type)
        return Bonus.getter(source, type)
    end

    function SetUnitBonus(source, type, value)
        return Bonus.setter(source, type, value)
    end

    function RemoveUnitBonus(source, type)
        Bonus.setter(source, type, 0)
    end

    function AddUnitBonus(source, type, value)
        return Bonus.adder(source, type, value)
    end

    function AddUnitBonusTimed(source, type, value, duration)
        Bonus.linkTimer(source, type, value, duration)
    end

    function LinkBonusToBuff(source, type, value, buff)
        Bonus.linkBuff(source, type, value, buff)
    end

    function LinkBonusToItem(source, type, value, item)
        Bonus.linkItem(source, type, value, item)
    end

    function UnitCopyBonuses(source, target)
        Bonus.copy(source, target)
    end

    function UnitMirrorBonuses(source, target)
        Bonus.mirror(source, target)
    end
end)