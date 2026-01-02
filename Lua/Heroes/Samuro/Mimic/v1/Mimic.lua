OnInit("Mimic", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires "MirrorImage"
    requires "RegisterPlayerUnitEvent"
    requires.optional "WindWalk"
    requires.optional "Bladestorm"

    -- -------------------------------- Mimic v1.3 by Chopinski -------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Critical Strike ability
    local ABILITY = S2A('Smr4')

    -- The level at which illsuions will start to mimic Wind Walk
    local function GetWindWalkMimicLevel()
        return 1
    end

    -- The level at which illsuions will start to mimic Bladestorm
    local function GetBladestormMimicLevel()
        return 3
    end

    -- The level at which mimic will double wind walk bonus damage
    local function GetWindWalkDoubleLevel()
        return 2
    end

    -- The level at which mimic will double Bladestorm damage per second
    local function GetBladestormDoubleLevel()
        return 4
    end

    -- The Wind Walk/Bladestorm new damage based on original value
    local function GetNewDamage(ability, original)
        if WindWalk and Bladestorm then
            if ability == WindWalk_ABILITY then
                return 2.*original
            elseif ability == Bladestorm_ABILITY then
                return 2.*original
            else
                return 2.*original
            end
        else
            return 2.*original
        end
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Mimic = Class(Spell)

        function Mimic.update(source, id, field)
            local spell = BlzGetUnitAbility(source, id)
            local levels = BlzGetAbilityIntegerField(spell, ABILITY_IF_LEVELS)

            for i = 0, levels - 1 do
                BlzSetAbilityRealLevelField(spell, field, i, GetNewDamage(id, BlzGetAbilityRealLevelField(spell, field, i)))
                IncUnitAbilityLevel(source, id)
                DecUnitAbilityLevel(source, id)
            end
        end

        function Mimic.mimic(source, skill, level, mana, field, order)
            local group = CreateGroup()

            GroupEnumUnitsOfPlayer(group, GetOwningPlayer(source), nil)

            local u = FirstOfGroup(group)

            while u do
                if GetUnitTypeId(u) == GetUnitTypeId(source) and IsUnitIllusionEx(u) then
                    SetUnitState(u, UNIT_STATE_MANA, mana)
                    UnitRemoveAbility(u, skill)
                    UnitAddAbility(u, skill)
                    SetUnitAbilityLevel(u, skill, level)
                    BlzSetAbilityRealLevelField(BlzGetUnitAbility(u, skill), field, level - 1, BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, skill), field, level - 1))
                    IssueImmediateOrder(u, order)
                    BlzUnitHideAbility(u, skill, true)
                end

                GroupRemoveUnit(group, u)
                u = FirstOfGroup(group)
            end

            DestroyGroup(group)
        end

        function Mimic:onLearn(source, skill, level)
            if level == GetWindWalkDoubleLevel() then
                if WindWalk then
                    Mimic.update(source, WindWalk_ABILITY, ABILITY_RLF_BACKSTAB_DAMAGE)
                end
            elseif level == GetBladestormDoubleLevel() then
                if Bladestorm then
                    Mimic.update(source, Bladestorm_ABILITY, ABILITY_RLF_DAMAGE_PER_SECOND_OWW1)
                end
            end
        end

        function Mimic.onSpell()
            local source = GetTriggerUnit()
            local skill = GetSpellAbilityId()
            local level = GetUnitAbilityLevel(source, ABILITY)
        
            if WindWalk then
                if level >= GetWindWalkMimicLevel() and skill == WindWalk_ABILITY and not IsUnitIllusionEx(source) then
                    Mimic.mimic(source, skill, GetUnitAbilityLevel(source, skill), GetUnitState(source, UNIT_STATE_MANA), ABILITY_RLF_BACKSTAB_DAMAGE, "windwalk")
                end
            end

            if Bladestorm then
                if level >= GetBladestormMimicLevel() and skill == Bladestorm_ABILITY and not IsUnitIllusionEx(source) then
                    Mimic.mimic(source, skill, GetUnitAbilityLevel(source, skill), GetUnitState(source, UNIT_STATE_MANA), ABILITY_RLF_DAMAGE_PER_SECOND_OWW1, "whirlwind")
                end
            end
        end

        function Mimic.onInit()
            RegisterSpell(Mimic.allocate(), ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, Mimic.onSpell)
        end
    end
end)