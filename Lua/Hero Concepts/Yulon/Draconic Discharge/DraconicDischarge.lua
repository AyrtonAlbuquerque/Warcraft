--[[ requires SpellEffectEvent, Utilities, LineSegmentEnumeration
    /* ------------------ Draconic Discharge v1.1 by Chopinski ------------------ */
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
    local ABILITY          = FourCC('A005')
    -- The Model
    local MODEL            = "Discharge.mdl"
    -- The model scale
    local SCALE            = 0.8
    -- The model offset
    local OFFSET           = 200

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
            local aoe = GetAoE(Spell.source.unit, Spell.level)
            local range = GetRange(Spell.source.unit, Spell.level)
            local damage = GetDamage(Spell.source.unit, Spell.level)
            local duration = GetStunDuration(Spell.source.unit, Spell.level)
            local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local minX = Spell.source.x + OFFSET*Cos(angle)
            local minY = Spell.source.y + OFFSET*Sin(angle)
            local maxX = Spell.source.x + (OFFSET + range)*Cos(angle)
            local maxY = Spell.source.y + (OFFSET + range)*Sin(angle)
            local effect = AddSpecialEffectEx(MODEL, minX, minY, 65, SCALE)
            local group = LineSegment.EnumUnits(minX, minY, maxX, maxY, aoe, true)
            
            QueueUnitAnimation(Spell.source.unit, "Stand")
            BlzSetUnitFacingEx(Spell.source.unit, angle*bj_RADTODEG)
            BlzSetSpecialEffectYaw(effect, angle)
            for i = 1, #group do
                local unit = group[i]
                if DamageFilter(Spell.source.player, unit) then
                    if UnitDamageTarget(Spell.source.unit, unit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        StunUnit(unit, duration)
                    end
                end
            end
            DestroyEffect(effect)
            
            group = nil
        end)
    end)
end