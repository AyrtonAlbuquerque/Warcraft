--[[ requires SpellEffectEvent, Utilities, LineSegmentEnumeration, CrowdControl
    /* ------------------ Draconic Discharge v1.3 by Chopinski ------------------ */
    // Credits:
    //     N-ix Studio      - Icon
    //     Bribe            - SpellEffectEvent
    //     IcemanBo, AGD    - LineSegmentEnumeration
    //     Wood             - Model
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY     = FourCC('A005')
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
        return 250.*level
    end

    -- The blast range
    local function GetRange(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_CAST_RANGE, level - 1)
    end
    
    -- The stun duration
    local function GetStunDuration(unit, level)
        return 1. + 1.*level
    end

    -- The Damage Filter.
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local source = Spell.source.unit
            local player = Spell.source.player
            local aoe = GetAoE(source, Spell.level)
            local range = GetRange(source, Spell.level)
            local damage = GetDamage(source, Spell.level)
            local duration = GetStunDuration(source, Spell.level)
            local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local minX = Spell.source.x + OFFSET*Cos(angle)
            local minY = Spell.source.y + OFFSET*Sin(angle)
            local maxX = Spell.source.x + (OFFSET + range)*Cos(angle)
            local maxY = Spell.source.y + (OFFSET + range)*Sin(angle)
            local effect = AddSpecialEffectEx(MODEL, minX, minY, 65, SCALE)
            local group = LineSegment.EnumUnits(minX, minY, maxX, maxY, aoe, true)
            
            QueueUnitAnimation(source, "Stand")
            BlzSetUnitFacingEx(source, angle*bj_RADTODEG)
            BlzSetSpecialEffectYaw(effect, angle)
            for i = 1, #group do
                local unit = group[i]
                if DamageFilter(player, unit) then
                    if UnitDamageTarget(source, unit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        StunUnit(unit, duration, STUN_MODEL, STUN_ATTACH, false)
                    end
                end
            end
            DestroyEffect(effect)
            
            group = nil
        end)
    end)
end