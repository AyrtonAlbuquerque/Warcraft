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
    -- The model path used in baldestorm
    local  MODEL            = "BladestormHots.mdl"
    -- The damage period
    local PERIOD            = 0.25
    -- The time scale during bladestorm
    local TIME_SCALE        = 1

    -- The Bladestorm damage per second
    local function GetDamage(source, level)
        if Bonus then
            return 100. * level + 0.15 * level * GetUnitBonus(source, BONUS_DAMAGE)
        else
            return 100. * level
        end
    end

    -- The BladeStorm AoE
    local function GetAoE(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, Bladestorm_ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    function Bladestorm_GetDuration(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, Bladestorm_ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
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
            DestroyEffect(self.effect)

            array[self.unit] = nil
            
            self.unit = nil
            self.effect = nil
        end

        function Bladestorm:onTooltip(source, level, ability)
            return "Causes a bladestorm of destructive force around |cffffcc00Samuro|r, dealing |cffff0000" .. N2S(GetDamage(source, level), 0) .. "|r |cffff0000Physical|r damage per second to enemy units within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. " AoE|r. Lasts |cffffcc00" .. N2S(Bladestorm_GetDuration(source, level), 0) .. "|r seconds."
        end

        function Bladestorm:onCast()
            local this = array[Spell.source.unit]

            if not this then
                this = { destroy = Bladestorm.destroy }

                this.unit = Spell.source.unit
                this.level = Spell.level
                this.timer = CreateTimer()
                this.duration = Bladestorm_GetDuration(this.unit, this.level)
                this.effect = AddSpecialEffectTarget(MODEL, this.unit, "origin")

                array[this.unit] = this
            
                SetUnitTimeScale(this.unit, TIME_SCALE)
                TimerStart(this.timer, PERIOD, true, function ()
                    this.duration = this.duration - PERIOD

                    if this.duration > 0 and UnitAlive(this.unit) and not IsUnitPaused(this.unit) then
                        UnitDamageArea(this.unit, GetUnitX(this.unit), GetUnitY(this.unit), GetAoE(this.unit, this.level), GetDamage(this.unit, this.level) * PERIOD, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, false, false, false)
                    else
                        this:destroy()
                    end
                end)
            end
        end

        function Bladestorm.onInit()
            RegisterSpell(Bladestorm.allocate(), Bladestorm_ABILITY)
        end
    end
end)