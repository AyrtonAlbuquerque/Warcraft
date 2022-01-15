--[[
    /* ------------------------ Utilities functions v1.6 ------------------------ */
        How to Import:
            1 - Copy this library into your map
            2 - Copy the Stun, Silence and Slow abilities and match them below and the Slow Buff
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the ability used to silence an unit
    local SILENCE   = FourCC('U000')
    -- The raw code of the ability used to stun an unit
    local STUN      = FourCC('U001')
    -- The raw code of the ability used to slow an unit
    local SLOW      = FourCC('U003')
    -- The dummy caster unit id
    local DUMMY     = FourCC('dumi')
    -- Update period
    local PERIOD    = 0.031250000
    -- location z
    local location  = Location(0,0)
    -- Closest Unit
    local bj_closestUnitGroup

    -- -------------------------------------------------------------------------- --
    --                                  DummyPool                                 --
    -- -------------------------------------------------------------------------- --
    do
        local group  = CreateGroup()
        local player = Player(PLAYER_NEUTRAL_PASSIVE)

        DummyPool = setmetatable({}, {})
        local mt = getmetatable(DummyPool)
        mt.__index = mt

        function mt:recycle(unit)
            if GetUnitTypeId(unit) ~= DUMMY then
                print("[DummyPool] Error: Trying to recycle a non dummy unit")
            else
                GroupAddUnit(group, unit)
                SetUnitX(unit, WorldBounds.maxX)
                SetUnitY(unit, WorldBounds.maxY)
                SetUnitOwner(unit, player, false)
                ShowUnit(unit, false)
                BlzPauseUnitEx(unit, true)
            end
        end

        function mt:retrieve(owner, x, y, z, face)
            if BlzGroupGetSize(group) > 0 then
                bj_lastCreatedUnit = FirstOfGroup(group)
                BlzPauseUnitEx(bj_lastCreatedUnit, false)
                ShowUnit(bj_lastCreatedUnit, true)
                GroupRemoveUnit(group, bj_lastCreatedUnit)
                SetUnitX(bj_lastCreatedUnit, x)
                SetUnitY(bj_lastCreatedUnit, y)
                SetUnitFlyHeight(bj_lastCreatedUnit, z, 0)
                BlzSetUnitFacingEx(bj_lastCreatedUnit, face*bj_RADTODEG)
                SetUnitOwner(bj_lastCreatedUnit, owner, false)
            else
                bj_lastCreatedUnit = CreateUnit(owner, DUMMY, x, y, face*bj_RADTODEG)
                SetUnitFlyHeight(bj_lastCreatedUnit, z, 0)
            end

            return bj_lastCreatedUnit
        end

        function mt:timed(unit, delay)
            local timer = CreateTimer()

            if GetUnitTypeId(unit) ~= DUMMY then
                print("[DummyPool] Error: Trying to recycle a non dummy unit")
            else
                TimerStart(timer, delay, false, function()
                    GroupAddUnit(group, unit)
                    SetUnitX(unit, WorldBounds.maxX)
                    SetUnitY(unit, WorldBounds.maxY)
                    SetUnitOwner(unit, player, false)
                    ShowUnit(unit, false)
                    BlzPauseUnitEx(unit, true)
                    PauseTimer(timer)
                    DestroyTimer(timer)
                end)
            end
        end

        onInit(function()
            local timer = CreateTimer()
            local unit

            TimerStart(timer, 0, false, function()
                for i = 0, 20 do
                    unit = CreateUnit(player, DUMMY, WorldBounds.maxX, WorldBounds.maxY, 0)
                    BlzPauseUnitEx(unit, false)
                    GroupAddUnit(group, unit)
                end
                PauseTimer(timer)
                DestroyTimer(timer)
            end)
        end)
    end

    -- -------------------------------------------------------------------------- --
    --                                  Knockback                                 --
    -- -------------------------------------------------------------------------- --
    do
        Knockback = setmetatable({}, {})
        local mt = getmetatable(Knockback)
        mt.__index = mt

        local knocked = {}

        function mt:isUnitKnocked(unit)
            return (knocked[unit] or 0) > 0
        end

        function mt:start(target, angle, distance, duration, model, point, cliff, dest, hit, isPaused)
            local x = GetUnitX(target)
            local y = GetUnitY(target)
            local this = Missiles:create(x, y, 0, x + distance*Cos(angle), y + distance*Sin(angle), 0)

            this.source = target
            this:duration(duration)
            this.collision = 2*BlzGetUnitCollisionSize(target)
            this.cliff = cliff
            this.dest = dest
            this.hit = hit
            this.isPaused = isPaused
            knocked[target] = (knocked[target] or 0) + 1

            if model and point then
                this.attachment = AddSpecialEffectTarget(model, target, point)
            end

            if isPaused and (knocked[target] or 0) == 1 then
                BlzPauseUnitEx(target, true)
            end

            this.onPeriod = function()
                if UnitAlive(this.source) then
                    SetUnitX(this.source, this.prevX)
                    SetUnitY(this.source, this.prevY)

                    return false
                else
                    return true
                end
            end

            this.onHit = function(unit)
                if this.hit then
                    if UnitAlive(unit) then
                        return true
                    else
                        return false
                    end
                else
                    return false
                end
            end

            this.onDestructable = function(destructable)
                if this.dest then
                    if GetDestructableLife(destructable) > 0 then
                        return true
                    else
                        return false
                    end
                else
                    return false
                end
            end

            this.onCliff = function()
                return this.cliff
            end

            this.onPause = function()
                this:pause(false)
                return false
            end

            this.onRemove = function()
                DestroyEffect(this.attachment)

                knocked[this.source] = (knocked[this.source] or 0) - 1

                if this.isPaused and (knocked[this.source] or 0) == 0 then
                    BlzPauseUnitEx(this.source, false)
                end
            end

            this:launch()
        end
    end

    -- -------------------------------------------------------------------------- --
    --                                Timed Ability                               --
    -- -------------------------------------------------------------------------- --
    do
        TimedAbility = setmetatable({}, {})
        local mt = getmetatable(TimedAbility)
        mt.__index = mt

        local timer = CreateTimer()
        local ability = {}
        local array = {}
        local key = 0

        function mt:destroy(i)
            UnitRemoveAbility(self.unit, self.id)

            array[i] = array[key]
            key = key - 1
            ability[self.unit][self.id] = nil
            self = nil

            if key == 0 then
                PauseTimer(timer)
            end

            return i - 1
        end

        function mt:add(unit, id, duration, level, hide)
            if not ability[unit] then ability[unit] = {} end

            local this = ability[unit][id]

            if not this then
                this = {}
                setmetatable(this, mt)

                this.unit = unit
                this.id = id
                key = key + 1
                array[key] = this
                ability[unit][id] = this

                if key == 1 then
                    TimerStart(timer, PERIOD, true, function()
                        local i = 1
                        local this

                        while i <= key do
                            this = array[i]

                            if this.duration <= 0 then
                                i = this:destroy(i)
                            end
                            this.duration = this.duration - PERIOD
                            i = i + 1
                        end
                    end)
                end
            end

            if GetUnitAbilityLevel(unit, id) ~= level then
                UnitAddAbility(unit, id)
                SetUnitAbilityLevel(unit, id, level)
                UnitMakeAbilityPermanent(unit, true, id)
                BlzUnitHideAbility(unit, id, hide)
            end

            this.duration = duration
        end
    end

    -- -------------------------------------------------------------------------- --
    --                                 Fear System                                --
    -- -------------------------------------------------------------------------- --
    do
        Fear = setmetatable({}, {})
        local mt = getmetatable(Fear)
        mt.__index = mt

        local timer = CreateTimer()
        local array = {}
        local struct = {}
        local flag = {}
        local x = {}
        local y = {}
        local key = 0
        local UPDATE = 0.2
        local DIRECTION_CHANGE = 5
        local MAX_CHANGE = 200.

        function mt:isFeared(unit)
            if struct[unit] then
                return true
            else
                return false
            end
        end

        function mt:destroy(i)
            flag[self.target] = true
            IssueImmediateOrder(self.target, "stop")
            DestroyEffect(self.effect)
            UnitRemoveAbility(self.target, FourCC('Abun'))

            if self.selected then
                SelectUnitAddForPlayer(self.target, GetOwningPlayer(self.target))
            end

            array[i] = array[key]
            key = key - 1
            struct[self.target] = nil
            self = nil

            if key == 0 then
                PauseTimer(timer)
            end

            return i - 1
        end

        function mt:unit(target, duration, effect, attach)
            local this

            if struct[target] then
                this = struct[target]
            else
                this = {}
                setmetatable(this, mt)
                key = key + 1
                array[key] = this
                struct[target] = this

                this.target = target
                this.change = 0
                this.selected = IsUnitSelected(target, GetOwningPlayer(target))

                UnitAddAbility(target, FourCC('Abun'))

                if this.selected then
                    SelectUnit(target, false)
                end

                if effect and attach then
                    this.effect = AddSpecialEffectTarget(effect, target, attach)
                end

                if key == 1 then
                    TimerStart(timer, UPDATE, true, function()
                        local i = 1
                        local this

                        while i <= key do
                            this = array[i]

                            if this.duration > 0 and UnitAlive(this.target) then
                                this.duration = this.duration - UPDATE
                                this.change = this.change + 1

                                if this.change == DIRECTION_CHANGE then
                                    this.change = 0
                                    flag[this.target] = true
                                    x[this.target] = GetRandomReal(GetUnitX(this.target) - MAX_CHANGE, GetUnitX(this.target) + MAX_CHANGE)
                                    y[this.target] = GetRandomReal(GetUnitY(this.target) - MAX_CHANGE, GetUnitY(this.target) + MAX_CHANGE)
                                    IssuePointOrder(this.target, "move", x[this.target], y[this.target])
                                end
                            else
                                i = this:destroy(i)
                            end
                            i = i + 1
                        end
                    end)
                end
            end

            this.duration = duration
            flag[target] = true
            x[target] = GetRandomReal(GetUnitX(target) - MAX_CHANGE, GetUnitX(target) + MAX_CHANGE)
            y[target] = GetRandomReal(GetUnitY(target) - MAX_CHANGE, GetUnitY(target) + MAX_CHANGE)
            IssuePointOrder(target, "move", x[target], y[target])
        end

        function mt:onOrder()
            local unit = GetOrderedUnit()

            if self:isFeared(unit) then
                if not flag[unit] then
                    flag[unit] = true
                    IssuePointOrder(unit, "move", x[unit], y[unit])
                else
                    flag[unit] = false
                end
            end
        end

        onInit(function()
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function()
                Fear:onOrder()
            end)

            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function()
                Fear:onOrder()
            end)

            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, function()
                Fear:onOrder()
            end)

            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, function()
                Fear:onOrder()
            end)

            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, function()
                local unit = GetTriggerUnit()

                if Fear:isFeared(unit) then
                    if IsUnitSelected(unit, GetOwningPlayer(unit)) then
                        SelectUnit(unit, false)
                    end
                end
            end)
        end)
    end

    -- -------------------------------------------------------------------------- --
    --                                 Effect Link                                --
    -- -------------------------------------------------------------------------- --
    do
        EffectLink = setmetatable({}, {})
        local mt = getmetatable(EffectLink)
        mt.__index = mt

        local timer = CreateTimer()
        local array = {}
        local items = {}
        local key = 0
        local k = 0

        function mt:destroy(i, item)
            DestroyEffect(self.effect)

            if item then
                items[i] = items[k]
                k = k - 1
            else
                array[i] = array[key]
                key = key - 1

                if key == 0 then
                    PauseTimer(timer)
                end
            end
            self = nil

            return i - 1
        end

        function mt:buff(unit, buffId, model, attach)
            local this = {}
            setmetatable(this, mt)

            key = key + 1
            array[key] = this
            this.unit = unit
            this.buff = buffId
            this.effect = AddSpecialEffectTarget(model, unit, attach)

            if key == 1 then
                TimerStart(timer, PERIOD, true, function()
                    local i = 1
                    local this

                    while i <= key do
                        this = array[i]

                        if GetUnitAbilityLevel(this.unit, this.buff) == 0 then
                            i = this:destroy(i, false)
                        end
                        i = i + 1
                    end
                end)
            end
        end

        function mt:item(unit, i, model, attach)
            local this = {}
            setmetatable(this, mt)

            k = k + 1
            items[k] = this
            this.item = i
            this.effect = AddSpecialEffectTarget(model, unit, attach)
        end

        onInit(function()
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, function()
                local item = GetManipulatedItem()
                local i = 1
                local this

                while i <= k do
                    this = items[i]

                    if this.item == item then
                        i = this:destroy(i, true)
                    end
                    i = i + 1
                end
            end)
        end)
    end

    -- -------------------------------------------------------------------------- --
    --                                   Disarm                                   --
    -- -------------------------------------------------------------------------- --
    do
        Disarm = setmetatable({}, {})
        local mt = getmetatable(Disarm)
        mt.__index = mt

        local timer = CreateTimer()
        local array = {}
        local count = {}
        local n = {}
        local key = 0
        local ability = FourCC('Abun')

        function mt:destroy(i)
            self:unit(self.target, false)

            array[i] = array[key]
            key = key - 1
            n[self.target] = nil
            self = nil

            if key == 0 then
                PauseTimer(timer)
            end

            return i - 1
        end

        function mt:disarmed(unit)
            return GetUnitAbilityLevel(unit, ability) > 0
        end

        function mt:timed(target, duration)
            local this

            if n[target] then
                this = n[target]
            else
                this = {}
                setmetatable(this, mt)
                n[target] = this

                key = key + 1
                array[key] = this
                this.target = target
                this:unit(target, true)

                if key == 1 then
                    TimerStart(timer, PERIOD, true, function()
                        local i = 1
                        local this

                        while i <= key do
                            this = array[i]

                            if this.ticks <= 0 then
                                i = this:destroy(i)
                            end
                            this.ticks = this.ticks - 1
                            i = i + 1
                        end
                    end)
                end
            end
            this.ticks = duration/PERIOD
        end

        function mt:unit(target, flag)
            if not count[target] then count[target] = 0 end

            if flag then
                count[target] = count[target] + 1
                if count[target] > 0 then
                    UnitAddAbility(target, ability)
                end
            else
                count[target] = count[target] - 1
                if count[target] <= 0 then
                    UnitRemoveAbility(target, ability)
                end
            end
        end
    end

    -- -------------------------------------------------------------------------- --
    --                                   LUA API                                  --
    -- -------------------------------------------------------------------------- --
    -- Anlge between 2D points
    function AngleBetweenCoordinates(x, y, x2, y2)
        return Atan2(y2 - y, x2 - x)
    end

    -- Returns the terrain Z value
    function GetLocZ(x, y)
        MoveLocation(location, x, y)
        return GetLocationZ(location)
    end

    -- Similar to GetUnitX and GetUnitY but for Z axis
    function GetUnitZ(unit)
        return GetLocZ(GetUnitX(unit), GetUnitY(unit)) + GetUnitFlyHeight(unit)
    end

    -- Similar to SetUnitX and SetUnitY but for Z axis
    function SetUnitZ(unit, z)
        SetUnitFlyHeight(unit, z - GetLocZ(GetUnitX(unit), GetUnitY(unit)), 0)
    end

    -- Similar to AddSpecialEffect but scales the effect and considers z and return it
    function AddSpecialEffectEx(effect, x, y, z, scale)
        bj_lastCreatedEffect = AddSpecialEffect(effect, x, y)

        if z ~= 0 then
            BlzSetSpecialEffectZ(bj_lastCreatedEffect, z + GetLocZ(x, y))
        end
        BlzSetSpecialEffectScale(bj_lastCreatedEffect, scale)

        return bj_lastCreatedEffect
    end

    -- Returns a group of enemy units of the specified player within the specified AOE of x and y
    function GetEnemyUnitsInRange(player, x, y, aoe, structures, magicImmune)
        local group = CreateGroup()
        local g = CreateGroup()
        local unit

        GroupEnumUnitsInRange(g, x, y, aoe, null)
        if structures and magicImmune then
            for i = 0, BlzGroupGetSize(g) - 1 do
                unit = BlzGroupUnitAt(g, i)
                if IsUnitEnemy(unit, player) and UnitAlive(unit) then
                    GroupAddUnit(group, unit)
                end
            end
        elseif structures and not magicImmune then
            for i = 0, BlzGroupGetSize(g) - 1 do
                unit = BlzGroupUnitAt(g, i)
                if IsUnitEnemy(unit, player) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE) then
                    GroupAddUnit(group, unit)
                end
            end
        elseif magicImmune and not structures then
            for i = 0, BlzGroupGetSize(g) - 1 do
                unit = BlzGroupUnitAt(g, i)
                if IsUnitEnemy(unit, player) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) then
                    GroupAddUnit(group, unit)
                end
            end
        else
            for i = 0, BlzGroupGetSize(g) - 1 do
                unit = BlzGroupUnitAt(g, i)
                if IsUnitEnemy(unit, player) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE) then
                    GroupAddUnit(group, unit)
                end
            end
        end
        DestroyGroup(g)

        return group
    end

    -- Returns the closest unit in a unit group with center at x and y
    function GetClosestUnitGroup(x, y, group)
        local md = 100000
        local unit
        local dx
        local dy

        bj_closestUnitGroup = nil
        for i = 0, BlzGroupGetSize(group) - 1 do
            unit = BlzGroupUnitAt(group, i)
            if UnitAlive(unit) then
                dx = GetUnitX(unit) - x
                dy = GetUnitY(unit) - y

                if (dx*dx + dy*dy)/100000 < md then
                    bj_closestUnitGroup = unit
                    md = (dx*dx + dy*dy)/100000
                end
            end
        end

        return bj_closestUnitGroup
    end

    -- Returns true if a unit is disarmed
    function IsUnitDisarmed(unit)
        return Disarm:disarmed(unit)
    end

    -- Disarms an unit for a duration
    function DisarmUnitTimed(unit, duration)
        Disarm:timed(unit, duration)
    end

    -- Disarms an unit if flag is true
    function DisarmUnit(target, flag)
        Disarm:unit(target, flag)
    end

    -- Link an effect to a unit buff or ability
    function LinkEffectToBuff(unit, buffId, model, attach)
        EffectLink:buff(unit, buffId, model, attach)
    end

    -- Link an effect to an unit item.
    function LinkEffectToItem(unit, i, model, attach)
        EffectLink:item(unit, i, model, attach)
    end

    -- Spams the specified effect model at a location with the given interval for the number of times count
    function SpamEffect(model, x, y, z, scale, interval, count)
        local timer = CreateTimer()

        TimerStart(timer, interval, true, function()
            if count > 0 then
                DestroyEffect(AddSpecialEffectEx(model, x, y, z, scale))
            else
                PauseTimer(timer)
                DestroyTimer(timer)
            end
            count = count - 1
        end)
    end

    -- Spams the specified effect model attached to a unit for the given interval for the number of times count
    function SpamEffectUnit(unit, model, attach, interval, count)
        local timer = CreateTimer()

        TimerStart(timer, interval, true, function()
            if count > 0 then
                DestroyEffect(AddSpecialEffectTarget(model, unit, attach))
            else
                PauseTimer(timer)
                DestroyTimer(timer)
            end
            count = count - 1
        end)
    end

    -- Applys Fear to the specified unit for the given duration
    function UnitApplyFear(target, duration, model, attach)
        Fear:unit(target, duration, model, attach)
    end

    -- Returns true if the specified unit is currently under the effect of fear effect
    function IsUnitFeared(unit)
        return Fear:isFeared(unit)
    end

    -- Add the specified ability to the specified unit for the given duration. Use hide to show or not the ability button.
    function UnitAddAbilityTimed(unit, ability, duration, level, hide)
        TimedAbility:add(unit, ability, duration, level, hide)
    end

    -- Resets the specified unit ability cooldown
    function ResetUnitAbilityCooldown(unit, ability)
        local timer = CreateTimer()

        TimerStart(timer, 0.01, false, function()
            BlzEndUnitAbilityCooldown(unit, ability)
            PauseTimer(timer)
            DestroyTimer(timer)
        end)
    end

    -- Knockback the target unit given the angle (Rad) and a distance. Set model and point to attach an effect. Set onCliff to true to make the knockback stop when hitting a cliff, same for the others.
    function KnockbackUnit(unit, angle, distance, duration, model, point, onCliff, onDestructable, onUnit, pause)
        Knockback:start(unit, angle, distance, duration, model, point, onCliff, onDestructable, onUnit, pause)
    end

    -- Returns true if a unit is currently being knocked back
    function IsUnitKnockedBack(unit)
        return Knockback:isUnitKnocked(unit)
    end

    -- Returns the distance between 2 coordinates in Warcraft III units
    function DistanceBetweenCoordinates(x1, y1, x2, y2)
        local dx = (x2 - x1)
        local dy = (y2 - y1)

        return SquareRoot(dx*dx + dy*dy)
    end

    -- Makes the specified source damage an area respecting some basic unit filters
    function UnitDamageArea(unit, x, y, aoe, damage, attacktype, damagetype, structures, magicImmune, allies)
        local group = CreateGroup()

        GroupEnumUnitsInRange(group, x, y, aoe, null)
        GroupRemoveUnit(group, unit)
        if allies then
            if structures and magicImmune then
                for i = 0, BlzGroupGetSize(group) - 1 do
                    local u = BlzGroupUnitAt(group, i)
                    if UnitAlive(u) then
                        UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, null)
                    end
                end
            elseif structures and not magicImmune then
                for i = 0, BlzGroupGetSize(group) - 1 do
                    local u = BlzGroupUnitAt(group, i)
                    if UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) then
                        UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, null)
                    end
                end
            elseif magicImmune and not structures then
                for i = 0, BlzGroupGetSize(group) - 1 do
                    local u = BlzGroupUnitAt(group, i)
                    if UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                        UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, null)
                    end
                end
            else
                for i = 0, BlzGroupGetSize(group) - 1 do
                    local u = BlzGroupUnitAt(group, i)
                    if UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) then
                        UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, null)
                    end
                end
            end
        else
            if structures and magicImmune then
                for i = 0, BlzGroupGetSize(group) - 1 do
                    local u = BlzGroupUnitAt(group, i)
                    local player = GetOwningPlayer(unit)
                    if IsUnitEnemy(u, player) and UnitAlive(u) then
                        UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, null)
                    end
                end
            elseif structures and not magicImmune then
                for i = 0, BlzGroupGetSize(group) - 1 do
                    local u = BlzGroupUnitAt(group, i)
                    local player = GetOwningPlayer(unit)
                    if IsUnitEnemy(u, player) and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) then
                        UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, null)
                    end
                end
            elseif magicImmune and not structures then
                for i = 0, BlzGroupGetSize(group) - 1 do
                    local u = BlzGroupUnitAt(group, i)
                    local player = GetOwningPlayer(unit)
                    if IsUnitEnemy(u, player) and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                        UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, null)
                    end
                end
            else
                for i = 0, BlzGroupGetSize(group) - 1 do
                    local u = BlzGroupUnitAt(group, i)
                    local player = GetOwningPlayer(unit)
                    if IsUnitEnemy(u, player) and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) then
                        UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, null)
                    end
                end
            end
        end
        DestroyGroup(group)
    end

    -- Makes the specified source damage a group. Creates a special effect if specified
    function UnitDamageGroup(unit, group, damage, attacktype, damagetype, effect, attach, destroy)
        for i = 0, BlzGroupGetSize(group) - 1 do
            local u = BlzGroupUnitAt(group, i)
            UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, nil)

            if effect and attach then
                DestroyEffect(AddSpecialEffectTarget(effect, u, attach))
            end
        end

        if destroy then
            DestroyGroup(group)
        end

        return group
    end

    -- Returns a random range given a max value
    function GetRandomRange(radius)
        local r = GetRandomReal(0, 1) + GetRandomReal(0, 1)

        if r > 1 then
            return (2 - r)*radius
        end

        return r*radius
    end

    -- Returns a random value in the x/y coordinates depending on the value of boolean x
    function GetRandomCoordInRange(center, radius, x)
        local theta = 2*bj_PI*GetRandomReal(0, 1)
        local r

        if x then
            r = center + radius*Cos(theta)
        else
            r = center + radius*Sin(theta)
        end

        return r
    end

    -- Clones the items in the source unit inventory to the target unit
    function CloneItems(source, target)
        for i = 0, bj_MAX_INVENTORY do
            local item = UnitItemInSlot(source, i)
            local j = GetItemCharges(item)
            item = CreateItem(GetItemTypeId(item), GetUnitX(target), GetUnitY(target))
            SetItemCharges(item, j)
            UnitAddItem(target, item)
        end
    end

    -- Add the mount for he unit mana pool
    function AddUnitMana(unit, real)
        SetUnitState(unit, UNIT_STATE_MANA, (GetUnitState(unit, UNIT_STATE_MANA) + real))
    end

    -- Add the specified amounts to a hero str/agi/int base amount
    function UnitAddStat(unit, strength, agility, intelligence)
        if strength ~= 0 then
            SetHeroStr(unit, GetHeroStr(unit, false) + strength, true)
        end

        if agility ~= 0 then
            SetHeroAgi(unit, GetHeroAgi(unit, false) + agility, true)
        end

        if intelligence ~= 0 then
            SetHeroInt(unit, GetHeroInt(unit, false) + intelligence, true)
        end
    end

    -- Returns the closest unit from the x and y coordinates in the map
    function GetClosestUnit(x, y, boolexpr)
        local group = CreateGroup()
        local md = 100000

        bj_closestUnitGroup = nil

        GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, boolexpr)
        for i = 0, BlzGroupGetSize(group) - 1 do
            local unit = BlzGroupUnitAt(group, i)
            if UnitAlive(unit) then
                local dx = GetUnitX(unit) - x
                local dy = GetUnitY(unit) - y

                if (dx*dx + dy*dy)/100000 < md then
                    bj_closestUnitGroup = unit
                    md = (dx*dx + dy*dy)/100000
                end
            end
        end
        DestroyGroup(group)
        DestroyBoolExpr(boolexpr)

        return bj_closestUnitGroup
    end

    -- Creates a chain lightning with the specified ligihtning effect with the amount of bounces
    function CreateChainLightning(source, target, damage, aoe, duration, interval, bounces, attacktype, damagetype, lightning, effect, attach, rebounce)
        local player = GetOwningPlayer(source)
        local group = GetEnemyUnitsInRange(player, GetUnitX(target), GetUnitY(target), aoe, false, false)

        if BlzGroupGetSize(group) == 1 then
            DestroyLightningTimed(AddLightningEx(lightning, true, GetUnitX(source), GetUnitY(source), GetUnitZ(source) + 60.0, GetUnitX(target), GetUnitY(target), GetUnitZ(target) + 60.0), duration)
            DestroyEffect(AddSpecialEffectTarget(effect, target, attach))
            UnitDamageTarget(source, target, damage, false, false, attacktype, damagetype, nil)
            DestroyGroup(group)
        else
            local timer = CreateTimer()
            local damaged = CreateGroup()
            local prev = nil
            local this = target
            local next = nil

            GroupRemoveUnit(group, this)
            GroupAddUnit(damaged, this)
            UnitDamageTarget(source, this, damage, false, false, attacktype, damagetype, nil)
            DestroyEffect(AddSpecialEffectTarget(effect, this, attach))
            TimerStart(timer, interval, true, function()
                DestroyGroup(group)
                if bounces > 0 then
                    group = GetEnemyUnitsInRange(player, GetUnitX(this), GetUnitY(this), aoe, false, false)
                    GroupRemoveUnit(group, this)

                    if not rebounce then
                        BlzGroupRemoveGroupFast(damaged, group)
                    end

                    if BlzGroupGetSize(group) == 0 then
                        PauseTimer(timer)
                        DestroyTimer(timer)
                        DestroyGroup(group)
                        DestroyGroup(damaged)
                    else
                        next = GetClosestUnitGroup(GetUnitX(this), GetUnitY(this), group)

                        if next == prev and BlzGroupGetSize(group) > 1 then
                            GroupRemoveUnit(group, prev)
                            next = GetClosestUnitGroup(GetUnitX(this), GetUnitY(this), group)
                        end

                        if next then
                            DestroyLightningTimed(AddLightningEx(lightning, true, GetUnitX(this), GetUnitY(this), GetUnitZ(this) + 60.0, GetUnitX(next), GetUnitY(next), GetUnitZ(next) + 60.0), duration)
                            DestroyEffect(AddSpecialEffectTarget(effect, next, attach))
                            GroupAddUnit(damaged, next)
                            UnitDamageTarget(source, next, damage, false, false, attacktype, damagetype, nil)
                            DestroyGroup(group)
                            prev = this
                            this = next
                            next = nil
                        else
                            PauseTimer(timer)
                            DestroyTimer(timer)
                            DestroyGroup(group)
                            DestroyGroup(damaged)
                        end
                    end
                else
                    PauseTimer(timer)
                    DestroyTimer(timer)
                    DestroyGroup(group)
                    DestroyGroup(damaged)
                end
                bounces = bounces - 1
            end)
        end
        DestroyGroup(group)
    end

    -- Add the specified amount to the specified player gold amount
    function AddPlayerGold(player, amount)
        SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD) + amount)
    end

    -- Unit Knockup
    function KnockupUnit(unit, airTime, maxHeight)
        local timer = CreateTimer()
        local rate  = maxHeight/airTime

        UnitAddAbility(unit, FourCC('Amrf'))
        UnitRemoveAbility(unit, FourCC('Amrf'))
        BlzPauseUnitEx(unit, true)
        SetUnitFlyHeight(unit, (GetUnitDefaultFlyHeight(unit) + maxHeight), rate)

        TimerStart(timer, airTime/2, false, function()
            SetUnitFlyHeight(unit, GetUnitDefaultFlyHeight(unit), rate)
            BlzPauseUnitEx(unit, false)
            PauseTimer(timer)
            DestroyTimer(timer)
        end)
    end

    -- Creates a text tag in an unit position for a duration
    function CreateTextOnUnit(unit, string, duration, red, green, blue, alpha)
        local texttag = CreateTextTag()

        SetTextTagText(texttag, string, 0.015)
        SetTextTagPosUnit(texttag, unit, 0)
        SetTextTagColor(texttag, red, green, blue, alpha)
        SetTextTagLifespan(texttag, duration)
        SetTextTagVelocity(texttag, 0.0, 0.0355)
        SetTextTagPermanent(texttag, false)
    end

    -- Add health regeneration to the unit base value
    function UnitAddHealthRegen(unit, regen)
        BlzSetUnitRealField(unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE, BlzGetUnitRealField(unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE) + regen)
    end

    -- Retrieves a dummy from the pool. Facing angle in radians
    function DummyRetrieve(player, x, y, z, face)
        return DummyPool:retrieve(player, x, y, z, face)
    end

    -- Recycles a dummy unit type, putting it back into the pool.
    function DummyRecycle(unit)
        DummyPool:recycle(unit)
    end

    -- Recycles a dummy with a delay.
    function DummyRecycleTimed(unit, delay)
        DummyPool:timed(unit, delay)
    end

    -- Casts an ability in the target unit. Must have no casting time
    function CastAbilityTarget(unit, ability, order, level)
        local dummy = DummyRetrieve(GetOwningPlayer(unit), 0, 0, 0, 0)

        UnitAddAbility(dummy, ability)
        SetUnitAbilityLevel(dummy, ability, level)
        IssueTargetOrder(dummy, order, unit)
        UnitRemoveAbility(dummy, ability)
        DummyRecycle(dummy)
    end

    -- Silences the specified unit for the given duration
    function SilenceUnit(unit, duration)
        local dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(unit), GetUnitY(unit), GetUnitFlyHeight(unit), 0)
        local ability

        UnitAddAbility(dummy, SILENCE)
        ability = BlzGetUnitAbility(dummy, SILENCE)
        BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_NORMAL, 0, duration)
        BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_HERO, 0, duration)
        IncUnitAbilityLevel(dummy, SILENCE)
        DecUnitAbilityLevel(dummy, SILENCE)
        IssueTargetOrder(dummy, "drunkenhaze", unit)
        UnitRemoveAbility(dummy, SILENCE)
        DummyRecycle(dummy)
    end

    -- Silences a group of units for the given duration
    function SilenceGroup(group, duration)
        local size = BlzGroupGetSize(group)
        local unit
        local dummy
        local ability

        if size > 0 then
            unit = BlzGroupUnitAt(whichGroup, 0)
            dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(unit), GetUnitY(unit), GetUnitFlyHeight(unit), 0)

            UnitAddAbility(dummy, SILENCE)
            ability = BlzGetUnitAbility(dummy, SILENCE)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_HERO, 0, duration)
            IncUnitAbilityLevel(dummy, SILENCE)
            DecUnitAbilityLevel(dummy, SILENCE)

            for i = 0, size - 1 do
                unit = BlzGroupUnitAt(group, i)
                if UnitAlive(unit) then
                    IssueTargetOrder(dummy, "drunkenhaze", unit)
                end
            end
            UnitRemoveAbility(dummy, SILENCE)
            DummyRecycle(dummy)
        end
    end

    -- Silences all units within the specified AOE with the center at x and y for the given duration
    function SilenceArea(x, y, aoe, duration)
        local group = CreateGroup()

        GroupEnumUnitsInRange(group, x, y, aoe, null)
        SilenceGroup(group, duration)
        DestroyGroup(group)
    end

    -- Stuns the specified unit for the given duration
    function StunUnit(unit, duration)
        local dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(unit), GetUnitY(unit), GetUnitFlyHeight(unit), 0)
        local ability

        UnitAddAbility(dummy, STUN)
        ability = BlzGetUnitAbility(dummy, STUN)
        BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_NORMAL, 0, duration)
        BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_HERO, 0, duration)
        IncUnitAbilityLevel(dummy, STUN)
        DecUnitAbilityLevel(dummy, STUN)
        IssueTargetOrder(dummy, "thunderbolt", unit)
        UnitRemoveAbility(dummy, STUN)
        DummyRecycle(dummy)
    end

    -- Stuns a group of units for the given duration
    function StunGroup(group, duration)
        local size = BlzGroupGetSize(group)
        local unit
        local dummy
        local ability

        if size > 0 then
            unit = BlzGroupUnitAt(group, 0)
            dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(unit), GetUnitY(unit), GetUnitFlyHeight(unit), 0)

            UnitAddAbility(dummy, STUN)
            ability = BlzGetUnitAbility(dummy, STUN)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_HERO, 0, duration)
            IncUnitAbilityLevel(dummy, STUN)
            DecUnitAbilityLevel(dummy, STUN)

            for i = 0, size - 1 do
                unit = BlzGroupUnitAt(group, i)
                if UnitAlive(unit) then
                    IssueTargetOrder(dummy, "thunderbolt", unit)
                end
            end
            UnitRemoveAbility(dummy, STUN)
            DummyRecycle(dummy)
        end
    end

    -- Stuns all units within the specified AOE with the center at x and y for the given duration
    function StunArea(x, y, aoe, duration)
        local group = CreateGroup()

        GroupEnumUnitsInRange(group, x, y, aoe, null)
        StunGroup(group, duration)
        DestroyGroup(group)
    end

    -- Slows the specified unit for the given duration
    function SlowUnit(unit, amount, duration)
        local dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(unit), GetUnitY(unit), GetUnitFlyHeight(unit), 0)
        local ability

        UnitAddAbility(dummy, SLOW)
        ability = BlzGetUnitAbility(dummy, SLOW)
        BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_NORMAL, 0, duration)
        BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_HERO, 0, duration)
        BlzSetAbilityRealLevelField(ability, ABILITY_RLF_MOVEMENT_SPEED_REDUCTION_PERCENT_CRI1, 0, amount)
        IncUnitAbilityLevel(dummy, SLOW)
        DecUnitAbilityLevel(dummy, SLOW)
        IssueTargetOrder(dummy, "cripple", unit)
        UnitRemoveAbility(dummy, SLOW)
        DummyRecycle(dummy)
    end

    -- Slows a group of units for the given duration
    function SlowGroup(group, amount, duration)
        local size = BlzGroupGetSize(group)
        local unit
        local dummy
        local ability

        if size > 0 then
            unit = BlzGroupUnitAt(group, 0)
            dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetUnitX(unit), GetUnitY(unit), GetUnitFlyHeight(unit), 0)

            UnitAddAbility(dummy, SLOW)
            ability = BlzGetUnitAbility(dummy, SLOW)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_HERO, 0, duration)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_MOVEMENT_SPEED_FACTOR_SLO1, 0, amount)
            IncUnitAbilityLevel(dummy, SLOW)
            DecUnitAbilityLevel(dummy, SLOW)

            for i = 0, size - 1 do
                unit = BlzGroupUnitAt(group, i)
                if UnitAlive(unit) then
                    IssueTargetOrder(dummy, "cripple", unit)
                end
            end
            UnitRemoveAbility(dummy, SLOW)
            DummyRecycle(dummy)
        end
    end

    -- Slows all units within the specified AOE with the center at x and y for the given duration
    function SlowArea(x, y, aoe, amount, duration)
        local group = CreateGroup()

        GroupEnumUnitsInRange(group, x, y, aoe, null)
        SlowGroup(group, amount, duration)
        DestroyGroup(group)
    end

    -- Returns a random unit within a group
    function GroupPickRandomUnitEx(group)
        if BlzGroupGetSize(group) > 0 then
            return BlzGroupUnitAt(group, GetRandomInt(0, BlzGroupGetSize(group) - 1))
        else
            return nil
        end
    end

    -- Returns true if a unit is within a cone given a facing and fov angle in degrees (Less precise)
    function IsUnitInConeEx(unit, x, y, face, fov)
        return Acos(Cos((Atan2(GetUnitY(unit) - y, GetUnitX(unit) - x)) - face*bj_DEGTORAD)) < fov*bj_DEGTORAD/2
    end

    -- Returns true if a unit is within a cone given a facing, fov angle and a range in degrees (takes collision into consideration). Credits to AGD.
    function IsUnitInCone(unit, x, y, range, face, fov)
        if IsUnitInRangeXY(unit, x, y, range) then
            x = GetUnitX(unit) - x
            y = GetUnitY(unit) - y
            range = x*x + y*y

            if range > 0 then
                face = face*bj_DEGTORAD - Atan2(y, x)
                fov = fov*bj_DEGTORAD/2 + Asin(BlzGetUnitCollisionSize(unit)/SquareRoot(range))

                return RAbsBJ(face) <= fov or RAbsBJ(face - 2.00*bj_PI) <= fov
            end

            return true
        end

        return false
    end

    -- Makes the source unit damage enemy unit in a cone given a direction, foy and range
    function UnitDamageCone(unit, x, y, face, fov, aoe, damage, attacktype, damagetype, structures, magicImmune, allies)
        local group  = CreateGroup()
        local player = GetOwningPlayer(unit)
        local u

        GroupEnumUnitsInRange(group, x, y, aoe, null)
        GroupRemoveUnit(group, unit)
        if allies then
            if structures and magicImmune then
                for i = 0, BlzGroupGetSize(group) - 1 do
                    u = BlzGroupUnitAt(group, i)
                    if UnitAlive(u) and IsUnitInCone(u, x, y, aoe, face, fov) then
                        UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, null)
                    end
                end
            elseif structures and not magicImmune then
                for i = 0, BlzGroupGetSize(group) - 1 do
                    u = BlzGroupUnitAt(group, i)
                    if UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) and IsUnitInCone(u, x, y, aoe, face, fov) then
                        UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, null)
                    end
                end
            elseif magicImmune and not structures then
                for i = 0, BlzGroupGetSize(group) - 1 do
                    u = BlzGroupUnitAt(group, i)
                    if UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and IsUnitInCone(u, x, y, aoe, face, fov) then
                        UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, null)
                    end
                end
            else
                for i = 0, BlzGroupGetSize(group) - 1 do
                    u = BlzGroupUnitAt(group, i)
                    if UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) and IsUnitInCone(u, x, y, aoe, face, fov) then
                        UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, null)
                    end
                end
            end
        else
            if structures and magicImmune then
                for i = 0, BlzGroupGetSize(group) - 1 do
                    u = BlzGroupUnitAt(group, i)
                    if IsUnitEnemy(u, player) and UnitAlive(u) and IsUnitInCone(u, x, y, aoe, face, fov) then
                        UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, null)
                    end
                end
            elseif structures and not magicImmune then
                for i = 0, BlzGroupGetSize(group) - 1 do
                    u = BlzGroupUnitAt(group, i)
                    if IsUnitEnemy(u, player) and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) and IsUnitInCone(u, x, y, aoe, face, fov) then
                        UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, null)
                    end
                end
            elseif magicImmune and not structures then
                for i = 0, BlzGroupGetSize(group) - 1 do
                    u = BlzGroupUnitAt(group, i)
                    if IsUnitEnemy(u, player) and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and IsUnitInCone(u, x, y, aoe, face, fov) then
                        UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, null)
                    end
                end
            else
                for i = 0, BlzGroupGetSize(group) - 1 do
                    u = BlzGroupUnitAt(group, i)
                    if IsUnitEnemy(u, player) and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) and IsUnitInCone(u, x, y, aoe, face, fov) then
                        UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, null)
                    end
                end
            end
        end
        DestroyGroup(group)
    end

    -- Heals all allied units of specified player in an area
    function HealArea(player, x, y, aoe, amount, effect, attach)
        local group = CreateGroup()
        local unit

        GroupEnumUnitsInRange(group, x, y, aoe, null)
        for i = 0, BlzGroupGetSize(group) - 1 do
            unit = BlzGroupUnitAt(group, i)
            if IsUnitAlly(unit, player) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) then
                SetWidgetLife(unit, GetWidgetLife(unit) + amount)
                if effect ~= "" then
                    if attach ~= "" then
                        DestroyEffect(AddSpecialEffectTarget(effect, unit, attach))
                    else
                        DestroyEffect(AddSpecialEffect(effect, GetUnitX(unit), GetUnitY(unit)))
                    end
                end
            end
        end
        DestroyGroup(group)
    end

    -- Pretty obvious.
    function R2I2S(real)
        return I2S(R2I(real))
    end

    -- Returns an ability real level field as a string. Usefull for toolltip manipulation.
    function AbilityRealField(unit, ability, field, level, multiplier, integer)
        if integer then
            return R2I2S(BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, level)*multiplier)
        else
            return R2SW(BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, level)*multiplier, 1, 1)
        end
    end

    -- Fix for camera pan desync. credits do Daffa
    function SmartCameraPanBJModified(player, loc, duration)
        local x = GetLocationX(loc)
        local y = GetLocationY(loc)
        local dx = x - GetCameraTargetPositionX()
        local dy = y - GetCameraTargetPositionY()
        local dist = SquareRoot(dx*dx + dy*dy)

        if GetLocalPlayer() == player then
            if dist >= bj_SMARTPAN_TRESHOLD_SNAP then
                PanCameraToTimed(x, y, duration)
            elseif dist >= bj_SMARTPAN_TRESHOLD_PAN then
                PanCameraToTimed(x, y, duration)
            else
                -- User is close, dont move camera
            end
        end
    end

    -- Fix for camera pan desync. credits do Daffa
    function SmartCameraPanBJModifiedXY(player, x, y, duration)
        local dx = x - GetCameraTargetPositionX()
        local dy = y - GetCameraTargetPositionY()
        local dist = SquareRoot(dx*dx + dy*dy)

        if GetLocalPlayer() == player then
            if dist >= bj_SMARTPAN_TRESHOLD_SNAP then
                PanCameraToTimed(x, y, duration)
            elseif dist >= bj_SMARTPAN_TRESHOLD_PAN then
                PanCameraToTimed(x, y, duration)
            else
                -- User is close, dont move camera
            end
        end
    end

    -- Start the cooldown for the source unit unit the new value
    function StartUnitAbilityCooldown(unit, ability, cooldown)
        local timer = CreateTimer()

        TimerStart(timer, 0.01, false, function()
            BlzStartUnitAbilityCooldown(unit, ability, cooldown)
            PauseTimer(timer)
            DestroyTimer(timer)
        end)
    end
end