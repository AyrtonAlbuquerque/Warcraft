--[[ requires DamageInterface, RegisterPlayerUnitEvent, NewBonusUtils
    /* ------------------- Ranger Precision v1.2 by Chopinski ------------------- */
    // Credits:
    //     Magtheridon96 - RegisterPlayerUnitEvent
    //     The Panda     - Dark Bow icon
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Ranger Precision ability
    local ABILITY     = FourCC('A00E')
    -- The bonus type gained
    local BONUS_TYPE  = BONUS_AGILITY

    -- The bonus duration
    local function GetBonusDuration(level)
        return 10. + 0*level
    end

    -- The amount of agility gained
    local function GetBonusAmount(level)
        return 2 + 0*level
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterAttackDamageEvent(function()
            local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if level > 0 and Damage.target.isHero then
                AddUnitBonusTimed(Damage.source.unit, BONUS_TYPE, GetBonusAmount(level), GetBonusDuration(level))
            end
        end)
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function()
            local unit = GetKillingUnit()
            local level = GetUnitAbilityLevel(unit, ABILITY)

            if level > 0 then
                AddUnitBonusTimed(unit, BONUS_TYPE, GetBonusAmount(level), GetBonusDuration(level))
            end
        end)
    end)
end