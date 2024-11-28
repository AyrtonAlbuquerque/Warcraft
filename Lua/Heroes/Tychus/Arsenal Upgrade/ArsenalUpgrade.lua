--[[ requires RegisterPlayerUnitEvent
    /* -------------------- Arsenal Upgrade v1.2 by Chopinski ------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Arsenal Upgrade Ability
    ArsenalUpgrade_ABILITY  = FourCC('A00B')
    -- The raw code of the Tychus unit in the editor
    local TYCHUS_ID         = FourCC('E000')
    -- The GAIN_AT_LEVEL is greater than 0
    -- Tychus will gain Arsenal Upgrade at this level 
    local GAIN_AT_LEVEL     = 20

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    ArsenalUpgrade = setmetatable({}, {})
    local mt = getmetatable(ArsenalUpgrade)
    mt.__index = mt
    
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function()
            if GAIN_AT_LEVEL > 0 then
                local unit = GetTriggerUnit()
                if GetUnitTypeId(unit) == TYCHUS_ID and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                    UnitAddAbility(unit, ArsenalUpgrade_ABILITY)
                    UnitMakeAbilityPermanent(unit, true, ArsenalUpgrade_ABILITY)
                end
            end
        end)
    end)
end