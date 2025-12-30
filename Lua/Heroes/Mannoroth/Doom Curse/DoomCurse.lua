OnInit("DoomCurse", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"
    requires "Utilities"

    -- ------------------------------ Doom Curse v1.6 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Doom Curse ability
    local ABILITY     = S2A('MnrD')
    -- The raw code of the Doom Curse buff
    local CURSE_BUFF  = S2A('BMn2')
    -- The raw code of the unit created
    local UNIT_ID     = S2A('umn0')
    -- The Attack type of the damage dealt (Spell)
    local ATTACK_TYPE = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt 
    local DAMAGE_TYPE = DAMAGE_TYPE_MAGIC

    -- The damage dealt per interval
    local function GetDamage(source, level)
        return 125. * level + 1.5 * GetUnitBonus(source, BONUS_SPELL_POWER)
    end

    -- The interval at which the damage is dealt
    local function GetInterval(level)
        return 1. + 0.*level
    end

    -- The damage amplification cursed units take from caster
    local function GetAmplification(level)
        return 0.1 + 0.2*level
    end

    -- The Pit Infernal base damage
    local function GetBaseDamage(unit, level)
        return R2I(50*level + GetUnitBonus(unit, BONUS_DAMAGE)*0.5)
    end

    -- The Pit Infernal base health
    local function GetHealth(unit, level)
        return R2I(1000 + 500*level + BlzGetUnitMaxHP(unit)*0.5)
    end

    -- The Pit Infernal base armor
    local function GetArmor(unit, level)
        return 10.*level + GetUnitBonus(unit, BONUS_ARMOR)
    end

    -- The Pit Infernal Spell Power
    local function GetSpellPower(source, level)
        return GetUnitBonus(source, BONUS_SPELL_POWER)
    end

    -- The Pit Infernal duration. By default is the ability summoned unit duration field. If 0 the unit will last forever.
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_SUMMONED_UNIT_DURATION_SECONDS_NDO3, level - 1)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        DoomCurse = Class(Spell)

        local source = {}

        function DoomCurse:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)

            source[self.target] = nil
            
            self.timer = nil
            self.caster = nil
            self.target = nil
        end

        function DoomCurse:onTooltip(source, level, ability)
            return "|cffffcc00Mannoroth|r marks an enemy unit with a |cffffcc00Doom Curse|r, silencing, dealing |cff00ffff" .. N2S(GetDamage(source, level), 0) .. "|r |cff00ffffMagic|r damage every |cffffcc00" .. N2S(GetInterval(level), 1) .. "|r second and increases the damage that the targeted unit takes from |cffffcc00Mannoroth|r by |cffffcc00" .. N2S(GetAmplification(level) * 100, 0) .. "%%|r. If the cursed unit dies under the effect of |cffffcc00Doom Curse|r, a |cffffcc00Pit Infernal|r will spawn from it corpse. The |cffffcc00Pit Infernal|r can cast |cffffcc00Infernal Charge|r, charging towards the pointed direction, knocking enemy units aside and damaging them, and |cffffcc00War Stomp|r."
        end

        function DoomCurse:onCast()
            local this = { destroy = DoomCurse.destroy }
            
            this.level = Spell.level
            this.caster = Spell.source.unit
            this.target = Spell.target.unit
            this.timer = CreateTimer()
            this.damage = GetDamage(Spell.source.unit, Spell.level)
            source[this.target] = Spell.source.unit

            TimerStart(this.timer, GetInterval(Spell.level), true, function ()
                if GetUnitAbilityLevel(this.target, CURSE_BUFF) > 0 then
                    UnitDamageTarget(this.caster, this.target, this.damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, nil)
                else
                    this:destroy()
                end
            end)
        end

        function DoomCurse.onDamage()
            local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)
            local cursed = GetUnitAbilityLevel(Damage.target.unit, CURSE_BUFF) > 0

            if cursed and Damage.amount > 0 then
                if source[Damage.target.unit] == Damage.source.unit then
                    Damage.amount = Damage.amount * (1 + GetAmplification(level))
                end

                if Damage.amount >= GetWidgetLife(Damage.target.unit) and source[Damage.target.unit] then
                    local unit = CreateUnit(GetOwningPlayer(source[Damage.target.unit]), UNIT_ID, Damage.target.x, Damage.target.y, 0)

                    SetUnitBonus(unit, BONUS_SPELL_POWER, GetSpellPower(source[Damage.target.unit], level))
                    SetUnitAnimation(unit, "Birth")
                    BlzSetUnitBaseDamage(u, GetBaseDamage(level, source[Damage.target.unit]), 0)
                    BlzSetUnitMaxHP(unit, GetHealth(level, source[Damage.target.unit]))
                    BlzSetUnitArmor(unit, GetArmor(level, source[Damage.target.unit]))
                    SetUnitLifePercentBJ(unit, 100)

                    if GetDuration(source[Damage.target.unit], level) > 0 then
                        UnitApplyTimedLife(unit, 'BTLF', GetDuration(source[Damage.target.unit], level))
                    end
                end
            end
        end

        function DoomCurse.onInit()
            RegisterSpell(DoomCurse.allocate(), ABILITY)
            RegisterAnyDamageEvent(DoomCurse.onDamage)
        end
    end
end)