OnInit("LightInfusion", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- ---------------------------- Light Infusion v1.4 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Light Infusion ability
    local ABILITY     = S2A('Trl0')
    -- The Light Infusion orb model
    local MODEL       = "LightOrb.mdl"
    -- The Light Infusion orb scale
    local SCALE       = 1.
    -- The Light Infusion orb death model
    local DEATH_MODEL = "LightFlash.mdl"
    -- The Light Infusion death model scale
    local DEATH_SCALE = 0.5
    -- The Light Infusion orbs offset
    local OFFSET      = 125.
    -- The Light Infusion orb update period
    local PERIOD      = 0.05

    -- The Light Infusion max number of charges
    local function GetMaxCharges(level)
        return 3 + 0*level
    end

    -- The Light Infusion health regen bonus per stack
    local function GetBonusRegen(level)
        return 5. + 0.*level
    end

    -- The Light Infusion level up base on hero level
    local function GetLevel(level)
        return level == 5 or level == 10 or level == 15 or level == 20
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        LightInfusion = Class(Spell)

        local array = {}
        local CIRCLE = 2*bj_PI
        local STEP = 2.5*bj_DEGTORAD

        LightInfusion.charges = {}

        function LightInfusion:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)

            for i = 0, GetMaxCharges(GetUnitAbilityLevel(self.unit, ABILITY)) do
                if self.effect[i] then
                    DestroyEffect(self.effect[i])
                    self.effect[i] = nil
                end
            end

            array[self.unit] = nil
			LightInfusion.charges[self.unit] = nil
            
			self.unit = nil
            self.timer = nil
        end

        function LightInfusion.consume(unit)
            local self = array[unit]

            if self and (LightInfusion.charges[unit] or 0) > 0 then
                LightInfusion.charges[unit] = (LightInfusion.charges[unit] or 0) - 1
                
                local x = BlzGetLocalSpecialEffectX(self.effect[LightInfusion.charges[unit]])
                local y = BlzGetLocalSpecialEffectY(self.effect[LightInfusion.charges[unit]])
                local z = BlzGetLocalSpecialEffectZ(self.effect[LightInfusion.charges[unit]])
                
                if LightInfusion.charges[unit] > 0 then
                    self.arc = CIRCLE/LightInfusion.charges[unit]
                end

                DestroyEffect(AddSpecialEffectEx(DEATH_MODEL, x, y, z, DEATH_SCALE))
                DestroyEffect(self.effect[LightInfusion.charges[unit]])
                AddUnitBonus(self.unit, BONUS_HEALTH_REGEN, -self.bonus)
                self.bonus = LightInfusion.charges[unit] * GetBonusRegen(GetUnitAbilityLevel(self.unit, ABILITY))
                AddUnitBonus(self.unit, BONUS_HEALTH_REGEN, self.bonus)
            end
        end

        function LightInfusion:onCast()
            if (LightInfusion.charges[Spell.source.unit] or 0) < GetMaxCharges(Spell.level) then
                local this = array[Spell.source.unit]

                if not this then
                    this = { destroy = LightInfusion.destroy }
                    
                    this.unit = Spell.source.unit
                    this.effect = {}
                    this.angle = 0
                    this.bonus = 0
                    this.timer = CreateTimer()

                    array[Spell.source.unit] = this

                    TimerStart(this.timer, PERIOD, true, function ()
                        if LightInfusion.charges[this.unit] > 0 then
                            this.angle = this.angle + STEP

                            for i = 0, LightInfusion.charges[this.unit] - 1 do
                                BlzSetSpecialEffectPosition(this.effect[i], GetUnitX(this.unit) + OFFSET*math.cos(this.angle + i*this.arc), GetUnitY(this.unit) + OFFSET*math.sin(this.angle + i*this.arc), GetUnitZ(this.unit) + 100)
                            end
                        else
                            this:destroy()
                        end
                    end)
                end

                this.effect[LightInfusion.charges[this.unit]] = AddSpecialEffectEx(MODEL, Spell.source.x, Spell.source.y, Spell.source.z + 100, SCALE)
                LightInfusion.charges[this.unit] = (LightInfusion.charges[this.unit] or 0) + 1
                this.arc = CIRCLE/LightInfusion.charges[this.unit]

                AddUnitBonus(this.unit, BONUS_HEALTH_REGEN, -this.bonus)
                this.bonus = LightInfusion.charges[this.unit] * GetBonusRegen(Spell.level)
                AddUnitBonus(this.unit, BONUS_HEALTH_REGEN, this.bonus)
            else
                ResetUnitAbilityCooldown(Spell.source.unit, Spell.id)
                DisplayTextToPlayer(Spell.source.player, 0, 0, "Already at full stacks.")
            end
        end

        function LightInfusion.onLevel()
            local source = GetTriggerUnit()

            if GetLevel(GetHeroLevel(source)) then
                IncUnitAbilityLevel(source, ABILITY)
            end
        end

        function LightInfusion.onInit()
            RegisterSpell(LightInfusion.allocate(), ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, LightInfusion.onLevel)
        end
    end
end)