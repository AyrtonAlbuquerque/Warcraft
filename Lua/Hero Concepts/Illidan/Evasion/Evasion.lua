--[[ requires RegisterPlayerUnitEvent, SpellEffectEvent, NewBonusUtils
    /* ------------------------- Evade v1.2 by Chopinski ------------------------ */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    //     Magtheridon96   - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Evasion ability
    local ABILITY = FourCC('A001')
    -- The raw code of the Evasion buff
    local BUFF    = FourCC('B001')

    -- The Evasion bonus per level
    local function GetPassiveBonus(level)
        if level == 1 then
            return 10.
        else
            return 5.
        end
    end

    -- The Evasion bonus on cast
    local function GetActiveBonus(level)
        return 100.
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            LinkBonusToBuff(Spell.source.unit, BONUS_EVASION_CHANCE, GetActiveBonus(Spell.level), BUFF)
        end)
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function()
            local ability = GetLearnedSkill()
        
            if ability == ABILITY then
                local unit = GetTriggerUnit()
                AddUnitBonus(unit, BONUS_EVASION_CHANCE, GetPassiveBonus(GetUnitAbilityLevel(unit, ability)))
            end
        end)
    end)
end