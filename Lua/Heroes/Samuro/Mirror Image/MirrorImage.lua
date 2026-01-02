OnInit("MirrorImage", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Utilities"
    requires "TimedHandles"
    requires "RegisterPlayerUnitEvent"

    -- ----------------------------- MirrorImage v1.5 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Mirror Image ability
    local ABILITY           = S2A('Smr2')
    -- The raw code of the Cloned Hero ability
    local CLONED_HERO       = S2A('Smr6')
    -- The raw code of the Cloned Inventory ability
    local CLONE_INVENTORY   = S2A('Smr7')
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
        return GetUnitAbilityLevel(unit, CLONED_HERO) > 0 or IsUnitIllusion(unit)
    end

    -- The expirience multiplyer value per illusion count
    local function GetBonusExp()
        return 1.
    end

    -- The number of illusions created per level
    local function GetNumberOfIllusions(level)
        return MathRound(SquareRoot(I2R(level)))
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

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        MirrorImage = Class(Spell)

        local dealt = {}
        local taken = {}
        local group = {}
        local effect = {}
        local source = {}

        function MirrorImage:destroy()
            self.unit = nil
            self.player = nil
        end

        function MirrorImage.clone(original, illusion)
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

        function MirrorImage:onTooltip(source, level, ability)
            return "Confuses the enemy by creating |cffffcc00" .. N2S(GetNumberOfIllusions(level), 0) .. "|r illusion of |cffffcc00Samuro|r and dispelling all magic. In addition, |cffffcc00Samuro|r gains |cffffcc00" .. N2S(GetBonusExp() * 100, 0) .. "%%|r more expirience from kills for each illusion alive.\n\nDeal |cffffcc00" .. N2S(GetDamageDealt(source, level) * 100, 0) .. "%%|r of the damage and take |cffffcc00" .. N2S(GetDamageTaken(source, level) * 100, 0) .. "%%|r more damage.\n\nLasts |cffffcc00" .. N2S(GetDuration(source, level), 0) .. "|r seconds."
        end

        function MirrorImage:onCast()
            local model = ID_MODEL
            local this = { destroy = MirrorImage.destroy }
            
            this.unit = Spell.source.unit
            this.level = Spell.level
            this.player = Spell.source.player
            this.amount = GetNumberOfIllusions(this.level)
            this.delay = BlzGetAbilityRealLevelField(Spell.ability, ABILITY_RLF_ANIMATION_DELAY, this.level - 1)
            this.duration = GetDuration(this.unit, this.level)
            
            if not group[this.unit] then
                group[this.unit] = CreateGroup()
            end

            DestroyEffect(effect[this.unit])

            local u = FirstOfGroup(group[this.unit])

            while u do
                ShowUnit(u, false)
                KillUnit(u)
                GroupRemoveUnit(group[this.unit], u)
                u = FirstOfGroup(group[this.unit])
            end
        
            if IsPlayerEnemy(GetLocalPlayer(), this.player) then
                model = ".mdl"
            end
        
            effect[this.unit] = AddSpecialEffectTarget(model, this.unit, ATTACH)

            DestroyEffectTimed(effect[this.unit], this.duration)
            TimerStart(CreateTimer(), this.delay, false, function ()
                for i = 0, this.amount - 1 do
                    local illusion = CreateUnit(this.player, GetUnitTypeId(this.unit), GetUnitX(this.unit), GetUnitY(this.unit), GetUnitFacing(this.unit))

                    source[illusion] = this.unit
                    dealt[illusion] = GetDamageDealt(this.unit, this.level)
                    taken[illusion] = GetDamageTaken(this.unit, this.level)  
                    
                    GroupAddUnit(group[this.unit], illusion)
                    UnitRemoveAbility(illusion, S2A('AInv'))
                    UnitAddAbility(illusion, CLONE_INVENTORY)
                    CloneItems(this.unit, illusion, true)
                    UnitAddAbility(illusion, CLONED_HERO)
                    MirrorImage.clone(this.unit, illusion)
                    UnitMirrorBonuses(this.unit, illusion)
                    UnitApplyTimedLife(illusion, S2A('BTLF'), this.duration)
                    SetPlayerHandicapXP(this.player, GetPlayerHandicapXP(this.player) + GetBonusExp())

                    if Switch then
                        UnitRemoveAbility(illusion, Switch_ABILITY)
                    end

                    if SamuroCritical then
                        if GetUnitAbilityLevel(this.unit, Critical_ABILITY) > 0 then
                            UnitAddAbility(illusion, Critical_ABILITY)
                            SetUnitAbilityLevel(illusion, Critical_ABILITY, GetUnitAbilityLevel(this.unit, Critical_ABILITY))
                        end
                    end

                    DestroyTimer(GetExpiredTimer())
                end
            end)
        end

        function MirrorImage.onLevelUp()
            local unit = GetTriggerUnit()
        
            if IsUnitIllusionEx(unit) then
                ModifyHeroSkillPoints(unit, bj_MODIFYMETHOD_SET, 0)
            end
        end

        function MirrorImage.onDamage()
            if IsUnitIllusionEx(Damage.source.unit) and Damage.amount > 0 and dealt[Damage.source.unit] then
                Damage.amount = Damage.amount * dealt[Damage.source.unit]
            end
        
            if IsUnitIllusionEx(Damage.target.unit) and Damage.amount > 0 and taken[Damage.target.unit] then
                Damage.amount = Damage.amount * taken[Damage.target.unit]
            end
        end

        function MirrorImage.onDeath()
            local killed = GetTriggerUnit()
        
            if IsUnitIllusionEx(killed) then
                local owner = GetOwningPlayer(killed)
                local id = source[killed]

                GroupRemoveUnit(group[id], killed)

                if BlzGroupGetSize(group[id]) == 0 then
                    DestroyEffect(effect[id])
                    effect[id] = nil
                end

                for i = 0, 5 do
                    local item = UnitItemInSlot(killed, i)

                    if item then
                        UnitRemoveItem(killed, item)
                        RemoveItem(item)
                    end
                end

                DestroyEffect(AddSpecialEffect(DEATH_EFFECT, GetUnitX(killed), GetUnitY(killed)))
                SetPlayerHandicapXP(owner, GetPlayerHandicapXP(owner) - GetBonusExp())
                SetUnitOwner(killed, PLAYER_EXTRA, true)
                ShowUnit(killed, false)

                source[id] = nil
            end
        end

        function MirrorImage.onDeindex()
            local removed = GetIndexUnit()

            if GetUnitAbilityLevel(removed, ABILITY) > 0 then
                DestroyGroup(group[removed])
                DestroyEffect(effect[removed])

                group[removed] = nil
                effect[removed] = nil
            end
        end

        function MirrorImage.onPickup()
            if IsUnitIllusionEx(GetManipulatingUnit()) then
                UnitRemoveItem(GetManipulatingUnit(), GetManipulatedItem())
            end
        end

        function MirrorImage.onInit()
            RegisterSpell(MirrorImage.allocate(), ABILITY)
            RegisterAnyDamageEvent(MirrorImage.onDamage)
            RegisterUnitDeindexEvent(MirrorImage.onDeindex)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, MirrorImage.onDeath)
            RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, MirrorImage.onLevelUp)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_PICKUP_ITEM, MirrorImage.onPickup)
        end
    end
end)