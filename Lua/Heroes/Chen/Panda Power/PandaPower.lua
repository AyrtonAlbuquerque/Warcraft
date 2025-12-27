OnInit("PandaPower", function(requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "RegisterPlayerUnitEvent"

    -- ----------------------------- Panda Power v1.2 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Panda Power Ability
    local ABILITY       = S2A('ChnE')
    -- The raw code of the Chen unit in the editor
    local CHEN_ID       = S2A('Chen')
    -- The GAIN_AT_LEVEL is greater than 0
    -- Chen will gain Panda Power at this level 
    local GAIN_AT_LEVEL = 20

    local function GetAgilityBonus(level)
        return 20 + 0.*level
    end

    local function GetStrengthBonus(level)
        return 20 + 0.*level
    end

    local function GetIntelligenceBonus(level)
        return 20 + 0.*level
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        PandaPower = Class(Spell)

        function PandaPower.onLevelUp()
            local unit = GetTriggerUnit()
        
            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(unit) == CHEN_ID and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                    UnitAddAbility(unit, ABILITY)
                    UnitMakeAbilityPermanent(unit, true, ABILITY)
                    AddUnitBonus(unit, BONUS_AGILITY, GetAgilityBonus(GetUnitAbilityLevel(unit, ABILITY)))
                    AddUnitBonus(unit, BONUS_STRENGTH, GetStrengthBonus(GetUnitAbilityLevel(unit, ABILITY)))
                    AddUnitBonus(unit, BONUS_INTELLIGENCE, GetIntelligenceBonus(GetUnitAbilityLevel(unit, ABILITY)))
                end
            end
        end

        function PandaPower.onInit()
            RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, PandaPower.onLevelUp)
        end
    end
end)