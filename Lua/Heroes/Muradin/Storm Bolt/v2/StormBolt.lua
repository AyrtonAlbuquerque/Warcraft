--[[ requires SpellEffectEvent, Missiles, Utilities, CrowdControl optional ThunderClap
    -- --------------------------------------- Storm Bolt v1.4 -------------------------------------- --
    -- Credits:
    --     Blizzard       - Icon
    --     Bribe          - SpellEffectEvent
    -- ---------------------------------------- By Chipinski ---------------------------------------- --
]]--

do
    -- ---------------------------------------------------------------------------------------------- --
    --                                          Configuration                                         --
    -- ---------------------------------------------------------------------------------------------- --
    -- The raw code of the Storm Bolt ability
    StormBolt_ABILITY            = FourCC('A005')
    -- The raw code of the Storm Bolt Double Thunder ability
    StormBolt_STORM_BOLT_RECAST  = FourCC('A00A')
    -- The missile model
    local MISSILE_MODEL          = "Abilities\\Spells\\Human\\StormBolt\\StormBoltMissile.mdl"
    -- The missile size
    local MISSILE_SCALE          = 1.15
    -- The missile speed
    local MISSILE_SPEED          = 1250.
    -- The model used when storm bolt deal bonus damage
    local BONUS_DAMAGE_MODEL     = "ShockHD.mdl"
    -- The attachment point of the bonus dmaage model
    local ATTACH_POINT           = "origin"
    -- The extra eye candy model
    local EXTRA_MODEL            = "StormShock.mdl"
    -- The model used when storm bolt slows a unit
    local SLOW_MODEL             = "Abilities\\Spells\\Human\\slow\\slowtarget.mdl"
    -- The attachment point of the slow model
    local SLOW_POINT             = "origin"

    -- The storm bolt damage
    function StormBolt_GetDamage(level)
        return 50. + 50.*level
    end

    -- The storm bolt damage when the target is already stunned
    function StormBolt_GetBonusDamage(damage, level)
        return damage * (1. + 0.25*level)
    end

    -- The storm bolt stun duration
    local function GetAoE(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, StormBolt_ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The storm bolt minimum travel distance
    local function GetMinimumDistance(level)
        return 300. + 0.*level
    end

    -- The storm bolt slow amount
    local function GetSlow(level)
        return 0.1 + 0.1*level
    end

    -- The storm bolt slow duration
    local function GetSlowDuration(level)
        return 2. + 0.*level
    end

    -- The Damage Filter units
    local function DamageFilter(player, target)
        return UnitAlive(target) and IsUnitEnemy(target, player) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    end

    -- ---------------------------------------------------------------------------------------------- --
    --                                             System                                             --
    -- ---------------------------------------------------------------------------------------------- --
    StormBolt = setmetatable({}, {})
    local mt = getmetatable(StormBolt)
    mt.__index = mt

    StormBolt.x = {}
    StormBolt.y = {}

    function mt:onCast()
        local level = GetUnitAbilityLevel(Spell.source.unit, StormBolt_ABILITY)
        local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
        local distance = GetMinimumDistance(level)
        local this

        if DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y) < distance then
            StormBolt.x[Spell.source.unit] = Spell.source.x + distance*Cos(angle)
            StormBolt.y[Spell.source.unit] = Spell.source.y + distance*Sin(angle)
            this = Missiles:create(Spell.source.x, Spell.source.y, 60, StormBolt.x[Spell.source.unit], StormBolt.y[Spell.source.unit], 60)
        else
            StormBolt.x[Spell.source.unit] = Spell.x
            StormBolt.y[Spell.source.unit] = Spell.y
            this = Missiles:create(Spell.source.x, Spell.source.y, 60, Spell.x, Spell.y, 60)
        end

        this.source = Spell.source.unit
        this.owner = Spell.source.player
        this:model(MISSILE_MODEL)
        this:speed(MISSILE_SPEED)
        this:scale(MISSILE_SCALE)
        this.level = level
        this.damage = StormBolt_GetDamage(level)
        this.collision = GetAoE(Spell.source.unit, level)
        this.slow = GetSlow(level)
        this.slowDuration = GetSlowDuration(level)

        this.onHit = function(unit)
            local damage

            if UnitAlive(unit) then
                if DamageFilter(this.owner, unit) then
                    if IsUnitStunned(unit) or IsUnitSlowed(unit) then
                        damage = StormBolt_GetBonusDamage(this.damage, this.level)
                        this.bonus = true
                    else
                        damage = this.damage
                    end
                end

                if UnitDamageTarget(this.source, unit, damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                    SlowUnit(unit, this.slow, this.slowDuration, SLOW_MODEL, SLOW_POINT, false)

                    if this.bonus then
                        DestroyEffect(AddSpecialEffectTarget(BONUS_DAMAGE_MODEL, unit, ATTACH_POINT))
                    end
                end
            end

            return false
        end

        this.onFinish = function()
            if not this.deflected then
                this.deflected = true
                this:deflectTarget(this.source)
                this:flushAll()
            else
                if ThunderClap then
                    ResetUnitAbilityCooldown(this.source, ThunderClap_ABILITY)
                end
            end

            return false
        end

        this:attach(EXTRA_MODEL, 0, 0, 0, MISSILE_SCALE)
        this:launch()
    end
    
    onInit(function()
        RegisterSpellEffectEvent(StormBolt_ABILITY, function()
            StormBolt:onCast()
        end)
        RegisterSpellEffectEvent(StormBolt_STORM_BOLT_RECAST, function()
            StormBolt:onCast()
        end)
    end)
end