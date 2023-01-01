--[[ requires SpellEffectEvent, PluginSpellEffect, Missiles, Utilities, CrowdControl
    -- ------------------------------------ Infernal Charge v1.5 ------------------------------------ --
    -- Credits:
    --     marilynmonroe - Pit Infernal model
    --     Bribe         - SpellEffectEvent
    -- ---------------------------------------- By Chopinski ---------------------------------------- --
]]--

do
    -- ---------------------------------------------------------------------------------------------- --
    --                                          Configuration                                         --
    -- ---------------------------------------------------------------------------------------------- --
    -- The raw code of the Infernal Charge ability
    local ABILITY          = FourCC('A003')
    -- The time scale of the pit infernal when charging
    local TIME_SCALE       = 2
    -- The index of the animation played when charging
    local ANIMATION_INDEX  = 16
    -- How long the Pit Infernal charges
    local CHARGE_TIME      = 1.0
    -- The blast model
    local KNOCKBACK_MODEL  = "WindBlow.mdx"
    -- The blast model
    local KNOCKBACK_ATTACH = "origin"
    -- The Attack type of the damage dealt (Spell)
    local ATTACK_TYPE      = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt 
    local DAMAGE_TYPE      = DAMAGE_TYPE_MAGIC

    -- The damage dealt by the Pit Infernal when charging
    local function GetChargeDamage(level)
        return 200. + 0.*level
    end

    -- The Area of Effect at which units will be knocked back
    local function GetChargeAoE(level)
        return 200. + 0.*level
    end

    -- The distance units are knocked back by the charging pit infernal
    local function GetKnockbackDistance(level)
        return 300. + 0.*level
    end

    -- How long units are knocked back
    local function GetKnockbackDuration(level)
        return 0.5 + 0.*level
    end

    -- The Area of Effect at which units will be knocked back
    local function ChargeFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ---------------------------------------------------------------------------------------------- --
    --                                             System                                             --
    -- ---------------------------------------------------------------------------------------------- --
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local this = Missiles:create(Spell.source.x, Spell.source.y, 0, Spell.x, Spell.y, 0)

            this.damage = GetChargeDamage(Spell.level)
            this.source = Spell.source.unit
            this.owner = GetOwningPlayer(Spell.source.unit)
            this.collision = GetChargeAoE(Spell.level)
            this.distance = GetKnockbackDistance(Spell.level)
            this.knockback = GetKnockbackDuration(Spell.level)
            this:model(KNOCKBACK_MODEL)
            this:duration(CHARGE_TIME)

            this.onPeriod = function()
                SetUnitX(this.source, this.x)
                SetUnitY(this.source, this.y)

                return false
            end
            
            this.onHit = function(unit)
                if ChargeFilter(this.owner, unit) then
                    if UnitDamageTarget(this.source, unit, this.damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, nil) then
                        KnockbackUnit(unit, AngleBetweenCoordinates(this.x, this.y, GetUnitX(unit), GetUnitY(unit)), this.distance, this.knockback, KNOCKBACK_MODEL, KNOCKBACK_ATTACH, true, true, false, false)
                    end
                end

                return false
            end
            
            this.onFinish = function()
                BlzPauseUnitEx(this.source, false)
                SetUnitTimeScale(this.source, 1)
                SetUnitAnimation(this.source, "Stand")

                return true
            end

            BlzPauseUnitEx(Spell.source.unit, true)
            SetUnitTimeScale(Spell.source.unit, TIME_SCALE)
            SetUnitAnimationByIndex(Spell.source.unit, ANIMATION_INDEX)
            
            this:launch()
        end)
    end)
end