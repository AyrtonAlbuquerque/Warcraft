OnInit("BerserkerZone", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Utilities"

    -- ---------------------------- BerserkerZone v1.1 by Chopinski ---------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Berserker Zone ability
    local ABILITY    = S2A('SmrB')
    -- The raw code of the Berserker Zone aura
    local AURA       = S2A('SmrC')
    -- The raw code of the Berserker Zone buff
    local BUFF       = S2A('BSm1')
    -- The model path used in Berserker Zone
    local MODEL      = "BladeZone.mdl"
    -- The model scale
    local SCALE      = 1

    -- The Berserker Zone damage bonus per interval
    local function GetBonusDamage(level)
        return 5. * level
    end

    -- The Berserker Zone crit chance bonus per interval
    local function GetBonusCriticalChance(level)
        return 0.01 * level
    end

    -- The Berserker Zone crit damage bonus per interval
    local function GetBonusCriticalDamage(level)
        return 0.025 * level
    end

    -- The Berserker Zone bonus interval
    local function GetInterval(level)
        return 1 + 0. * level
    end

    -- The Berserker Zone duration
    local function GetDuration(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The Berserker Zone AoE
    local function GetAoE(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        BerserkerZone = Class(Spell)

        function BerserkerZone:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyGroup(self.group)
            DestroyEffect(self.effect)
            UnitRemoveAbility(self.unit, AURA)
            DummyRecycle(self.unit)

            self.unit = nil
            self.timer = nil
            self.group = nil
            self.effect = nil
        end

        function BerserkerZone:onTooltip(source, level, ability)
            return "|cffffcc00Samuro|r places his blade in the ground creating a |cffffcc00Berserker Zone|r. Allied units within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. " AoE|r of the blade gains |cffff0000" .. N2S(GetBonusDamage(level), 0) .. "|r |cffff0000Damage|r, |cffffcc00" .. N2S(GetBonusCriticalChance(level) * 100, 1) .. "%%|r |cffff0000Critical Chance|r and |cffffcc00" .. N2S(GetBonusCriticalDamage(level) * 100, 1) .. "%%|r |cffff0000Critical Damage|r every second.\n\nLasts |cffffcc00" .. N2S(GetDuration(source, level), 0) .. "|r seconds."
        end

        function BerserkerZone:onCast()
            local this = { destroy = BerserkerZone.destroy }

            this.x = Spell.x
            this.y = Spell.y
            this.level = Spell.level
            this.timer = CreateTimer()
            this.group = CreateGroup()
            this.period = GetInterval(Spell.level)
            this.aoe = GetAoE(Spell.source.unit, Spell.level)
            this.unit = DummyRetrieve(Spell.source.player, Spell.x, Spell.y, 0, 0)
            this.effect = AddSpecialEffectEx(MODEL, Spell.x, Spell.y, 0, SCALE)
            this.duration = GetDuration(Spell.source.unit, Spell.level)

            UnitAddAbility(this.unit, AURA)
            SetUnitAbilityLevel(this.unit, AURA, Spell.level)
            TimerStart(this.timer, this.period, true, function ()
                this.duration = this.duration - this.period

                if this.duration > 0 then
                    GroupEnumUnitsInRange(this.group, this.x, this.y, this.aoe, nil)

                    local u = FirstOfGroup(this.group)

                    while u do
                       if GetUnitAbilityLevel(u, BUFF) > 0 then
                            LinkBonusToBuff(u, BONUS_DAMAGE, GetBonusDamage(this.level), BUFF)
                            LinkBonusToBuff(u, BONUS_CRITICAL_CHANCE, GetBonusCriticalChance(this.level), BUFF)
                            LinkBonusToBuff(u, BONUS_CRITICAL_DAMAGE, GetBonusCriticalDamage(this.level), BUFF)
                        end 

                        GroupRemoveUnit(this.group, u)
                        u = FirstOfGroup(this.group)
                    end
                else
                    this:destroy()
                end
            end)
        end

        function BerserkerZone.onInit()
            RegisterSpell(BerserkerZone.allocate(), ABILITY)
        end
    end
end)