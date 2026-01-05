OnInit("Overkill", function (requires)
    requires "Class"
    requires "Bonus"
    requires "Missiles"
    requires "Utilities"
    requires "MouseUtils"
    requires "RegisterPlayerUnitEvent"
    requires.optional "ArsenalUpgrade"

    -- ------------------------------- Overkill v1.5 by Chopinski ------------------------------ --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Overkill ability
    Overkill_ABILITY = S2A('Tyc3')
    -- The raw code of the Overkill buff
    local BUFF       = S2A('BTy0')
    -- The Bullet model
    local MODEL      = "Bullet.mdl"
    -- The Bullet scale
    local SCALE      = 1.
    -- The Bullet speed
    local SPEED      = 2000.
    -- The firing period
    local PERIOD     = 0.03125
    -- The key to move without following cursor
    local KEY        = OSKEY_TAB

    -- The X coordinate starting point for the bullets. This exists so the bullets
    -- will come out of the tychus model weapon barrel.
    local function GetX(x, face)
        return x + 120*Cos(face + 13*bj_DEGTORAD)
    end

    -- The Y coordinate starting point for the bullets. This exists so the bullets
    -- will come out of the tychus model weapon barrel.
    local function GetY(y, face)
        return y + 120*Sin(face + 13*bj_DEGTORAD)
    end

    -- The Bullet damage.
    local function GetDamage(level, source)
        return (5. + 5.*level) + (0.1 * level) * GetUnitBonus(source, BONUS_DAMAGE)
    end

    -- The Bullet collision.
    local function GetCollision(level)
        return 15. + 0.*level
    end

    -- The Bullets max aoe spread.
    local function GetMaxAoE(level)
        return 200. + 0.*level
    end

    -- The Bullet max travel distance
    local function GetTravelDistance(level)
        return 700. + 0.*level
    end

    -- The Bullet mana cost
    local function GetManaCost(unit, level)
        if ArsenalUpgrade then
            if GetUnitAbilityLevel(unit, ArsenalUpgrade_ABILITY) > 0 then
                return 0.5 * level
            else
                return 1. * level
            end
        else
            return 1. * level
        end
    end

    -- The Damage Filter.
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Bullet = Class(Missile)

        function Bullet:onUnit(unit)
            if DamageFilter(self.owner, unit) then
                UnitDamageTarget(self.owner, unit, self.damage, true, true, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, nil)
            end

            return false
        end
    end

    do
        Overkill = Class(Spell)

        local array = {}
        local holding = {}
        local registered = {}
        local trigger = CreateTrigger()
            
        function Overkill:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            AddUnitAnimationProperties(self.unit, "spin", false)
            QueueUnitAnimation(self.unit, "Stand Ready")
            IssueImmediateOrderById(self.unit, 852590)
            SetUnitPropWindowBJ(self.unit, self.window)
            UnitRemoveAbility(self.unit, S2A('Abun'))

            array[self.unit] = nil

            self.unit = nil
            self.timer = nil
            self.player = nil
        end

        function Overkill:onTooltip(source, level, ability)
            return "|cffffcc00Tychus|r fire his mini-gun at full power, unleashing a barrage of bullets towards his facing direction. Each bullet consumes |cff00ffff" .. N2S(GetManaCost(source, level), 0) .. " Mana|r and deals |cffff0000" .. N2S(GetDamage(level, source), 0) .. " Physical|r damage to any enemy unit in its trajectory. |cffffcc00Tychus|r will only stop firing if he has no mana left or deactivates |cffffcc00Overkill|r. In addition |cffffcc00Tychus|r can move while on |cffffcc00Overkill|r and will always be facing the |cffffcc00Cursor|r during its active period. Hold the |cffffcc00TAB|r key to move wihtout changing direction."
        end

        function Overkill:onCast()
            local this = array[Spell.source.unit]

            if not this then
                this = { destroy = Overkill.destroy }

                this.unit = Spell.source.unit
                this.prevX = Spell.source.x
                this.prevY = Spell.source.y
                this.timer = CreateTimer()
                this.window = GetUnitPropWindow(this.unit) * bj_RADTODEG
                this.facing = GetUnitFacing(this.unit) * bj_DEGTORAD
                this.player = Spell.source.player

                array[Spell.source.unit] = this

                if not registered[GetPlayerId(this.player)] then
                    registered[GetPlayerId(this.player)] = true
                    BlzTriggerRegisterPlayerKeyEvent(trigger, this.player, KEY, 0, true)
                    BlzTriggerRegisterPlayerKeyEvent(trigger, this.player, KEY, 0, false)
                end

                UnitAddAbility(this.unit, S2A('Abun'))
                SetUnitPropWindowBJ(this.unit, 360)
                TimerStart(this.timer, PERIOD, true, function ()
                    local morphed = false
                    local level = GetUnitAbilityLevel(this.unit, Overkill_ABILITY)
                    local cost = GetManaCost(this.unit, level)

                    if CommanderOdin then
                        morphed = CommanderOdin.morphed[this.unit]
                    end

                    if GetUnitAbilityLevel(this.unit, BUFF) > 0 and GetUnitState(this.unit, UNIT_STATE_MANA) >= cost and not morphed then
                        local x = GetUnitX(this.unit)
                        local y = GetUnitY(this.unit)
                        local offset = GetTravelDistance(level)
                        local range = GetRandomRange(GetMaxAoE(level))
                        local face = GetUnitFacing(this.unit)*bj_DEGTORAD
                        local bullet = Bullet.create(GetX(x, face), GetY(y, face), 70, GetRandomCoordInRange(x + offset*math.cos(face), range, true), GetRandomCoordInRange(y + offset*math.sin(face), range, false), GetRandomReal(0, 80))
                        
                        bullet.model = MODEL
                        bullet.speed = SPEED
                        bullet.scale = SCALE
                        bullet.source = this.unit
                        bullet.owner = this.player
                        bullet.damage = GetDamage(level, this.unit)
                        bullet.collision = GetCollision(level)

                        if x ~= this.prevX and y ~= this.prevY then
                            this.prevX = x
                            this.prevY = y

                            AddUnitAnimationProperties(this.unit, "spin", true)
                        else
                            AddUnitAnimationProperties(this.unit, "spin", false)
                            SetUnitAnimation(this.unit, "Attack")
                        end

                        if not holding[GetPlayerId(this.player)] then
                            this.facing = AngleBetweenCoordinates(x, y, GetPlayerMouseX(this.player), GetPlayerMouseY(this.player))*bj_RADTODEG
                        end

                        BlzSetUnitFacingEx(this.unit, this.facing)
                        AddUnitMana(this.unit, -cost)
                        bullet:launch()

                    else
                        this:destroy()
                    end
                end)
            end
        end

        function Overkill.onKey()
            if BlzGetTriggerPlayerIsKeyDown() then
                holding[GetPlayerId(GetTriggerPlayer())] = true
            else
                holding[GetPlayerId(GetTriggerPlayer())] = false
            end
        end

        function Overkill.onInit()
            RegisterSpell(Overkill.allocate(), Overkill_ABILITY)
            TriggerAddCondition(trigger, Condition(Overkill.onKey))
        end
    end
end)