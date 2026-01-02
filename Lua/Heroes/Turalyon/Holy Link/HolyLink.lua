OnInit("HolyLink", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"
    requires "Utilities"
    requires.optional "LightInfusion"

    -- ------------------------------ Holy Link v1.4 by Chopinski ------------------------------ --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Holy Link ability
    local ABILITY       = S2A('Trl2')
    -- The Holy Link Normal buff model
    local MODEL         = "Rejuvenation.mdl"
    -- The Holy Link infused buff model
    local INFUSED_MODEL = "Rejuvenation.mdl"
    -- The Holy Link lightning effect
    local LIGHTNING     = "HWSB"
    -- The Holy Link model attachment point
    local ATTACH_POINT  = "chest"
    -- The Holy Link update period
    local PERIOD        = 0.03125

    -- The Holy Link Health Regen bonus
    local function GetBonus(unit, level)
        local base = 5. + 5.*level

        return (base + base*(1 - (GetUnitLifePercent(unit)*0.01)))*PERIOD
    end

    -- The Holy Link Movement Speed bonus
    local function GetMovementBonus(level, infused)
        if infused then
            return 50 + 0*level
        else
            return 0
        end
    end

    -- The Holy Link break distance
    local function GetAoE(level, infused)
        if infused then
            return 1200. + 0.*level
        else
            return 800. + 0.*level
        end
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        HolyLink = Class(Spell)

        local array = {}
        local reduce = {}

        function HolyLink:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyLightning(self.lightning)
            DestroyEffect(self.effect)

            if self.infused then
                reduce[self.target] = reduce[self.target] - 1

                DestroyEffect(self.self)
                AddUnitBonus(self.unit, BONUS_MOVEMENT_SPEED, -self.bonus)
                AddUnitBonus(self.target, BONUS_MOVEMENT_SPEED, -self.bonus)
            end

            array[self.unit] = nil

            self.self = nil
            self.unit = nil
            self.timer = nil
            self.target = nil
            self.effect = nil
            self.lightning = nil
        end
        
        function HolyLink.link(source, target, level, infused)
            local self = { destroy = HolyLink.destroy }

            self.count = 0
            self.unit = source
            self.target = target
            self.infused = infused
            self.timer = CreateTimer()
            self.distance = GetAoE(level, infused)
            self.bonus = GetMovementBonus(level, infused)
            self.effect = AddSpecialEffectTarget(MODEL, target, ATTACH_POINT)
            self.lightning = AddLightningEx(LIGHTNING, false, GetUnitX(source), GetUnitY(source), GetUnitZ(source) + 30, GetUnitX(target), GetUnitY(target), GetUnitZ(target) + 30)
            array[source] = self

            if infused then
                self.self = AddSpecialEffectTarget(MODEL, source, ATTACH_POINT)
                reduce[target] = (reduce[target] or 0) + 1

                AddUnitBonus(source, BONUS_MOVEMENT_SPEED, self.bonus)
                AddUnitBonus(target, BONUS_MOVEMENT_SPEED, self.bonus)
            end

            TimerStart(self.timer, PERIOD, true, function ()
                local x = GetUnitX(self.unit)
                local y = GetUnitY(self.unit)
                local tx = GetUnitX(self.target)
                local ty = GetUnitY(self.target)
                local level = GetUnitAbilityLevel(self.unit, ABILITY)

                if DistanceBetweenCoordinates(x, y, tx, ty) <= self.distance and UnitAlive(self.target) and UnitAlive(self.unit) then
                    if self.infused then
                        SetWidgetLife(self.unit, GetWidgetLife(self.unit) + GetBonus(self.unit, level))
                        SetWidgetLife(self.target, GetWidgetLife(self.target) + GetBonus(self.target, level))
                    else
                        SetWidgetLife(self.target, GetWidgetLife(self.target) + GetBonus(self.target, level))
                    end

                    if self.count <= 28 then -- This is here because reforged lightnings don't persist visually...
                        self.count = self.count + 1
                        MoveLightningEx(self.lightning, false, x, y, GetUnitZ(self.unit) + 30, tx, ty, GetUnitZ(self.target) + 30)
                    else
                        self.count = 0
                        DestroyLightning(self.lightning)
                        self.lightning = AddLightningEx(LIGHTNING, false, x, y, GetUnitZ(self.unit) + 30, tx, ty, GetUnitZ(self.target) + 30)
                    end
                
                else
                    self:destroy()
                end
            end)
        end

        function HolyLink:onTooltip(source, level, ability)
            return "|cffffcc00Turalyon|r creates a |cffffcc00Holy Link|r between himself and the targeted allied unit, increasing its |cff00ff00Health Regeneration|r while linked to |cffffcc00Turalyon|r by |cff00ff00" .. N2S(5. + 5.*level, 1) .. "|r increased by |cffffcc001%|r for every |cffffcc001%|r of the linked unit missing health. The link is broken if the distance between |cffffcc00Turalyon|r and the linked unit is greater than |cffffcc00" .. N2S(GetAoE(level, false), 0) .. " AoE|r.\n\n|cffffcc00Light Infused|r: Both |cffffcc00Turalyon|r and the linked unit get their |cff00ff00Health Regeneration|r increased. In addition their |cffffff00Movement Speed|r is increased by |cffffcc00" .. I2S(GetMovementBonus(level, true)) .. "|r and all the damage the linked unit takes is reduced by |cffffcc0025%|r. The distance at which the link is broken is also increased to |cffffcc00" .. N2S(GetAoE(level, true), 0) .. " AoE|r."
        end

        function HolyLink:onCast()
            local this = array[Spell.source.unit]

            if this then
                if Spell.target.unit == this.target then
                    if LightInfusion then
                        if this.infused then
                            ResetUnitAbilityCooldown(this.unit, Spell.id)
                        else
                            this.infused = LightInfusion.charges[this.unit] > 0
                            this.distance = GetAoE(Spell.level, this.infused)
                            this.bonus = GetMovementBonus(Spell.level, this.infused)

                            if this.infused then
                                reduce[Spell.target.unit] =(reduce[Spell.target.unit] or 0)+ 1 
                                this.self = AddSpecialEffectTarget(MODEL, this.unit, ATTACH_POINT)

                                AddUnitBonus(this.unit, BONUS_MOVEMENT_SPEED, this.bonus)
                                AddUnitBonus(this.target, BONUS_MOVEMENT_SPEED, this.bonus)
                            end

                            LightInfusion.consume(Spell.source.unit)
                        end
                    else
                        ResetUnitAbilityCooldown(this.unit, Spell.id)
                    end
                else
                    DestroyLightning(this.lightning)
                    DestroyEffect(this.effect)

                    if LightInfusion then
                        if this.infused then
                            reduce[this.target] = (reduce[this.target] or 0) - 1

                            DestroyEffect(this.self)
                            AddUnitBonus(this.unit, BONUS_MOVEMENT_SPEED, -this.bonus)
                            AddUnitBonus(this.target, BONUS_MOVEMENT_SPEED, -this.bonus)
                        end

                        this.count = 0
                        this.unit = Spell.source.unit
                        this.target = Spell.target.unit
                        this.infused = (LightInfusion.charges[this.unit] or 0) > 0
                        this.distance = GetAoE(Spell.level, this.infused)
                        this.bonus = GetMovementBonus(Spell.level, this.infused)
                        this.effect = AddSpecialEffectTarget(MODEL, this.target, ATTACH_POINT)
                        this.lightning = AddLightningEx(LIGHTNING, false, Spell.source.x, Spell.source.y, Spell.source.z + 30, Spell.target.x, Spell.target.y, Spell.target.z + 30)

                        if this.infused then
                            reduce[Spell.target.unit] = (reduce[Spell.target.unit] or 0) + 1 
                            this.self = AddSpecialEffectTarget(MODEL, this.unit, ATTACH_POINT)

                            AddUnitBonus(this.unit, BONUS_MOVEMENT_SPEED, this.bonus)
                            AddUnitBonus(this.target, BONUS_MOVEMENT_SPEED, this.bonus)
                        end

                        LightInfusion.consume(this.unit)
                    else
                        this.count = 0
                        this.infused = false
                        this.unit = Spell.source.unit
                        this.target = Spell.target.unit
                        this.distance = GetAoE(Spell.level, this.infused)
                        this.bonus = GetMovementBonus(Spell.level, this.infused)
                        this.effect = AddSpecialEffectTarget(MODEL, this.target, ATTACH_POINT)
                        this.lightning = AddLightningEx(LIGHTNING, false, Spell.source.x, Spell.source.y, Spell.source.z + 30, Spell.target.x, Spell.target.y, Spell.target.z + 30)
                    end
                end
            else
                if LightInfusion then
                    HolyLink.link(Spell.source.unit, Spell.target.unit, Spell.level, (LightInfusion.charges[Spell.source.unit] or 0) > 0)
                    LightInfusion.consume(Spell.source.unit)
                else
                    HolyLink.link(Spell.source.unit, Spell.target.unit, Spell.level, false)
                end
            end
        end

        function HolyLink.onDamage()
            if LightInfusion then
                if Damage.amount > 0 and (reduce[Damage.target.unit] or 0) > 0 then
                    Damage.amount = Damage.amount * 0.75
                end
            end
        end

        function HolyLink.onInit()
            RegisterSpell(HolyLink.allocate(), ABILITY)

            if LightInfusion then
                RegisterAnyDamageEvent(HolyLink.onDamage)
            end
        end
    end
end)