--[[ requires RegisterPlayerUnitEvent
    /* ---------------------- Panda Power v1.2 by Chopinski --------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     NFWar          - Icon
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Panda Power Ability
    local ABILITY       = FourCC('A00D')
    -- The raw code of the Chen unit in the editor
    local CHEN_ID       = FourCC('N000')
    -- The GAIN_AT_LEVEL is greater than 0
    -- Chen will gain Panda Power at this level 
    local GAIN_AT_LEVEL = 20

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function()
            if GAIN_AT_LEVEL > 0 then
                local unit = GetTriggerUnit()
                if GetUnitTypeId(unit) == CHEN_ID and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                    UnitAddAbility(unit, ABILITY)
                    UnitMakeAbilityPermanent(unit, true, ABILITY)
                end
            end
        end)
    end)
end