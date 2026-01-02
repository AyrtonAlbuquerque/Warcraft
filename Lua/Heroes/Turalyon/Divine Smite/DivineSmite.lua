OnInit("DivineSmite", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires.optional "Bonus"
    requires.optional "LightInfusion"

    -- ----------------------------- Divine Smite v1.4 by Chopinski ---------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Divine Smite ability
    local ABILITY       = S2A('Trl1')
    -- The Divine Smite model
    local MODEL         = "Divine Edict.mdl"
    -- The  Divine Smite heal model
    local HEAL_MODEL    = "HolyLight2.mdl"
    -- The Divine Smite model
    local ATTACH_POINT  = "origin"
    -- The Divine Smite normal scale
    local SCALE         = 0.6
    -- The Divine Smite infused scale
    local INFUSED_SCALE = 1.
    -- The Divine Smite stomp model
    local STOMP         = "LightStomp.mdl"
    -- The Divine Smite stomp scale
    local STOMP_SCALE   = 0.8

    -- The Divine Smite damage/heal
    local function GetDamage(source, level, infused)
        if Bonus then
            if infused then
                return 50. * level + (0.25 * GetUnitBonus(source, BONUS_SPELL_POWER)) + (0.1 * level * GetHeroStr(source, true))
            else    
                return 100. * level + (0.25 * level * GetUnitBonus(source, BONUS_SPELL_POWER)) + (0.25 * level * GetHeroStr(source, true))
            end
        else
            if infused then
                return 50. * level + (0.1 * level *  GetHeroStr(source, true))
            else    
                return 100. * level + (0.25 * level *  GetHeroStr(source, true))
            end
        end
    end

    -- The Divine Smite AoE
    local function GetAoE(unit, level, infused)
        if infused then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1) + 50*level
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
        end
    end

    -- The Divine Smite Infused duration
    local function GetDuration(level)
        return 3. + 0.*level
    end

    -- The Divine Smite infused damage/heal interval
    local function GetInterval(level)
        return 0.5 + 0.*level
    end

    -- Filter for damage/heal
    local function GroupFilter(player, unit)
        return UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        DivineSmite = Class(Spell)

        function DivineSmite:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyEffect(AddSpecialEffectEx(STOMP, self.x, self.y, 0, STOMP_SCALE))

            self.unit = nil
            self.timer = nil
            self.player = nil
        end

        function DivineSmite.smite(caster, owner, x, y, aoe, damage)
            local group = CreateGroup()

            GroupEnumUnitsInRange(group, x, y, aoe, nil)

            local u = FirstOfGroup(group)

            while u do
                if GroupFilter(owner, u) then
                    if IsUnitEnemy(u, owner) then
                        UnitDamageTarget(caster, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                    else
                        SetWidgetLife(u, GetWidgetLife(u) + damage)
                        DestroyEffect(AddSpecialEffectTarget(HEAL_MODEL, u, ATTACH_POINT))
                    end
                end

                GroupRemoveUnit(group, u)
                u = FirstOfGroup(group)
            end

            DestroyGroup(group)
        end

        function DivineSmite:onTooltip(source, level, ability)
            return "|cffffcc00Turalyon|r calls forth a |cffffcc00Divine Smite|r at the target area, healing allied units and damaging enemy units within |cffffcc00" .. N2S(GetAoE(source, level, false), 0) .. " AoE|r for |cff00ffff" .. N2S(GetDamage(source, level, false), 0) .. "|r |cff00ffffMagic|r damage/heal.\n\n|cffffcc00Light Infused|r: |cffffcc00Divine Smite|r area of effect is increased to |cffffcc00" .. N2S(GetAoE(source, level, true), 0) .. " AoE|r and it becomes a beam, lasting for |cffffcc00" .. N2S(GetDuration(level), 1) .. "|r seconds and damaging/healing every |cffffcc00" .. N2S(GetInterval(level), 1) .. "|r seconds for |cff00ffff" .. N2S(GetDamage(source, level, true), 0) .. "|r |cff00ffffMagic|r damage/heal."
        end

        function DivineSmite:onCast()
            if LightInfusion then
                if (LightInfusion.charges[Spell.source.unit] or 0) > 0 then
                    local this = { destroy = DivineSmite.destroy }

                    this.x = Spell.x
                    this.y = Spell.y
                    this.unit = Spell.source.unit
                    this.player = Spell.source.player
                    this.timer = CreateTimer()
                    this.period = GetInterval(Spell.level)
                    this.duration = GetDuration(Spell.level)
                    this.aoe = GetAoE(Spell.source.unit, Spell.level, true)
                    this.damage = GetDamage(Spell.source.unit, Spell.level, true)

                    LightInfusion.consume(Spell.source.unit)
                    DivineSmite.smite(this.unit, this.player, this.x, this.y, this.aoe, this.damage)
                    SpamEffect(MODEL, this.x, this.y, 0, INFUSED_SCALE, 0.15, 20)
                    DestroyEffect(AddSpecialEffectEx(STOMP, this.x, this.y, 0, STOMP_SCALE))
                    TimerStart(this.timer, this.period, true, function ()
                        this.duration = this.duration - this.period

                        if this.duration > 0 then
                            DivineSmite.smite(this.unit, this.player, this.x, this.y, this.aoe, this.damage)
                        else
                            this:destroy()
                        end
                    end)
                else
                    DestroyEffect(AddSpecialEffectEx(MODEL, Spell.x, Spell.y, 0, SCALE))
                    DestroyEffect(AddSpecialEffectEx(STOMP, Spell.x, Spell.y, 0, SCALE))
                    DivineSmite.smite(Spell.source.unit, Spell.source.player, Spell.x, Spell.y, GetAoE(Spell.source.unit, Spell.level, false), GetDamage(Spell.source.unit, Spell.level, false))
                end
            else
                DestroyEffect(AddSpecialEffectEx(MODEL, Spell.x, Spell.y, 0, SCALE))
                DestroyEffect(AddSpecialEffectEx(STOMP, Spell.x, Spell.y, 0, SCALE))
                DivineSmite.smite(Spell.source.unit, Spell.source.player, Spell.x, Spell.y, GetAoE(Spell.source.unit, Spell.level, false), GetDamage(Spell.source.unit, Spell.level, false))
            end
        end

        function DivineSmite.onInit()
            RegisterSpell(DivineSmite.allocate(), ABILITY)
        end
    end
end)