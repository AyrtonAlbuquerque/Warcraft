--[[ requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, NewBonusUtils, TimerUtils, TimedHandles, Indexer optional Switch
    /* ---------------------- MirrorImage v1.2 by Chopinski --------------------- */
    // Credits:
    //     Magtheridon96    - RegisterPlayerUnitEvent
    //     Bribe            - SpellEffectEvent
    //     TriggerHappy     - TimedHandles
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Mirror Image ability
    local ABILITY       = FourCC('A002')
    -- The model that is used to identify the real Samuro
    local ID_MODEL      = "CloudAura.mdx"
    -- The model that is used when a illusion dies
    local DEATH_EFFECT  = "Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageDeathCaster.mdl"
    -- Used to remove the hero card when an illusion die
    local PLAYER_EXTRA  = Player(bj_PLAYER_NEUTRAL_EXTRA)
    -- You can use this to do some other stuff if you like
    IsIllusion = {}

    -- The expirience multiplyer value per illusion count
    local function GetBonusExp()
        return 1.
    end

    -- The illusions duration. By default the object editor field value
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The dealt damage percentage. By default the object editor field value
    local function GetDamageDealt(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DAMAGE_DEALT_PERCENT_OMI2, level - 1)
    end

    -- The taken damage percentage. By default the object editor field value
    local function GetDamageTaken(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DAMAGE_TAKEN_PERCENT_OMI3, level - 1)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    local dealt = {}
    local taken = {}
    local effects = {}
    
    local function CloneStats(source, illusion)
        SetHeroXP(illusion, GetHeroXP(source), false)
        SetHeroStr(illusion, GetHeroStr(source, false), true)
        SetHeroAgi(illusion, GetHeroAgi(source, false), true)
        SetHeroInt(illusion, GetHeroInt(source, false), true)
        BlzSetUnitMaxHP(illusion, BlzGetUnitMaxHP(source))
        BlzSetUnitMaxMana(illusion, BlzGetUnitMaxMana(source))
        BlzSetUnitBaseDamage(illusion, BlzGetUnitBaseDamage(source, 0), 0)
        SetWidgetLife(illusion, GetWidgetLife(source))
        SetUnitState(illusion, UNIT_STATE_MANA, GetUnitState(source, UNIT_STATE_MANA))
        ModifyHeroSkillPoints(illusion, bj_MODIFYMETHOD_SET, 0)
    end
    
    onInit(function()
        RegisterUnitIndexEvent(function()
            local unit = GetIndexUnit()
            
            IsIllusion[unit] = false
            
            if Critical then
                Critical.chance[unit] = 0
                Critical.multiplier[unit] = 0
            end
            
            if Evasion then
                Evasion.evasion[unit] = 0
                Evasion.miss[unit] = 0
                Evasion.neverMiss[unit] = 0
            end
            
            if SpellPower then
                SpellPower.flat[unit] = 0
                SpellPower.percent[unit] = 0
            end
            
            if LifeSteal then
                LifeSteal.amount[unit] = 0
            end
            
            if SpellVamp then
                SpellVamp.amount[unit] = 0
            end
        end)
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, function()
            if IsIllusion[GetManipulatingUnit()] then
                local item = GetManipulatedItem()
                local id = GetItemTypeId(item)
                
                if id == FourCC('ankh') then
                    BlzItemRemoveAbility(item, FourCC('AIrc'))
                end
                BlzSetItemBooleanField(item, ITEM_BF_ACTIVELY_USED, false)
            end
        end)
    
        RegisterAnyDamageEvent(function()
            local damage = GetEventDamage()
        
            if IsIllusion[Damage.source.unit] and damage > 0 then
                BlzSetEventDamage(damage * dealt[Damage.source.unit])
            end
        
            if IsIllusion[Damage.target.unit] and damage > 0 then
                BlzSetEventDamage(damage * taken[Damage.target.unit])
            end
        end)
        
        RegisterSpellEffectEvent(ABILITY, function()
            local timer = CreateTimer()
            local group = CreateGroup()
            local unit = Spell.source.unit
            local player = Spell.source.player
            local string = ID_MODEL
            local level = Spell.level
            local delay = BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_ANIMATION_DELAY, level - 1)
            local duration = GetDuration(unit, level)
            local effect = effects[unit]
            
            if effect then
                DestroyEffect(effects[unit])
                effects[unit] = nil
            end
            
            GroupEnumUnitsOfPlayer(group, player, nil)
            for i = 0, BlzGroupGetSize(group) - 1 do
                local v = BlzGroupUnitAt(group, i)
                if GetUnitTypeId(v) == GetUnitTypeId(unit) and IsIllusion[v] then
                    ShowUnit(v, false)
                    KillUnit(v)
                end
            end
            DestroyGroup(group)
        
            if IsPlayerEnemy(GetLocalPlayer(), player) then
                string = ".mdl"
            end
        
            effect = AddSpecialEffectTarget(string, unit, "origin") 
            effects[unit] = effect
            DestroyEffectTimed(effect, duration)
            TimerStart(timer, delay, false, function()
                local facing = GetUnitFacing(unit)
                local x = GetUnitX(unit)
                local y = GetUnitY(unit) 
                
                for i = 0, level - 1 do
                    local illusion = CreateUnit(player, GetUnitTypeId(unit), x, y, facing)
                    
                    dealt[illusion] = GetDamageDealt(unit, level)
                    taken[illusion] = GetDamageTaken(unit, level)  
                    IsIllusion[illusion] = true

                    CloneItems(unit, illusion)
                    CloneStats(unit, illusion)
                    UnitMirrorBonuses(unit, illusion)
                    SetUnitAbilityLevel(illusion, FourCC('AInv'), 2)
                    UnitApplyTimedLife(illusion, FourCC('BTLF'), GetDuration(unit, level))
                    SetPlayerHandicapXP(player, GetPlayerHandicapXP(player) + GetBonusExp())
                    if Switch then
                        UnitRemoveAbility(illusion, Switch_ABILITY)
                    end
                end
                PauseTimer(timer)
                DestroyTimer(timer)
            end)
        end)
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function()
            local unit = GetTriggerUnit()
        
            if IsIllusion[unit] then
                ModifyHeroSkillPoints(unit, bj_MODIFYMETHOD_SET, 0)
            end
        end)
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function()
            local unit = GetTriggerUnit()
            local player = GetOwningPlayer(unit)
        
            if IsIllusion[unit] then
                for i = 0, bj_MAX_INVENTORY do
                    local item = UnitItemInSlot(unit, i)
                    if item then
                        UnitRemoveItem(unit, item)
                        RemoveItem(item)
                    end
                end
                DestroyEffect(AddSpecialEffect(DEATH_EFFECT, GetUnitX(unit), GetUnitY(unit)))
                SetPlayerHandicapXP(player, GetPlayerHandicapXP(player) - GetBonusExp())
                SetUnitOwner(unit, PLAYER_EXTRA, true)
                ShowUnit(unit, false)
                dealt[unit] = nil
                taken[unit] = nil
            end
        end)
    end)
end