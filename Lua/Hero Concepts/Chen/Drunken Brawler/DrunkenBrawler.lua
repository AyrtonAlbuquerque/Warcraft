--[[ requires RegisterPlayerUnitEvent, NewBonusUtils
    /* -------------------- Drunken Brawler v1.2 by Chopinski ------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Magtheridon96   - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Drunken Brawler ability
    local ABILITY = FourCC('A006')

    -- The Evasion bonus
    local function GetEvasionBonus(level)
        return 7. + 0.*level
    end

    -- The Critical chance bonus
    local function GetCriticalChanceBonus(level)
        if level == 1 then
            return 10. + 0.*level
        else
            return 0.
        end
    end

    -- The Critical damage bonus
    local function GetCriticalDamageBonus(level)
        if level == 1 then
            return 1. + 0.*level
        else
            return 0.75
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
            
                AddUnitBonus(unit, BONUS_EVASION_CHANCE, GetEvasionBonus(level))
                AddUnitBonus(unit, BONUS_CRITICAL_CHANCE, GetCriticalChanceBonus(level))
                AddUnitBonus(unit, BONUS_CRITICAL_DAMAGE, GetCriticalDamageBonus(level))
            end
        end)
    end)
end