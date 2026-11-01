OnInit("OdinIncinerate", function (requires)
    requires "Class"
    requires "Spell"
    requires "Damage"
    requires "Missiles"
    requires "Utilities"
    requires "MouseUtils"
    requires "RegisterPlayerUnitEvent"
    requires.optional "Bonus"

    -- --------------------------- Odin Annihilate v1.4 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Odin Incinerate ability
    OdinIncinerate_ABILITY     = S2A('Tyc9')
    -- The raw code of the Incinerate ability
    local FLAMES               = S2A('Flam')
    -- The Missile model
    local MODEL                = "Interceptor Shell.mdl"
    -- The Missile scale
    local SCALE                = 0.6
    -- The Missile speed
    local SPEED                = 1000.
    -- The Missile arc
    local ARC                  = 45.
    -- The Missile height offset
    local HEIGHT               = 200.
    -- The time the player has to move the mouse before the spell starts
    local DRAG_AND_DROP_TIME   = 3.
    -- Skill indicator model
    local INDICATOR_MODEL      = "Skill_Indicator_Move.mdl"
    -- Indicator scaling
    local INDICATOR_SCALE      = 2.5
    -- Indicator time scaling
    local INDICATOR_TIME_SCALE = 1.5

    -- The distance between rocket explosions that create the flames. Recommended about 50% of the size of the flame strike aoe.
    local function GetOffset(level)
        return 100. + 0*level
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

    -- The number of rockets.
    local function GetRocketCount(level)
        return 3 + 2*level
    end

    -- The interval at which rockets are spawned.
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
            local group = CreateGroup()

            Incineration.create(self.x, self.y, self.iDamage, self.iDuration, self.iAoE, self.iInterval, self.source)
            DestroyEffect(AddSpecialEffect(MODEL, self.x, self.y))
            GroupEnumUnitsInRange(group, self.x, self.y, self.aoe, nil)

            local u = FirstOfGroup(group)

            while u do
                if DamageFilter(self.owner, u) then
                    UnitDamageTarget(self.source, u, self.damage, true, true, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                end

                GroupRemoveUnit(group, u)
                u = FirstOfGroup(group)
            end

            DestroyGroup(group)

            return true
        end
    end

    do
        OdinIncinerate = Class(Spell)

        local link = {}
        local struct = {}

        function OdinIncinerate:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)

            if self.casting then
                DestroyEffectTimed(self.effect, 2)
            else
                DestroyEffect(self.effect)
            end

            link[self.timer] = nil

            if struct[self.unit] == self then
                struct[self.unit] = nil
            end

            self.unit = nil
            self.timer = nil
            self.effect = nil
            self.player = nil
        end

        function OdinIncinerate:onTooltip(source, level, ability)
            return "|cffffcc00Odin|r fires |cffffcc00" .. N2S(GetRocketCount(level), 0) .. "|r incendiary rockets towards the desired direction. The rockets explode dealing |cff00ffff" .. N2S(GetDamage(source, level), 0) .. "|r damage within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. "|r AoE and leaves a trail of fire that deals |cff00ffff" .. N2S(GetIncinerationDamage(source, level), 1) .. "|r damage per second to any enemy unit standing in it. Lasts for |cffffcc00" .. N2S(GetIncinerationDuration(level), 1) .. "|r seconds.\n\n|cffffcc00Drag and Drop|r to choose direction."
        end

        function OdinIncinerate.onPeriod()
            local self = link[GetExpiredTimer()]
            local down = IsPlayerMouseButtonDown(self.player, MOUSE_BUTTON_TYPE_LEFT)

            if down and not self.firing and (self.casting or not self.done) then
                self.angle = AngleBetweenCoordinates(self.x, self.y, GetPlayerMouseX(self.player), GetPlayerMouseY(self.player))
            end

            if not self.casting then
                if not UnitAlive(self.unit) then
                    self:destroy()
                    return
                end

                if down and not self.done then
                    BlzSetSpecialEffectYaw(self.effect, self.angle)
                elseif not down then
                    self.done = true
                end

                return
            end

            self.timeout = self.timeout - 0.03
            self.delay = self.delay - 0.03

            if (not down or self.timeout <= 0) and self.delay <= 0 then
                local rocket = Rocket.create(GetUnitX(self.unit), GetUnitY(self.unit), HEIGHT, self.x + self.offset*self.i*math.cos(self.angle), self.y + self.offset*self.i*math.sin(self.angle), 50)

                self.firing = true
                self.delay = self.interval
                self.i = self.i + 1

                rocket.model = MODEL
                rocket.scale = SCALE
                rocket.speed = SPEED
                rocket.arc = ARC * bj_DEGTORAD
                rocket.aoe = self.aoe
                rocket.source = self.unit
                rocket.owner = self.player
                rocket.damage = self.damage
                rocket.iAoE = self.iAoE
                rocket.iDamage = self.iDamage
                rocket.iInterval = self.iInterval
                rocket.iDuration = self.iDuration

                rocket:launch()
            end

            if not self.firing then
                BlzSetSpecialEffectYaw(self.effect, self.angle)
            end

            if self.i >= self.count then
                self:destroy()
            end
        end

        function OdinIncinerate:onCast()
            if struct[Spell.source.unit] then
                local this = struct[Spell.source.unit]

                if this.x ~= Spell.x or this.y ~= Spell.y then
                    BlzSetSpecialEffectX(this.effect, Spell.x)
                    BlzSetSpecialEffectY(this.effect, Spell.y)
                    BlzSetSpecialEffectYaw(this.effect, AngleBetweenCoordinates(Spell.x, Spell.y, GetPlayerMouseX(this.player), GetPlayerMouseY(this.player)))
                end

                this.x = Spell.x
                this.y = Spell.y
                this.i = 0
                this.delay = 0
                this.firing = false
                this.casting = true
                this.level = Spell.level
                this.timeout = DRAG_AND_DROP_TIME
                this.interval = GetInterval(Spell.level)
                this.count = GetRocketCount(Spell.level)
                this.offset = GetOffset(Spell.level)
                this.damage = GetDamage(Spell.source.unit, Spell.level)
                this.aoe = GetAoE(Spell.source.unit, Spell.level)
                this.iAoE = GetIncinerationAoE(Spell.source.unit, Spell.level)
                this.iDamage = GetIncinerationDamage(Spell.source.unit, Spell.level)
                this.iInterval = GetIncinerationInterval(Spell.level)
                this.iDuration = GetIncinerationDuration(Spell.level)
            else
                local this = {
                    x = Spell.x,
                    y = Spell.y,
                    i = 0,
                    delay = 0,
                    firing = false,
                    casting = true,
                    level = Spell.level,
                    unit = Spell.source.unit,
                    timer = CreateTimer(),
                    timeout = DRAG_AND_DROP_TIME,
                    player = GetOwningPlayer(Spell.source.unit),
                    effect = AddSpecialEffectEx(INDICATOR_MODEL, Spell.x, Spell.y, 0, INDICATOR_SCALE),
                    angle = AngleBetweenCoordinates(Spell.x, Spell.y, GetPlayerMouseX(Spell.source.player), GetPlayerMouseY(Spell.source.player)),
                    interval = GetInterval(Spell.level),
                    count = GetRocketCount(Spell.level),
                    offset = GetOffset(Spell.level),
                    damage = GetDamage(Spell.source.unit, Spell.level),
                    aoe = GetAoE(Spell.source.unit, Spell.level),
                    iAoE = GetIncinerationAoE(Spell.source.unit, Spell.level),
                    iDamage = GetIncinerationDamage(Spell.source.unit, Spell.level),
                    iInterval = GetIncinerationInterval(Spell.level),
                    iDuration = GetIncinerationDuration(Spell.level),
                    destroy = OdinIncinerate.destroy
                }

                link[this.timer] = this

                BlzSetSpecialEffectYaw(this.effect, this.angle)
                BlzSetSpecialEffectTimeScale(this.effect, INDICATOR_TIME_SCALE)
                TimerStart(this.timer, 0.03, true, OdinIncinerate.onPeriod)
            end
        end

        function OdinIncinerate.onOrder()
            local source = GetOrderedUnit()
            local level = GetUnitAbilityLevel(source, OdinIncinerate_ABILITY)
            local self = struct[source]
            local range
            local base
            local order
            local skill
            local distance

            if level > 0 then
                skill = BlzGetUnitAbility(source, OdinIncinerate_ABILITY)
                order = OrderId2String(GetIssuedOrderId())
                base = BlzGetAbilityStringLevelField(skill, ABILITY_SLF_BASE_ORDER_ID_NCL6, level - 1)
                range = BlzGetAbilityRealLevelField(skill, ABILITY_RLF_CAST_RANGE, level - 1)
                distance = DistanceBetweenCoordinates(GetOrderPointX(), GetOrderPointY(), GetUnitX(source), GetUnitY(source))

                if order ~= base and self then
                    if not self.casting then
                        self:destroy()
                    end
                elseif BlzGetUnitAbilityCooldownRemaining(source, OdinIncinerate_ABILITY) == 0 and order == base and distance > range then
                    if self then
                        self:destroy()
                    end

                    self = {
                        done = false,
                        x = GetOrderPointX(),
                        y = GetOrderPointY(),
                        i = 0,
                        delay = 0,
                        firing = false,
                        casting = false,
                        level = level,
                        unit = source,
                        timer = CreateTimer(),
                        player = GetOwningPlayer(source),
                        effect = AddSpecialEffectEx(INDICATOR_MODEL, GetOrderPointX(), GetOrderPointY(), 0, INDICATOR_SCALE),
                        angle = AngleBetweenCoordinates(GetOrderPointX(), GetOrderPointY(), GetPlayerMouseX(GetOwningPlayer(source)), GetPlayerMouseY(GetOwningPlayer(source))),
                        destroy = OdinIncinerate.destroy
                    }

                    link[self.timer] = self
                    struct[source] = self

                    BlzSetSpecialEffectTimeScale(self.effect, INDICATOR_TIME_SCALE)
                    BlzSetSpecialEffectYaw(self.effect, self.angle)
                    TimerStart(self.timer, 0.03, true, OdinIncinerate.onPeriod)
                end
            end
        end

        function OdinIncinerate.onInit()
            RegisterSpell(OdinIncinerate.allocate(), OdinIncinerate_ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, OdinIncinerate.onOrder)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, OdinIncinerate.onOrder)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, OdinIncinerate.onOrder)
        end
    end
end)