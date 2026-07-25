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
    local BUFF_1        = S2A('BTr1')
    -- The Blessed Field Aura level 2 buff
    local BUFF_2        = S2A('BTr2')
    -- The Blessed Field Aura Infused buff
    local INFUSED_BUFF  = S2A('BTr3')
    -- The Blessed Field model
    local MODEL         = "BlessedField.mdl"
    -- The Blessed Field scale
    local SCALE         = 1.
    -- The Blessed Field spawn model
    local SPAWN_MODEL   = "Blessings.mdl"
    -- The Blessed Field spawn model scale
    local SPAWN_SCALE   = 2.5

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

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        BlessedField = Class(Spell)

        function BlessedField:destroy()
            DestroyEffect(self.effect)
            UnitRemoveAbility(self.unit, AURA)
            UnitRemoveAbility(self.unit, INFUSED_AURA)
            DummyRecycle(self.unit)

            self.unit = nil
            self.effect = nil
        end

        function BlessedField:onTooltip(source, level, ability)
            return "|cffffcc00Turalyon|r blesses the targeted area, creating a |cffffcc00Blessed Field|r. All allied units within |cffffcc00" .. N2S(BlzGetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, level - 1), 0) .. "|r |cffffcc00AoE|r have their |cff00ff00Health Regeneration|r increased by |cff00ff00" .. N2S(GetRegenBonus(source, level), 0) .. "|r and take |cffffcc00" .. N2S((1 - GetDamageReduction(level)) * 100, 0) .. "%%|r reduced damage from all sources.\n\n|cffffcc00Light Infused|r: Allied units within |cffffcc00Blessed Field|r area cannot be killed."
        end

        function BlessedField:onCast()
            local this = { destroy = BlessedField.destroy }

            this.unit = DummyRetrieve(Spell.source.player, Spell.x, Spell.y, 0, 0)
            this.effect = AddSpecialEffectEx(MODEL, Spell.x, Spell.y, 0, SCALE)

            UnitAddAbility(this.unit, AURA)
            SetUnitAbilityLevel(this.unit, AURA, Spell.level)
            BlzSetAbilityRealLevelField(BlzGetUnitAbility(this.unit, AURA), ABILITY_RLF_LIFE_REGENERATION_INCREASE_PERCENT, Spell.level - 1, GetRegenBonus(Spell.source.unit, Spell.level))
            IncUnitAbilityLevel(this.unit, AURA)
            DecUnitAbilityLevel(this.unit, AURA)

            if LightInfusion then
                if (LightInfusion.charges[Spell.source.unit] or 0) > 0 then
                    UnitAddAbility(this.unit, INFUSED_AURA)
                    SetUnitAbilityLevel(this.unit, INFUSED_AURA, Spell.level)
                    LightInfusion.consume(Spell.source.unit)
                end
            end

            DestroyEffect(AddSpecialEffectEx(SPAWN_MODEL, Spell.x, Spell.y, 0, SPAWN_SCALE))
            TimerStart(CreateTimer(), GetDuration(Spell.source.unit, Spell.level), false, function ()
                this:destroy()
                DestroyTimer(GetExpiredTimer())
            end)
        end

        function BlessedField.onDamage()
            if Damage.amount > 0 then
                if GetUnitAbilityLevel(Damage.target.unit, BUFF_2) > 0 then
                    Damage.amount = Damage.amount * GetDamageReduction(2)
                elseif GetUnitAbilityLevel(Damage.target.unit, BUFF_1) > 0 then
                    Damage.amount = Damage.amount * GetDamageReduction(1)
                end

                if GetUnitAbilityLevel(Damage.target.unit, INFUSED_BUFF) > 0 then
                    if Damage.amount >= (Damage.target.health - 1) then
                        Damage.amount = 0
                        SetWidgetLife(Damage.target.unit, 1)
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