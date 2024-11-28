--[[ requires SpellEffectEvent, PluginSpellEffect, Missiles, Utilities, TimerUtils, CrowdControl
    /* ----------------------- Stampede v1.1 by Chopinski ----------------------- */
    -- Credits:
    --     Bribe           - SpellEffectEvent
    --     Vexorian        - TimerUtils
    --     00110000        - RemorselessWinter effect
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The ability raw code
    local ABILITY = FourCC('A005')
    -- The missile model
    local MODEL = "Abilities\\Spells\\Other\\Stampede\\StampedeMissile.mdl"
    -- The missile scale
    local SCALE = 0.8
    -- The model used to indicate the aoe effect
    local AOE_MODEL = "RemorselessWinter.mdl"
    -- The blind model attachment point
    local AOE_SCALE = 1.7
    -- The missile speed
    local SPEED = 1000
    -- The stun model
    local STUN_MODEL  = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
    -- The stun model attach point
    local STUN_ATTACH = "overhead"

    -- The amount of damage dealt when a boar hits an enemy
    local function GetDamage(unit, level)
        return 75. * level
    end

    -- The stun duration
    local function GetStunDuration(level)
        return 0.25 * level
    end

    -- The ability duration
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The ability aoe
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The missile spawn interval
    local function GetSpawnInterval(level)
        return 0.5 - 0.1 * level
    end

    -- The missile collision size
    local function GetCollisionSize(level)
        return 64. + 0. * level
    end

    -- The unit filter
    local function UnitFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end
    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local timer = CreateTimer()
            local unit = Spell.source.unit
            local player = Spell.source.player
            local level = Spell.level
            local x = Spell.x
            local y = Spell.y
            local collision = GetCollisionSize(level)
            local duration = GetDuration(unit, level)
            local damage = GetDamage(unit, level)
            local tick = GetSpawnInterval(level)
            local stun = GetStunDuration(level)
            local aoe = GetAoE(unit, level)/2
            local effect = AddSpecialEffectEx(AOE_MODEL, x, y, 0, AOE_SCALE)

            TimerStart(timer, tick, true, function()
                if duration > 0 then
                    duration = duration - tick
                    local fx = GetRandomCoordInRange(x, aoe, true)
                    local fy = GetRandomCoordInRange(y, aoe, false)
                    local angle = AngleBetweenCoordinates(fx, fy, x, y)
                    local this = Missiles:create(fx, fy, 0, x + aoe*Cos(angle), y + aoe*Sin(angle), 0)

                    this:model(MODEL)
                    this:scale(SCALE)
                    this:speed(SPEED)
                    this.source = unit
                    this.owner = player
                    this.collision = collision
                    this.damage = damage
                    this.stun = stun

                    this.onHit = function(u)
                        if UnitFilter(this.owner, u) then
                            if UnitDamageTarget(this.source, u, this.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                                StunUnit(u, this.stun, STUN_MODEL, STUN_ATTACH, false)
                            end
                        end

                        return false
                    end

                    this:launch()
                else
                    PauseTimer(timer)
                    DestroyTimer(timer)
                    DestroyEffect(effect)
                end
            end)
        end)
    end)
end