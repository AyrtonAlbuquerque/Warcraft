--[[ requires RegisterPlayerUnitEvent, NewBonusUtils
    /* ----------------------- Critical v1.2 by Chopinski ----------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     Blizzard       - Icon
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Critical Strike ability
    local ABILITY = FourCC('A003')

    -- The the critical strike chance increament
    local function GetBonusChance(level)
        if level == 1 then
            return 10.
        else
            return 5.
        end
    end

    -- The the critical strike multiplier increament
    local function GetBonusMultiplier(level)
        if level == 1 then
            return 1.
        else
            return 0.5
        end
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function()
            if GetLearnedSkill() == ABILITY then
                local unit = GetTriggerUnit()
                local level = GetUnitAbilityLevel(unit, ABILITY)
                
                AddUnitBonus(unit, BONUS_CRITICAL_CHANCE, GetBonusChance(level))
                AddUnitBonus(unit, BONUS_CRITICAL_DAMAGE, GetBonusMultiplier(level))
            end
        end)
    end)
end