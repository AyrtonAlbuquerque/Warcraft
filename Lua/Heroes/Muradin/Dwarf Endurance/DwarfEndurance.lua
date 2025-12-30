OnInit("DwarfEndurance", function (requires)
    requires "Class"
    requires "Spell"
    requires "Damage"
    requires "Utilities"

    -- --------------------------- Dwarf Endurance v1.3 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Dwarf Endurance ability
    local ABILITY        = S2A('Mrd4')
    -- The period at which health is restored
    local PERIOD         = 0.1
    -- The model used
    local HEAL_EFFECT    = "GreenHeal.mdl"
    -- The attachment point
    local ATTACH_POINT   = "origin"

    -- The time necessary for muradin to not take damage until the ability activates
    local function GetCooldown()
        return 4.
    end

    -- The heal per second
    local function GetHeal(level)
        return 25. + 25.*level
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        DwarfEndurance = Class(Spell)

        local array = {}

        function DwarfEndurance:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyEffect(self.effect)

            array[self.unit] = nil

            self.unit = nil
            self.timer = nil
            self.effect = nil
        end

        function DwarfEndurance:onTooltip(source, level, ability)
            return "When |cffffcc00Muradin|r stops taking damage for |cffffcc00" .. N2S(GetCooldown(), 1) .. "|r seconds, |cff00ff00Health Regeneration|r is increased by |cff00ff00" .. N2S(GetHeal(level), 0) .. "|r per second."
        end

        function DwarfEndurance:onLearn(source, skill, level)
            if not array[source] then
                local this = { destroy = DwarfEndurance.destroy }
                
                this.cooldown = 0
                this.unit = source
                this.timer = CreateTimer()
                this.effect = AddSpecialEffectTarget(HEAL_EFFECT, source, ATTACH_POINT)
                array[source] = this

                TimerStart(this.timer, PERIOD, true, function ()
                    local level = GetUnitAbilityLevel(this.unit, ABILITY)
                    
                    if level > 0 then
                        if this.cooldown <= 0 then
                            if UnitAlive(this.unit) then
                                SetWidgetLife(this.unit, GetWidgetLife(this.unit) + GetHeal(level) * PERIOD)
                            end
                        else
                            this.cooldown = this.cooldown - PERIOD

                            if this.effect then
                                DestroyEffect(this.effect)
                                this.effect = nil
                            end

                            if this.cooldown <= 0 then
                                this.effect = AddSpecialEffectTarget(HEAL_EFFECT, this.unit, ATTACH_POINT)
                            end
                        end
                    else
                        this:destroy()
                    end
                end)
            end
        end

        function DwarfEndurance.onDamage()
            local self = array[Damage.target.unit]
        
            if self then
                self.cooldown = GetCooldown()
            end
        end

        function DwarfEndurance.onInit()
            RegisterSpell(DwarfEndurance.allocate(), ABILITY)
            RegisterAnyDamageEvent(DwarfEndurance.onDamage)
        end
    end
end)