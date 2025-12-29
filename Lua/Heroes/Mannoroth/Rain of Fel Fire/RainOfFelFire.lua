OnInit("RainOfFelFire", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires.optional "Bonus"

    -- --------------------------- Rain of Fel Fire v1.6 by Chopinski -------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- the raw code of the Rain of Fel Fire ability
    local ABILITY             = S2A('Mnr1')
    -- the starting height of the missile
    local START_HEIGHT        = 2000
    -- The landing time of the falling misisle
    local LANDING_TIME        = 1.5
    -- The impact radius of the missile that will damage units.
    local IMPACT_RADIUS       = 120.
    -- the missile model
    local MISSILE_MODEL       = "FelRain.mdx"
    -- the dot model
    local DOT_MODEL           = "BurnLarge.mdx"
    -- the dot attachment point
    local DOT_ATTACH          = "origin"
    -- The Attack type of the damage dealt on imapact (Spell)
    local IMPACT_ATTACK_TYPE  = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt on impact
    local IMPACT_DAMAGE_TYPE  = DAMAGE_TYPE_MAGIC
    -- The Attack type of the damage over time
    local DOT_ATTACK_TYPE     = ATTACK_TYPE_HERO
    -- The Damage type of the damage over time
    local DOT_DAMAGE_TYPE     = DAMAGE_TYPE_UNIVERSAL

    -- How long the spell will last
    local function GetDuration(level)
        return 10. + 0.*level
    end

    -- The interval at which the rain of fire meteors spwan
    local function GetInterval(level)
        return 0.2 - 0.025 * level
    end

    -- The max range that a rain of fel fire missile can spawn
    -- By default it is the ability Area of Effect Field value
    local function GetRange(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end
    
    -- The amount of damage dealt when the missile lands
    local function GetImpactDamage(source, level)
        if Bonus then
            return 25. * level + (0.8 + 0.05*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 25. * level
        end
    end

    -- The amount of damage over time dealt to units in range of the impact area
    local function GetDoTDamage(source, level)
        if Bonus then
            return 5. * level + (0.05 + 0.05*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 5. * level
        end
    end

    -- How long the dot will last
    local function GetDoTDuration(level)
        return 4. + 0.*level
    end

    -- The interval at which the dot effect will do damage
    local function GetDoTInterval(level)
        return 1. + 0.*level
    end

    -- Filter for the units that will be damaged on impact and get DoT
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    local DoT = Class()

    do
        local array = {}

        function DoT:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyEffect(self.effect)

            array[self.target] = nil

            self.timer = nil
            self.source = nil
            self.target = nil
            self.effect = nil
        end

        function DoT.create(source, target, damage, level)
            local self = array[target]

            if not self then
                self = DoT.allocate()

                self.level = level
                self.source = source
                self.target = target
                self.damage = damage
                self.timer = CreateTimer()
                self.effect = AddSpecialEffectTarget(DOT_MODEL, target, DOT_ATTACH)

                array[target] = self

                TimerStart(self.timer, GetDoTInterval(level), true, function ()
                    self.duration = self.duration - GetDoTInterval(self.level)

                    if self.duration > 0 then
                        if UnitAlive(self.target) then
                            UnitDamageTarget(self.source, self.target, self.damage, true, false, DOT_ATTACK_TYPE, DOT_DAMAGE_TYPE, nil)
                        else
                            self:destroy()
                        end
                    else
                        self:destroy()
                    end
                end)
            end

            self.duration = GetDoTDuration(level)

            return self
        end
    end

    do
        Meteor = Class(Missile)

        function Meteor:onFinish()
            local group = CreateGroup()

            GroupEnumUnitsInRange(group, self.x, self.y, IMPACT_RADIUS, nil)

            local u = FirstOfGroup(group)

            while u do
                if DamageFilter(self.owner, u) then
                    if UnitDamageTarget(self.source, u, self.damage, false, false, IMPACT_ATTACK_TYPE, IMPACT_DAMAGE_TYPE, nil) then
                        DoT.create(self.source, u, GetDoTDamage(self.source, self.level), self.level)
                    end
                end

                GroupRemoveUnit(group, u)
                u = FirstOfGroup(group)
            end

            DestroyGroup(group)

            return true
        end
    end

    do
        FelFire = Class(Spell)

        function FelFire:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)

            self.unit = nil
            self.timer = nil
        end

        function FelFire:onTooltip(source, level, ability)
            return "|cffffcc00Mannoroth|r calls fire down from the skies every |cffffcc00" .. N2S(GetInterval(level), 3) .. "|r seconds, dealing |cff00ffff" .. N2S(GetImpactDamage(source, level), 0) .. "|r |cff00ffffMagic|r damage on impact and |cffd45e19" .. N2S(GetDoTDamage(source, level), 0) .. " Pure|r damage per second for |cffffcc00" .. N2S(GetDoTDuration(level), 1) .. "|r seconds.\n\nLasts |cffffcc00" .. N2S(GetDuration(level), 1) .. "|r seconds."
        end

        function FelFire:onCast()
            local this = FelFire.allocate()

            this.x = Spell.x
            this.y = Spell.y
            this.level = Spell.level
            this.unit = Spell.source.unit
            this.timer = CreateTimer()
            this.duration = GetDuration(Spell.level)

            TimerStart(this.timer, GetInterval(Spell.level), true, function ()
                this.duration = this.duration - GetInterval(this.level)

                if this.duration > 0 then
                    local theta = 2*bj_PI*GetRandomReal(0, 1)
                    local radius = GetRandomRange(GetRange(this.unit, this.level))
                    local x = this.x + radius*math.cos(theta)
                    local y = this.y + radius*math.sin(theta)  
                    local meteor = Meteor.create(x, y, START_HEIGHT, x, y, 20)

                    meteor.source = this.unit
                    meteor.level = this.level
                    meteor.model = MISSILE_MODEL
                    meteor.duration = LANDING_TIME
                    meteor.owner = GetOwningPlayer(this.unit)
                    meteor.damage = GetImpactDamage(this.unit, this.level)

                    meteor:launch()
                else
                    this:destroy()
                end
            end)
        end

        function FelFire.onInit()
            RegisterSpell(FelFire.allocate(), ABILITY)
        end
    end
end)