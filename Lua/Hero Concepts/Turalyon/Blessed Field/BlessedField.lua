--[[ requires SpellEffectEvent, Utilities, optional LightInfusion
    /* --------------------- Blessed Field v1.2 by Chopinski -------------------- */
    // Credits:
    //     Darkfang           - Icon
    //     Bribe              - SpellEffectEvent
    //     Vexorian           - TimerUtils
    //     AZ                 - Blessings effect
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The Blessed Field Ability
    local ABILITY       = FourCC('A005')
    -- The Blessed Field Aura ability
    local AURA          = FourCC('A006')
    -- The Blessed Field Aura Infused ability
    local INFUSED_AURA  = FourCC('A007')
    -- The Blessed Field Aura level 1 buff
    local BUFF_1        = FourCC('B005')
    -- The Blessed Field Aura level 2 buff
    local BUFF_2        = FourCC('B006')
    -- The Blessed Field Aura Infused level 1 buff
    local BUFF_3        = FourCC('B007')
    -- The Blessed Field Aura Infused level 2 buff
    local BUFF_4        = FourCC('B008')
    -- The Blessed Field model
    local MODEL         = "BlessedField.mdl"
    -- The Blessed Field scale
    local SCALE         = 1.
    -- The Blessed Field spawn model
    local SPAWN_MODEL   = "Blessings.mdl"
    -- The Blessed Field spawn model scale
    local SPAWN_SCALE   = 2.5
    -- The Blessed Field Infused Restore model
    local RESTORE_MODEL = "Abilities\\Spells\\Human\\ReviveHuman\\ReviveHuman.mdl"

    -- The Blessed Field duration
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The Blessed Field damage reduction based on the buff level
    local function GetDamageReduction(level)
        return 1. - (0.1 + 0.2*level)
    end

    -- The Blessed Field health restored when receiving a killing blow
    local function GetHealthRegained(unit, level)
        return BlzGetUnitMaxHP(unit)*(0.1 + 0.2*level)
    end

    -- The Blessed Field Infused hero revive cooldown 
    local function GetHeroResetTime()
        return 60.
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    local revive = {}
    
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local timer = CreateTimer()
            local x = Spell.x
            local y = Spell.y
            local face = 0.
            local player = Spell.source.player
            local unit = DummyRetrieve(player, x, y, 0, face)
            local effect = AddSpecialEffectEx(MODEL, x, y, 0, SCALE)
            local level = Spell.level

            UnitAddAbility(unit, AURA)
            SetUnitAbilityLevel(unit, AURA, level)

            if LightInfusion then
                if (LightInfusion.charges[Spell.source.unit] or 0) > 0 then
                    UnitAddAbility(unit, INFUSED_AURA)
                    SetUnitAbilityLevel(unit, INFUSED_AURA, level)
                    LightInfusion:consume(Spell.source.unit)
                end
            end

            DestroyEffect(AddSpecialEffectEx(SPAWN_MODEL, x, y, 0, SPAWN_SCALE))
            TimerStart(timer, GetDuration(Spell.source.unit, level), true, function()
                DestroyEffect(effect)
                UnitRemoveAbility(unit, AURA)
                UnitRemoveAbility(unit, INFUSED_AURA)
                DummyRecycle(unit)
                PauseTimer(timer)
                DestroyTimer(timer)
            end)
        end)
        
        RegisterAnyDamageEvent(function()
            local real damage = GetEventDamage()

            if damage > 0 then
                if GetUnitAbilityLevel(Damage.target.unit, BUFF_2) > 0 then
                    damage = damage*GetDamageReduction(2)

                    if GetUnitAbilityLevel(Damage.target.unit, BUFF_4) > 0 then
                        if damage >= GetWidgetLife(Damage.target.unit) then
                            if not Damage.target.isHero then
                                damage = 0
                                SetWidgetLife(Damage.target.unit, GetHealthRegained(Damage.target.unit, 2))
                                DestroyEffect(AddSpecialEffectTarget(RESTORE_MODEL, Damage.target.unit, "origin"))
                            else
                                if (revive[Damage.target.unit] or 0) == 0 then
                                    local timer = CreateTimer()
                                    local unit = Damage.target.unit
                                    
                                    damage = 0
                                    revive[unit] = (revive[unit] or 0) + 1

                                    SetWidgetLife(unit, GetHealthRegained(unit, 2))
                                    DestroyEffect(AddSpecialEffectTarget(RESTORE_MODEL, unit, "origin"))
                                    TimerStart(timer, GetHeroResetTime(), false, function()
                                        revive[unit] = revive[unit] - 1
                                        PauseTimer(timer)
                                        DestroyTimer(timer)
                                    end)
                                end
                            end
                        end
                    end
                    BlzSetEventDamage(damage)
                elseif GetUnitAbilityLevel(Damage.target.unit, BUFF_1) > 0 then
                    damage = damage*GetDamageReduction(1)

                    if GetUnitAbilityLevel(Damage.target.unit, BUFF_3) > 0 then
                        if damage >= GetWidgetLife(Damage.target.unit) then
                            if not Damage.target.isHero then
                                damage = 0
                                SetWidgetLife(Damage.target.unit, GetHealthRegained(Damage.target.unit, 1))
                                DestroyEffect(AddSpecialEffectTarget(RESTORE_MODEL, Damage.target.unit, "origin"))
                            else
                                if (revive[Damage.target.unit] or 0) == 0 then
                                    local timer = CreateTimer()
                                    local unit = Damage.target.unit
                                    
                                    damage = 0
                                    revive[unit] = (revive[unit] or 0) + 1

                                    SetWidgetLife(unit, GetHealthRegained(unit, 1))
                                    DestroyEffect(AddSpecialEffectTarget(RESTORE_MODEL, unit, "origin"))
                                    TimerStart(timer, GetHeroResetTime(), false, function()
                                        revive[unit] = revive[unit] - 1
                                        PauseTimer(timer)
                                        DestroyTimer(timer)
                                    end)
                                end
                            end
                        end
                    end
                    BlzSetEventDamage(damage)
                end
            end
        end)
    end)
end