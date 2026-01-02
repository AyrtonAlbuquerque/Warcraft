OnInit("WitheringFire", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- ---------------------------- Withering Fire v1.4 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Withering Fire Ability
    WitheringFire_ABILITY       = S2A('SvnA')
    -- The raw code of the Withering Fire Normal Ability
    local WITHERING_FIRE_NORMAL = S2A('Svn6')
    -- The raw code of the Withering Fire Cursed Ability
    local WITHERING_FIRE_CURSED = S2A('Svn7')
    -- The raw code of the Sylvanas unit in the editor
    local SYLVANAS_ID           = S2A('Svns')
    -- The GAIN_AT_LEVEL is greater than 0
    -- sylvanas will gain Withering Fire at this level 
    local GAIN_AT_LEVEL         = 20

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        WitheringFire = Class(Spell)

        function WitheringFire.setMissileArt(source, curse)
            if curse then
                UnitRemoveAbility(source, WITHERING_FIRE_NORMAL)
                UnitAddAbility(source, WITHERING_FIRE_CURSED)
                UnitMakeAbilityPermanent(source, true, WITHERING_FIRE_CURSED)
            else
                UnitRemoveAbility(source, WITHERING_FIRE_CURSED)
                UnitAddAbility(source, WITHERING_FIRE_NORMAL)
                UnitMakeAbilityPermanent(source, true, WITHERING_FIRE_NORMAL)
            end
        end

        function WitheringFire.onLevelUp()
            local unit = GetTriggerUnit()
        
            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(unit) == SYLVANAS_ID and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                    UnitAddAbility(unit, WitheringFire_ABILITY)
                    UnitMakeAbilityPermanent(unit, true, WitheringFire_ABILITY)
                    IssueImmediateOrderById(unit, 852175)
                end
            end
        end

        function WitheringFire.onInit()
            RegisterSpell(WitheringFire.allocate(), WitheringFire_ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, WitheringFire.onLevelUp)
        end
    end
end)