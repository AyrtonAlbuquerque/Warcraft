OnInit("Bladestorm", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires.optional "Bonus"

    -- ------------------------------ Bladestorm v1.4 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Bladestorm ability
    Bladestorm_ABILITY      = S2A('Smr1')
    -- The raw code of the Bladestorm buff
    Bladestorm_BUFF         = S2A('BSm0')
    -- The model path used in baldestorm
    local  MODEL            = "BladestormHots.mdl"
    -- If true, the bladestorm model will be spawned at the damage period
    local SPAM              = false
    -- The damage period
    local PERIOD            = 0.25
    -- The time scale during bladestorm
    local TIME_SCALE        = 1

    -- The Bladestorm damage per second
    local function GetDamage(source, level)
        if Bonus then
            return 50. * level + 0.1 * level * GetUnitBonus(source, BONUS_DAMAGE)
        else
            return 50. * level
        end
    end

    -- The BladeStorm AoE
    local function GetAoE(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, Bladestorm_ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    local function GetManaCost(source, level)
        return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(source, Bladestorm_ABILITY), ABILITY_ILF_MANA_COST, level - 1)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Bladestorm = Class(Spell)

        local array = {}

        function Bladestorm:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            SetUnitTimeScale(self.unit, 1)
            UnitRemoveAbility(self.unit, S2A('Abun'))
            IssueImmediateOrderById(self.unit, 852590)
            QueueUnitAnimation(self.unit, "Stand Ready")
            AddUnitAnimationProperties(self.unit, "spin", false)
            DestroyEffect(self.effect)

            array[self.unit] = nil
            
            self.unit = nil
            self.effect = nil
        end

        function Bladestorm:onTooltip(source, level, ability)
            return "Causes a bladestorm of destructive force around |cffffcc00Samuro|r, dealing |cffff0000" .. N2S(GetDamage(source, level), 0) .. "|r |cffff0000Physical|r damage per second to enemy units within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. " AoE|r. Drains |cff00ffff" .. N2S(GetManaCost(source, level), 0) .. " mana|r per second while activated."
        end

        function Bladestorm:onCast()
            local this = array[Spell.source.unit]

            if not this then
                this ={ destroy = Bladestorm.destroy }

                this.unit = Spell.source.unit
                this.level = Spell.level
                this.timer = CreateTimer()

                array[this.unit] = this
            
                SetUnitTimeScale(this.unit, TIME_SCALE)
                UnitAddAbility(this.unit, S2A('Abun'))
                AddUnitAnimationProperties(this.unit, "spin", true)
                TimerStart(this.timer, PERIOD, true, function ()
                    local cost = GetManaCost(this.unit, this.level)

                    if GetUnitAbilityLevel(this.unit, Bladestorm_BUFF) > 0 and GetUnitState(this.unit, UNIT_STATE_MANA) >= cost then
                        AddUnitMana(this.unit, -cost * PERIOD)
                        UnitDamageArea(this.unit, GetUnitX(this.unit), GetUnitY(this.unit), GetAoE(this.unit, this.level), GetDamage(this.unit, this.level) * PERIOD, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, false, false, false)

                        if not SPAM then
                            DestroyEffect(AddSpecialEffectTarget(MODEL, this.unit, "origin"))
                        end

                    else
                        this:destroy()
                    end
                end)

                if SPAM then
                    this.effect = AddSpecialEffectTarget(MODEL, this.unit, "origin")
                end
            end
        end

        function Bladestorm.onInit()
            RegisterSpell(Bladestorm.allocate(), Bladestorm_ABILITY)
        end
    end
end)