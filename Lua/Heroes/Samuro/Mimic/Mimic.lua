--[[ requires RegisterPlayerUnitEvent, MirrorImage, optional WindWalk, optional Bladestorm
    /* ------------------------- Mimic v1.3 by Chopinski ------------------------ */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     CRAZYRUSSIAN   - Icon
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Critical Strike ability
    local ABILITY  = FourCC('A004')

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

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    local function Update(unit, id, field)
        local ability = BlzGetUnitAbility(unit, id)
        local level = BlzGetAbilityIntegerField(ability, ABILITY_IF_LEVELS)
        
        for i = 0, level do
            local damage = BlzGetAbilityRealLevelField(ability, field, i)
            BlzSetAbilityRealLevelField(ability, field, i, GetNewDamage(id, damage))
            IncUnitAbilityLevel(unit, id)
            DecUnitAbilityLevel(unit, id)
        end
    end
    
    local function Mimic(unit, ability, level, mana, field, order)
        local group = CreateGroup()
        
        GroupEnumUnitsOfPlayer(group, GetOwningPlayer(unit), nil)
        for i = 0, BlzGroupGetSize(group) - 1 do
            local u = BlzGroupUnitAt(group, i)
            if GetUnitTypeId(u) == GetUnitTypeId(unit) and IsUnitIllusionEx(u) then
                SetUnitState(u, UNIT_STATE_MANA, mana)
                UnitRemoveAbility(u, ability)
                UnitAddAbility(u, ability)
                SetUnitAbilityLevel(u, ability, level)
                
                local a = BlzGetUnitAbility(u, ability)
                local damage = BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, level - 1)
                BlzSetAbilityRealLevelField(a, field, level - 1, damage)
                IssueImmediateOrder(u, order)
                BlzUnitHideAbility(u, ability, true)
            end
        end
        DestroyGroup(group)
    end
    
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function()
            if GetLearnedSkill() == ABILITY then
                local unit = GetTriggerUnit()
                local level = GetUnitAbilityLevel(unit, ABILITY)
                
                if level == GetWindWalkDoubleLevel() then
                    if WindWalk then
                        Update(unit, WindWalk_ABILITY, ABILITY_RLF_BACKSTAB_DAMAGE)
                    end
                elseif level == GetBladestormDoubleLevel() then
                    if Bladestorm then
                        Update(unit, Bladestorm_ABILITY, ABILITY_RLF_DAMAGE_PER_SECOND_OWW1)
                    end
                end
            end
        end)
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function()
            local unit = GetTriggerUnit()
            local level = GetUnitAbilityLevel(unit, ABILITY)
            local ability = GetSpellAbilityId()
        
            if WindWalk then
                if level >= GetWindWalkMimicLevel() and ability == WindWalk_ABILITY and not IsUnitIllusionEx(unit) then
                    Mimic(unit, ability, GetUnitAbilityLevel(unit, ability), GetUnitState(unit, UNIT_STATE_MANA), ABILITY_RLF_BACKSTAB_DAMAGE, "windwalk")
                end
            end

            if Bladestorm then
                if level >= GetBladestormMimicLevel() and ability == Bladestorm_ABILITY and not IsUnitIllusionEx(unit) then
                    Mimic(unit, ability, GetUnitAbilityLevel(unit, ability), GetUnitState(unit, UNIT_STATE_MANA), ABILITY_RLF_DAMAGE_PER_SECOND_OWW1, "whirlwind")
                end
            end
        end)
    end)
end