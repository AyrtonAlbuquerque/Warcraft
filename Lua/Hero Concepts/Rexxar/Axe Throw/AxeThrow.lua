--[[requires SpellEffectEvent, PluginSpellEffect, Missiles, Utilities, CrowdControl
    /* ----------------------- Axe Throw v1.1 by Chopinski ---------------------- */
    // Credits:
    //     -Berz-          - Icon
    //     Bribe           - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY   = FourCC('A001')
    -- The missile model
    local MODEL     = "Abilities\\Weapons\\RexxarMissile\\RexxarMissile.mdl"
    -- The missile scale
    local SCALE     = 1.2
    -- The missile speed
    local SPEED     = 1200
    -- The missile hit model
    local HIT_MODEL = "Objects\\Spawnmodels\\Orc\\Orcblood\\OrdBloodWyvernRider.mdl"
    -- The hit model attachment point
    local ATTACH    = "origin"

    -- The number  of axes
    local function GetAxeCount(level)
        return 2 + 0.*level
    end

    -- The missile curve
    local function GetCurve(level)
        return 10. + 0.*level
    end

    -- The missile arc
    local function GetArc(level)
        return 0. + 0.*level
    end

    -- The missile collision size
    local function GetAoE(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The missile damage
    local function GetDamage(source, level)
        return 50. + 50.*level
    end

    -- The missile slow amount
    local function GetSlowAmount(level)
        return 0.1 + 0.1*level
    end

    -- The slow duration
    local function GetSlowDuration(level)
        return 2. + 0.*level
    end

    -- The cooldown reduction when killing units
    local function GetCooldownReduction(level)
        return 0.5 + 0.*level
    end

    -- The damage filter units
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local angle = 1

            for i = 1, GetAxeCount(Spell.level) do
                local this = Missiles:create(Spell.source.x, Spell.source.y, 100, Spell.x, Spell.y, 100)
                this:model(MODEL)
                this:scale(SCALE)
                this:speed(SPEED)
                this.deflected = false
                this.source = Spell.source.unit
                this.owner = Spell.source.player
                this:arc(GetArc(Spell.level))
                this:curve(angle*GetCurve(Spell.level))
                this.collision = GetAoE(Spell.source.unit, Spell.level)
                this.damage = GetDamage(Spell.source.unit, Spell.level)
                this.slow = GetSlowAmount(Spell.level)
                this.time = GetSlowDuration(Spell.level)
                this.reduction = GetCooldownReduction(Spell.level)
                angle = -angle

                this.onHit = function(unit)
                    if UnitAlive(unit) then
                        if DamageFilter(this.owner, unit) then
                            if UnitDamageTarget(this.source, unit, this.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                                DestroyEffect(AddSpecialEffectTarget(HIT_MODEL, unit, ATTACH))
                                if not UnitAlive(unit) then
                                    StartUnitAbilityCooldown(this.source, ABILITY, BlzGetUnitAbilityCooldownRemaining(this.source, ABILITY) - this.reduction)
                                else
                                    SlowUnit(unit, this.slow, this.time, nil, nil, false)
                                end
                            end
                        end
                    end

                    return false
                end

                this.onFinish = function()
                    if not this.deflected then
                        this.deflected = true
                        this:deflectTarget(this.source)
                    end

                    return false
                end

                this:launch()
            end
        end)
    end)
end