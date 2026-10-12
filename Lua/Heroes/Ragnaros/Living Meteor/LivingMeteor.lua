OnInit("LivingMeteor", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires "MouseUtils"
    requires "RegisterPlayerUnitEvent"
    requires.optional "Bonus"
    requires.optional "Afterburner"

    -- ---------------------------- Living Meteor v1.7 by Chopinski ---------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Living Meteor ability
    local ABILITY              = S2A('Rgn2')
    -- The landing time of the falling meteor
    local LANDING_TIME         = 0.75
    -- The roll time of the rolling meteor
    local ROLLING_TIME         = 2.0
    -- The damage interval of the rolling interval
    local DAMAGE_INTERVAL      = 0.1
    -- The time the player has to move the mouse before the spell starts
    local DRAG_AND_DROP_TIME   = 3.
    -- The distance from the casting point from where the meteor spawns
    local LAUNCH_OFFSET        = 3000
    -- The starting height fo the meteor
    local START_HEIGHT         = 2000
    -- Meteor Model
    local METEOR_MODEL         = "LivingMeteor.mdl"
    -- Meteor Impact effect model
    local IMPACT_MODEL         = "LivingMeteor.mdl"
    -- Meteor size
    local METEOR_SCALE         = 0.75
    -- The Attack type of the damage dealt (Spell)
    local ATTACK_TYPE          = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt
    local DAMAGE_TYPE          = DAMAGE_TYPE_MAGIC
    -- If true will damage structures
    local DAMAGE_STRUCTURES    = true
    -- If true will damage allies
    local DAMAGE_ALLIES        = false
    -- If true will damage magic immune unit if the
    -- ATTACK_TYPE is not spell damage
    local DAMAGE_MAGIC_IMMUNE  = false
    -- Skill indicator model
    local INDICATOR_MODEL      = "Skill_Indicator_Move.mdl"
    -- Indicator scaling
    local INDICATOR_SCALE      = 1.5
    -- Indicator time scaling
    local INDICATOR_TIME_SCALE = 1.5

    -- The roll distance of the meteor
    local function RollDistance(level)
        return 600. + 100.*level
    end

    -- The landing damage distance of the meteor
    local function LandingDamage(source, level)
        if Bonus then
            return 50. + 50.*level + 1 * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 50. + 50.*level
        end
    end

    -- The roll damage distance of the meteor.
    -- will do this damage every DAMAGE_INTERVAL
    local function RollDamage(source, level)
        if Bonus then
            return 100. * level * DAMAGE_INTERVAL + (1 + 0.25*level) * GetUnitBonus(source, BONUS_SPELL_POWER) * DAMAGE_INTERVAL
        else
            return 100. * level * DAMAGE_INTERVAL
        end
    end

    -- The size of the area around the impact point where units will be damaged
    -- By default it is the Living Meteor ability field Area of Effect
    local function GetImpactAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The size of the area of the roll meteor that will damage units
    -- every DAMAGE_INTERVAL. by default it is the same as the impact AoE
    local function GetRollAoE(unit, level)
        return GetImpactAoE(unit, level)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    local Meteor = Class(Missile)
    
    do
        local ticks = R2I(DAMAGE_INTERVAL/Missile.period)

        function Meteor:onPeriod()
            if self.rolling then
                self.i = (self.i or 0) + 1
                self.j = (self.j or 0) + 1

                if self.j == 15 then
                    self.j = 0

                    if Afterburner then
                        Afterburn(self.x, self.y, self.source)
                    end
                end

                if self.i == ticks then
                    self.i = 0
                    UnitDamageArea(self.source, self.x, self.y, self.aoe, self.damage, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_STRUCTURES, DAMAGE_ALLIES, DAMAGE_MAGIC_IMMUNE)
                end
            end

            return false
        end

        function Meteor:onFinish()
            if not self.rolling then
                DestroyEffect(AddSpecialEffect(IMPACT_MODEL, self.x, self.y))
                UnitDamageArea(self.source, self.x, self.y, GetImpactAoE(self.source, self.level), self.damage, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_STRUCTURES, DAMAGE_ALLIES, DAMAGE_MAGIC_IMMUNE)
                self:deflect(self.x + self.distance*math.cos(self.angle), self.y + self.distance*math.sin(self.angle), 0)
                
                if Afterburner then
                    Afterburn(self.x, self.y, self.source)
                end

                self.rolling = true
                self.damage = RollDamage(self.source, self.level)
                self.duration = ROLLING_TIME
            end

            return false
        end
    end

    do
        LivingMeteor = Class(Spell)

        local link = {}
        local struct = {}

        function LivingMeteor:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)

            if self.casting then
                DestroyEffectTimed(self.effect, 2)
            else
                DestroyEffect(self.effect)
            end

            link[self.timer] = nil
            struct[self.unit] = nil
            self.unit = nil
            self.timer = nil
            self.effect = nil
            self.player = nil 
        end

        function LivingMeteor:onTooltip(source, level, ability)
            return "Ragnaros summon a meteor at the target area that deals |cff00ffff" .. N2S(LandingDamage(source, level), 0) .. " Magic|r damage on impact, then rolls in that target direction dealing |cff00ffff" .. N2S(RollDamage(source, level), 0) .. " Magic|r every |cffffcc00" .. N2S(DAMAGE_INTERVAL, 2) .. "|r seconds to enemy units within |cffffcc00250 AoE|r until it reaches it's maximum range of |cffffcc00700 AoE|r from the initial impact point."
        end

        function LivingMeteor.onPeriod()
            local self = link[GetExpiredTimer()]
            local down = IsPlayerMouseButtonDown(self.player, MOUSE_BUTTON_TYPE_LEFT)

            if down then
                self.angle = AngleBetweenCoordinates(self.x, self.y, GetPlayerMouseX(self.player), GetPlayerMouseY(self.player))
            end

            if not self.casting then
                if down and not self.done then
                    BlzSetSpecialEffectYaw(self.effect, self.angle)
                elseif not down then
                    self.done = true
                end

                return
            end

            self.timeout = self.timeout - 0.03

            if not down or self.timeout <= 0 then
                local meteor = Meteor.create(self.x + LAUNCH_OFFSET*math.cos(self.angle + bj_PI), self.y + LAUNCH_OFFSET*math.sin(self.angle + bj_PI), START_HEIGHT, self.x, self.y, 0)

                meteor.source = self.unit
                meteor.owner = self.player
                meteor.model = METEOR_MODEL
                meteor.scale = METEOR_SCALE
                meteor.duration = LANDING_TIME
                meteor.angle = self.angle
                meteor.level = self.level
                meteor.rolling  = false
                meteor.aoe = GetRollAoE(self.unit, self.level)
                meteor.damage = LandingDamage(self.unit, self.level)
                meteor.distance = RollDistance(self.level)

                meteor:launch()
                BlzSetSpecialEffectYaw(self.effect, self.angle)
                self:destroy()
            else
                BlzSetSpecialEffectYaw(self.effect, self.angle)
            end
        end

        function LivingMeteor:onCast()
            if struct[Spell.source.unit] then
                local this = struct[Spell.source.unit]

                if this.x ~= Spell.x or this.y ~= Spell.y then
                    BlzSetSpecialEffectX(this.effect, Spell.x)
                    BlzSetSpecialEffectY(this.effect, Spell.y)
                    BlzSetSpecialEffectYaw(this.effect, AngleBetweenCoordinates(Spell.x, Spell.y, GetPlayerMouseX(this.player), GetPlayerMouseY(this.player)))
                end

                this.x = Spell.x
                this.y = Spell.y
                this.casting = true
                this.level = Spell.level
                this.timeout = DRAG_AND_DROP_TIME
            else
                local this = { 
                    x = Spell.x,
                    y = Spell.y,
                    casting = true,
                    level = Spell.level,
                    unit = Spell.source.unit,
                    timer = CreateTimer(),
                    timeout = DRAG_AND_DROP_TIME,
                    player = GetOwningPlayer(Spell.source.unit),
                    effect = AddSpecialEffectEx(INDICATOR_MODEL, Spell.x, Spell.y, 0, INDICATOR_SCALE),
                    angle = AngleBetweenCoordinates(Spell.x, Spell.y, GetPlayerMouseX(Spell.source.player), GetPlayerMouseY(Spell.source.player)),
                    destroy = LivingMeteor.destroy
                }

                link[this.timer] = this

                BlzSetSpecialEffectYaw(this.effect, this.angle)
                BlzSetSpecialEffectTimeScale(this.effect, INDICATOR_TIME_SCALE)
                TimerStart(this.timer, 0.03, true, LivingMeteor.onPeriod)
            end
        end

        function LivingMeteor.onOrder()
            local source = GetOrderedUnit()
            local level = GetUnitAbilityLevel(source, ABILITY)
            local self = struct[source]
            local range
            local base
            local order
            local skill
            local distance
            
            if level > 0 then
                skill = BlzGetUnitAbility(source, ABILITY)
                order = OrderId2String(GetIssuedOrderId())
                base = BlzGetAbilityStringLevelField(skill, ABILITY_SLF_BASE_ORDER_ID_NCL6, level - 1)
                range = BlzGetAbilityRealLevelField(skill, ABILITY_RLF_CAST_RANGE, level - 1)
                distance = DistanceBetweenCoordinates(GetOrderPointX(), GetOrderPointY(), GetUnitX(source), GetUnitY(source))

                if order ~= base and self then
                    self:destroy()
                elseif BlzGetUnitAbilityCooldownRemaining(source, ABILITY) == 0 and order == base and distance > range then
                    if self then
                        self:destroy()
                    end

                    self = { 
                        done = false,
                        x = GetOrderPointX(),
                        y = GetOrderPointY(),
                        casting = false,
                        level = level,
                        unit = source,
                        timer = CreateTimer(),
                        player = GetOwningPlayer(source),
                        effect = AddSpecialEffectEx(INDICATOR_MODEL, GetOrderPointX(), GetOrderPointY(), 0, INDICATOR_SCALE),
                        angle = AngleBetweenCoordinates(GetOrderPointX(), GetOrderPointY(), GetPlayerMouseX(GetOwningPlayer(source)), GetPlayerMouseY(GetOwningPlayer(source))),
                        destroy = LivingMeteor.destroy
                    }

                    link[self.timer] = self
                    struct[source] = self

                    BlzSetSpecialEffectTimeScale(self.effect, INDICATOR_TIME_SCALE)
                    BlzSetSpecialEffectYaw(self.effect, self.angle)
                    TimerStart(self.timer, 0.03, true, LivingMeteor.onPeriod)
                end
            end
        end

        function LivingMeteor.onInit()
            RegisterSpell(LivingMeteor.allocate(), ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, LivingMeteor.onOrder)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, LivingMeteor.onOrder)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, LivingMeteor.onOrder)
        end
    end
end)