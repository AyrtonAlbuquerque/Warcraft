--[[ requires SpellEffectEvent, Utilities, Missiles, MouseUtils
    /* --------------------- Drunken Style v1.2 by Chopinski -------------------- */
    // Credits:
    //     Blizzard           - Icon
    //     Bribe              - SpellEffectEvent
    //     Vexorian           - TimerUtils
    //     Vexorian           - MouseUtils
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The Drunken Style Ability
    local ABILITY = FourCC('A005')
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
    local function GetKnockbackDistance(level)
        return 100. + 0.*level
    end

    -- The Drunken Style knockback duration
    local function GetKnockbackDuration(level)
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
    local function GetDamage(level)
        return 25.*level
    end

    -- The Drunken Style Damage Filter for enemy units
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    local n = {}
    
    local function GetAngle(player, unit, x, y, mx, my, aoe)
        local group = CreateGroup() 
        local angle = GetUnitFacing(unit)*bj_DEGTORAD
        local size

        GroupEnumUnitsInRange(group, mx, my, aoe, nil)
        size = BlzGroupGetSize(group)
        if size > 0 then
            for i = 0, size - 1 do
                local u = BlzGroupUnitAt(group, i)
                if IsUnitEnemy(u, player) and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                    angle = AngleBetweenCoordinates(x, y, mx, my)
                    break
                end
            end
        end
        DestroyGroup(group)
        
        return angle
    end
    
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local d = GetDistance(Spell.level)
            local a = GetAngle(Spell.source.player, Spell.source.unit, Spell.source.x, Spell.source.y, GetPlayerMouseX(Spell.source.player), GetPlayerMouseY(Spell.source.player), 100)
            local dash = Missiles:create(Spell.source.x, Spell.source.y, 0, Spell.source.x + d*Cos(a), Spell.source.y + d*Sin(a), 0)
            local this

            if n[Spell.source.unit] then
                this = n[Spell.source.unit]
            else
                this = {}
                this.type = {}
                this.timer = CreateTimer()
                this.unit = Spell.source.unit
                n[this.unit] = this
            end
            
            this.type[this.unit] = (this.type[this.unit] or 0) + 1
            
            if this.type[this.unit] > 3 then
                this.type[this.unit] = 0
                SetUnitAnimationByIndex(Spell.source.unit, 14)
            elseif this.type[this.unit] == 1 then
                StartUnitAbilityCooldown(Spell.source.unit, ABILITY, 0.25)
                SetUnitAnimationByIndex(Spell.source.unit, 14)
            elseif this.type[this.unit] == 2 then
                StartUnitAbilityCooldown(Spell.source.unit, ABILITY, 0.25)
                SetUnitAnimationByIndex(Spell.source.unit, 23)
            else
                SetUnitAnimationByIndex(Spell.source.unit, 17)
            end
            
            dash:model(MODEL)
            dash.source = Spell.source.unit
            dash.owner = Spell.source.player
            dash.centerX = Spell.source.x
            dash.centerY = Spell.source.y
            dash.type = this.type[this.unit]
            dash.face = a*bj_RADTODEG
            dash.damage = GetDamage(Spell.level)
            dash:duration(GetDuration(Spell.level))
            dash.collision = GetCollision(this.type[this.unit])
            dash.fov = GetDamageCone(this.type[this.unit])
            dash.distance  = GetKnockbackDistance(Spell.level)
            dash.knockback = GetKnockbackDuration(Spell.level)
            
            dash.onPeriod = function()
                if UnitAlive(dash.source) then
                    SetUnitX(dash.source, dash.x)
                    SetUnitY(dash.source, dash.y)
                    BlzSetUnitFacingEx(dash.source, dash.face)

                    return false
                else
                    return true
                end
            end
            
            dash.onHit = function(unit)
                if IsUnitInCone(unit, dash.centerX, dash.centerY, dash.collision, dash.face, dash.fov) then
                    if DamageFilter(dash.owner, unit) then
                        if UnitDamageTarget(dash.source, unit, dash.damage, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, WEAPON_TYPE_WOOD_HEAVY_BASH) then
                            KnockbackUnit(unit, AngleBetweenCoordinates(dash.x, dash.y, GetUnitX(unit), GetUnitY(unit)), dash.distance, dash.knockback, MODEL, ATTACH, true, true, false, true)
                        end
                    end
                end

                return false
            end
            
            dash.onRemove = function()
                BlzUnitInterruptAttack(dash.source)
                SetUnitTimeScale(dash.source, 1)
                IssueImmediateOrder(dash.source, "stop")
                QueueUnitAnimation(dash.source, "Stand Ready")
            end

            dash:launch()
            
            BlzUnitInterruptAttack(Spell.source.unit)
            SetUnitTimeScale(Spell.source.unit, 1.75)
            TimerStart(this.timer, GetResetTime(Spell.level), false, function()
                n[this.unit] = nil
                this.type[this.unit] = 0
                PauseTimer(this.timer)
                DestroyTimer(this.timer)
            end)
        end)
    end)
end