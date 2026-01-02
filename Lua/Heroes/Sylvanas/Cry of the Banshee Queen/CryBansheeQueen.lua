OnInit("BansheeCry", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "BlackArrow"

    -- ----------------------------- Cry of the Banshee Queen v1.5 ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Cry of the Banshee Queen ability
    local ABILITY       = S2A('Svn2')
    -- The fear model
    local FEAR_MODEL    = "Fear.mdl"
    -- The the fear attachment point
    local ATTACH_FEAR   = "overhead"
    -- The scream spammable model
    local SCREAM_MODEL  = "Call of Dread Purple.mdl"
    -- The the scream attachment point
    local ATTACH_SCREAM = "origin"

    -- The fear/slow duration
    local function GetDuration(unit, level)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
            return 2. + 0.*level
        else
            return 5. + 0.*level
        end
    end

    -- The slow amount
    local function GetSlow(unit, level)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
            return 0.5 + 0.*level
        else
            return 0.5 + 0.*level
        end
    end

    -- The AoE
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- Filter for effects
    local function Filtered(player, unit)
        return IsUnitEnemy(unit, player) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        BansheeCry = Class(Spell)

        function BansheeCry:onCast()
            local group = CreateGroup()

            SpamEffectUnit(Spell.source.unit, SCREAM_MODEL, ATTACH_SCREAM, 0.1, 5)
            GroupEnumUnitsInRange(group, Spell.source.x, Spell.source.y, GetAoE(Spell.source.unit, Spell.level), nil)

            local u = FirstOfGroup(group)

            while u do
                if BlackArrow then
                    if Filtered(Spell.source.player, u) then
                        FearUnit(u, GetDuration(u, Spell.level), FEAR_MODEL, ATTACH_FEAR, false)
                        SlowUnit(u, GetSlow(u, Spell.level), GetDuration(u, Spell.level), nil, nil, false)
                    elseif GetOwningPlayer(u) == Spell.source.player and (GetUnitTypeId(u) == BlackArrow_SKELETON_WARRIOR or GetUnitTypeId(u) == BlackArrow_SKELETON_ARCHER) then
                        UnitApplyTimedLife(ReplaceUnit(u, GetUnitTypeId(u), bj_UNIT_STATE_METHOD_ABSOLUTE), S2A('BTLF'), BlackArrow_GetSkeletonDuration(GetUnitAbilityLevel(Spell.source.unit, BlackArrow_ABILITY)))
                    elseif GetOwningPlayer(u) == Spell.source.player and GetUnitTypeId(u) == BlackArrow_SKELETON_ELITE then
                        UnitApplyTimedLife(ReplaceUnit(u, GetUnitTypeId(u), bj_UNIT_STATE_METHOD_ABSOLUTE), S2A('BTLF'), BlackArrow_GetEliteDuration(GetUnitAbilityLevel(Spell.source.unit, BlackArrow_ABILITY)))
                    end
                else
                    if Filtered(Spell.source.player, u) then
                        FearUnit(u, GetDuration(u, Spell.level), FEAR_MODEL, ATTACH_FEAR, false)
                        SlowUnit(u, GetSlow(u, Spell.level), GetDuration(u, Spell.level), nil, nil, false)
                    end
                end

                GroupRemoveUnit(group, u)
                u = FirstOfGroup(group)
            end

            DestroyGroup(group)
        end

        function BansheeCry.onInit()
            RegisterSpell(BansheeCry.allocate(), ABILITY)
        end
    end
end)