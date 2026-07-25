OnInit("Mimic", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Utilities"
    requires "MirrorImage"
    requires "RegisterPlayerUnitEvent"
    requires.optional "Bladestorm"

    -- -------------------------------- Mimic v1.4 by Chopinski -------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Critical Strike ability
    local ABILITY  = S2A('Smr4')

    -- The bonus damage every level up
    local function GetBonusDamage(level)
        return 25. * level
    end

    -- The level at which illsuions will start to mimic Bladestorm
    local function GetBonusArmor(level)
        return 2. * level
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Mimic = Class(Spell)

        function Mimic:onTooltip(source, level, ability)
            return "|cffffcc00Samuro|r Illusions mimic him perfectly. When |cffffcc00Samuro|r uses |cffffcc00Bladestorm|r, so will his illusions. In addintion, |cffffcc00Samuro|r gains |cffff0000" .. N2S(GetBonusDamage(level), 0) .. "|r |cffff0000Damage|r and |cff808080" .. N2S(GetBonusArmor(level), 0) .. "|r |cff808080Armor|r while casting |cffffcc00Bladestorm|r."
        end

        function Mimic.onSpell()
            local source = GetTriggerUnit()
            local skill = GetSpellAbilityId()

            if Bladestorm then
                if skill == Bladestorm_ABILITY and not IsUnitIllusionEx(source) and GetUnitAbilityLevel(source, ABILITY) > 0 then
                    local g = CreateGroup()
                    local level = GetUnitAbilityLevel(source, Bladestorm_ABILITY)
                    local duration = Bladestorm_GetDuration(source, level)

                    AddUnitBonusTimed(source, BONUS_ARMOR, GetBonusArmor(level), duration)
                    AddUnitBonusTimed(source, BONUS_DAMAGE, GetBonusDamage(level), duration)
                    GroupEnumUnitsOfPlayer(g, GetOwningPlayer(source), nil)

                    local u = FirstOfGroup(g)

                    while u do
                        if GetUnitTypeId(u) == GetUnitTypeId(source) and IsUnitIllusionEx(u) then
                            SetUnitState(u, UNIT_STATE_MANA, GetUnitState(source, UNIT_STATE_MANA))
                            UnitRemoveAbility(u, Bladestorm_ABILITY)
                            UnitAddAbility(u, Bladestorm_ABILITY)
                            SetUnitAbilityLevel(u, Bladestorm_ABILITY, level)
                            IssueImmediateOrder(u, "whirlwind")
                            BlzUnitHideAbility(u, Bladestorm_ABILITY, true)
                            AddUnitBonusTimed(u, BONUS_ARMOR, GetBonusArmor(level), duration)
                            AddUnitBonusTimed(u, BONUS_DAMAGE, GetBonusDamage(level), duration)
                        end

                        GroupRemoveUnit(g, u)
                        u = FirstOfGroup(g)
                    end

                    DestroyGroup(g)
                end
            end
        end

        function Mimic.onInit()
            RegisterSpell(Mimic.allocate(), ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, Mimic.onSpell)
        end
    end
end)