--[[ requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, NewBonusUtils, TimerUtils, TimedHandles, Indexer
    /* ---------------------- MirrorImage v1.3 by Chopinski --------------------- */
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
    local ABILITY           = FourCC('A002')
    -- The raw code of the Cloned Hero ability
    local CLONED_HERO       = FourCC('A007')
    -- The raw code of the Cloned Inventory ability
    local CLONE_INVENTORY   = FourCC('A008')
    -- The model that is used to identify the real Samuro
    local ID_MODEL          = "CloudAura.mdx"
    -- The model attchment point
    local ATTACH            = "origin"
    -- The model that is used when a illusion dies
    local DEATH_EFFECT      = "Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageDeathCaster.mdl"
    -- Used to remove the hero card when an illusion die
    local PLAYER_EXTRA      = Player(bj_PLAYER_NEUTRAL_EXTRA)

    -- Use this function to also check if a unit is a illusion
    function IsUnitIllusionEx(unit)
        return GetUnitAbilityLevel(unit, CLONED_HERO) > 0
    end

    -- The expirience multiplyer value per illusion count
    local function GetBonusExp()
        return 1.
    end

    -- The number of illusions created per level
    local function GetNumberOfIllusions(level)
        return level
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
    local effect = {}
    local source = {}
    local group = {}

    local function CloneStats(original, illusion)
        SetHeroXP(illusion, GetHeroXP(original), false)
        SetHeroStr(illusion, GetHeroStr(original, false), true)
        SetHeroAgi(illusion, GetHeroAgi(original, false), true)
        SetHeroInt(illusion, GetHeroInt(original, false), true)
        BlzSetUnitMaxHP(illusion, BlzGetUnitMaxHP(original))
        BlzSetUnitMaxMana(illusion, BlzGetUnitMaxMana(original))
        BlzSetUnitBaseDamage(illusion, BlzGetUnitBaseDamage(original, 0), 0)
        SetWidgetLife(illusion, GetWidgetLife(original))
        SetUnitState(illusion, UNIT_STATE_MANA, GetUnitState(original, UNIT_STATE_MANA))
        ModifyHeroSkillPoints(illusion, bj_MODIFYMETHOD_SET, 0)
    end

    onInit(function()
        RegisterUnitIndexEvent(function()
            local unit = GetIndexUnit()

            source[unit] = nil

            if Critical then
                Critical.chance[unit] = nil
                Critical.multiplier[unit] = nil
            end

            if Evasion then
                Evasion.evasion[unit] = nil
                Evasion.miss[unit] = nil
                Evasion.neverMiss[unit] = nil
            end

            if SpellPower then
                SpellPower.flat[unit] = nil
                SpellPower.percent[unit] = nil
            end

            if LifeSteal then
                LifeSteal[unit] = nil
            end

            if SpellVamp then
                SpellVamp[unit] = nil
            end
        end)

        RegisterUnitDeindexEvent(function()
            local unit = GetIndexUnit()

            if GetUnitAbilityLevel(unit, ABILITY) > 0 then
                DestroyGroup(group[unit])
                DestroyEffect(effect[unit])

                group[unit] = nil
                effect[unit] = nil
            end
        end)

        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, function()
            if IsUnitIllusionEx(GetManipulatingUnit()) then
                UnitRemoveItem(GetManipulatingUnit(), GetManipulatedItem())
            end
        end)

        RegisterAnyDamageEvent(function()
            local damage = GetEventDamage()

            if IsUnitIllusionEx(Damage.source.unit) and damage > 0 then
                BlzSetEventDamage(damage * dealt[Damage.source.unit])
            end

            if IsUnitIllusionEx(Damage.target.unit) and damage > 0 then
                BlzSetEventDamage(damage * taken[Damage.target.unit])
            end
        end)

        RegisterSpellEffectEvent(ABILITY, function()
            local timer = CreateTimer()
            local unit = Spell.source.unit
            local player = Spell.source.player
            local model = ID_MODEL
            local level = Spell.level
            local amount = GetNumberOfIllusions(level)
            local delay = BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_ANIMATION_DELAY, level - 1)
            local duration = GetDuration(unit, level)

            if not group[unit] then
                group[unit] = CreateGroup()
            end

            if effect[unit] then
                DestroyEffect(effect[unit])
                effect[unit] = nil
            end

            while FirstOfGroup(group[unit]) do
                local u = FirstOfGroup(group[unit])

                ShowUnit(u, false)
                KillUnit(u)
                GroupRemoveUnit(group[unit], u)
            end

            if IsPlayerEnemy(GetLocalPlayer(), player) then
                model = ".mdl"
            end

            effect[unit] = AddSpecialEffectTarget(model, unit, ATTACH)
            DestroyEffectTimed(effect[unit], duration)
            TimerStart(timer, delay, false, function()
                local facing = GetUnitFacing(unit)
                local x = GetUnitX(unit)
                local y = GetUnitY(unit)

                for i = 0, amount - 1 do
                    local illusion = CreateUnit(player, GetUnitTypeId(unit), x, y, facing)
                    source[illusion] = unit
                    dealt[illusion] = GetDamageDealt(unit, level)
                    taken[illusion] = GetDamageTaken(unit, level)

                    GroupAddUnit(group[unit], illusion)
                    UnitRemoveAbility(illusion, FourCC('AInv'))
                    UnitAddAbility(illusion, CLONE_INVENTORY)
                    CloneItems(unit, illusion, true)
                    UnitAddAbility(illusion, CLONED_HERO)
                    CloneStats(unit, illusion)
                    UnitMirrorBonuses(unit, illusion)
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

            if IsUnitIllusionEx(unit) then
                ModifyHeroSkillPoints(unit, bj_MODIFYMETHOD_SET, 0)
            end
        end)

        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function()
            local unit = GetTriggerUnit()

            if IsUnitIllusionEx(unit) then
                local player = GetOwningPlayer(unit)

                GroupRemoveUnit(group[source[unit]], unit)

                if BlzGroupGetSize(group[source[unit]]) == 0 then
                    DestroyEffect(effect[source[unit]])
                    effect[source[unit]] = nil
                end

                for i = 0, bj_MAX_INVENTORY do
                    local item = UnitItemInSlot(unit, i)
                    if item then
                        UnitRemoveItem(unit, item)
                        RemoveItem(item)
                    end
                end

                if Critical then
                    Critical.chance[unit] = nil
                    Critical.multiplier[unit] = nil
                end

                if Evasion then
                    Evasion.evasion[unit] = nil
                    Evasion.miss[unit] = nil
                    Evasion.neverMiss[unit] = nil
                end

                if SpellPower then
                    SpellPower.flat[unit] = nil
                    SpellPower.percent[unit] = nil
                end

                if LifeSteal then
                    LifeSteal[unit] = nil
                end

                if SpellVamp then
                    SpellVamp[unit] = nil
                end

                DestroyEffect(AddSpecialEffect(DEATH_EFFECT, GetUnitX(unit), GetUnitY(unit)))
                SetPlayerHandicapXP(player, GetPlayerHandicapXP(player) - GetBonusExp())
                SetUnitOwner(unit, PLAYER_EXTRA, true)
                ShowUnit(unit, false)

                dealt[unit] = nil
                taken[unit] = nil
                source[unit] = nil
            end
        end)
    end)
end