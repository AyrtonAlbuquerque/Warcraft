OnInit("FireStrike", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires "MouseUtils"
    requires "RegisterPlayerUnitEvent"
    requires.optional "Bonus"

    -- ----------------------------- Fire Strike v1.0 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Fire Strike ability
    local ABILITY              = S2A('Tyc5')
    -- The raw code of the Flames ability
    local FLAMES               = S2A('Flam')
    -- The starting height of the missile
    local START_HEIGHT         = 1500
    -- The starting offset of the missile
    local START_OFFSET         = 3000
    -- The Missile model
    local MODEL                = "Interceptor Shell.mdl"
    -- The Missile scale
    local SCALE                = 0.8
    -- The Missile speed
    local SPEED                = 1500.
    -- The time the player has to move the mouse before the spell starts
    local DRAG_AND_DROP_TIME   = 3.
    -- Skill indicator model
    local INDICATOR_MODEL      = "Skill_Indicator_Move.mdl"
    -- Indicator scaling
    local INDICATOR_SCALE      = 7
    -- Indicator time scaling
    local INDICATOR_TIME_SCALE = 1.5

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
            return 150. * level + (0.15*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 150. * level
        end
    end

    -- The max range that a missile can spawn
    -- By default it is the ability Area of Effect Field value
    local function GetAoE(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The amount of missiles spawned per line
    local function GetCount(source, level)
        return 5 + 0*level
    end

    -- The amount of missile lines
    local function GetLineCount(source, level)
        return 7 + 0*level
    end

    -- The missile line spawn interval
    local function GetInterval(source, level)
        return 0.2 - 0.*level
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
            BlzSetAbilityStringLevelField(spell, ABILITY_SLF_SPECIAL, 0, "")
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

        local link = {}
        local struct = {}

        function FireStrike:destroy()
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

        function FireStrike:onTooltip(source, level, ability)
            return "|cffffcc00Tychus|r calls for a |cffffcc00Fire Strike|r in the targeted direction. Each missile deals |cff00ffff" .. N2S(GetDamage(source, level), 0) .. " Magic|r damage to all enemy units within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. " AoE|r of its impact location and leaves a trail of fire that burns enemy units for |cff00ffff" .. N2S(GetFireDamage(source, level), 0) .. " Magic|r damage per second for |cffffcc00" .. N2S(GetDuration(source, level), 1) .. "|r seconds.\n\n|cffffcc00Drag and Drop|r to choose direction."
        end

        function FireStrike.onPeriod()
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
            self.lineInterval = self.lineInterval - 0.03

            if (not down or self.timeout <= 0) and self.lineInterval <= 0 then
                local x = self.x + self.index * self.range * math.cos(self.angle)
                local y = self.y + self.index * self.range * math.sin(self.angle)

                self.lineInterval = GetInterval(self.unit, self.level)
                self.index = self.index + 1
                self.lines = self.lines - 1
                self.firing = true

                for i = 0, self.count - 1 do
                    local side = (i - (self.count - 1) / 2.) * self.range
                    local tx = x + side * math.cos(self.angle + bj_PI/2)
                    local ty = y + side * math.sin(self.angle + bj_PI/2)
                    local rocket = Rocket.create(tx - START_OFFSET*math.cos(self.angle), ty - START_OFFSET*math.sin(self.angle), START_HEIGHT, tx, ty, 0)

                    rocket.source = self.unit
                    rocket.model = MODEL
                    rocket.scale = SCALE
                    rocket.speed = SPEED
                    rocket.burn = self.burn
                    rocket.time = self.time
                    rocket.interval = self.interval
                    rocket.arc = GetRandomReal(0, 30) * bj_DEGTORAD
                    rocket.owner = self.player
                    rocket.damage = GetDamage(self.unit, self.level)
                    rocket.collision = GetAoE(self.unit, self.level)

                    rocket:launch()
                end
            end

            if not self.firing then
                BlzSetSpecialEffectYaw(self.effect, self.angle)
            end

            if self.lines <= 0 then
                self:destroy()
            end
        end

        function FireStrike:onCast()
            if struct[Spell.source.unit] then
                local this = struct[Spell.source.unit]

                if this.x ~= Spell.x or this.y ~= Spell.y then
                    BlzSetSpecialEffectX(this.effect, Spell.x)
                    BlzSetSpecialEffectY(this.effect, Spell.y)
                    BlzSetSpecialEffectYaw(this.effect, AngleBetweenCoordinates(Spell.x, Spell.y, GetPlayerMouseX(this.player), GetPlayerMouseY(this.player)))
                end

                this.x = Spell.x
                this.y = Spell.y
                this.index = 0
                this.firing = false
                this.casting = true
                this.level = Spell.level
                this.timeout = DRAG_AND_DROP_TIME
                this.range = GetAoE(Spell.source.unit, Spell.level)
                this.count = GetCount(Spell.source.unit, Spell.level)
                this.lines = GetLineCount(Spell.source.unit, Spell.level)
                this.burn = GetFireDamage(Spell.source.unit, Spell.level)
                this.time = GetDuration(Spell.source.unit, Spell.level)
                this.interval = GetFireInterval(Spell.level)
                this.lineInterval = 0
            else
                local this = {
                    x = Spell.x,
                    y = Spell.y,
                    index = 0,
                    firing = false,
                    casting = true,
                    level = Spell.level,
                    unit = Spell.source.unit,
                    timer = CreateTimer(),
                    timeout = DRAG_AND_DROP_TIME,
                    player = GetOwningPlayer(Spell.source.unit),
                    effect = AddSpecialEffectEx(INDICATOR_MODEL, Spell.x, Spell.y, 0, INDICATOR_SCALE),
                    angle = AngleBetweenCoordinates(Spell.x, Spell.y, GetPlayerMouseX(Spell.source.player), GetPlayerMouseY(Spell.source.player)),
                    range = GetAoE(Spell.source.unit, Spell.level),
                    count = GetCount(Spell.source.unit, Spell.level),
                    lines = GetLineCount(Spell.source.unit, Spell.level),
                    burn = GetFireDamage(Spell.source.unit, Spell.level),
                    time = GetDuration(Spell.source.unit, Spell.level),
                    interval = GetFireInterval(Spell.level),
                    lineInterval = 0,
                    destroy = FireStrike.destroy
                }

                link[this.timer] = this

                BlzSetSpecialEffectYaw(this.effect, this.angle)
                BlzSetSpecialEffectTimeScale(this.effect, INDICATOR_TIME_SCALE)
                TimerStart(this.timer, 0.03, true, FireStrike.onPeriod)
            end
        end

        function FireStrike.onOrder()
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
                    if not self.casting then
                        self:destroy()
                    end
                elseif BlzGetUnitAbilityCooldownRemaining(source, ABILITY) == 0 and order == base and distance > range then
                    if self then
                        self:destroy()
                    end

                    self = {
                        done = false,
                        x = GetOrderPointX(),
                        y = GetOrderPointY(),
                        index = 0,
                        firing = false,
                        casting = false,
                        level = level,
                        unit = source,
                        timer = CreateTimer(),
                        player = GetOwningPlayer(source),
                        effect = AddSpecialEffectEx(INDICATOR_MODEL, GetOrderPointX(), GetOrderPointY(), 0, INDICATOR_SCALE),
                        angle = AngleBetweenCoordinates(GetOrderPointX(), GetOrderPointY(), GetPlayerMouseX(GetOwningPlayer(source)), GetPlayerMouseY(GetOwningPlayer(source))),
                        destroy = FireStrike.destroy
                    }

                    link[self.timer] = self
                    struct[source] = self

                    BlzSetSpecialEffectTimeScale(self.effect, INDICATOR_TIME_SCALE)
                    BlzSetSpecialEffectYaw(self.effect, self.angle)
                    TimerStart(self.timer, 0.03, true, FireStrike.onPeriod)
                end
            end
        end

        function FireStrike.onInit()
            RegisterSpell(FireStrike.allocate(), ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, FireStrike.onOrder)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, FireStrike.onOrder)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, FireStrike.onOrder)
        end
    end
end)