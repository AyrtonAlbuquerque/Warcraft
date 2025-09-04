OnInit("Damage", function(requires)
    requires "Unit"
    requires "Class"

    Damage = Class()

    local after  = {}
    local before = {}
    local damage = {}
    local damaging = {}
    local source = Unit.create(nil)
    local target = Unit.create(nil)
    local trigger = CreateTrigger()

    function Damage.onInit()
        for i = 1, 7 do
            after[i] = {}
            before[i] = {}
        end

        TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_DAMAGING)
        TriggerAddCondition(trigger, Filter(function()
            if GetTriggerEventId() == EVENT_PLAYER_UNIT_DAMAGING then
                if Damage.damagetype ~= DAMAGE_TYPE_UNKNOWN then
                    local i = GetHandleId(Damage.attacktype) + 1
                    local j = GetHandleId(Damage.damagetype) + 1

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

                    for k = 1, #damaging do
                        damaging[k]()
                    end
                end
            end
        end))

        TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_DAMAGED)
        TriggerAddCondition(trigger, Filter(function()
            if GetTriggerEventId() == EVENT_PLAYER_UNIT_DAMAGED then
                if Damage.damagetype ~= DAMAGE_TYPE_UNKNOWN then
                    local i = GetHandleId(Damage.attacktype) + 1
                    local j = GetHandleId(Damage.damagetype) + 1

                    if after[i][1] then
                        for k = 1, #after[i][1] do
                            after[i][1][k]()
                        end
                    end

                    if after[1][j] then
                        if Damage.isAttack and Evasion then
                            if not Evasion.evade then
                                for k = 1, #after[1][j] do
                                    after[1][j][k]()
                                end
                            end
                        else
                            for k = 1, #after[1][j] do
                                after[1][j][k]()
                            end
                        end
                    end

                    if after[i][j] then
                        for k = 1, #after[i][j] do
                            after[i][j][k]()
                        end
                    end

                    for k = 1, #damage do
                        damage[k]()
                    end
                end
            end
        end))
    end

    -- -------------------------------------------------------------------------- --
    --                                   LUA API                                  --
    -- -------------------------------------------------------------------------- --
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
end)