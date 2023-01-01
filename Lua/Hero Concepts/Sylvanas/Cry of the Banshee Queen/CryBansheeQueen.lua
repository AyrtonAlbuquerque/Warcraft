--[[ requires SpellEffectEvent, Utilities, CrowdControl
    -- -------------------------------- Cry of the Banshee Queen v1.3 ------------------------------- --
    -- Credits:
    --     Bribe         - SpellEffectEvent
    --     Darkfang      - Void Curse Icon
    --     Mythic        - Call of the Dread model (edited by me)
    -- ---------------------------------------- By Chopinski ---------------------------------------- --
]]--

do
    -- ---------------------------------------------------------------------------------------------- --
    --                                          Configuration                                         --
    -- ---------------------------------------------------------------------------------------------- --
    -- The raw code of the Cry of the Banshee Queen ability
    local ABILITY       = FourCC('A00F')
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

    -- ---------------------------------------------------------------------------------------------- --
    --                                             System                                             --
    -- ---------------------------------------------------------------------------------------------- --
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local group = CreateGroup()
            local player = Spell.source.player
            local level = Spell.level

            SpamEffectUnit(Spell.source.unit, SCREAM_MODEL, ATTACH_SCREAM, 0.1, 5)
            GroupEnumUnitsInRange(group, Spell.source.x, Spell.source.y, GetAoE(Spell.source.unit, Spell.level), nil)
            for i = 0, BlzGroupGetSize(group) - 1 do
                local unit = BlzGroupUnitAt(group, i)
                if Filtered(player, unit) then
                    FearUnit(unit, GetDuration(unit, level), FEAR_MODEL, ATTACH_FEAR, false)
                    SlowUnit(unit, GetSlow(unit, level), GetDuration(unit, level), nil, nil, false)
                end
            end
            DestroyGroup(group)
        end)
    end)
end