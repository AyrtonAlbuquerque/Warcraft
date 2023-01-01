--[[ requires SpellEffectEvent, PluginSpellEffect, NewBonusUtils, Utilities, CrowdControl optional Misha
    /* ---------------------- Feral Roar v1.1 by Chopinski ---------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The ability raw code
    local ABILITY = FourCC('A002')
    -- The buff raw code
    local BUFF = FourCC('B001')
    -- The model used in fear
    local FEAR = "Fear.mdl"
    -- Where the fear model is attached to
    local ATTACH = "overhead"
    -- The ability order string
    local ORDER = "battleroar"

    -- The aoe
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The fear duration
    local function GetFearDuration(level)
        return 1. + 0.25 * level
    end

    -- The health regeneration bonus
    local function GetBonusRegeneration(level)
        return 10. + 10 * level
    end

    -- The bonus damage
    local function GetBonusDamage(unit, level)
        return BlzGetUnitBaseDamage(unit, 0) * (0.2 + 0.05 * level)
    end

    -- The bonus armor
    local function GetBonusArmor(unit, level)
        return 4. + level
    end

    -- The unit filter
    local function UnitFilter(player, unit)
        return IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local group = CreateGroup()
            local unit = Spell.source.unit
            local player = Spell.source.player
            local level = Spell.level
            local size

            GroupEnumUnitsInRange(group, Spell.source.x, Spell.source.y, GetAoE(unit, level))
            for i = 0, BlzGroupGetSize(group) - 1 do
                local u = BlzGroupUnitAt(group, i)
                if UnitAlive(u) then
                    if IsUnitAlly(u, player) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                        if GetUnitAbilityLevel(u, BUFF) == 0 then
                            LinkBonusToBuff(u, BONUS_DAMAGE, GetBonusDamage(u, level), BUFF)
                            LinkBonusToBuff(u, BONUS_ARMOR, GetBonusArmor(u, level), BUFF)
                        end
                    else
                        if UnitFilter(player, u) then
                            FearUnit(u, GetFearDuration(level), FEAR, ATTACH, false)
                        end
                    end
                end
            end
            DestroyGroup(group)

            if Misha then
                if GetUnitTypeId(unit) ~= Misha_MISHA then
                    size = BlzGroupGetSize(Misha.group[unit])

                    if size > 0 then
                        for i = 0, size - 1 do
                            local u = BlzGroupUnitAt(Misha.group[unit], i)
                            UnitAddAbilityTimed(u, ABILITY, 0.75, level, false)
                            BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(u, ABILITY), ABILITY_ILF_MANA_COST, level - 1, 0)
                            IssueImmediateOrder(u, ORDER)
                        end
                    end
                else
                    LinkBonusToBuff(unit, BONUS_HEALTH_REGEN, GetBonusRegeneration(level), BUFF)
                end
            end
        end)
    end)
end