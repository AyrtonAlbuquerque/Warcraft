--[[ requires SpellEffectEvent, Utilities, CrowdControl
    /* --------------------- WhirlwindSpin v1.2 by Chopinski -------------------- */
    // Credits:
    //     AnsonRuk    - Icon
    //     Bribe       - SpellEffectEvent
    //     AZ          - Model
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY          = FourCC('A003')
    -- The Model
    local MODEL            = "DragonSpin.mdl"
    -- The model scale
    local SCALE            = 0.6
    -- The knock back model
    local KNOCKBACK_MODEL  = "WindBlow.mdl"
    -- The knock back attachment point
    local ATTACH_POINT     = "origin"

    -- The AOE
    local function GetAoE(unit, level)
         return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The Damage dealt
    local function GetDamage(level)
        return 50. + 50.*level
    end

    -- The Knock Back duration
    local function GetKnockBackDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end
    
    -- The caster time scale. Speed or slow down aniamtions.
    local function GetTimeScale(unit, level)
        return 2.
    end
    
    -- The amoount of time until time scale is reset
    local function GetTimeScaleTime(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_FOLLOW_THROUGH_TIME, level - 1)
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
            local damage = GetDamage(Spell.level)
            local duration = GetKnockBackDuration(Spell.source.unit, Spell.level)
            local timer = CreateTimer()
            local unit = Spell.source.unit
            local group = CreateGroup()
            
            DestroyEffect(AddSpecialEffectEx(MODEL, Spell.source.x, Spell.source.y, 0, SCALE))
            GroupEnumUnitsInRange(group, Spell.source.x, Spell.source.y, aoe, nil)
            for i = 0, BlzGroupGetSize(group) - 1 do
                local u = BlzGroupUnitAt(group, i)
                if DamageFilter(Spell.source.player, u) then
                    local x = GetUnitX(u)
                    local y = GetUnitY(u)
                    local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, x, y)
                    local distance = DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, x, y)
                    
                    if UnitDamageTarget(unit, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        KnockbackUnit(u, angle, aoe - distance, duration, KNOCKBACK_MODEL, ATTACH_POINT, true, true, false, false)
                    end
                end
            end
            DestroyGroup(group)
            SetUnitTimeScale(unit, GetTimeScale(unit, Spell.level))
            TimerStart(timer, GetTimeScaleTime(unit, Spell.level), false, function()
                SetUnitTimeScale(unit, 1)
                PauseTimer(timer)
                DestroyTimer(timer)
            end)
        end)
    end)
end