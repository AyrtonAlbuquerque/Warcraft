OnInit("DraconicDischarge", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires "LineSegment"
    requires "CrowdControl"
    requires.optional "Bonus"

    -- -------------------------- Draconic Discharge v1.4 by Chopinski ------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY     = S2A('Yul3')
    -- The Model
    local MODEL       = "Discharge.mdl"
    -- The model scale
    local SCALE       = 1
    -- The model offset
    local OFFSET      = 200
    -- The stun model
    local STUN_MODEL  = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
    -- The stun model attach point
    local STUN_ATTACH = "overhead"

    -- The AOE
    local function GetAoE(unit, level)
         return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The Damage dealt
    local function GetDamage(unit, level)
        if Bonus then
            return 125. * level + (0.2 + 0.2*level) * GetUnitBonus(unit, BONUS_SPELL_POWER)
        else
            return 125. * level
        end
    end

    -- The blast range
    local function GetRange(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_CAST_RANGE, level - 1)
    end
    
    -- The stun duration
    local function GetStunDuration(unit, level)
        return 1. + 0.25*level
    end

    -- The Damage Filter.
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        DraconicDischarge = Class(Spell)

        function DraconicDischarge:onTooltip(source, level, ability)
            return "|cffffcc00Yu'lon|r discharges a powerful enegy blast towards the targeted direction, dealing |cff00ffff" .. N2S(GetDamage(source, level), 0) .. "|r Magic|r damage and stunning enemy units caught in its radius for |cffffcc00" .. N2S(GetStunDuration(source, level), 0) .. "|r seconds. |cffffcc00" .. N2S(GetAoE(source, level), 0) .. " AoE|r, |cffffcc00" .. N2S(GetRange(source, level), 0) .. "|r blast range."
        end

        function DraconicDischarge:onCast()
            local aoe = GetAoE(Spell.source.unit, Spell.level)
            local range = GetRange(Spell.source.unit, Spell.level)
            local damage = GetDamage(Spell.source.unit, Spell.level)
            local duration = GetStunDuration(Spell.source.unit, Spell.level)
            local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local minX = Spell.source.x
            local minY = Spell.source.y
            local maxX = Spell.source.x + range * math.cos(angle)
            local maxY = Spell.source.y + range * math.sin(angle)
            local effect = AddSpecialEffectEx(MODEL, Spell.source.x + OFFSET * math.cos(angle), Spell.source.y + OFFSET * math.sin(angle), 65, SCALE)
            
            BlzSetSpecialEffectYaw(effect, angle)
            QueueUnitAnimation(Spell.source.unit, "Stand")
            BlzSetUnitFacingEx(Spell.source.unit, angle*bj_RADTODEG)

            local group = LineSegment.EnumUnits(minX, minY, maxX, maxY, aoe, true)

            for i = 1, #group do
                local unit = group[i]

                if DamageFilter(Spell.source.player, unit) then
                    if UnitDamageTarget(Spell.source.unit, unit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        StunUnit(unit, duration, STUN_MODEL, STUN_ATTACH, false)
                    end
                end
            end

            DestroyEffect(effect)
        end

        function DraconicDischarge.onInit()
            RegisterSpell(DraconicDischarge.allocate() ,ABILITY)
        end
    end
end)