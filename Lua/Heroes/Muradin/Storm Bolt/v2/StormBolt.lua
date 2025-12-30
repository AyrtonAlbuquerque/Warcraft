OnInit("StormBolt", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "Bonus"

    -- ------------------------------------ Storm Bolt v1.5 ------------------------------------ --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Storm Bolt ability
    StormBolt_ABILITY            = S2A('Mrd9')
    -- The raw code of the Storm Bolt Double Thunder ability
    StormBolt_STORM_BOLT_RECAST  = S2A('MrdB')
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
    function StormBolt_GetDamage(source, level)
        if Bonus then
            return 50. + 50.*level + (1.1 + 0.1*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 50. + 50.*level
        end
    end

    -- The storm bolt damage when the target is already stunned
    function StormBolt_GetBonusDamage(damage, level)
        return 0.25 * level
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

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Hammer = Class(Missile)

        function Hammer:onUnit(unit)
            if UnitAlive(unit) then
                if DamageFilter(self.owner, unit) then
                    self.newDamage = self.damage

                    if IsUnitStunned(unit) or IsUnitSlowed(unit) then
                        self.newDamage = self.damage * (1 + StormBolt_GetBonusDamage(self.level))
                        self.bonus  = true
                    end
    
                    if UnitDamageTarget(self.source, unit, self.newDamage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        SlowUnit(unit, self.slow, self.slowDuration, SLOW_MODEL, SLOW_POINT, false)

                        if self.bonus then
                            DestroyEffect(AddSpecialEffectTarget(BONUS_DAMAGE_MODEL, unit, ATTACH_POINT))
                        end
                    end
                end
            end
            
            return false
        end

        function Hammer:onFinish()
            if not self.deflected then
                self.deflected = true
                
                self:deflectTarget(self.source)
                self:flushAll()
            else
                if ThunderClap then
                    ResetUnitAbilityCooldown(self.source, ThunderClap_ABILITY)
                end
            end

            return false
        end
    end

    do
        StormBolt = Class(Spell)

        StormBolt.x = {}
        StormBolt.y = {}

        function StormBolt:onTooltip(source, level, ability)
            return "|cffffcc00Muradin|r throw his hammer towards a target location. On its way the hammer deals |cff00ffff" .. N2S(StormBolt_GetDamage(source, level), 0) .. "|r |cff00ffffMagic|r damage and slows enemy units by |cffffcc00" .. N2S(GetSlow(level) * 100, 0) .. "%%|r for |cffffcc00" .. N2S(GetSlowDuration(level), 1) .. "|r seconds. Units already under the effect of a |cffd45e19Stun|r or |cffd45e19Slow|r takes |cffffcc00" .. N2S(StormBolt_GetBonusDamage(level) * 100, 0) .. "%%|r bonus damage. Upon reaching the destination the hammer comes back to |cffffcc00Muradin|r. When the hammer finally reaches |cffffcc00Muradin|r the cooldown of |cff00ff00Thunder Clap|r is reseted."
        end

        function StormBolt:onCast()
            local level = GetUnitAbilityLevel(Spell.source.unit, StormBolt_ABILITY)
            local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local distance = GetMinimumDistance(level)
            local hammer

            if DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y) < distance then
                StormBolt.x[Spell.source.unit] = Spell.source.x + distance * math.cos(angle)
                StormBolt.y[Spell.source.unit] = Spell.source.y + distance * math.sin(angle)
                hammer = Hammer.create(Spell.source.x, Spell.source.y, 60, StormBolt.x[Spell.source.unit], StormBolt.y[Spell.source.unit], 60)
            else
                StormBolt.x[Spell.source.unit] = Spell.x
                StormBolt.y[Spell.source.unit] = Spell.y
                hammer = Hammer.create(Spell.source.x, Spell.source.y, 60, Spell.x, Spell.y, 60)
            end

            hammer.source = Spell.source.unit
            hammer.owner = Spell.source.player
            hammer.model = MISSILE_MODEL
            hammer.speed = MISSILE_SPEED
            hammer.scale = MISSILE_SCALE
            hammer.level = level
            hammer.bonus = false
            hammer.deflected = false
            hammer.damage = StormBolt_GetDamage(hammer.source, hammer.level)
            hammer.collision = GetAoE(Spell.source.unit, level)
            hammer.slow = GetSlow(level)
            hammer.slowDuration = GetSlowDuration(level)

            hammer:attach(EXTRA_MODEL, 0, 0, 0, MISSILE_SCALE)
            hammer:launch()
        end

        function StormBolt.onInit()
            RegisterSpell(StormBolt.allocate(), StormBolt_ABILITY)
            RegisterSpell(StormBolt.allocate(), StormBolt_STORM_BOLT_RECAST)
        end
    end
end)