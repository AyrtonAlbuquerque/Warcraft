OnInit("DrunkenStyle", function(requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Missiles"
    requires "Utilities"
    requires "MouseUtils"
    requires "CrowdControl"

    -- ---------------------------- Drunken Style v1.5 by Chopinski ---------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The Drunken Style Ability
    local ABILITY = S2A('Chn7')
    -- The Drunken Style knockback model
    local MODEL   = "WindBlow.mdl"
    -- The Drunken Style knockback attach point
    local ATTACH  = "origin"

    -- The Drunken Style dash duration
    local function GetDuration(level)
        return 0.25
    end

    -- The Drunken Style dash distance
    local function GetDistance(level)
        return 200. + 0.*level
    end

    -- The Drunken Style dash type reset time
    local function GetResetTime(level)
        return 5. + 0.*level
    end

    -- The Drunken Style knockback distance
    local function GetKnockDistance(level)
        return 200. + 0.*level
    end

    -- The Drunken Style knockback duration
    local function GetKnockDuration(level)
        return 0.25 + 0.*level
    end

    -- The Drunken Style collison per dash type
    local function GetCollision(level)
        return 300. + 0.*level
    end

    -- The Drunken Style dash cone at which damage can be applyed in degrees
    local function GetDamageCone(type)
        if type == 1 then
            return 180.
        elseif type == 2 then
            return 360.
        elseif type == 3 then
            return 30.
        else
            return 180.
        end
    end

    -- The Drunken Style dash damage
    local function GetDamage(source, level)
         return 25. * level + (0.25 + 0.25*level) * GetUnitBonus(source, BONUS_DAMAGE)
    end

    -- The Drunken Style Damage Filter for enemy units
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    local Dash = Class(Missile)
    
    do
        function Dash:onPeriod()
            return not UnitAlive(self.source)
        end

        function Dash:onUnit(unit)
            if IsUnitInCone(unit, self.centerX, self.centerY, self.collision, self.face, self.fov) then
                if DamageFilter(self.owner, unit) then
                    if UnitDamageTarget(self.source, unit, self.damage, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WOOD_HEAVY_BASH) then
                        KnockbackUnit(unit, AngleBetweenCoordinates(self.x, self.y, GetUnitX(unit), GetUnitY(unit)), self.distance, self.knockback, MODEL, ATTACH, true, true, false, true)
                    end
                end
            end

            return false
        end

        function Dash:onRemove()
            BlzUnitInterruptAttack(self.source)
            SetUnitTimeScale(self.source, 1)
            IssueImmediateOrder(self.source, "stop")
            QueueUnitAnimation(self.source, "Stand Ready")
        end
    end

    do
        DrunkenStyle = Class(Spell)

        local array = {}
        local types = {}

        function DrunkenStyle:onTooltip(unit, level, ability)
            return "|cffffcc00Chen|r performs a series of |cffffcc003|r attacks in sequence, |cffffcc00Swing|r, |cffffcc00Kick|r and |cffffcc00Swipe|r, dashing a short distance towards the cursor in each attack, dealing |cffff0000" .. N2S(GetDamage(unit, level), 0) .. "|r |cffff0000Physical|r damage and knocking back enemy units in range. Every cast performs one attack of the sequence. The sequence resets after |cffffcc00" .. N2S(GetResetTime(level), 1) .. "|r seconds if left uncasted. If |cffffcc00Chen|r performs all attacks, |cffffcc00Drunken Style|r goes into cooldown. All attacks can hit |cffffcc00Critical Strikes|r and/or |cffffcc00Miss|r.\n\n|cffffcc00Swing|r  knocks back enemy units in a wide angle in front of |cffffcc00Chen|r.\n\n|cffffcc00Kick|r knocks back enemy units directly in front of |cffffcc00Chen|r.\n\n|cffffcc00Swipe|r knocks back enemy units all around |cffffcc00Chen|r."
        end

        function DrunkenStyle:onCast()
            local distance = GetDistance(Spell.level)
            local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, GetPlayerMouseX(Spell.source.player), GetPlayerMouseY(Spell.source.player))
            local dash = Dash.create(Spell.source.x, Spell.source.y, 0, Spell.source.x + distance * math.cos(angle), Spell.source.y + distance * math.sin(angle), 0)
            local this = array[Spell.source.unit]

            if not this then
                this = DrunkenStyle.allocate()
                this.unit = Spell.source.unit
                array[Spell.source.unit] = this
            end

            types[this.unit] = (types[this.unit] or 0) + 1

            if types[this.unit] == 1 then
                StartUnitAbilityCooldown(Spell.source.unit, ABILITY, 0.25)
                SetUnitAnimationByIndex(Spell.source.unit, 14)
            elseif types[this.unit] == 2 then
                StartUnitAbilityCooldown(Spell.source.unit, ABILITY, 0.25)
                SetUnitAnimationByIndex(Spell.source.unit, 23)
            else
                types[this.unit] = 0
                SetUnitAnimationByIndex(Spell.source.unit, 17)
            end

            dash.model = MODEL
            dash.type = types[this.unit]
            dash.face = angle * bj_RADTODEG
            dash.source = Spell.source.unit
            dash.unit = Spell.source.unit
            dash.owner = Spell.source.player
            dash.centerX = Spell.source.x
            dash.centerY = Spell.source.y
            dash.damage = GetDamage(Spell.source.unit, Spell.level)
            dash.duration = GetDuration(Spell.level)
            dash.collision = GetCollision(types[this.unit])
            dash.fov = GetDamageCone(types[this.unit])
            dash.distance = GetKnockDistance(Spell.level)
            dash.knockback = GetKnockDuration(Spell.level)

            dash:launch()
            BlzUnitInterruptAttack(Spell.source.unit)
            SetUnitTimeScale(Spell.source.unit, 1.75)
            TimerStart(CreateTimer(), GetResetTime(Spell.level), false, function()
                types[this.unit] = nil
                array[this.unit] = nil

                DestroyTimer(GetExpiredTimer())
            end)
        end

        function DrunkenStyle.onInit()
            RegisterSpell(DrunkenStyle.allocate(), ABILITY)
        end
    end
end)