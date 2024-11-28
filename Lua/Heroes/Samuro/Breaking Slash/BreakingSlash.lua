--[[ requires CriticalStrike, Missiles
    /* -------------------- Breaking Slash v1.2 by Chopinski -------------------- */
    // Credits:
    //     PeeKay         - Icon
    //     AZ             - Slash model
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Breaking Slash ability
    local BreakingSlash_ABILITY = FourCC('A000')
    -- The missile model
    local MISSILE_MODEL         = "Fire_Slash.mdl"
    -- The missile size
    local MISSILE_SCALE         = 1.
    -- The missile speed
    local MISSILE_SPEED         = 1200.
    -- The attack type of the damage dealt
    local ATTACK_TYPE           = ATTACK_TYPE_HERO  
    -- The damage type of the damage dealt
    local DAMAGE_TYPE           = DAMAGE_TYPE_UNIVERSAL

    -- The Fire Slash damage deatl based on a base damage amount and the ability level
    function BreakingSlash_GetDamage(damage, level)
        return damage*level*0.3
    end

    -- The Fire Slash travel distance
    local function GetDistance(level)
        return 500. + 100.*level
    end

    -- The Fire Slash collision size
    local function GetCollision(level)
        return 75. + 0.*level
    end

    -- Filter
    local function Filtered(player, unit)
        return IsUnitEnemy(unit, player) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    BreakingSlash = setmetatable({}, {})
    local mt = getmetatable(BreakingSlash)
    mt.__index = mt
    
    function mt:slash(source, target, damage, level)
        local x = GetUnitX(target)
        local y = GetUnitY(target)
        local z = GetUnitZ(target)
        local a = AngleBetweenCoordinates(GetUnitX(source), GetUnitY(source), x, y)
        local d = GetDistance(level)
        local this = Missiles:create(x, y, z, x + d*Cos(a), y + d*Sin(a), 0)

        this.source = source
        this.owner = GetOwningPlayer(source)
        this.damage = damage
        this.collision = GetCollision(level)
        this:model(MISSILE_MODEL)
        this:scale(MISSILE_SCALE)
        this:speed(MISSILE_SPEED)

        this.onHit = function(unit)
            if Filtered(this.owner, unit) then
                UnitDamageTarget(this.source, unit, this.damage, true, false, ATTACK_TYPE, DAMAGE_TYPE, nil)
            end

            return false
        end

        this:launch()
    end
    
    onInit(function()
        RegisterCriticalStrikeEvent(function()
            local source = GetCriticalSource()
            local level  = GetUnitAbilityLevel(source, BreakingSlash_ABILITY)

            if level > 0 then
                BreakingSlash:slash(source, GetCriticalTarget(), BreakingSlash_GetDamage(GetCriticalDamage(), level), level)
            end
        end)
    end)
end