OnInit("RegisterPlayerUnitEvent", function()
    local trigger = {}
    local f = {}
    local n = {}

    function RegisterPlayerUnitEvent(playerunitevent, code)
        if type(code) == "function" then
            local i = GetHandleId(playerunitevent)

            if not trigger[i] then
                trigger[i] = CreateTrigger()

                for j = 0, bj_MAX_PLAYERS do
                    TriggerRegisterPlayerUnitEvent(trigger[i], Player(j), playerunitevent, null)
                end
            end

            if not n[i] then n[i] = 1 end
            if not f[i] then f[i] = {} end
            table.insert(f[i], code)

            TriggerAddCondition(trigger[i], Filter(function()
                f[i][n[i]]()
                n[i] = n[i] + 1
                if n[i] > #f[i] then n[i] = 1 end
            end))
        end
    end

    function RegisterPlayerUnitEventForPlayer(playerunitevent, code, player)
        if type(code) == "function" then
            local i = (bj_MAX_PLAYERS + 1) * GetHandleId(playerunitevent) + GetPlayerId(player)

            if not trigger[i] then
                trigger[i] = CreateTrigger()

                TriggerRegisterPlayerUnitEvent(trigger[i], player, playerunitevent, null)
            end

            if not n[i] then n[i] = 1 end
            if not f[i] then f[i] = {} end
            table.insert(f[i], code)

            TriggerAddCondition(event[i].trigger, Filter(function()
                f[i][n[i]]()
                n[i] = n[i] + 1
                if n[i] > #f[i] then n[i] = 1 end
            end))
        end
    end

    function GetPlayerUnitEventTrigger(playerunitevent)
        return trigger[GetHandleId(playerunitevent)]
    end
end)