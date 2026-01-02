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
    Bladestorm_ABILITY = S2A('SmrA')
    -- The model path used in baldestorm
    local MODEL        = "Bladestorm.mdl"
    -- The rate at which the bladestorm model is spammed
    local RATE         = 0.3

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Bladestorm = Class(Spell)

        function Bladestorm:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            SetUnitTimeScale(self.unit, 1)
            
            self.unit = nil
            self.timer = nil
        end

        function Bladestorm:onCast()
            local this = { destroy = Bladestorm.destroy }

            this.unit = Spell.source.unit
            this.timer = CreateTimer()
            this.duration = BlzGetAbilityRealLevelField(Spell.ability, ABILITY_RLF_DURATION_HERO, Spell.level - 1)
        
            SetUnitTimeScale(this.unit, 3)
            TimerStart(this.timer, RATE, true, function ()
                this.duration = this.duration - RATE

                if this.duration > 0 and UnitAlive(this.unit) and not IsUnitPaused(this.unit) then
                    DestroyEffect(AddSpecialEffectTarget(MODEL, this.unit, "origin"))
                else
                    this:destroy()
                end
            end)
        end

        function Bladestorm.onInit()
            RegisterSpell(Bladestorm.allocate(), Bladestorm_ABILITY)
        end
    end
end)