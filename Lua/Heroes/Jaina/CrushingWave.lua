--[[ requires SpellEffectEvent, PluginSpellEffect, Missiles, Utilities, CrowdControl optional WaterElemental
    /* --------------------- Crushing Wave v1.1 by Chopinski -------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY   = FourCC('A001')
    -- The Wave model
    local MODEL     = "LivingTide.mdl"
    -- The Wave speed
    local SPEED     = 1250
    -- The wave model scale
    local SCALE     = 0.8

    -- The wave damage
    local function GetDamage(unit, level)
        return 50. + 50.*level
    end

    -- The Wave collision
    local function GetCollision(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The water elemental search range
    local function GetAoE(unit, level)
        return 1000. + 0.*level
    end

    -- The wave travel distance
    local function GetTravelDistance(unit, level)
        return 1000. + 0.*level
    end

    -- The Wave slow amount
    local function GetSlowAmount(unit, level)
        return 0.1 + 0.1*level
    end

    -- The Slow duration
    local function GetSlowDuration(unit, level)
        return 1. + 0.25*level
    end

    -- The damae filter
    local function UnitFilter(player, target)
        return UnitAlive(target) and IsUnitEnemy(target, player) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    do
        local function launch(x, y, z, tx, ty, tz, source, player, level, elemental)
            local this = Missiles:create(x, y, z, tx, ty, tz)

            this:model(MODEL)
            this:scale(SCALE)
            this:speed(SPEED)
            this.source = source
            this.owner = player
            this.unit = elemental
            this.damage = GetDamage(source, level)
            this.collision = GetCollision(source, level)
            this.slow = GetSlowAmount(source, level)
            this.timeout = GetSlowDuration(source, level)

            if elemental then
                BlzSetUnitFacingEx(elemental, AngleBetweenCoordinates(x, y, tx, ty)*bj_RADTODEG)
                PauseUnit(elemental, true)
                SetUnitAnimationByIndex(elemental, 8)
                SetUnitInvulnerable(elemental, true)
            end

            this.onPeriod = function()
                if this.unit then
                    SetUnitX(this.unit, this.x)
                    SetUnitY(this.unit, this.y)
                end

                return false
            end

            this.onHit = function(unit)
                if UnitFilter(this.owner, unit) then
                    if UnitDamageTarget(this.source, unit, this.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        SlowUnit(unit, this.slow, this.timeout, nil, nil, false)
                    end
                end

                return false
            end

            this.onRemove = function()
                if this.unit then
                    PauseUnit(this.unit, false)
                    SetUnitAnimation(this.unit, "Stand")
                    SetUnitInvulnerable(this.unit, false)
                end
            end

            this:launch()
        end

        onInit(function()
            RegisterSpellEffectEvent(ABILITY, function()
                local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
                local offset = GetTravelDistance(Spell.source.unit, Spell.level)

                launch(Spell.source.x, Spell.source.y, 0, Spell.source.x + offset*Cos(angle), Spell.source.y + offset*Sin(angle), 0, Spell.source.unit, Spell.source.player, Spell.level, nil)

                if Elemental then
                    local group = CreateGroup()

                    GroupEnumUnitsInRange(group, Spell.source.x, Spell.source.y, GetAoE(Spell.source.unit, Spell.level), nil)
                    for i = 0, BlzGroupGetSize(group) - 1 do
                        local unit = BlzGroupUnitAt(group, i)
                        if UnitAlive(unit) and GetUnitTypeId(unit) == WaterElemental_ELEMENTAL then
                            if Elemental:owner(unit) == Spell.source.unit then
                                launch(GetUnitX(unit), GetUnitY(unit), 0, Spell.x, Spell.y, 0, Spell.source.unit, Spell.source.player, Spell.level, unit)
                            end
                        end
                    end
                    DestroyGroup(group)
                end
            end)
        end)
    end
end