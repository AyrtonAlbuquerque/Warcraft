--[[ requires SpellEffectEvent, Missiles, Utilities
    /* ---------------------- Dragon Dash v1.1 by Chopinski --------------------- */
    // Credits:
    //     Zipfinator    - Icon
    //     Bribe         - SpellEffectEvent
    //     AZ            - Model
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY        = FourCC('A002')
    -- The Model
    local MODEL          = "DDash.mdl"
    -- The model scale
    local SCALE          = 1
    -- The dash speed
    local SPEED          = 1500
    -- The dash effect offset
    local OFFSET         = 100
    -- The secondary model
    local WIND_MODEL     = "WindBlow.mdl"
    -- The secondary attach point
    local ATTACH_POINT   = "origin"

    -- The Dash distance
    local function GetDistance(level)
         return 600. + 50.*level
    end

    -- The Cooldown Reduction per unit dashed through
    local function GetCooldownReduction(level)
         return 0.5*level
    end

    -- The Dash collision
    local function GetCollision(level)
        return 64. + 0.*level
    end

    -- The Dash unit filter.
    local function UnitFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local point = DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local distance = GetDistance(Spell.level)
            local this
            
            if point < distance then
                distance = point
            end
            
            this = Missiles:create(Spell.source.x, Spell.source.y, 0, Spell.source.x + distance*Cos(angle), Spell.source.y + distance*Sin(angle), 0)
            this:speed(SPEED)
            this.theta = angle
            this.owner = Spell.source.player
            this.source = Spell.source.unit
            this.collision = GetCollision(Spell.level)
            this.reduction = GetCooldownReduction(Spell.level)
            this.dash = AddSpecialEffectEx(MODEL, Spell.source.x + OFFSET*Cos(angle), Spell.source.y + OFFSET*Sin(angle), 0, SCALE)
            this.wind = AddSpecialEffectTarget(WIND_MODEL, source, ATTACH_POINT)
            
            BlzSetAbilityRealLevelField(Spell.ability, ABILITY_RLF_FOLLOW_THROUGH_TIME, Spell.level - 1, distance/SPEED)
            SetUnitAnimation(this.source, "Spell Channel")
            
            this.onPeriod = function()
                BlzSetSpecialEffectPosition(this.dash, this.x + OFFSET*Cos(this.theta), this.y + OFFSET*Sin(this.theta), this.z)
                BlzSetSpecialEffectYaw(this.dash, this.effect.yaw)
                SetUnitX(this.source, this.x)
                SetUnitY(this.source, this.y)
                BlzSetUnitFacingEx(this.source, this.effect.yaw*bj_RADTODEG)
                
                return false
            end
            
            this.onHit = function(unit)
                if UnitFilter(this.owner, unit) then
                    local cooldown = BlzGetUnitAbilityCooldownRemaining(this.source, ABILITY)
                    if this.reduction >= cooldown then
                        ResetUnitAbilityCooldown(this.source, ABILITY)
                    else
                        StartUnitAbilityCooldown(this.source, ABILITY, cooldown - this.reduction)
                    end
                end
                
                return false
            end
            
            this.onPause = function()
                return true
            end
            
            this.onRemove = function()
                IssueImmediateOrder(this.source, "stop")
                SetUnitAnimation(this.source, "Stand")
                DestroyEffect(this.wind)
                DestroyEffect(this.dash)
            end
            
            this:launch()
        end)
    end)
end