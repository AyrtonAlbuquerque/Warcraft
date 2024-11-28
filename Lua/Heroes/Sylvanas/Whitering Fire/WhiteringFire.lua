--[[ requires RegisterPlayerUnitEvent
    /* -------------------- Withering Fire v1.2 by Chopinski -------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     Blizzard       - Icon
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Withering Fire Ability
    WitheringFire_ABILITY       = FourCC('A00L')
    -- The raw code of the Withering Fire Normal Ability
    local WITHERING_FIRE_NORMAL = FourCC('A00M')
    -- The raw code of the Withering Fire Cursed Ability
    local WITHERING_FIRE_CURSED = FourCC('A00N')
    -- The raw code of the Sylvanas unit in the editor
    local SYLVANAS_ID           = FourCC('H001')
    -- The GAIN_AT_LEVEL is greater than 0
    -- sylvanas will gain Withering Fire at this level 
    local GAIN_AT_LEVEL         = 20

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    WitheringFire = setmetatable({}, {})
    local mt = getmetatable(WitheringFire)
    mt.__index = mt
    
    function mt:setMissileArt(unit, curse)
        if curse then
            UnitRemoveAbility(unit, WITHERING_FIRE_NORMAL)
            UnitAddAbility(unit, WITHERING_FIRE_CURSED)
            UnitMakeAbilityPermanent(unit, true, WITHERING_FIRE_CURSED)
        else
            UnitRemoveAbility(unit, WITHERING_FIRE_CURSED)
            UnitAddAbility(unit, WITHERING_FIRE_NORMAL)
            UnitMakeAbilityPermanent(unit, true, WITHERING_FIRE_NORMAL)
        end
    end
    
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function()
            if GAIN_AT_LEVEL > 0 then
                local unit  = GetTriggerUnit()
                if GetUnitTypeId(unit) == SYLVANAS_ID and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                    UnitAddAbility(unit, WitheringFire_ABILITY)
                    UnitMakeAbilityPermanent(unit, true, WitheringFire_ABILITY)
                    IssueImmediateOrderById(unit, 852175)
                end
            end
        end)
    end)
end