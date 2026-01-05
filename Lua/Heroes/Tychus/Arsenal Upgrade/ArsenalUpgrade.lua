OnInit("ArsenalUpgrade", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- --------------------------- Arsenal Upgrade v1.3 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Arsenal Upgrade Ability
    ArsenalUpgrade_ABILITY  = S2A('TycB')
    -- The raw code of the Tychus unit in the editor
    local TYCHUS_ID         = S2A('Tycs')
    -- The GAIN_AT_LEVEL is greater than 0
    -- Tychus will gain Arsenal Upgrade at this level 
    local GAIN_AT_LEVEL     = 20

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        ArsenalUpgrade = Class(Spell)

        function ArsenalUpgrade:onTooltip(source, level, ability)
            return "|cffffcc00Tychus|r non ultimate abilities are upgraded.\n\n|cffffcc00Frag Granade|r - Enemy units cought in the explosion radius are stunned for |cffffcc001.5|r seconds.\n\n|cffffcc00Automated Turrent|r - Reduces the number of attacks necessary to the turrents to release a missile by |cffffcc004|r.\n\n|cffffcc00Overkill|r - The mana cost per bullet is halved.\n\n|cffffcc00Run and Gun|r - Doubles the duration of the movement speed bonus."
        end

        function ArsenalUpgrade.onLevelUp()
            local unit = GetTriggerUnit()
        
            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(unit) == TYCHUS_ID and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                    UnitAddAbility(unit, ArsenalUpgrade_ABILITY)
                    UnitMakeAbilityPermanent(unit, true, ArsenalUpgrade_ABILITY)
                end
            end
        end

        function ArsenalUpgrade.onInit()
            RegisterSpell(ArsenalUpgrade.allocate(), ArsenalUpgrade_ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, ArsenalUpgrade.onLevelUp)
        end
    end
end)