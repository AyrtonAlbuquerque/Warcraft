OnInit("BlessedField", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires.optional "LightInfusion"

    -- ---------------------------- Blessed Field v1.4 by Chopinski ---------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The Blessed Field Ability
    local ABILITY       = S2A('Trl5')
    -- The Blessed Field Aura ability
    local AURA          = S2A('Trl6')
    -- The Blessed Field Aura Infused ability
    local INFUSED_AURA  = S2A('Trl7')
    -- The Blessed Field Aura level 1 buff
    local BUFF_1        = S2A('BTr4')
    -- The Blessed Field Aura level 2 buff
    local BUFF_2        = S2A('BTr5')
    -- The Blessed Field Aura Infused level 1 buff
    local BUFF_3        = S2A('BTr6')
    -- The Blessed Field Aura Infused level 2 buff
    local BUFF_4        = S2A('BTr7')
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

    -- The regeneration bonus
    local function GetRegenBonus(source, level)
        return 25 * level + ((0.25 + 0.25 * level) * GetHeroStr(source, true))
    end

    -- The Blessed Field damage reduction based on the buff level
    local function GetDamageReduction(level)
        return 1. - (0.1 + 0.2*level)
    end

    -- The Blessed Field health restored when receiving a killing blow
    local function GetHealthRegained(unit, level)
        return BlzGetUnitMaxHP(unit) * (0.1 + 0.2*level)
    end

    -- The Blessed Field Infused hero revive cooldown 
    local function GetHeroResetTime()
        return 60.
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        BlessedField = Class(Spell)

        local revive = {}

        function BlessedField:destroy()
            if not self.unit then
                revive[self.hero] = revive[self.hero] - 1
            else
                DestroyEffect(self.effect)
                UnitRemoveAbility(self.unit, AURA)
                UnitRemoveAbility(self.unit, INFUSED_AURA)
                DummyRecycle(self.unit)
            end

            self.unit = nil
            self.hero = nil
            self.effect = nil
            self.player = nil
        end

        function BlessedField:onTooltip(source, level, ability)
            return "|cffffcc00Turalyon|r blesses the targeted area, creating a |cffffcc00Blessed Field|r. All allied units within |cffffcc00" .. N2S(BlzGetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, level - 1), 0) .. "|r |cffffcc00AoE|r have their |cff00ff00Health Regeneration|r increased by |cff00ff00" .. N2S(GetRegenBonus(source, level), 0) .. "|r and take |cffffcc00" .. N2S((1 - GetDamageReduction(level)) * 100, 0) .. "%%|r reduced damage from all sources.\n\n|cffffcc00Light Infused|r: When allied units within |cffffcc00Blessed Field|r area receives a killing blow, their death is denied and they regain |cffffcc00" .. N2S((0.1 + 0.2*level) * 100, 0) .. "%%|r of their |cffff0000Maximum Health|r. This effect can only happen once for |cffffcc00Hero|r units with |cffffcc00" .. N2S(GetHeroResetTime(), 1) .. "|r seconds cooldown."
        end

        function BlessedField:onCast()
            local this = {  destroy = BlessedField.destroy }

            this.face = 0
            this.x = Spell.x
            this.y = Spell.y
            this.level = Spell.level
            this.player = Spell.source.player
            this.unit = DummyRetrieve(this.player, this.x, this.y, 0, this.face)
            this.effect = AddSpecialEffectEx(MODEL, this.x, this.y, 0, SCALE)

            UnitAddAbility(this.unit, AURA)
            SetUnitAbilityLevel(this.unit, AURA, this.level)
            BlzSetAbilityRealLevelField(BlzGetUnitAbility(this.unit, AURA), ABILITY_RLF_LIFE_REGENERATION_INCREASE_PERCENT, this.level - 1, GetRegenBonus(Spell.source.unit, this.level))
            IncUnitAbilityLevel(this.unit, AURA)
            DecUnitAbilityLevel(this.unit, AURA)

            if LightInfusion then
                if (LightInfusion.charges[Spell.source.unit] or 0) > 0 then
                    UnitAddAbility(this.unit, INFUSED_AURA)
                    SetUnitAbilityLevel(this.unit, INFUSED_AURA, this.level)
                    LightInfusion.consume(Spell.source.unit)
                end
            end

            DestroyEffect(AddSpecialEffectEx(SPAWN_MODEL, x, y, 0, SPAWN_SCALE))
            TimerStart(CreateTimer(), GetDuration(Spell.source.unit, this.level), false, function ()
                this:destroy()
                DestroyTimer(GetExpiredTimer())
            end)
        end

        function BlessedField.onDamage()
            if Damage.amount > 0 then
                if GetUnitAbilityLevel(Damage.target.unit, BUFF_2) > 0 then
                    Damage.amount = Damage.amount * GetDamageReduction(2)

                    if GetUnitAbilityLevel(Damage.target.unit, BUFF_4) > 0 then
                        if Damage.amount >= Damage.target.health then
                            Damage.amount = 0
                            
                            if not Damage.target.isHero then
                                SetWidgetLife(Damage.target.unit, GetHealthRegained(Damage.target.unit, 2))
                                DestroyEffect(AddSpecialEffectTarget(RESTORE_MODEL, Damage.target.unit, "origin"))
                            else
                                if (revive[Damage.target.unit] or 0) == 0 then
                                    local self = { destroy = BlessedField.destroy }
                                    
                                    self.hero = Damage.target.unit
                                    revive[Damage.target.unit] = (revive[Damage.target.unit] or 0) + 1

                                    SetWidgetLife(Damage.target.unit, GetHealthRegained(Damage.target.unit, 2))
                                    DestroyEffect(AddSpecialEffectTarget(RESTORE_MODEL, Damage.target.unit, "origin"))
                                    TimerStart(CreateTimer(), GetHeroResetTime(), false, function ()
                                        self:destroy()
                                        DestroyTimer(GetExpiredTimer())
                                    end)
                                end
                            end
                        end
                    end
                elseif GetUnitAbilityLevel(Damage.target.unit, BUFF_1) > 0 then
                    Damage.amount = Damage.amount * GetDamageReduction(1)

                    if GetUnitAbilityLevel(Damage.target.unit, BUFF_3) > 0 then
                        if Damage.amount >= Damage.target.health then
                            Damage.amount = 0

                            if not Damage.target.isHero then
                                SetWidgetLife(Damage.target.unit, GetHealthRegained(Damage.target.unit, 1))
                                DestroyEffect(AddSpecialEffectTarget(RESTORE_MODEL, Damage.target.unit, "origin"))
                            else
                                if (revive[Damage.target.unit] or 0) == 0 then
                                    local self = { destroy = BlessedField.destroy }
                                    
                                    self.hero = Damage.target.unit
                                    revive[Damage.target.unit] = (revive[Damage.target.unit] or 0) + 1

                                    SetWidgetLife(Damage.target.unit, GetHealthRegained(Damage.target.unit, 1))
                                    DestroyEffect(AddSpecialEffectTarget(RESTORE_MODEL, Damage.target.unit, "origin"))
                                    TimerStart(CreateTimer(), GetHeroResetTime(), false, function ()
                                        self:destroy()
                                        DestroyTimer(GetExpiredTimer())
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        end

        function BlessedField.onInit()
            RegisterSpell(BlessedField.allocate(), ABILITY)
            RegisterAnyDamageEvent(BlessedField.onDamage)
        end
    end
end)