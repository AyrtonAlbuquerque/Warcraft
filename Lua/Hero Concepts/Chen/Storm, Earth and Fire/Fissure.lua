--[[ requires SpellEffectEvent, Missiles
    /* ------------------------ Fissure v1.2 by CHopinski ----------------------- */
    // Credits:
    //     AnsonRuk    - Icon Darky29
    //     Darky29     - Fissure Model
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of Fissure ability
    Fissure_ABILITY   = FourCC('A00B')
    -- The pathing blocker raw code
    local BLOCKER     = FourCC('YTpc')
    -- The Fissure model
    local MODEL       = "Fissure.mdl"
    -- The Fissure model scale
    local SCALE       = 1.
    -- The Fissure birth model
    local BIRTH_MODEL = "RockSlam.mdl"
    -- The Fissure birth model scale
    local BIRTH_SCALE = 0.7
    -- The Fissure Missile speed
    local SPEED       = 1500.

    -- The Fissure travel distance, by default the ability cast range
    local function GetDistance(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, Fissure_ABILITY), ABILITY_RLF_CAST_RANGE, level - 1)
    end

    -- The number of bounces
    local function GetStunTime(level)
        return 1. + 0.*level
    end

    -- The damage
    local function GetDamage(level)
        return 150.*level
    end

    -- The Fissure damage aoe
    local function GetAoE(level)
        return 200. + 0.*level
    end

    -- The Fissure duration
    local function GetFissureDuration(level)
        return 10. + 0.*level
    end

    -- The Filter Damage Filter for enemy units
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterSpellEffectEvent(Fissure_ABILITY, function()
            local a = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local d = GetDistance(Spell.source.unit, Spell.level)
            local this = Missiles:create(Spell.source.x, Spell.source.y, 0, Spell.source.x + d*Cos(a), Spell.source.y + d*Sin(a), 0)
            
            this:speed(SPEED)
            this.yaw = a
            this.source = Spell.source.unit
            this.owner = Spell.source.player
            this.damage = GetDamage(Spell.level)
            this.collision = GetAoE(Spell.level)     
            this.stun = GetStunTime(Spell.level)
            this.dur = GetFissureDuration(Spell.level)
            this.offset = 0

            this.onPeriod = function()
                this.offset = this.offset + this.veloc
                if this.offset >= 96 then
                    local effect = AddSpecialEffectEx(MODEL, this.x, this.y, 0, SCALE)
                    this.offset = 0

                    DestroyEffect(AddSpecialEffectEx(BIRTH_MODEL, this.x, this.y, 0, BIRTH_SCALE))
                    BlzSetSpecialEffectYaw(effect, this.yaw)
                    DestroyEffectTimed(effect, this.dur - 5)
                    RemoveDestructableTimed(CreateDestructable(BLOCKER, this.x, this.y, this.yaw*bj_RADTODEG, 1, 0), this.dur)
                end

                return false
            end
            
            this.onHit = function(unit)
                if DamageFilter(this.owner, unit) then
                    if UnitDamageTarget(this.source, unit, this.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        StunUnit(unit, this.stun)
                    end
                end

                return false
            end

            this:launch()
        end)
    end)
end