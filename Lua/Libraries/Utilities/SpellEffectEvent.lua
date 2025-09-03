OnInit("SpellEffectEvent", function(requires)
    requires.optional "Spell"

    local callbacks = {}
    local trigger = CreateTrigger()

    OnInit.trig(function()
        TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_SPELL_EFFECT)
        TriggerAddCondition(trigger, Condition(function()
            local callback = callbacks[GetSpellAbilityId()]

            if callback then
                callback()
            end
        end))
    end)

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function RegisterSpellEffectEvent(ability, code)
        if type(code) == "function" then
            callbacks[ability] = code
        end
    end
end)