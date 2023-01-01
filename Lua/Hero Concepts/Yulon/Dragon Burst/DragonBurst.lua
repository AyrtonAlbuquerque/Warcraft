--[[ requires SpellEffectEvent, Utilities, CrowdControl
    /* --------------------- Dragon Burst v1.2 by Chopinski --------------------- */
    // Credits:
    //     Blizzard, TheKaldorei    - Icon
    //     Bribe                    - SpellEffectEvent
    //     AZ                       - Model
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY          = FourCC('A001')
    -- The Model
    local MODEL            = "DragonBurst.mdl"
    -- The model scale
    local SCALE            = 0.75
    -- The knock back model
    local KNOCKBACK_MODEL  = "WindBlow.mdl"
    -- The knock back attachment point
    local ATTACH_POINT     = "origin"

    -- The AOE
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The Center AOE for Knock Up
    local function GetCenterAoE(unit, level)
        return 100. + 0.*level
    end

    -- The Damage dealt
    local function GetDamage(level)
        return 100. + 50.*level
    end

    -- The Knock Up duration
    local function GetKnockUpDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end
    
    -- The Knock Up height
    local function GetKnockUpHeight(level)
        return 300. + 0.*level
    end

    -- The Knock Back duration
    local function GetKnockBackDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
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
            local center = GetCenterAoE(Spell.source.unit, Spell.level)
            local aoe = GetAoE(Spell.source.unit, Spell.level)
            local height = GetKnockUpHeight(Spell.level)
            local damage = GetDamage(Spell.level)
            local group = CreateGroup()
            
            DestroyEffect(AddSpecialEffectEx(MODEL, Spell.x, Spell.y, 0, SCALE))
            GroupEnumUnitsInRange(group, Spell.x, Spell.y, aoe, nil)
            for i = 0, BlzGroupGetSize(group) - 1 do
                local unit = BlzGroupUnitAt(group, i)
                if DamageFilter(Spell.source.player, unit) then
                    local x = GetUnitX(unit)
                    local y = GetUnitY(unit)
                    local angle = AngleBetweenCoordinates(Spell.x, Spell.y, x, y)
                    local distance = DistanceBetweenCoordinates(Spell.x, Spell.y, x, y)
                    
                    if UnitDamageTarget(Spell.source.unit, unit, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        if distance > center then
                            KnockbackUnit(unit, angle, aoe - distance, GetKnockBackDuration(Spell.source.unit, Spell.level), KNOCKBACK_MODEL, ATTACH_POINT, true, true, false, false)
                        else
                            KnockupUnit(unit, height, GetKnockUpDuration(Spell.source.unit, Spell.level), nil, nil, false)
                        end
                    end 
                end
            end
            DestroyGroup(group)
        end)
    end)
end