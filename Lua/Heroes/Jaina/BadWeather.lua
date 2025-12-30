OnInit("BadWeather", function (requires)
    requires "Class"
    requires "Spell"
    requires "Damage"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- ----------------------------- Bad Weather v1.1 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Ability
    local ABILITY       = S2A('Jna6')
    -- The raw code of the debuff Ability
    local DEBUFF        = S2A('Jna7')
    -- The raw code of the debuff buff
    local BUFF          = S2A('BJn4')
    -- The rain model
    local MODEL         = "Rain.mdl"
    -- The rain model scale
    local SCALE         = 2.5
    -- The raw code of the Jaina unit in the editor
    local JAINA_ID      = S2A('H000')
    -- The GAIN_AT_LEVEL is greater than 0
    -- Jaina will gain Bad Weather at this level
    local GAIN_AT_LEVEL = 20

    -- The rain duration
    local function GetDuratoin(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The bonus damage dealt (use different buffs per level in the debuff ability)
    local function GetDamageBonus(buff)
        if buff == BUFF then
            return 0.2
        else
            return 0.2
        end
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        BadWeather = Class(Spell)

        function BadWeather:destroy()
            UnitRemoveAbility(self.unit, DEBUFF)
            DestroyEffect(self.effect)
            DummyRecycle(self.unit)
            
            self.unit = nil
            self.effect = nil
        end

        function BadWeather:onTooltip(source, level, ability)
            return "|cffffcc00Jaina|r conjures a heavy rain at the target region causing all enemy units within |cffffcc00" .. N2S(BlzGetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, level - 1), 0) .. " AoE|r to take |cffffcc00" .. N2S(20, 0) .. "%%|r increased |cff00ffffMagic|r damage.\n\nLasts for |cffffcc00" .. N2S(GetDuratoin(source, level), 0) .. "|r seconds."
        end

        function BadWeather:onCast()
            local this = { destroy = BadWeather.destroy }

            this.unit = DummyRetrieve(Spell.source.player, Spell.x, Spell.y, 0, 0)
            this.effect = AddSpecialEffectEx(MODEL, Spell.x, Spell.y, 0, SCALE)

            UnitAddAbility(this.unit, DEBUFF)
            TimerStart(CreateTimer(), GetDuratoin(Spell.source.unit, Spell.level), false, function ()
                DestroyTimer(GetExpiredTimer())
                this:destroy()
            end)
        end

        function BadWeather.onDamage()
            if GetUnitAbilityLevel(Damage.target.unit, BUFF) > 0 and Damage.isEnemy then
                Damage.amount = Damage.amount * (1 + GetDamageBonus(BUFF))
            end
        end

        function BadWeather.onLevelUp()
            local unit = GetTriggerUnit()
        
            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(unit) == JAINA_ID and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                    UnitAddAbility(unit, ABILITY)
                    UnitMakeAbilityPermanent(unit, true, ABILITY)
                end
            end
        end

        function BadWeather.onInit()
            RegisterSpell(BadWeather.allocate(), ABILITY)
            RegisterSpellDamageEvent(BadWeather.onDamage)
            RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, BadWeather.onLevelUp)
        end
    end
end)