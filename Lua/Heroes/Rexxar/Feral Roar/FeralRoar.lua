OnInit("FeralRoar", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "Misha"

    -- ------------------------------ Feral Roar v1.2 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The ability raw code
    local ABILITY   = S2A('Rex2')
    -- The buff raw code
    local BUFF      = S2A('BRx0')
    -- The model used in fear
    local FEAR      = "Fear.mdl"
    -- Where the fear model is attached to
    local ATTACH    = "overhead"
    -- The ability order string
    local ORDER     = "battleroar"

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
        return 0.2 + 0.05*level
    end

    -- The bonus armor
    local function GetBonusArmor(unit, level)
        return 4. + level
    end

    -- The unit filter
    local function UnitFilter(player, unit)
        return IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        FeralRoar = Class(Spell)

        function FeralRoar:onTooltip(source, level, ability)
            return "|cffffcc00Rexxar|r roars in fury, increasing the damage of nearby allies by |cffffcc00" .. N2S(GetBonusDamage(source, level) * 100, 0) .. "%%|r of base damage, armor by |cffffcc00" .. N2S(GetBonusArmor(source, level), 0) .. "|r and fearing enemy units within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. " AoE|r for |cffffcc00" .. N2S(GetFearDuration(level), 2) .. "|r seconds. If |cffffcc00Misha|r is summoned she will also roar granting the same effects and gainning |cff00ff00" .. N2S(GetBonusRegeneration(level), 1) .. " Health Regeneration|r.\n\nLasts for |cffffcc00" .. N2S(BlzGetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_NORMAL, level - 1), 0) .. "|r seconds."
        end

        function FeralRoar:onCast()
            local group = CreateGroup()
            local level = Spell.level
            local source = Spell.source.unit
            local owner = Spell.source.player
            
            GroupEnumUnitsInRange(group, Spell.source.x, Spell.source.y, GetAoE(source, level), nil)

            local u = FirstOfGroup(group)

            while u do
                if UnitAlive(u) then
                    if IsUnitAlly(u, owner) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                        if GetUnitAbilityLevel(u, BUFF) == 0 then
                            LinkBonusToBuff(u, BONUS_DAMAGE, BlzGetUnitBaseDamage(source, 0) * GetBonusDamage(u, level), BUFF)
                            LinkBonusToBuff(u, BONUS_ARMOR, GetBonusArmor(u, level), BUFF)
                        end
                    else
                        if UnitFilter(owner, u) then
                            FearUnit(u, GetFearDuration(level), FEAR, ATTACH, false)
                        end
                    end
                end

                GroupRemoveUnit(group, u)
                u = FirstOfGroup(group)
            end

            DestroyGroup(group)
            
            if Misha then
                if GetUnitTypeId(source) ~= Misha_MISHA then
                    local size = BlzGroupGetSize(Misha.group[source])
                    
                    if size > 0 then
                        for i = 0, size - 1 do
                            u = BlzGroupUnitAt(Misha.group[source], i)
                                
                            UnitAddAbilityTimed(u, ABILITY, 1, level, false)
                            BlzSetAbilityIntegerLevelField(BlzGetUnitAbility(u, ABILITY), ABILITY_ILF_MANA_COST, level - 1, 0)
                            IssueImmediateOrder(u, ORDER)
                        end
                    end
                else
                    LinkBonusToBuff(source, BONUS_HEALTH_REGEN, GetBonusRegeneration(level), BUFF)
                end
            end
        end

        function FeralRoar.onInit()
            RegisterSpell(FeralRoar.allocate(), ABILITY)
        end
    end
end)