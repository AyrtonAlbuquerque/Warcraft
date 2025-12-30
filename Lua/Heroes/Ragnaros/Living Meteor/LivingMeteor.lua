OnInit("LivingMeteor", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires "MouseUtils"
    requires.optional "Bonus"
    requires.optional "Afterburner"

    -- ---------------------------- Living Meteor v1.7 by Chopinski ---------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Living Meteor ability
    local ABILITY             = S2A('Rgn2')
    -- The landing time of the falling meteor
    local LANDING_TIME        = 0.75
    -- The roll time of the rolling meteor
    local ROLLING_TIME        = 2.0
    -- The damage interval of the rolling interval
    local DAMAGE_INTERVAL     = 0.1
    -- The time the player has to move the mouse before the spell starts
    local DRAG_AND_DROP_TIME  = 0.05
    -- The distance from the casting point from where the meteor spawns
    local LAUNCH_OFFSET       = 3000
    -- The starting height fo the meteor
    local START_HEIGHT        = 2000
    -- Meteor Model
    local METEOR_MODEL        = "LivingMeteor.mdl"
    -- Meteor Impact effect model
    local IMPACT_MODEL        = "LivingMeteor.mdl"
    -- Meteor size
    local METEOR_SCALE        = 0.75
    -- The Attack type of the damage dealt (Spell)
    local ATTACK_TYPE         = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt
    local DAMAGE_TYPE         = DAMAGE_TYPE_MAGIC
    -- If true will damage structures
    local DAMAGE_STRUCTURES   = true
    -- If true will damage allies
    local DAMAGE_ALLIES       = false
    -- If true will damage magic immune unit if the
    -- ATTACK_TYPE is not spell damage
    local DAMAGE_MAGIC_IMMUNE = false

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

        function LivingMeteor:destroy()
            self.unit = nil
            self.player = nil
        end

        function LivingMeteor:onTooltip(source, level, ability)
            return "Ragnaros summon a meteor at the target area that deals |cff00ffff" .. N2S(LandingDamage(source, level), 0) .. " Magic|r damage on impact, then rolls in that target direction dealing |cff00ffff" .. N2S(RollDamage(source, level), 0) .. " Magic|r every |cffffcc00" .. N2S(DAMAGE_INTERVAL, 2) .. "|r seconds to enemy units within |cffffcc00250 AoE|r until it reaches it's maximum range of |cffffcc00700 AoE|r from the initial impact point."
        end

        function LivingMeteor:onCast()
            local this = { destroy = LivingMeteor.destroy }

            this.x = Spell.x
            this.y = Spell.y
            this.level = Spell.level
            this.unit = Spell.source.unit
            this.player = Spell.source.player

            TimerStart(CreateTimer(), DRAG_AND_DROP_TIME, false, function ()
                local angle = AngleBetweenCoordinates(this.x, this.y, GetPlayerMouseX(this.player), GetPlayerMouseY(this.player))
                local meteor = Meteor.create(this.x + LAUNCH_OFFSET*math.cos(angle + bj_PI), this.y + LAUNCH_OFFSET*math.sin(angle + bj_PI), START_HEIGHT, this.x, this.y, 0)
                
                meteor.source = this.unit
                meteor.owner = this.player
                meteor.model = METEOR_MODEL
                meteor.scale = METEOR_SCALE
                meteor.duration = LANDING_TIME
                meteor.angle = angle
                meteor.level = this.level
                meteor.rolling = false
                meteor.aoe = GetRollAoE(this.unit, this.level)
                meteor.damage = LandingDamage(this.unit, this.level)
                meteor.distance = RollDistance(this.level)

                meteor:launch()
                this:destroy()
                DestroyTimer(GetExpiredTimer())
            end)
        end

        function LivingMeteor.onInit()
            RegisterSpell(LivingMeteor.allocate(), ABILITY)
        end
    end
end)