OnInit("SamuroCritical", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"
    requires "Missiles"
    requires "Utilities"
    requires "CriticalStrike"

    -- ------------------------------- Critical v1.4 by Chopinski ------------------------------ --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Critical Strike ability
    Critical_ABILITY        = S2A('Smr3')
    -- The missile model
    local MISSILE_MODEL      = "Fire_Slash.mdl"
    -- The missile size
    local MISSILE_SCALE      = 1.
    -- The missile speed
    local MISSILE_SPEED      = 1200.
    -- The attack type of the damage dealt
    local ATTACK_TYPE        = ATTACK_TYPE_HERO  
    -- The damage type of the damage dealt
    local DAMAGE_TYPE        = DAMAGE_TYPE_UNIVERSAL

    -- The the critical strike chance increament
    local function GetBonusChance(level)
        if level == 1 then
            return 0.1
        else
            return 0.05
        end
    end

    -- The the critical strike multiplier increament
    local function GetBonusMultiplier(level)
        return 0.1
    end

    -- The Fire Slash damage deatl based on a base damage amount and the ability level
    local function GetDamage(level)
        return 0.2 + 0.05 * level
    end

    -- The Fire Slash travel distance
    local function GetDistance(level)
        return 600. + 0.*level
    end

    -- The Fire Slash collision size
    local function GetCollision(level)
        return 75. + 0.*level
    end

    -- Filter
    local function Filtered(op, target)
        return IsUnitEnemy(target, op) and UnitAlive(target) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
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
        SamuroCritical = Class(Spell)

        function SamuroCritical.slash(source, target, damage, level)
            local x = GetUnitX(target)
            local y = GetUnitY(target)
            local distance = GetDistance(level)
            local angle = AngleBetweenCoordinates(GetUnitX(source), GetUnitY(source), x, y)
            local slash = FireSlash.create(x, y, GetUnitFlyHeight(target), x + distance * Cos(angle), y + distance * Sin(angle), 0)

            slash.source = source
            slash.damage = damage
            slash.model = MISSILE_MODEL
            slash.scale = MISSILE_SCALE
            slash.speed = MISSILE_SPEED
            slash.owner = GetOwningPlayer(source)
            slash.collision = GetCollision(level)

            slash:launch()
        end

        function SamuroCritical:onTooltip(source, level, ability)
            return "|cffffcc00Samuro|r gains |cffffcc00" .. N2S(5 + 5 * level, 0) .. "%%|r increased |cffffcc00Critical Strike Chance|r and |cffffcc00" .. N2S(10 * level, 0) .. "%%|r |cffffcc00Critical Strike Damage|r. Whenever |cffffcc00Samuro|r hits a |cffffcc00Critical Strike|r a |cffffcc00Fire Slash|r is generated in the direction of the attack, damaging enemy units in its path for |cffffcc00" .. N2S(GetDamage(level) * 100, 0) .. "%%|r of the total critical strike damage as |cffd45e19True|r damage."
        end

        function SamuroCritical.onCritical()
            local level = GetUnitAbilityLevel(GetCriticalSource(), Critical_ABILITY)

            if level > 0 then
                SamuroCritical.slash(GetCriticalSource(), GetCriticalTarget(), GetCriticalDamage() * GetDamage(level), level)
            end
        end

        function SamuroCritical:onLearn(source, skill, level)
            AddUnitBonus(source, BONUS_CRITICAL_CHANCE, GetBonusChance(level))
            AddUnitBonus(source, BONUS_CRITICAL_DAMAGE, GetBonusMultiplier(level))
        end

        function SamuroCritical.onInit()
            RegisterSpell(SamuroCritical.allocate(), Critical_ABILITY)
            RegisterCriticalStrikeEvent(SamuroCritical.onCritical)
        end
    end
end)