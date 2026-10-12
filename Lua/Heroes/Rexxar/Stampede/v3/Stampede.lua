OnInit("Stampede", function (requires)
    requires "Class"
    requires "Spell"
    requires "Slow"
    requires "Missiles"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"
    requires.optional "Bonus"
    requires.optional "CDR"

    -- ------------------------------- Stampede v1.3 by Chopinski ------------------------------ --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The ability raw code
    local ABILITY            = S2A('Rex5')
    -- The missile model
    local MODEL              = "Abilities\\Spells\\Other\\Stampede\\StampedeMissile.mdl"
    -- The missile scale
    local SCALE              = 1.5
    -- The missile speed
    local SPEED              = 800
    -- The slow model
    local SLOW_MODEL         = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
    -- The slow model attach point
    local SLOW_ATTACH        = "origin"
    -- The slow damage model
    local DAMAGE_MODEL       = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
    -- The slow damage model attach point
    local DAMAGE_ATTACH      = "origin"
    -- The time the player has to move the mouse before the spell starts
    local DRAG_AND_DROP_TIME = 3.
    -- Skill indicator model
    local INDICATOR_MODEL      = "Skill_Indicator_Move.mdl"
    -- Indicator scaling
    local INDICATOR_SCALE      = 4
    -- Indicator time scaling
    local INDICATOR_TIME_SCALE = 1.5

    -- The amount of damage dealt when a boar hits an enemy
    local function GetDamage(source, level)
        if Bonus then
            return 750. * level + (0.3 * level * GetUnitBonus(source, BONUS_SPELL_POWER)) + ((1 + 0.25 * level) * GetUnitBonus(source, BONUS_DAMAGE))
        else
            return 750. * level
        end
    end

    -- The slow amount
    local function GetSlow(source, level)
        return 0.1 + 0.1 * level
    end

    -- The slow duration
    local function GetSlowDuration(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end
    
    -- The ability aoe
    local function GetAoE(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The lizard total distance
    local function GetRange(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_CAST_RANGE, level - 1)
    end

    -- The stack cooldown
    local function GetCooldown(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_COOLDOWN, level - 1)
    end

    -- The lizard count (purely cosmetic)
    local function GetLizardCount(source, level)
        return 2 + 0 * level
    end

    -- The unit filter
    local function UnitFilter(owner, target)
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Lizard = Class(Missile)

        function Lizard:onUnit(unit)
            if UnitFilter(self.owner, unit) then
                if UnitDamageTarget(self.source, unit, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                    SlowUnit(self.source, unit, self.slow, self.slowDuration, SLOW_MODEL, SLOW_ATTACH, false)
                    DestroyEffect(AddSpecialEffectTarget(DAMAGE_MODEL, unit, DAMAGE_ATTACH))
                end
            end

            return false
        end
    end

    do
        Stampede = Class(Spell)

        local link = {}
        local array = {}
        local struct = {}
        local charges = {}

        function Stampede:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)

            if self.type == 0 then
                array[self.unit] = nil
                charges[self.unit] = nil
            else
                if self.casting then
                    DestroyEffectTimed(self.effect, 2)
                else
                    DestroyEffect(self.effect)
                end

                link[self.timer] = nil
                struct[self.unit] = nil
            end

            self.unit = nil
            self.timer = nil
            self.effect = nil
            self.player = nil
        end

        function Stampede:onTooltip(source, level, ability)
            return "|cffffcc00Rexxar|r calls forth  rampaging lizards to trample all enemy units in its path. The lizards will do |cff00ffff" .. N2S(GetDamage(source, level), 0) .. " Magic|r damage and slow any enemy unit in comes in contact with by |cffffcc00" .. N2S(GetSlow(source, level) * 100, 0) .. "%|r for |cffffcc00" .. N2S(GetSlowDuration(source, level), 1) .. "|r seconds. Stampede gains |cffffcc001|r stack every |cffffcc00" .. N2S(GetCooldown(source, level), 0) .. "|r seconds.\n\n|cffffcc00Drag and Drop|r to choose direction.\n\nCharges: |cffffcc00" .. I2S(charges[source] or 0) .. "|r"
        end

        function Stampede.onPeriod()
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
                local range = GetRange(self.unit, self.level)
                local count = GetLizardCount(self.unit, self.level)
                local lizard = Lizard.create(self.x, self.y, 0, self.x + range * math.cos(self.angle), self.y + range * math.sin(self.angle), 0)
                
                lizard.source = self.unit
                lizard.owner = self.player
                lizard.model = MODEL
                lizard.scale = SCALE
                lizard.speed = SPEED
                lizard.collision = GetAoE(self.unit, self.level)
                lizard.damage = GetDamage(self.unit, self.level)
                lizard.slow = GetSlow(self.unit, self.level)
                lizard.slowDuration = GetSlowDuration(self.unit, self.level)

                if count > 0 then
                    local row = 1
                    local col = 1
                    local flip = 1

                    for i = 0, count - 1, 1 do
                        lizard:attach(MODEL, row * -150, col * flip * 150, 0, SCALE)

                        flip = flip * -1

                        if i > 0 and i % 2 == 0 then
                            row = row + 1
                            col = col + 1
                        end
                    end
                end

                lizard:launch()
                BlzSetSpecialEffectYaw(self.effect, self.angle)
                self:destroy()
            else
                BlzSetSpecialEffectYaw(self.effect, self.angle)
            end
        end

        function Stampede:onCast()
            local this = { 
                x = Spell.x,
                y = Spell.y,
                level = Spell.level,
                unit = Spell.source.unit,
                player = Spell.source.player,
                destroy = Stampede.destroy 
            }

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
                    destroy = Stampede.destroy
                }

                link[this.timer] = this

                BlzSetSpecialEffectYaw(this.effect, this.angle)
                BlzSetSpecialEffectTimeScale(this.effect, INDICATOR_TIME_SCALE)
                TimerStart(this.timer, 0.03, true, Stampede.onPeriod)
            end

            if (charges[Spell.source.unit] or 0) > 0 then
                charges[Spell.source.unit] = (charges[Spell.source.unit] or 0) - 1

                if charges[Spell.source.unit] > 0 then
                    ResetUnitAbilityCooldown(Spell.source.unit, ABILITY)
                else
                    if CDR then
                        CalculateAbilityCooldown(Spell.source.unit, ABILITY, Spell.level, TimerGetRemaining(array[Spell.source.unit].timer))
                    else
                        Spell.cooldown = TimerGetRemaining(array[Spell.source.unit].timer)
                    end
                end
            end
        end

        function Stampede.onOrder()
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
                        type = 1,
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
                        destroy = Stampede.destroy
                    }

                    link[self.timer] = self
                    struct[source] = self

                    BlzSetSpecialEffectTimeScale(self.effect, INDICATOR_TIME_SCALE)
                    BlzSetSpecialEffectYaw(self.effect, self.angle)
                    TimerStart(self.timer, 0.03, true, Stampede.onPeriod)
                end
            end
        end

        function Stampede:onLearn(unit, ability, level)
            if not array[unit] then
                local this = {
                    type = 0,
                    unit = unit,
                    timer = CreateTimer(),
                    destroy = Stampede.destroy
                }
                
                array[unit] = this
                charges[unit] = 1

                TimerStart(this.timer, GetCooldown(unit, level), true, function ()
                    local level = GetUnitAbilityLevel(this.unit, ABILITY)

                    if level > 0 then
                        if (charges[this.unit] or 0) >= 0 then
                            charges[this.unit] = (charges[this.unit] or 0) + 1

                            BlzEndUnitAbilityCooldown(this.unit, ABILITY)
                        end
                    else
                        this:destroy()
                    end
                end)
            else
                local this = array[unit]
                
                if this then
                    charges[this.unit] = (charges[this.unit] or 0) + 1

                    BlzEndUnitAbilityCooldown(this.unit, ABILITY)
                    TimerStart(this.timer, GetCooldown(this.unit, level), true, function ()
                        local level = GetUnitAbilityLevel(this.unit, ABILITY)

                        if level > 0 then
                            if (charges[this.unit] or 0) >= 0 then
                                charges[this.unit] = (charges[this.unit] or 0) + 1

                                BlzEndUnitAbilityCooldown(this.unit, ABILITY)
                            end
                        else
                            this:destroy()
                        end
                    end)
                end
            end
        end

        function Stampede.onInit()
            RegisterSpell(Stampede.allocate(), ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, Stampede.onOrder)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, Stampede.onOrder)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, Stampede.onOrder)
        end
    end
end)