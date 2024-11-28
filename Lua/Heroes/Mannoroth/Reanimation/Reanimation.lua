--[[ requires RegisterPlayerUnitEvent
    /* --------------------- Reanimation v1.4 by Chopinski -------------------- */
    // Credits:
    //     Henry         - Reanimated Mannoroth model
    //     Magtheridon96 - RegisterPlayerUnitEvent
    //     Vexorian      - TimerUtils
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the reanimation ability
    local ABILITY                   = FourCC('A005')
    -- The raw code of the Mannoroth unit in the editor
    local MANNOROTH_ID              = FourCC('N000')
    -- The raw code of the reanimation metamorphosis 
    -- ability that is used to change its model
    local REANIMATION_METAMORPHOSIS = FourCC('A006')
    -- The GAIN_AT_LEVEL is greater than 0
    -- Mannoroth will gain reanimation at this level 
    local GAIN_AT_LEVEL             = 20
    -- The effect created on the gorund when mannoroth
    -- dies
    local MANNOROTH_SKELETON        = "Mannorothemerdg.mdl"
    -- The size of the skeleton model
    local SKELETON_SCALE            = 0.4

    -- The damage area
    local function GetCooldown(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, REANIMATION_METAMORPHOSIS), ABILITY_RLF_COOLDOWN, level - 1)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    local Reanimated = {}
    
    onInit(function()
        RegisterAnyDamageEvent(function()
            local damage = GetEventDamage()
            local level = GetUnitAbilityLevel(Damage.target.unit, ABILITY)
            
        
            if level > 0 and damage >= GetWidgetLife(Damage.target.unit) and not Reanimated[Damage.target.unit] then
                local timer = CreateTimer()
                local unit = Damage.target.unit
                local face = GetUnitFacing(unit)*bj_DEGTORAD
                local effect
                Reanimated[unit] = true
                
                BlzSetAbilityStringLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_SLF_ICON_NORMAL, level - 1, "ReplaceableTextures\\CommandButtonsDisabled\\DISPASReanimation.blp")
                IncUnitAbilityLevel(unit, ABILITY)
                DecUnitAbilityLevel(unit, ABILITY)
                SetUnitInvulnerable(unit, true)
                BlzSetEventDamage(0)
                BlzPauseUnitEx(unit, true)
                SetUnitAnimation(unit, "Death")
                
                TimerStart(timer, 3, false, function()
                    BlzPauseUnitEx(unit, false)
                    ShowUnit(unit, false)
                    SetUnitLifePercentBJ(unit, 100)
                    SetUnitManaPercentBJ(unit, 100)
                    IssueImmediateOrder(unit, "metamorphosis")
                    SetUnitInvulnerable(unit, true)
                    BlzPauseUnitEx(unit, true)
                    effect = AddSpecialEffect(MANNOROTH_SKELETON, GetUnitX(unit), GetUnitY(unit))
                    BlzSetSpecialEffectScale(effect, SKELETON_SCALE)
                    BlzSetSpecialEffectYaw(effect, face)
                    
                    TimerStart(timer, 2, false, function()
                        BlzPlaySpecialEffect(effect, ANIM_TYPE_MORPH)
                        
                        TimerStart(timer, 9, false, function()
                            BlzSetSpecialEffectZ(effect, 4000)
                            ShowUnit(unit, true)
                            BlzPauseUnitEx(unit, false)
                            SetUnitInvulnerable(unit, false)
                            DestroyEffect(effect)
                            
                            TimerStart(timer, GetCooldown(unit, level) - 14, false, function()
                                Reanimated[unit] = false
                                BlzSetAbilityStringLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_SLF_ICON_NORMAL, level - 1, "ReplaceableTextures\\CommandButtons\\PASReanimation.blp")
                                IncUnitAbilityLevel(unit, ABILITY)
                                DecUnitAbilityLevel(unit, ABILITY)
                                PauseTimer(timer)
                                DestroyTimer(timer)
                            end)
                        end)
                    end)
                end)
            end
        end)
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function()
            if GAIN_AT_LEVEL > 0 then
                local u = GetTriggerUnit()
                if GetUnitTypeId(u) == MANNOROTH_ID and GetHeroLevel(u) == GAIN_AT_LEVEL then
                    UnitAddAbility(u, ABILITY)
                    UnitMakeAbilityPermanent(u, true, ABILITY)
                end
            end
        end)
    end)
end