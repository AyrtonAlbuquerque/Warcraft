--[[ requires RegisterPlayerUnitEvent, NewBonusUtils, TimedHandles, optional ArsenalUpgrade
    /* ---------------------- Run And Gun v1.2 by Chopinski --------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     TriggerHappy    - TimerUtils
    //     Magtheridon96   - RegisterPlayerUnitEvent
    //     Mythic          - Effect
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
        -- The raw code of the Run and Gun ability
        RunAndGun_ABILITY = FourCC('A005')
        -- The Buff model
        local MODEL       = "Valiant Charge Royal.mdl"
        -- The Buff attachment point
        local ATTACH      = "origin"

    -- The Run and Gun duration.
    local function GetDuration(unit, level)
        if ArsenalUpgrade then
            if GetUnitAbilityLevel(unit, ArsenalUpgrade_ABILITY) > 0 then
                return 5. + 0.*level
            else
                return 2.5 + 0.*level
            end
        else
            return 2.5 + 0.*level
        end
    end

    -- The Run and Gun Movement Speed bonus per kill.
    local function GetBonus(level, hero)
        if hero then
            return 20*level
        else
            return 5*level
        end
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    RunAndGun = setmetatable({}, {})
    local mt = getmetatable(RunAndGun)
    mt.__index = mt
    
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function()
            local killed = GetTriggerUnit()
            local killer = GetKillingUnit()
            local level  = GetUnitAbilityLevel(killer, RunAndGun_ABILITY)

            if IsUnitEnemy(killed, GetOwningPlayer(killer)) and level > 0 then
                local duration = GetDuration(killer, level)
                AddUnitBonusTimed(killer, BONUS_MOVEMENT_SPEED, GetBonus(level, IsUnitType(killed, UNIT_TYPE_HERO)), duration)
                DestroyEffectTimed(AddSpecialEffectTarget(MODEL, killer, ATTACH), duration)
            end
        end)
    end)
end