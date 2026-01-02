OnInit("RangerPrecision", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- --------------------------- Ranger Precision v1.3 by Chopinski -------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Ranger Precision ability
    RangerPrecision_ABILITY     = S2A('Svn0')
    -- The raw code of the Withering Fire Normal Ability
    local WITHERING_FIRE_NORMAL = S2A('Svn6')
    -- The raw code of the Withering Fire Cursed Ability
    local WITHERING_FIRE_CURSED = S2A('Svn7')

    -- The bonus duration
    local function GetBonusDuration(level)
        return 10. + 0*level
    end

    -- The amount of agility gained
    local function GetBonusAmount(level)
        return 2 + 0*level
    end

    -- The attack count
    local function GetAttackCount(level)
        return 4 - level
    end

    -- The auto level up levels
    local function GetLevel(level)
        return level == 5 or level == 10 or level == 15
    end

    -- The minimum level for normal units to gain the bonus
    local function GetMinLevel()
        return 6
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        RangerPrecision = Class(Spell)

        local count = {}
        local enabled = {}

        function RangerPrecision.enable(unit, flag)
            enabled[unit] = flag
        end

        function RangerPrecision:onTooltip(source, level, ability)
            return "Whenever |cffffcc00Sylvanas|r kill an enemy unit or |cffffcc00attack|r an enemy |cffffcc00Hero|r or |cffffcc00High Level Unit|r her abilities with the bow and arrow improve and she gains |cff00ff00" .. N2S(GetBonusAmount(level), 0) .. " Agility|r for |cffffcc00" .. N2S(GetBonusDuration(level), 0) .. "|r seconds. Additionally every |cffffcc00" .. N2S(GetAttackCount(level), 0) .. "|r attacks |cffffcc00Sylvanas|r will shoot up to |cffffcc003|r targets at once. If |cffffcc00Black Arrows|r is active, all targets will be cursed."
        end

        function RangerPrecision.onDamage()
            local level = GetUnitAbilityLevel(Damage.source.unit, RangerPrecision_ABILITY)

            if level > 0 and (Damage.target.isHero or Damage.target.level >= GetMinLevel()) then
                AddUnitBonusTimed(Damage.source.unit, BONUS_AGILITY, GetBonusAmount(level), GetBonusDuration(level))
            end
        end

        function RangerPrecision.onDeath()
            local killer = GetKillingUnit()
            local level = GetUnitAbilityLevel(killer, RangerPrecision_ABILITY)

            if level > 0 then
                AddUnitBonusTimed(killer, BONUS_AGILITY, GetBonusAmount(level), GetBonusDuration(level))
            end
        end

        function RangerPrecision.onAttack()
            local source = GetAttacker()
            local level = GetUnitAbilityLevel(source, RangerPrecision_ABILITY)

            if level > 0 then
                local attacks = GetAttackCount(level)

                if attacks >= 1 then
                    count[source] = (count[source] or 0) + 1

                    if count[source] == attacks then
                        if enabled[source] then
                            UnitRemoveAbility(source, WITHERING_FIRE_NORMAL)
                            UnitAddAbility(source, WITHERING_FIRE_CURSED)
                        else
                            UnitRemoveAbility(source, WITHERING_FIRE_CURSED)
                            UnitAddAbility(source, WITHERING_FIRE_NORMAL)
                        end
                    elseif count[source] > attacks then
                        count[source] = 0
                        UnitRemoveAbility(source, WITHERING_FIRE_NORMAL)
                        UnitRemoveAbility(source, WITHERING_FIRE_CURSED)
                    end
                else
                    if enabled[source] then
                        UnitRemoveAbility(source, WITHERING_FIRE_NORMAL)
                        UnitAddAbility(source, WITHERING_FIRE_CURSED)
                    else
                        UnitRemoveAbility(source, WITHERING_FIRE_CURSED)
                        UnitAddAbility(source, WITHERING_FIRE_NORMAL)
                    end
                end
            end
        end

        function RangerPrecision.onLevel()
            local source = GetTriggerUnit()

            if GetLevel(GetHeroLevel(source)) then
                IncUnitAbilityLevel(source, RangerPrecision_ABILITY)
            end
        end

        function RangerPrecision.onInit()
            RegisterSpell(RangerPrecision.allocate(), RangerPrecision_ABILITY)
            RegisterAttackDamageEvent(RangerPrecision.onDamage)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, RangerPrecision.onDeath)
            RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, RangerPrecision.onLevel)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, RangerPrecision.onAttack)
        end
    end
end)