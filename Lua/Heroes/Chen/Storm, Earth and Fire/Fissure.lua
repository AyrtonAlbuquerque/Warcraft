OnInit("Fissure", function(requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "Bonus"
    
    -- ------------------------------- Fissure v1.5 by CHopinski ------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of Fissure ability
    Fissure_ABILITY   = S2A('ChnB')
    -- The pathing blocker raw code
    local BLOCKER     = S2A('YTpc')
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
    -- The Fissure stun model
    local STUN_MODEL  = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
    -- The Fissure stun model attach point
    local STUN_ATTACH = "overhead"

    -- The Fissure travel distance, by default the ability cast range
    local function GetDistance(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, Fissure_ABILITY), ABILITY_RLF_CAST_RANGE, level - 1)
    end

    -- The number of bounces
    local function GetStunTime(level)
        return 1. + 0.*level
    end

    -- The damage
    local function GetDamage(source, level)
        if Bonus then
            return 250. * level + 1.5 * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 250. * level
        end
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
    
    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Fissure = Class(Missile)

        function Fissure:onPeriod()
            self.offset = self.offset + self.speed * Missile.period

            if self.offset >= 96 then
                local effect = AddSpecialEffectEx(MODEL, self.x, self.y, 0, SCALE)
                self.offset = 0

                DestroyEffect(AddSpecialEffectEx(BIRTH_MODEL, self.x, self.y, 0, BIRTH_SCALE))
                BlzSetSpecialEffectYaw(effect, self.face)
                DestroyEffectTimed(effect, self.time - 5)
                RemoveDestructableTimed(CreateDestructable(BLOCKER, self.x, self.y, self.face*bj_RADTODEG, 1, 0), self.time)
            end

            return false
        end

        function Fissure:onUnit(unit)
            if DamageFilter(self.owner, unit) then
                if UnitDamageTarget(self.source, unit, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                    StunUnit(unit, self.stun, STUN_MODEL, STUN_ATTACH, false)
                end
            end

            return false
        end

        function Fissure.onCast()
            local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local distance = GetDistance(Spell.source.unit, Spell.level)
            local self = Fissure.create(Spell.source.x, Spell.source.y, 0, Spell.source.x + distance * math.cos(angle), Spell.source.y + distance * math.sin(angle), 0)

            self.face = angle
            self.speed = SPEED
            self.offset = 0
            self.source = Spell.source.unit
            self.owner = Spell.source.player
            self.damage = GetDamage(Spell.source.unit, Spell.level)
            self.collision = GetAoE(Spell.level)     
            self.stun = GetStunTime(Spell.level)
            self.time = GetFissureDuration(Spell.level)

            self:launch()
        end

        function Fissure.onInit()
            RegisterSpellEffectEvent(Fissure_ABILITY, Fissure.onCast)
        end
    end
end)