--[[ requires SpellEffectEvent
    /* ---------------------- Bladestorm v1.2 by Chopinski ---------------------- */
    // Credits:
    //     Bribe     - SpellEffectEvent
    //     Vexorian  - TimerUtils
    //     zbc       - Icon
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Bladestorm ability
    Bladestorm_ABILITY = FourCC('A005')
    -- The model path used in baldestorm
    local MODEL        = "Bladestorm.mdl"
    -- The rate at which the bladestorm model is spammed
    local RATE         = 0.3

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    Bladestorm = setmetatable({}, {})
    local mt = getmetatable(Bladestorm)
    mt.__index = mt
    
    onInit(function()
        RegisterSpellEffectEvent(Bladestorm_ABILITY, function()
            local timer = CreateTimer()
            local unit = Spell.source.unit
            local duration = BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, Bladestorm_ABILITY), ABILITY_RLF_DURATION_HERO, Spell.level - 1) 
            local count = 0
        
            SetUnitTimeScale(unit, 3)
            TimerStart(timer, RATE, true, function()
                if count < duration and UnitAlive(unit) and not IsUnitPaused(unit) then
                    DestroyEffect(AddSpecialEffectTarget(MODEL, unit, "origin"))
                else
                    SetUnitTimeScale(unit, 1)
                    PauseTimer(timer)
                    DestroyTimer(timer)
                end
                count = count + RATE
            end)
        end)
    end)
end