OnInit("BreakingSlash", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"

    -- ---------------------------- Breaking Slash v1.4 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Breaking Slash ability
    BreakingSlash_ABILITY       = S2A('Smr8')
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
    function BreakingSlash_GetDamage(level)
        return 0.3 * level
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

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        FireSlash = Class(Missile)

        function FireSlash:onUnit(unit)
            if Filtered(self.owner, unit) then
                UnitDamageTarget(self.source, unit, self.damage, true, false, ATTACK_TYPE, DAMAGE_TYPE, nil)
            end

            return false
        end
    end

    do
        BreakingSlash = Class(Spell)

        function BreakingSlash.slash(source, target, damage, level)
            local x = GetUnitX(target)
            local y = GetUnitY(target)
            local distance = GetDistance(level)
            local angle = AngleBetweenCoordinates(GetUnitX(source), GetUnitY(source), x, y)
            local slash = FireSlash.create(x, y, GetUnitFlyHeight(target), x + distance * math.cos(angle), y + distance * math.sin(angle), 0)

            slash.source = source
            slash.damage = damage
            slash.model = MISSILE_MODEL
            slash.scale = MISSILE_SCALE
            slash.speed = MISSILE_SPEED
            slash.owner = GetOwningPlayer(source)
            slash.collision = GetCollision(level)

            slash:launch()
        end

        function BreakingSlash.onCritical()
            local level = GetUnitAbilityLevel(GetCriticalSource(), BreakingSlash_ABILITY)

            if level > 0 then
                BreakingSlash.slash(GetCriticalSource(), GetCriticalTarget(), GetCriticalDamage() * BreakingSlash_GetDamage(level), level)
            end
        end

        function BreakingSlash.onInit()
            RegisterSpell(BreakingSlash.allocate(), BreakingSlash_ABILITY)
            RegisterCriticalStrikeEvent(BreakingSlash.onCritical)
        end
    end
end)