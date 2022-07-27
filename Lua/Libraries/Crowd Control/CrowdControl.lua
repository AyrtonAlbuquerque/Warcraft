--[[ requires Utilities, Missiles, Indexer, TimerUtils, RegisterPlayerUnitEvent, optional Tenacity
    -- ------------------------------------- Crowd Control v1.0 ------------------------------------- --
    -- How to Import:
    -- 1 - Copy the Utilities library over to your map and follow its install instructions
    -- 2 - Copy the Missiles libraries over to your map and follow their install instructions
    -- 3 - Copy the Indexer library over to your map and follow its install instructions
    -- 4 - Copy the TimerUtils library over to your map and follow its install instructions
    -- 5 - Copy the RegisterPlayerUnitEvent library over to your map and follow its install instructions
    -- 6 - Copy the Tenacity library over to your map and follow its install instructions
    -- 7 - Copy this library into your map
    -- 8 - Copy the 13 buffs and 13 abilities with the CC prefix and match their raw code below.
    -- ---------------------------------------- By Chopinski ---------------------------------------- --
]]--

do
    -- ---------------------------------------------------------------------------------------------- --
    --                                          Configuration                                         --
    -- ---------------------------------------------------------------------------------------------- --
    -- The raw code of the silence ability
    local SILENCE            = FourCC('U000')
    -- The raw code of the stun ability
    local STUN               = FourCC('U001')
    -- The raw code of the attack slow ability
    local ATTACK_SLOW        = FourCC('U002')
    -- The raw code of the movement slow ability
    local MOVEMENT_SLOW      = FourCC('U003')
    -- The raw code of the banish ability
    local BANISH             = FourCC('U004')
    -- The raw code of the ensnare ability
    local ENSNARE            = FourCC('U005')
    -- The raw code of the purge ability
    local PURGE              = FourCC('U006')
    -- The raw code of the hex ability
    local HEX                = FourCC('U007')
    -- The raw code of the sleep ability
    local SLEEP              = FourCC('U008')
    -- The raw code of the cyclone ability
    local CYCLONE            = FourCC('U009')
    -- The raw code of the entangle ability
    local ENTANGLE           = FourCC('U010')
    -- The raw code of the disarm ability
    local DISARM             = FourCC('U011')
    -- The raw code of the fear ability
    local FEAR               = FourCC('U012')
    -- The raw code of the silence buff
    local SILENCE_BUFF       = FourCC('BU00')
    -- The raw code of the stun buff
    local STUN_BUFF          = FourCC('BU01')
    -- The raw code of the attack slow buff
    local ATTACK_SLOW_BUFF   = FourCC('BU02')
    -- The raw code of the movement slow buff
    local MOVEMENT_SLOW_BUFF = FourCC('BU03')
    -- The raw code of the banish buff
    local BANISH_BUFF        = FourCC('BU04')
    -- The raw code of the ensnare buff
    local ENSNARE_BUFF       = FourCC('BU05')
    -- The raw code of the purge buff
    local PURGE_BUFF         = FourCC('BU06')
    -- The raw code of the hex buff
    local HEX_BUFF           = FourCC('BU07')
    -- The raw code of the sleep buff
    local SLEEP_BUFF         = FourCC('BU08')
    -- The raw code of the cyclone buff
    local CYCLONE_BUFF       = FourCC('BU09')
    -- The raw code of the entangle buff
    local ENTANGLE_BUFF      = FourCC('BU10')
    -- The raw code of the disarm buff
    local DISARM_BUFF        = FourCC('BU11')
    -- The raw code of the fear buff
    local FEAR_BUFF          = FourCC('BU12')

    -- This is the maximum recursion limit allowed by the system.
    -- It's value must be greater than or equal to 0. When equal to 0
    -- no recursion is allowed. Values too big can cause screen freezes.
    local RECURSION_LIMIT    = 8

    -- The Crowd Control types
    CROWD_CONTROL_SILENCE      = 0
    CROWD_CONTROL_STUN         = 1
    CROWD_CONTROL_SLOW         = 2
    CROWD_CONTROL_SLOW_ATTACK  = 3
    CROWD_CONTROL_BANISH       = 4
    CROWD_CONTROL_ENSNARE      = 5
    CROWD_CONTROL_PURGE        = 6
    CROWD_CONTROL_HEX          = 7
    CROWD_CONTROL_SLEEP        = 8
    CROWD_CONTROL_CYCLONE      = 9
    CROWD_CONTROL_ENTANGLE     = 10
    CROWD_CONTROL_DISARM       = 11
    CROWD_CONTROL_FEAR         = 12
    CROWD_CONTROL_KNOCKBACK    = 13
    CROWD_CONTROL_KNOCKUP      = 14

    -- ---------------------------------------------------------------------------------------------- --
    --                                             LUA API                                            --
    -- ---------------------------------------------------------------------------------------------- --
    -- ------------------------------------------- Disarm ------------------------------------------- --
    function DisarmUnit(unit, duration, model, point, stack)
        CrowdControl:disarm(unit, duration, model, point, stack)
    end

    function IsUnitDisarmed(unit)
        return CrowdControl:disarmed(unit)
    end

    -- -------------------------------------------- Fear -------------------------------------------- --
    function FearUnit(unit, duration, model, point, stack)
        CrowdControl:fear(unit, duration, model, point, stack)
    end

    function IsUnitFeared(unit)
        return CrowdControl:feared(unit)
    end

    -- ------------------------------------------ Knockback ----------------------------------------- --
    function KnockbackUnit(unit, angle, distance, duration, model, point, onCliff, onDestructable, onUnit, stack)
        CrowdControl:knockback(unit, angle, distance, duration, model, point, onCliff, onDestructable, onUnit, stack)
    end

    function IsUnitKnockedBack(unit)
        return CrowdControl:knockedback(unit)
    end

    -- ------------------------------------------- Knockup ------------------------------------------ --
    function KnockupUnit(unit, height, duration, model, point, stack)
        CrowdControl:knockup(unit, height, duration, model, point, stack)
    end

    function IsUnitKnockedUp(unit)
        return CrowdControl:knockedup(unit)
    end

    -- ------------------------------------------- Silence ------------------------------------------ --
    function SilenceUnit(unit, duration, model, point, stack)
        CrowdControl:silence(unit, duration, model, point, stack)
    end

    function IsUnitSilenced(unit)
        return CrowdControl:silenced(unit)
    end

    -- -------------------------------------------- Stun -------------------------------------------- --
    function StunUnit(unit, duration, model, point, stack)
        CrowdControl:stun(unit, duration, model, point, stack)
    end

    function IsUnitStunned(unit)
        return CrowdControl:stunned(unit)
    end

    -- ---------------------------------------- Movement Slow --------------------------------------- --
    function SlowUnit(unit, amount, duration, model, point, stack)
        CrowdControl:slow(unit, amount, duration, model, point, stack)
    end

    function IsUnitSlowed(unit)
        return CrowdControl:slowed(unit)
    end

    -- ----------------------------------------- Attack Slow ---------------------------------------- --
    function SlowUnitAttack(unit, amount, duration, model, point, stack)
        CrowdControl:slowAttack(unit, amount, duration, model, point, stack)
    end

    function IsUnitAttackSlowed(unit)
        return CrowdControl:attackSlowed(unit)
    end

    -- ------------------------------------------- Banish ------------------------------------------- --
    function BanishUnit(unit, duration, model, point, stack)
        CrowdControl:banish(unit, duration, model, point, stack)
    end

    function IsUnitBanished(unit)
        return CrowdControl:banished(unit)
    end

    -- ------------------------------------------- Ensnare ------------------------------------------ --
    function EnsnareUnit(unit, duration, model, point, stack)
        CrowdControl:ensnare(unit, duration, model, point, stack)
    end

    function IsUnitEnsnared(unit)
        return CrowdControl:ensnared(unit)
    end

    -- -------------------------------------------- Purge ------------------------------------------- --
    function PurgeUnit(unit, duration, model, point, stack)
        CrowdControl:purge(unit, duration, model, point, stack)
    end

    function IsUnitPurged(unit)
        return CrowdControl:purged(unit)
    end

    -- --------------------------------------------- Hex -------------------------------------------- --
    function HexUnit(unit, duration, model, point, stack)
        CrowdControl:hex(unit, duration, model, point, stack)
    end

    function IsUnitHexed(unit)
        return CrowdControl:hexed(unit)
    end

    -- -------------------------------------------- Sleep ------------------------------------------- --
    function SleepUnit(unit, duration, model, point, stack)
        CrowdControl:sleep(unit, duration, model, point, stack)
    end

    function IsUnitSleeping(unit)
        return CrowdControl:sleeping(unit)
    end

    -- ------------------------------------------- Cyclone ------------------------------------------ --
    function CycloneUnit(unit, duration, model, point, stack)
        CrowdControl:cyclone(unit, duration, model, point, stack)
    end

    function IsUnitCycloned(unit)
        return CrowdControl:cycloned(unit)
    end

    -- ------------------------------------------ Entangle ------------------------------------------ --
    function EntangleUnit(unit, duration, model, point, stack)
        CrowdControl:entangle(unit, duration, model, point, stack)
    end

    function IsUnitEntangled(unit)
        return CrowdControl:entangled(unit)
    end

    -- ------------------------------------------- Dispel ------------------------------------------- --
    function UnitDispelCrowdControl(unit, type)
        CrowdControl:dispel(unit, type)
    end

    function UnitDispelAllCrowdControl(unit)
        CrowdControl:dispelAll(unit)
    end

    -- ------------------------------------------- Events ------------------------------------------- --
    function RegisterCrowdControlEvent(type, code)
        CrowdControl:register(type, code)
    end

    function RegisterAnyCrowdControlEvent(code)
        CrowdControl:register(-1, code)
    end

    function GetCrowdControlUnit()
        return CrowdControl.unit[CrowdControl.key]
    end

    function GetCrowdControlType()
        return CrowdControl.type[CrowdControl.key]
    end

    function GetCrowdControlDuration()
        return CrowdControl.duration[CrowdControl.key]
    end

    function GetCrowdControlAmount()
        return CrowdControl.amount[CrowdControl.key]
    end

    function GetKnockbackAngle()
        return CrowdControl.angle[CrowdControl.key]
    end

    function GetKnockbackDistance()
        return CrowdControl.distance[CrowdControl.key]
    end

    function GetKnockupHeight()
        return CrowdControl.height[CrowdControl.key]
    end

    function GetCrowdControlModel()
        return CrowdControl.model[CrowdControl.key]
    end

    function GetCrowdControlBone()
        return CrowdControl.point[CrowdControl.key]
    end

    function GetCrowdControlStack()
        return CrowdControl.stack[CrowdControl.key]
    end

    function GetKnockbackOnCliff()
        return CrowdControl.cliff[CrowdControl.key]
    end

    function GetKnockbackOnDestructable()
        return CrowdControl.destructable[CrowdControl.key]
    end

    function GetKnockbackOnUnit()
        return CrowdControl.agent[CrowdControl.key]
    end

    function GetCrowdControlRemaining(unit, type)
        return CrowdControl:remaining(unit, type)
    end

    function SetCrowdControlUnit(unit)
        CrowdControl.unit[CrowdControl.key] = unit
    end

    function SetCrowdControlType(type)
        if type >= CROWD_CONTROL_SILENCE and type <= CROWD_CONTROL_KNOCKUP then
            CrowdControl.type[CrowdControl.key] = type
        end
    end

    function SetCrowdControlDuration(duration)
        CrowdControl.duration[CrowdControl.key] = duration
    end

    function SetCrowdControlAmount(amount)
        CrowdControl.amount[CrowdControl.key] = amount
    end

    function SetKnockbackAngle(angle)
        CrowdControl.angle[CrowdControl.key] = angle
    end

    function SetKnockbackDistance(distance)
        CrowdControl.distance[CrowdControl.key] = distance
    end

    function SetKnockupHeight(height)
        CrowdControl.height[CrowdControl.key] = height
    end

    function SetCrowdControlModel(model)
        CrowdControl.model[CrowdControl.key] = model
    end

    function SetCrowdControlBone(point)
        CrowdControl.point[CrowdControl.key] = point
    end

    function SetCrowdControlStack(stack)
        CrowdControl.stack[CrowdControl.key] = stack
    end

    function SetKnockbackOnCliff(onCliff)
        CrowdControl.cliff[CrowdControl.key] = onCliff
    end

    function SetKnockbackOnDestructable(onDestructable)
        CrowdControl.destructable[CrowdControl.key] = onDestructable
    end

    function SetKnockbackOnUnit(onUnit)
        CrowdControl.agent[CrowdControl.key] = onUnit
    end

    -- ---------------------------------------------------------------------------------------------- --
    --                                             Systems                                            --
    -- ---------------------------------------------------------------------------------------------- --
    -- ------------------------------------------ Knockback ----------------------------------------- --
    do
        Knockback = setmetatable({}, {})
        local mt = getmetatable(Knockback)
        mt.__index = mt

        local knocked = {}

        function mt:isUnitKnocked(unit)
            return (knocked[unit] or 0) > 0
        end

        function mt:apply(target, angle, distance, duration, model, point, cliff, dest, hit)
            local x = GetUnitX(target)
            local y = GetUnitY(target)
            local this = Missiles:create(x, y, 0, x + distance*Cos(angle), y + distance*Sin(angle), 0)

            this.source = target
            this:duration(duration)
            this.collision = 2*BlzGetUnitCollisionSize(target)
            this.cliff = cliff
            this.dest = dest
            this.hit = hit
            knocked[target] = (knocked[target] or 0) + 1

            if model and point then
                this.attachment = AddSpecialEffectTarget(model, target, point)
            end

            if (knocked[target] or 0) == 1 then
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
                if this.hit and unit ~= this.source then
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

                if (knocked[this.source] or 0) == 0 then
                    BlzPauseUnitEx(this.source, false)
                end
            end

            this:launch()
        end
    end

    -- ------------------------------------------- Knockup ------------------------------------------ --
    do
        Knockup = setmetatable({}, {})
        local mt = getmetatable(Knockup)
        mt.__index = mt

        local knocked = {}

        function mt:isUnitKnocked(unit)
            return (knocked[unit] or 0) > 0
        end

        function mt:apply(unit, duration, height, model, point)
            if duration > 0 then
                local timer = CreateTimer()
                local rate = height/duration
                local effect

                knocked[unit] = (knocked[unit] or 0) + 1

                if model and point then
                    effect = AddSpecialEffect(model, unit, point)
                end

                if knocked[unit] == 1 then
                    BlzPauseUnitEx(unit, true)
                end

                UnitAddAbility(unit, FourCC('Amrf'))
                UnitRemoveAbility(unit, FourCC('Amrf'))
                SetUnitFlyHeight(unit, (GetUnitDefaultFlyHeight(unit) + height), rate)

                TimerStart(timer, duration/2, false, function()
                    SetUnitFlyHeight(unit, GetUnitDefaultFlyHeight(unit), rate)
                    TimerStart(timer, duration/2, false, function()
                        DestroyEffect(effect)
                        PauseTimer(timer)
                        DestroyTimer(timer)

                        knocked[unit] = knocked[unit] - 1

                        if knocked[unit] == 0 then
                            BlzPauseUnitEx(unit, false)
                        end
                    end)
                end)
            end
        end
    end

    -- -------------------------------------------- Fear -------------------------------------------- --
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
        local dummy

        function mt:feared(unit)
            return GetUnitAbilityLevel(unit, FEAR_BUFF) > 0
        end

        function mt:destroy(i)
            flag[self.target] = true
            IssueImmediateOrder(self.target, "stop")
            DestroyEffect(self.effect)

            array[i] = array[key]
            key = key - 1
            struct[self.target] = nil
            self = nil

            if key == 0 then
                PauseTimer(timer)
            end

            return i - 1
        end

        function mt:apply(target, duration, effect, attach)
            local this

            if duration > 0 then
                UnitAddAbility(dummy, FEAR)
                local ability = BlzGetUnitAbility(dummy, FEAR)
                BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_NORMAL, 0, duration)
                BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_HERO, 0, duration)
                IncUnitAbilityLevel(dummy, FEAR)
                DecUnitAbilityLevel(dummy, FEAR)

                if IssueTargetOrder(dummy, "drunkenhaze", target) then
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

                        if effect and attach then
                            this.effect = AddSpecialEffectTarget(effect, target, attach)
                        end

                        if key == 1 then
                            TimerStart(timer, UPDATE, true, function()
                                local i = 1
                                local this

                                while i <= key do
                                    this = array[i]

                                    if GetUnitAbilityLevel(this.target, FEAR_BUFF) > 0 then
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

                    flag[target] = true
                    x[target] = GetRandomReal(GetUnitX(target) - MAX_CHANGE, GetUnitX(target) + MAX_CHANGE)
                    y[target] = GetRandomReal(GetUnitY(target) - MAX_CHANGE, GetUnitY(target) + MAX_CHANGE)
                    IssuePointOrder(target, "move", x[target], y[target])
                end

                UnitRemoveAbility(dummy, FEAR)
            end
        end

        function mt:onOrder()
            local unit = GetOrderedUnit()

            if self:feared(unit) and GetIssuedOrderId() ~= 851973 then
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

            TimerStart(CreateTimer(), 0, false, function()
                dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetRectCenterX(GetWorldBounds()), GetRectCenterY(GetWorldBounds()), 0, 0)
                PauseTimer(GetExpiredTimer())
                DestroyTimer(GetExpiredTimer())
            end)
        end)
    end

    -- ---------------------------------------- Crowd Control --------------------------------------- --
    do
        CrowdControl = setmetatable({}, {})
        local mt = getmetatable(CrowdControl)
        mt.__index = mt

        CrowdControl.key = 0
        CrowdControl.unit = {}
        CrowdControl.amount = {}
        CrowdControl.duration = {}
        CrowdControl.angle = {}
        CrowdControl.distance = {}
        CrowdControl.height = {}
        CrowdControl.model = {}
        CrowdControl.point = {}
        CrowdControl.stack = {}
        CrowdControl.cliff = {}
        CrowdControl.destructable = {}
        CrowdControl.agent = {}
        CrowdControl.type = {}

        local trigger = {}
        local timer = {}
        local event = {}
        local ability = {}
        local buff = {}
        local dummy

        onInit(function()
            local t = CreateTimer()

            TimerStart(t, 0, false, function()
                dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetRectCenterX(GetWorldBounds()), GetRectCenterY(GetWorldBounds()), 0, 0)
                PauseTimer(t)
                DestroyTimer(t)
            end)
        end)

        function mt:onEvent(key)
            local i = 0
            local next = -1
            local prev = -2

            while CrowdControl.type[key] ~= next do
                next = CrowdControl.type[key]

                if event[next] then
                    for j = 1, #event[next] do
                        event[next][j]()
                    end
                end

                if CrowdControl.type[key] ~= next then
                    i = i + 1
                else
                    if next ~= prev then
                        for j = 1, #trigger do
                            trigger[j]()
                        end

                        if CrowdControl.type[key] ~= next then
                            i = i + 1
                            prev = next
                        end
                    end
                end

                if i - CROWD_CONTROL_KNOCKUP > RECURSION_LIMIT then
                    print("[Crowd Control] Recursion limit reached: " .. RECURSION_LIMIT)
                    break
                end
            end

            CrowdControl.key = key
        end

        function mt:order(type)
            if type == CROWD_CONTROL_SILENCE or type == CROWD_CONTROL_DISARM then
                return "drunkenhaze"
            elseif type == CROWD_CONTROL_STUN then
                return "thunderbolt"
            elseif type == CROWD_CONTROL_SLOW then
                return "cripple"
            elseif type == CROWD_CONTROL_SLOW_ATTACK then
                return "cripple"
            elseif type == CROWD_CONTROL_BANISH then
                return "banish"
            elseif type == CROWD_CONTROL_ENSNARE then
                return "ensnare"
            elseif type == CROWD_CONTROL_PURGE then
                return "purge"
            elseif type == CROWD_CONTROL_HEX then
                return "hex"
            elseif type == CROWD_CONTROL_SLEEP then
                return "sleep"
            elseif type == CROWD_CONTROL_CYCLONE then
                return "cyclone"
            elseif type == CROWD_CONTROL_ENTANGLE then
                return "entanglingroots"
            else
                return nil
            end
        end

        function mt:setup(type, key)
            if type == CROWD_CONTROL_SILENCE then
                ability[key] = SILENCE
                buff[key] = SILENCE_BUFF
            elseif type == CROWD_CONTROL_STUN then
                ability[key] = STUN
                buff[key] = STUN_BUFF
            elseif type == CROWD_CONTROL_SLOW then
                ability[key] = ATTACK_SLOW
                buff[key] = ATTACK_SLOW_BUFF
            elseif type == CROWD_CONTROL_SLOW_ATTACK then
                ability[key] = MOVEMENT_SLOW
                buff[key] = MOVEMENT_SLOW_BUFF
            elseif type == CROWD_CONTROL_BANISH then
                ability[key] = BANISH
                buff[key] = BANISH_BUFF
            elseif type == CROWD_CONTROL_ENSNARE then
                ability[key] = ENSNARE
                buff[key] = ENSNARE_BUFF
            elseif type == CROWD_CONTROL_PURGE then
                ability[key] = PURGE
                buff[key] = PURGE_BUFF
            elseif type == CROWD_CONTROL_HEX then
                ability[key] = HEX
                buff[key] = HEX_BUFF
            elseif type == CROWD_CONTROL_SLEEP then
                ability[key] = SLEEP
                buff[key] = SLEEP_BUFF
            elseif type == CROWD_CONTROL_CYCLONE then
                ability[key] = CYCLONE
                buff[key] = CYCLONE_BUFF
            elseif type == CROWD_CONTROL_ENTANGLE then
                ability[key] = ENTANGLE
                buff[key] = ENTANGLE_BUFF
            elseif type == CROWD_CONTROL_DISARM then
                ability[key] = DISARM
                buff[key] = DISARM_BUFF
            end
        end

        function mt:cast(target, amount, angle, distance, height, duration, model, point, stack, onCliff, onDestructable, onUnit, type)
            if not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE) and UnitAlive(target) and duration > 0 then
                CrowdControl.key = CrowdControl.key + 1
                CrowdControl.unit[CrowdControl.key] = target
                CrowdControl.amount[CrowdControl.key] = amount
                CrowdControl.angle[CrowdControl.key] = angle
                CrowdControl.distance[CrowdControl.key] = distance
                CrowdControl.height[CrowdControl.key] = height
                CrowdControl.duration[CrowdControl.key] = duration
                CrowdControl.model[CrowdControl.key] = model
                CrowdControl.point[CrowdControl.key] = point
                CrowdControl.stack[CrowdControl.key] = stack
                CrowdControl.cliff[CrowdControl.key] = onCliff
                CrowdControl.destructable[CrowdControl.key] = onDestructable
                CrowdControl.agent[CrowdControl.key] = onUnit
                CrowdControl.type[CrowdControl.key] = type

                self:onEvent(CrowdControl.key)

                if Tenacity then
                    CrowdControl.duration[CrowdControl.key] = GetTenacityDuration(CrowdControl.unit[CrowdControl.key], CrowdControl.duration[CrowdControl.key])
                end

                if CrowdControl.duration[CrowdControl.key] > 0 and UnitAlive(CrowdControl.unit[CrowdControl.key]) then
                    local i = CrowdControl.unit[CrowdControl.key]
                    local j = CrowdControl.type[CrowdControl.key]

                    if not timer[i] then timer[i] = {} end
                    if not timer[i][j] then
                        timer[i][j] = CreateTimer()
                    end

                    if CrowdControl.stack[CrowdControl.key] then
                        CrowdControl.duration[CrowdControl.key] = CrowdControl.duration[CrowdControl.key] + TimerGetRemaining(timer[i][j])
                    end

                    if CrowdControl.type[CrowdControl.key] ~= CROWD_CONTROL_FEAR and CrowdControl.type[CrowdControl.key] ~= CROWD_CONTROL_KNOCKBACK and CrowdControl.type[CrowdControl.key] ~= CROWD_CONTROL_KNOCKUP then
                        self:setup(CrowdControl.type[CrowdControl.key], CrowdControl.key)
                        UnitAddAbility(dummy, ability[CrowdControl.key])
                        local spell = BlzGetUnitAbility(dummy, ability[CrowdControl.key])
                        BlzSetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_NORMAL, 0, CrowdControl.duration[CrowdControl.key])
                        BlzSetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_HERO, 0, CrowdControl.duration[CrowdControl.key])

                        if CrowdControl.type[CrowdControl.key] == CROWD_CONTROL_SLOW then
                            BlzSetAbilityRealLevelField(spell, ABILITY_RLF_MOVEMENT_SPEED_REDUCTION_PERCENT_CRI1, 0, CrowdControl.amount[CrowdControl.key])
                        elseif CrowdControl.type[CrowdControl.key] == CROWD_CONTROL_SLOW_ATTACK then
                            BlzSetAbilityRealLevelField(spell, ABILITY_RLF_ATTACK_SPEED_REDUCTION_PERCENT_CRI2, 0, CrowdControl.amount[CrowdControl.key])
                        end

                        IncUnitAbilityLevel(dummy, ability[CrowdControl.key])
                        DecUnitAbilityLevel(dummy, ability[CrowdControl.key])
                        UnitRemoveAbility(CrowdControl.unit[CrowdControl.key], buff[CrowdControl.key])

                        if IssueTargetOrder(dummy, self:order(CrowdControl.type[CrowdControl.key]), CrowdControl.unit[CrowdControl.key]) then
                            TimerStart(timer[i][j], CrowdControl.duration[CrowdControl.key], false, function()
                                PauseTimer(timer[i][j])
                                DestroyTimer(timer[i][j])
                                timer[i][j] = nil
                            end)

                            if CrowdControl.model[CrowdControl.key] then
                                if CrowdControl.point[CrowdControl.key] then
                                    LinkEffectToBuff(CrowdControl.unit[CrowdControl.key], buff[CrowdControl.key], CrowdControl.model[CrowdControl.key], CrowdControl.point[CrowdControl.key])
                                else
                                    DestroyEffect(AddSpecialEffect(CrowdControl.model[CrowdControl.key], GetUnitX(CrowdControl.unit[CrowdControl.key]), GetUnitY(CrowdControl.unit[CrowdControl.key])))
                                end
                            end
                        else
                            PauseTimer(timer[i][j])
                            DestroyTimer(timer[i][j])
                            timer[i][j] = nil
                        end

                        UnitRemoveAbility(dummy, ability[CrowdControl.key])
                    else
                        if CrowdControl.type[CrowdControl.key] == CROWD_CONTROL_FEAR then
                            Fear:apply(CrowdControl.unit[CrowdControl.key], CrowdControl.duration[CrowdControl.key], CrowdControl.model[CrowdControl.key], CrowdControl.point[CrowdControl.key])
                        elseif CrowdControl.type[CrowdControl.key] == CROWD_CONTROL_KNOCKBACK then
                            Knockback:apply(CrowdControl.unit[CrowdControl.key], CrowdControl.angle[CrowdControl.key], CrowdControl.distance[CrowdControl.key], CrowdControl.duration[CrowdControl.key], CrowdControl.model[CrowdControl.key], CrowdControl.point[CrowdControl.key], CrowdControl.cliff[CrowdControl.key], CrowdControl.destructable[CrowdControl.key], CrowdControl.agent[CrowdControl.key])
                        elseif CrowdControl.type[CrowdControl.key] == CROWD_CONTROL_KNOCKUP then
                            Knockup:apply(CrowdControl.unit[CrowdControl.key], CrowdControl.duration[CrowdControl.key], CrowdControl.height[CrowdControl.key], CrowdControl.model[CrowdControl.key], CrowdControl.point[CrowdControl.key])
                        end

                        TimerStart(timer[i][j], CrowdControl.duration[CrowdControl.key], false, function()
                            PauseTimer(timer[i][j])
                            DestroyTimer(timer[i][j])
                            timer[i][j] = nil
                        end)
                    end
                end

                if CrowdControl.key > 0 then
                    CrowdControl.key = CrowdControl.key - 1
                end
            end
        end

        function mt:silence(unit, duration, model, point, stack)
            self:cast(unit, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_SILENCE)
        end

        function mt:silenced(unit)
            return GetUnitAbilityLevel(unit, SILENCE_BUFF) > 0
        end

        function mt:stun(unit, duration, model, point, stack)
            self:cast(unit, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_STUN)
        end

        function mt:stunned(unit)
            return GetUnitAbilityLevel(unit, STUN_BUFF) > 0
        end

        function mt:slow(unit, amount, duration, model, point, stack)
            self:cast(unit, amount, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_SLOW)
        end

        function mt:slowed(unit)
            return GetUnitAbilityLevel(unit, MOVEMENT_SLOW_BUFF) > 0
        end

        function mt:slowAttack(unit, amount, duration, model, point, stack)
            self:cast(unit, amount, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_SLOW_ATTACK)
        end

        function mt:attackSlowed(unit)
            return GetUnitAbilityLevel(unit, ATTACK_SLOW_BUFF) > 0
        end

        function mt:banish(unit, duration, model, point, stack)
            self:cast(unit, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_BANISH)
        end

        function mt:banished(unit)
            return GetUnitAbilityLevel(unit, BANISH_BUFF) > 0
        end

        function mt:ensnare(unit, duration, model, point, stack)
            self:cast(unit, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_ENSNARE)
        end

        function mt:ensnared(unit)
            return GetUnitAbilityLevel(unit, ENSNARE_BUFF) > 0
        end

        function mt:purge(unit, duration, model, point, stack)
            self:cast(unit, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_PURGE)
        end

        function mt:purged(unit)
            return GetUnitAbilityLevel(unit, PURGE_BUFF) > 0
        end

        function mt:hex(unit, duration, model, point, stack)
            self:cast(unit, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_HEX)
        end

        function mt:hexed(unit)
            return GetUnitAbilityLevel(unit, HEX_BUFF) > 0
        end

        function mt:sleep(unit, duration, model, point, stack)
            self:cast(unit, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_SLEEP)
        end

        function mt:sleeping(unit)
            return GetUnitAbilityLevel(unit, SLEEP_BUFF) > 0
        end

        function mt:cyclone(unit, duration, model, point, stack)
            self:cast(unit, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_CYCLONE)
        end

        function mt:cycloned(unit)
            return GetUnitAbilityLevel(unit, CYCLONE_BUFF) > 0
        end

        function mt:entangle(unit, duration, model, point, stack)
            self:cast(unit, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_ENTANGLE)
        end

        function mt:entangled(unit)
            return GetUnitAbilityLevel(unit, ENTANGLE_BUFF) > 0
        end

        function mt:knockback(unit, angle, distance, duration, model, point, onCliff, onDestructable, onUnit, stack)
            self:cast(unit, 0, angle, distance, 0, duration, model, point, stack, onCliff, onDestructable, onUnit, CROWD_CONTROL_KNOCKBACK)
        end

        function mt:knockedback(unit)
            return Knockback:isUnitKnocked(unit)
        end

        function mt:knockup(unit, height, duration, model, point, stack)
            self:cast(unit, 0, 0, 0, height, duration, model, point, stack, false, false, false, CROWD_CONTROL_KNOCKUP)
        end

        function mt:knockedup(unit)
            return Knockup:isUnitKnocked(unit)
        end

        function mt:fear(unit, duration, model, point, stack)
            self:cast(unit, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_FEAR)
        end

        function mt:feared(unit)
            return Fear:feared(unit)
        end

        function mt:disarm(unit, duration, model, point, stack)
            self:cast(unit, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_DISARM)
        end

        function mt:disarmed(unit)
            return GetUnitAbilityLevel(unit, DISARM_BUFF) > 0
        end

        function mt:dispel(unit, type)
            local buff

            if type == CROWD_CONTROL_SILENCE then
                buff = SILENCE_BUFF
            elseif type == CROWD_CONTROL_STUN then
                buff = STUN_BUFF
            elseif type == CROWD_CONTROL_SLOW then
                buff = MOVEMENT_SLOW_BUFF
            elseif type == CROWD_CONTROL_SLOW_ATTACK then
                buff = ATTACK_SLOW_BUFF
            elseif type == CROWD_CONTROL_BANISH then
                buff = BANISH_BUFF
            elseif type == CROWD_CONTROL_ENSNARE then
                buff = ENSNARE_BUFF
            elseif type == CROWD_CONTROL_PURGE then
                buff = PURGE_BUFF
            elseif type == CROWD_CONTROL_HEX then
                buff = HEX_BUFF
            elseif type == CROWD_CONTROL_SLEEP then
                buff = SLEEP_BUFF
            elseif type == CROWD_CONTROL_CYCLONE then
                buff = CYCLONE_BUFF
            elseif type == CROWD_CONTROL_ENTANGLE then
                buff = ENTANGLE_BUFF
            elseif type == CROWD_CONTROL_DISARM then
                buff = DISARM_BUFF
            elseif type == CROWD_CONTROL_FEAR then
                buff = FEAR_BUFF
            end

            if buff then
                UnitRemoveAbility(unit, buff)

                if timer[unit] then
                    PauseTimer(timer[unit][type])
                    DestroyTimer(timer[unit][type])
                    timer[unit][type] = nil
                end
            end
        end

        function mt:dispelAll(unit)
            self:dispel(unit, CROWD_CONTROL_SILENCE)
            self:dispel(unit, CROWD_CONTROL_STUN)
            self:dispel(unit, CROWD_CONTROL_SLOW)
            self:dispel(unit, CROWD_CONTROL_SLOW_ATTACK)
            self:dispel(unit, CROWD_CONTROL_BANISH)
            self:dispel(unit, CROWD_CONTROL_ENSNARE)
            self:dispel(unit, CROWD_CONTROL_PURGE)
            self:dispel(unit, CROWD_CONTROL_HEX)
            self:dispel(unit, CROWD_CONTROL_SLEEP)
            self:dispel(unit, CROWD_CONTROL_CYCLONE)
            self:dispel(unit, CROWD_CONTROL_ENTANGLE)
            self:dispel(unit, CROWD_CONTROL_DISARM)
            self:dispel(unit, CROWD_CONTROL_FEAR)
        end

        function mt:remaining(unit, type)
            if not timer[unit] then
                return 0
            else
                return TimerGetRemaining(timer[unit][type])
            end
        end

        function mt:register(id, code)
            if type(code) == "function" then
                if id >= CROWD_CONTROL_SILENCE and id <= CROWD_CONTROL_KNOCKUP then
                    if not event[id] then event[id] = {} end
                    table.insert(event[id], code)
                else
                    table.insert(trigger, code)
                end
            end
        end
    end
end
