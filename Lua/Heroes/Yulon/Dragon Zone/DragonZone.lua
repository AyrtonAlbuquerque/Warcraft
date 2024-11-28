--[[ requires RegisterPlayerUnitEvent, SpellEffectEvent, Utilities, CrowdControl
    /* ---------------------- Dragon Zone v1.2 by Chopinski --------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     Bribe          - SpellEffectEvent
    //     AZ             - Model
    //     N-ix Studio    - Icon
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Ability
    local ABILITY          = FourCC('A006')
    -- The raw code of the regen ability
    local REGEN_ABILITY    = FourCC('A007')
    -- The raw code of the Yulon unit in the editor
    local YULON_ID         = FourCC('H000')
    -- The Model
    local MODEL            = "DragonZone.mdl"
    -- The model scale
    local SCALE            = 2.5
    -- The knock back model
    local KNOCKBACK_MODEL  = "WindBlow.mdl"
    -- The knock back attachment point
    local ATTACH_POINT     = "origin"
    -- The pdate period
    local PERIOD           = 0.1
    -- The GAIN_AT_LEVEL is greater than 0
    -- Yulon will gain Dragon Zone at this level 
    local GAIN_AT_LEVEL    = 20

    -- The AOE
    local function GetAoE(unit, level)
         return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The Damage dealt
    local function GetDamage(level)
        return 50. + 50.*level
    end

    -- The maximum Knock Back duration
    local function GetMaxKnockBackDuration(unit, level)
        return 0.5 + 0.*level
    end
    
    -- The spell duration
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end
    
    -- The caster time scale. Speed or slow down aniamtions.
    local function GetTimeScale(unit, level)
        return 1.5
    end
    
    -- The amoount of time until time scale is reset
    local function GetTimeScaleTime(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_FOLLOW_THROUGH_TIME, level - 1)
    end

    -- The Unit Filter.
    local function UnitFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function()
            if GAIN_AT_LEVEL > 0 then
                local unit = GetTriggerUnit()
                
                if GetUnitTypeId(unit) == YULON_ID and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                    UnitAddAbility(unit, ABILITY)
                    UnitMakeAbilityPermanent(unit, true, ABILITY)
                end
            end
        end)
        
        RegisterSpellEffectEvent(ABILITY, function()
            local dummy = DummyRetrieve(Spell.source.player, Spell.source.x, Spell.source.y, 0, 0)
            local t = CreateTimer()
            local timer = CreateTimer()
            local unit = Spell.source.unit
            local player = Spell.source.player
            local x = Spell.source.x
            local y = Spell.source.y
            local aoe = GetAoE(unit, Spell.level)
            local duration = GetDuration(unit, Spell.level)
            local knock = GetMaxKnockBackDuration(unit, Spell.level)
            local group = CreateGroup()
            
            DestroyEffectTimed(AddSpecialEffectEx(MODEL, x, y, 0, SCALE), duration)
            UnitAddAbilityTimed(dummy, REGEN_ABILITY, duration, Spell.level, true)
            DummyRecycleTimed(dummy, duration)
            SetUnitTimeScale(unit, GetTimeScale(unit, Spell.level))
            
            TimerStart(timer, GetTimeScaleTime(unit, Spell.level), false, function()
                SetUnitTimeScale(unit, 1)
                PauseTimer(timer)
                DestroyTimer(timer)
            end)
            
            TimerStart(t, PERIOD, true, function()
                if duration > 0 then
                    duration = duration - PERIOD
                    
                    GroupEnumUnitsInRange(group, x, y, aoe, nil)
                    for i = 0, BlzGroupGetSize(group) - 1 do
                        local u = BlzGroupUnitAt(group, i)
                        if UnitFilter(player, u) then
                            if not IsUnitKnockedBack(u) then
                                local ux = GetUnitX(u)
                                local uy = GetUnitY(u)
                                local angle = AngleBetweenCoordinates(x, y, ux, uy)
                                local distance = DistanceBetweenCoordinates(x, y, ux, uy)
                                
                                KnockbackUnit(u, angle, aoe + 25 - distance, knock*(distance/aoe), KNOCKBACK_MODEL, ATTACH_POINT, true, true, false, false)
                            end
                        end
                    end
                else
                    DestroyGroup(group)
                    PauseTimer(t)
                    DestroyTimer(t)
                end
            end)
        end)
    end)
end