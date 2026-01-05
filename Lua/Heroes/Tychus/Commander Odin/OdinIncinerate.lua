OnInit("OdinIncinerate", function (requires)
    requires "Class"
    requires "Spell"
    requires "Damage"
    requires "Missiles"
    requires "Utilities"
    requires "MouseUtils"
    requires.optional "Bonus"

    -- --------------------------- Odin Annihilate v1.4 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Odin Incinerate ability
    OdinIncinerate_ABILITY = S2A('Tyc9')
    -- The raw code of the Incinerate ability
    local FLAMES  = S2A('TycA')
    -- The Missile model
    local MODEL   = "Interceptor Shell.mdl"
    -- The Missile scale
    local SCALE   = 0.6
    -- The Missile speed
    local SPEED   = 1000.
    -- The Missile arc
    local ARC     = 45.
    -- The Missile height offset
    local HEIGHT  = 200.
    -- The time the player has to move the mouse before the spell starts
    local DRAG_AND_DROP_TIME  = 0.05

    -- The distance between rocket explosions that create the flames. Recommended about 50% of the size of the flame strike aoe.
    local function GetOffset(level)
        return 100. +0*level
    end

    -- The explosion damage
    local function GetDamage(source, level)
        if Bonus then
            return 50. * level + 0.8 * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 50. * level
        end
    end

    -- The explosion aoe
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, OdinIncinerate_ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The incineration damage per interval
    local function GetIncinerationDamage(source, level)
        if Bonus then
            return 12.5 * level + 0.2 * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 12.5 * level
        end
    end

    -- The incineration AoE
    local function GetIncinerationAoE(unit, level)
        return GetAoE(unit, level)
    end

    -- The incineration damage interval
    local function GetIncinerationInterval(level)
        return 1. + 0.*level
    end

    -- The the incineration duration
    local function GetIncinerationDuration(level)
        return 5. + 0.*level
    end

    -- The numebr of rockets.
    local function GetRocketCount(level)
        return 3 + 2*level
    end

    -- The interval at which rockets are spawnned.
    local function GetInterval(level)
        return 0.2 + 0.*level
    end

    -- The Damage Filter.
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    local Incineration = Class()
    
    do
        local proxy = {}

        function Incineration:destroy()
            UnitRemoveAbility(self.dummy, FLAMES)
            DummyRecycle(self.dummy)

            proxy[self.dummy] = nil

            self.unit = nil
            self.dummy = nil
        end

        function Incineration.create(x, y, damage, duration, aoe, interval, source)
            local self = Incineration.allocate()

            self.unit = source
            self.damage = damage
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
            TimerStart(CreateTimer(), duration + 0.05, false, function ()
                self:destroy()
                DestroyTimer(GetExpiredTimer())
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
            Incineration.create(self.x, self.y, self.iDamage, self.iDuration, self.iAoE, self.iInterval, self.source)
            DestroyEffect(AddSpecialEffect(MODEL, self.x, self.y))
            GroupEnumUnitsInRange(self.group, self.x, self.y, self.iAoE, nil)

            local u = FirstOfGroup(self.group)

            while u do
                if DamageFilter(self.owner, u) then
                    UnitDamageTarget(self.source, u, self.damage, true, true, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                end

                GroupRemoveUnit(self.group, u)
                u = FirstOfGroup(self.group)
            end

            DestroyGroup(self.group)

            return true
        end
    end

    do
        OdinIncinerate = Class(Spell)

        function OdinIncinerate:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)

            self.unit = nil
            self.timer = nil
            self.player = nil
        end

        function OdinIncinerate:onTooltipl(source, level, ability)
            return "|cffffcc00Odin|r fires |cffffcc00" .. N2S(GetRocketCount(level), 0) .. "|r incendiary rockets towards the desired direction. The rockets explode dealing |cff00ffff" .. N2S(GetDamage(source, level), 0) .. "|r damage within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. "|r AoE and leaves a trail of fire that deals |cff00ffff" .. N2S(GetIncinerationDamage(source, level), 1) .. "|r damage per second to any enemy unit standing in it. Lasts for |cffffcc00" .. N2S(GetIncinerationDuration(level), 1) .. "|r seconds."
        end

        function OdinIncinerate:onCast()
            local this = { destroy = OdinIncinerate.destroy }

            this.i = 0
            this.x = Spell.x
            this.y = Spell.y
            this.level = Spell.level
            this.unit = Spell.source.unit
            this.player = Spell.source.player
            this.timer = CreateTimer()
            this.count = GetRocketCount(Spell.level)
            this.offset = GetOffset(Spell.level)
            this.damage = GetDamage(Spell.source.unit, Spell.level)
            this.aoe = GetAoE(Spell.source.unit, Spell.level)
            this.iAoE = GetIncinerationAoE(Spell.source.unit, Spell.level)
            this.iDamage = GetIncinerationDamage(Spell.source.unit, Spell.level)
            this.iInterval = GetIncinerationInterval(Spell.level)
            this.iDuration = GetIncinerationDuration(Spell.level)

            TimerStart(this.timer, DRAG_AND_DROP_TIME, false, function ()
                this.angle = AngleBetweenCoordinates(this.x, this.y, GetPlayerMouseX(this.player), GetPlayerMouseY(this.player))
            
                TimerStart(this.timer, GetInterval(this.level), true, function ()
                    this.i = this.i + 1

                    if this.i >= this.count then
                        local rocket = Rocket.create(GetUnitX(this.unit), GetUnitY(this.unit), HEIGHT, this.x + this.offset*this.i*math.cos(this.angle), this.y + this.offset*this.i*math.sin(this.angle), 50)

                        rocket.model = MODEL
                        rocket.scale = SCALE
                        rocket.speed = SPEED
                        rocket.arc = ARC * bj_DEGTORAD
                        rocket.aoe = this.aoe
                        rocket.source = this.unit
                        rocket.owner = this.player
                        rocket.damage = this.damage
                        rocket.iAoE = this.iAoE
                        rocket.iDamage = this.iDamage
                        rocket.iInterval = this.iInterval
                        rocket.iDuration = this.iDuration
                        rocket.group = CreateGroup()

                        rocket:launch()
                    else
                        this:destroy()
                    end
                end)
            end)
        end

        function OdinIncinerate.onInit()
            RegisterSpell(OdinIncinerate.allocate(), OdinIncinerate_ABILITY)
        end
    end
end)