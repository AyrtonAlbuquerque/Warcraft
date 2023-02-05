--[[ requires SpellEffectEvent, Utilities, Missiles, CrowdControl optional BlackArrow
    -- ------------------------------------- Forseken Arrow v1.4 ------------------------------------ --
    -- Credits:
    --     Bribe          - SpellEffectEvent
    --     Darkfang       - Icon
    --     AZ             - Arrow model
    --     JetFangInferno - Dark Nova model
    -- ---------------------------------------- By Chopinski ---------------------------------------- --
]]--

do
    -- ---------------------------------------------------------------------------------------------- --
    --                                          Configuration                                         --
    -- ---------------------------------------------------------------------------------------------- --a
    -- The raw code of the Screaming Banshees ability
    local ABILITY         = FourCC('A00K')
    -- The missile model
    local MISSILE_MODEL   = "DeathShot.mdl"
    -- The missile size
    local MISSILE_SCALE   = 0.8
    -- The missile speed
    local MISSILE_SPEED   = 2000.
    -- The Explosion model
    local EXPLOSION_MODEL = "DarkNova.mdl"
    -- The Explosion size
    local EXPLOSION_SCALE = 0.5
    -- The fear model
    local FEAR_MODEL      = "Fear.mdl"
    -- The the fear attachment point
    local ATTACH_FEAR     = "overhead"
    -- The attack type of the damage dealt
    local ATTACK_TYPE     = ATTACK_TYPE_NORMAL  
    -- The damage type of the damage dealt
    local DAMAGE_TYPE     = DAMAGE_TYPE_MAGIC

    -- The Explosion AoE
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The duration of the Fear, Silence and Slow. By Defauklt its the field value in the abiltiy
    local function GetDuration(caster, target, level)
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(caster, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(caster, ABILITY), ABILITY_RLF_DURATION_NORMAL, level - 1)
        end
    end

    -- The slow amount
    local function GetSlow(unit, level)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
            return 0.5 + 0.*level
        else
            return 0.5 + 0.*level
        end
    end

    -- The damage when passing through units
    local function GetCollisionDamage(unit, level)
        return level*GetHeroAgi(unit, true)*0.5 + level*250
    end

    -- The damage when exploding
    local function GetExplosionDamage(unit, level)
        return level*GetHeroAgi(unit, true)*0.5 + level*250
    end

    -- The missile collision size
    local function GetCollisionSize(level)
        return 200. + 0.*level
    end

    -- Filter
    local function Filtered(player, unit)
        return IsUnitEnemy(unit, player) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- ---------------------------------------------------------------------------------------------- --
    --                                             System                                             --
    -- ---------------------------------------------------------------------------------------------- --
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local this = Missiles:create(Spell.source.x, Spell.source.y, 50, Spell.x, Spell.y, 50)

            this:speed(MISSILE_SPEED)
            this:model(MISSILE_MODEL)
            this:scale(MISSILE_SCALE)
            this.source = Spell.source.unit
            this.level = Spell.level
            this.owner = Spell.source.player
            this.aoe = GetAoE(Spell.source.unit, Spell.level)
            this.damage = GetCollisionDamage(Spell.source.unit, Spell.level)
            this.collision = GetCollisionSize(Spell.level)
            this.exp_damage = GetExplosionDamage(Spell.source.unit, Spell.level)

            if BlackArrow then
                this.curse_level = GetUnitAbilityLevel(Spell.source.unit, BlackArrow_ABILITY)
                this.ability = BlackArrow_BLACK_ARROW_CURSE
                this.curse = this.curse_level > 0
                this.curse_duration = BlackArrow_GetCurseDuration(this.curse_level)
            else
                this.curse = false
            end

            this.onHit = function(unit)
                if Filtered(this.owner, unit) then
                    if UnitDamageTarget(this.source, unit, this.damage, true, false, ATTACK_TYPE, DAMAGE_TYPE, nil) and this.curse then
                        if BlackArrow then
                            BlackArrow:curse(unit, this.source, this.owner)
                        end
                    end
                end

                return false
            end
            
            this.onFinish = function()
                local group = CreateGroup()

                DestroyEffect(AddSpecialEffectEx(EXPLOSION_MODEL, this.x, this.y, this.z, EXPLOSION_SCALE))
                GroupEnumUnitsInRange(group, this.x, this.y, this.aoe, nil)
                for i = 0, BlzGroupGetSize(group) - 1 do
                    local unit = BlzGroupUnitAt(group, i)
                    if Filtered(this.owner, unit) then
                        if UnitDamageTarget(this.source, unit, this.exp_damage, true, false, ATTACK_TYPE, DAMAGE_TYPE, nil) then
                            local duration = GetDuration(this.source, unit, this.level)

                            if BlackArrow then
                                if this.curse then
                                    BlackArrow:curse(unit, this.source, this.owner)
                                end
                            end

                            FearUnit(unit, duration, FEAR_MODEL, ATTACH_FEAR, false)
                            SilenceUnit(unit, duration, nil, nil, false)
                            SlowUnit(unit, GetSlow(unit, this.level), duration, nil, nil, false)
                        end
                    end
                end
                DestroyGroup(group)

                return true
            end

            this:launch()
        end)
    end)
end