OnInit("Damage", function(requires)
    requires "Unit"
    requires "Class"

    Damage = Class()

    local event = {}
    local after  = {}
    local before = {}
    local damage = {}
    local damaging = {}
    local configuration = {}
    local trigger = CreateTrigger()

    Damage:property("source", {
        get = function(self) return Damage._event.source end,
        set = function(self, value) Damage._event.newSource = value end
    })

    Damage:property("target", {
        get = function(self) return Damage._event.target end,
        set = function(self, value) Damage._event.newTarget = value end
    })

    Damage:property("amount", {
        get = function(self) return Damage._event.damage end,
        set = function(self, value)
            Damage._event.damage = value
            BlzSetEventDamage(value)
        end
    })

    Damage:property("process", {
        get = function(self) return not Damage._event.skip end,
        set = function(self, value)
            Damage._event.skip = not value
        end
    })

    Damage:property("damagetype", {
        get = function(self) return Damage._event.damagetype end,
        set = function(self, value)
            Damage._event.damagetype = value
            BlzSetEventDamageType(value)
        end
    })

    Damage:property("attacktype", {
        get = function(self) return Damage._event.attacktype end,
        set = function(self, value)
            Damage._event.attacktype = value
            BlzSetEventAttackType(value)
        end
    })

    Damage:property("weapontype", {
        get = function(self) return Damage._event.weapontype end,
        set = function(self, value)
            Damage._event.weapontype = value
            BlzSetEventWeaponType(value)
        end
    })

    Damage:property("premitigation", { get = function(self) return Damage._event.predamage end })

    Damage:property("isAlly", { get = function(self) return IsUnitAlly(Damage._event.target.unit, Damage._event.source.player) end })

    Damage:property("isEnemy", { get = function(self) return IsUnitEnemy(Damage._event.target.unit, Damage._event.source.player) end })

    Damage:property("isSpell", { get = function(self) return Damage._event.attacktype == ATTACK_TYPE_NORMAL end })

    Damage:property("isAttack", { get = function(self) return Damage._event.damagetype == DAMAGE_TYPE_NORMAL or BlzGetEventIsAttack() end })

    function Damage.__clear()
        local this = table.remove(event)

        this.source:destroy()
        this.target:destroy()
        this = nil
    end

    function Damage.__pre()
        local this = {
            skip = false,
            predamage = 0,
            damage = GetEventDamage(),
            source = Unit.create(GetEventDamageSource()),
            target = Unit.create(BlzGetEventDamageTarget()),
            attacktype = BlzGetEventAttackType(),
            damagetype = BlzGetEventDamageType(),
            weapontype = BlzGetEventWeaponType(),
        }

        table.insert(event, this)

        Damage._event = this

        for i = 1, #configuration do
            configuration[i]()
        end
    end

    function Damage.__pos()
        Damage._event = event[#event]
        Damage._event.predamage = Damage._event.damage
        Damage._event.damage = GetEventDamage()
    end

    function Damage.onInit()
        for i = 1, 7 do
            after[i] = {}
            before[i] = {}
        end

        TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_DAMAGING)
        TriggerAddCondition(trigger, Filter(function()
            if GetTriggerEventId() == EVENT_PLAYER_UNIT_DAMAGING then
                Damage.__pre()

                if not Damage._event.skip then
                    if Damage._event.damagetype ~= DAMAGE_TYPE_UNKNOWN then
                        local i = GetHandleId(Damage._event.attacktype) + 1
                        local j = GetHandleId(Damage._event.damagetype) + 1

                        if before[i][1] then
                            for k = 1, #before[i][1] do
                                before[i][1][k]()
                            end
                        end

                        if before[1][j] then
                            for k = 1, #before[1][j] do
                                before[1][j][k]()
                            end
                        end

                        if before[i][j] then
                            for k = 1, #before[i][j] do
                                before[i][j][k]()
                            end
                        end
                    end

                    for k = 1, #damaging do
                        damaging[k]()
                    end
                end
            end
        end))

        TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_DAMAGED)
        TriggerAddCondition(trigger, Filter(function()
            if GetTriggerEventId() == EVENT_PLAYER_UNIT_DAMAGED then
                Damage.__pos()

                if not Damage._event.skip then
                    if Damage._event.damagetype ~= DAMAGE_TYPE_UNKNOWN then
                        local i = GetHandleId(Damage._event.attacktype) + 1
                        local j = GetHandleId(Damage._event.damagetype) + 1

                        if after[i][1] then
                            for k = 1, #after[i][1] do
                                after[i][1][k]()
                            end
                        end

                        if after[1][j] then
                            for k = 1, #after[1][j] do
                                after[1][j][k]()
                            end
                        end

                        if after[i][j] then
                            for k = 1, #after[i][j] do
                                after[i][j][k]()
                            end
                        end
                    end

                    for k = 1, #damage do
                        damage[k]()
                    end

                    BlzSetEventDamage(Damage._event.damage)

                    if Damage._event.newSource or Damage._event.newTarget then
                        if Damage._event.newSource then
                            Damage._event.source.unit = Damage._event.newSource
                        end

                        if Damage._event.newTarget then
                            Damage._event.target.unit = Damage._event.newTarget
                        end

                        BlzSetEventDamage(0)
                        UnitDamageTarget(Damage._event.source.unit, Damage._event.target.unit, Damage._event.damage, false, false, Damage._event.attacktype, Damage._event.damagetype, Damage._event.weapontype)
                    end
                end

                Damage.__clear()
            end
        end))
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function RegisterDamageEvent(attacktype, damagetype, code)
        if type(code) == "function" then
            local i = GetHandleId(attacktype) + 1
            local j = GetHandleId(damagetype) + 1

            if not after[i][j] then after[i][j] = {} end

            table.insert(after[i][j], code)
        end
    end

    function RegisterAttackDamageEvent(code)
        RegisterDamageEvent(nil, DAMAGE_TYPE_NORMAL, code)
    end

    function RegisterSpellDamageEvent(code)
        RegisterDamageEvent(ATTACK_TYPE_NORMAL, nil, code)
    end

    function RegisterAnyDamageEvent(code)
        if type(code) == "function" then
            table.insert(damage, code)
        end
    end

    function RegisterDamagingEvent(attacktype, damagetype, code)
        if type(code) == "function" then
            local i = GetHandleId(attacktype) + 1
            local j = GetHandleId(damagetype) + 1

            if not before[i][j] then before[i][j] = {} end

            table.insert(before[i][j], code)
        end
    end

    function RegisterAttackDamagingEvent(code)
        RegisterDamagingEvent(nil, DAMAGE_TYPE_NORMAL, code)
    end

    function RegisterSpellDamagingEvent(code)
        RegisterDamagingEvent(ATTACK_TYPE_NORMAL, nil, code)
    end

    function RegisterAnyDamagingEvent(code)
        if type(code) == "function" then
            table.insert(damaging, code)
        end
    end

    function RegisterDamageConfigurationEvent(code)
        if type(code) == "function" then
            table.insert(configuration, code)
        end
    end
end)