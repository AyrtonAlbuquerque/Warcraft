OnInit("FireStrike", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires.optional "Bonus"

    -- ----------------------------- Fire Strike v1.0 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Fire Strike ability
    local ABILITY        = S2A('Tyc5')
    -- The raw code of the Incinerate ability
    local FLAMES         = S2A('TycA')
    -- The starting height of the missile
    local START_HEIGHT   = 1500
    -- The starting offset of the missile
    local START_OFFSET   = 3000
    -- The Missile model
    local MODEL          = "Interceptor Shell.mdl"
    -- The Missile scale
    local SCALE          = 0.8
    -- The Missile speed
    local SPEED          = 1500.

    -- The amount of damage dealt when the missile lands
    local function GetDamage(source, level)
        if Bonus then
            return 300 * level + (0.5 + 0.25*level) * GetUnitBonus(source, BONUS_DAMAGE) + (0.2 + 0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 300. * level
        end
    end

    -- The amount of damage Fire deals per second
    local function GetFireDamage(source, level)
        if Bonus then
            return 50. * level + (0.15*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 50. * level
        end
    end

    -- The max range that a missile can spawn
    -- By default it is the ability Area of Effect Field value
    local function GetAoE(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The impact aoe
    local function GetDamageAoE(source, level)
        return 200. + 0.*level
    end

    -- The amount of missiles spawned
    local function GetCount(source, level)
        return 60 + 20*level
    end

    -- The missile spawn interval
    local function GetInterval(source, level)
        return 0.1 - 0.*level
    end

    -- The Fire damage interval
    local function GetFireInterval(level)
        return 1. + 0.*level
    end

    -- The fire duration
    local function GetDuration(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The damage filter
    local function DamageFilter(owner, target)
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Incineration = Class()

        local proxy = {}

        function Incineration:destroy()
            DestroyTimer(self.timer)
            UnitRemoveAbility(self.dummy, FLAMES)
            DummyRecycle(self.dummy)

            proxy[self.dummy] = nil

            self.unit = nil
            self.timer = nil
            self.dummy = nil
        end

        function Incineration.create(x, y, damage, duration, aoe, interval, source)
            local self = Incineration.allocate()

            self.unit = source
            self.damage = damage
            self.timer = CreateTimer()
            self.dummy = DummyRetrieve(GetOwningPlayer(source), x, y, 0, 0)
            proxy[self.dummy] = self

            UnitAddAbility(self.dummy, FLAMES)
            local spell = BlzGetUnitAbility(self.dummy, FLAMES)
            BlzSetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            BlzSetAbilityRealLevelField(spell, ABILITY_RLF_FULL_DAMAGE_INTERVAL, 0, duration)
            BlzSetAbilityRealLevelField(spell, ABILITY_RLF_HALF_DAMAGE_INTERVAL, 0, interval)
            BlzSetAbilityRealLevelField(spell, ABILITY_RLF_AREA_OF_EFFECT, 0, aoe)
            BlzSetAbilityRealLevelField(spell, ABILITY_RLF_HALF_DAMAGE_DEALT, 0, damage)
            IncUnitAbilityLevel(self.dummy, FLAMES)
            DecUnitAbilityLevel(self.dummy, FLAMES)
            IssuePointOrder(self.dummy, "flamestrike", x, y)
            TimerStart(self.timer, duration + 0.05, false, function ()
                self:destroy()
            end)

            return self
        end

        function Incineration.onDamage()
            local self = proxy[Damage.source.unit]

            if self and Damage.amount > 0 then
                Damage.source = self.unit
            end
        end

        function Incineration.onInit()
            RegisterSpellDamageEvent(Incineration.onDamage)
        end
    end

    local Rocket = Class(Missile)

    do
        function Rocket:onFinish()
            local group = CreateGroup()

            GroupEnumUnitsInRange(group, self.x, self.y, self.collision, nil)
            Incineration.create(self.x, self.y, self.burn, self.time, self.collision, self.interval, self.source)

            local u = FirstOfGroup(group)

            while u do
                if DamageFilter(self.owner, u) then
                    UnitDamageTarget(self.source, u, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                end

                GroupRemoveUnit(group, u)
                u = FirstOfGroup(group)
            end

            DestroyGroup(group)

            return true
        end
    end

    do
        FireStrike = Class(Spell)

        function FireStrike:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)

            self.unit = nil
            self.timer = nil
        end

        function FireStrike:onTooltip(source, level, ability)
            return "|cffffcc00Tychus|r calls for a |cffffcc00Fire Strike|r in the targeted location. Each missile deals |cff00ffff" .. N2S(GetDamage(source, level), 0) .. " Magic|r damage to all enemy units within |cffffcc00" .. N2S(GetDamageAoE(source, level), 0) .. " AoE|r of its impact location and leaves a trail of fire that burns enemy units for |cff00ffff" .. N2S(GetFireDamage(source, level), 0) .. " Magic|r damage per second for |cffffcc00" .. N2S(GetDuration(source, level), 1) .. "|r seconds."
        end

        function FireStrike:onCast()
            local this = { destroy = FireStrike.destroy }

            this.x = Spell.x
            this.y = Spell.y
            this.level = Spell.level
            this.unit = Spell.source.unit
            this.timer = CreateTimer()
            this.angle = AngleBetweenCoordinates(Spell.x, Spell.y, Spell.source.x, Spell.source.y)
            this.range = GetAoE(Spell.source.unit, Spell.level)
            this.count = GetCount(Spell.source.unit, Spell.level)
            this.burn = GetFireDamage(Spell.source.unit, Spell.level)
            this.time = GetDuration(Spell.source.unit, Spell.level)
            this.interval = GetFireInterval(Spell.level)

            TimerStart(this.timer, GetInterval(Spell.source.unit, Spell.level), true, function ()
                this.count = this.count - 1

                if this.count > 0 then
                    local theta = 2*bj_PI*GetRandomReal(0, 1)
                    local radius = GetRandomRange(this.range)
                    local x = this.x + radius*math.cos(theta)
                    local y = this.y + radius*math.sin(theta)
                    local rocket = Rocket.create(x + START_OFFSET*math.cos(this.angle), y + START_OFFSET*math.sin(this.angle), START_HEIGHT, x, y, 0)

                    rocket.source = this.unit
                    rocket.level = this.level
                    rocket.model = MODEL
                    rocket.scale = SCALE
                    rocket.speed = SPEED
                    rocket.burn = this.burn
                    rocket.time = this.time
                    rocket.interval = this.interval
                    rocket.arc = GetRandomReal(-45, 45) * bj_DEGTORAD
                    rocket.curve = GetRandomReal(-30, 30) * bj_DEGTORAD
                    rocket.owner = GetOwningPlayer(this.unit)
                    rocket.damage = GetDamage(this.unit, this.level)
                    rocket.collision = GetDamageAoE(this.unit, this.level)

                    rocket:launch()
                else
                    this:destroy()
                end
            end)
        end

        function FireStrike.onInit()
            RegisterSpell(FireStrike.allocate(), ABILITY)
        end
    end
end)