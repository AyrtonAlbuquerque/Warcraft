OnInit("MouseUtils", function()
    local mouse = {}
    local trigger = CreateTrigger()

    for i = 0, bj_MAX_PLAYER_SLOTS do
        local player = Player(i)

        if GetPlayerController(player) == MAP_CONTROL_USER and GetPlayerSlotState(player) == PLAYER_SLOT_STATE_PLAYING then
            mouse[player] = {}

            TriggerRegisterPlayerEvent(trigger, player, EVENT_PLAYER_MOUSE_MOVE)
        end
    end

    TriggerAddCondition(trigger, Condition(function()
        local player = GetTriggerPlayer()

        mouse[player].x = BlzGetTriggerPlayerMouseX()
        mouse[player].y = BlzGetTriggerPlayerMouseY()
    end))

    -- -------------------------------------------------------------------------- --
    --                                   LUA API                                  --
    -- -------------------------------------------------------------------------- --
    function GetPlayerMouseX(player)
        return mouse[player].x or 0
    end

    function GetPlayerMouseY(player)
        return mouse[player].y or 0
    end
end)