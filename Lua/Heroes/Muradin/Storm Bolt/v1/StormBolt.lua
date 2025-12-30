OnInit("StormBolt", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Missiles"
    requires "Utilities"
    requires "TimedHandles"
    requires.optional "Avatar"

    -- ------------------------------------ Storm Bolt v1.4 ------------------------------------ --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Storm Bolt ability
    StormBolt_ABILITY            = S2A('Mrd8')
    -- The raw code of the Storm Bolt Double Thunder ability
    StormBolt_STORM_BOLT_RECAST  = S2A('MrdA')
    -- The missile model
    local MISSILE_MODEL          = "Abilities\\Spells\\Human\\StormBolt\\StormBoltMissile.mdl"
    -- The missile size
    local MISSILE_SCALE          = 1.
    -- The missile speed
    local MISSILE_SPEED          = 1250.
    -- The model used when storm bolt deal bonus damage
    local BONUS_DAMAGE_MODEL     = "ShockHD.mdl"
    -- The model used when storm bolt refunds mana on kill
    local REFUND_MANA            = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl"
    -- The attachment point of the bonus dmaage model
    local ATTACH_POINT           = "origin"
    -- The model used when storm bolt stuns a unit
    local STUN_MODEL             = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
    -- The attachment point of the stun model
    local STUN_POINT             = "overhead"

    -- The storm bolt damage
    function StormBolt_GetDamage(source, level)
        if Bonus then
            return 150. + 50.*level + (1.1 + 0.1*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 150. + 50.*level
        end
    end

    -- The storm bolt damage when the target is already stunned
    function StormBolt_GetBonusDamage(damage, level)
        return 0.25 * level
    end

    -- The storm bolt stun duration
    local function GetDuration(source, target, level)
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, StormBolt_ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, StormBolt_ABILITY), ABILITY_RLF_DURATION_NORMAL, level - 1)
        end
    end

    -- The storm bolt mana refunded
    function StormBolt_GetMana(unit, level)
        return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, StormBolt_ABILITY), ABILITY_ILF_MANA_COST, level - 1)*0.5
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Hammer = Class(Missile)

        function Hammer:onFinish()
            if UnitAlive(self.target) then
                if IsUnitStunned(self.target) then
                    self.damage = self.damage * (1 + StormBolt_GetBonusDamage(self.level))
                    self.bonus  = true
                end

                if UnitDamageTarget(self.source, self.target, self.damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                    if self.bonus then
                        DestroyEffect(AddSpecialEffectTarget(BONUS_DAMAGE_MODEL, self.target, ATTACH_POINT))
                    end

                    if not UnitAlive(self.target) then
                        AddUnitMana(self.source, self.mana)
                        DestroyEffectTimed(AddSpecialEffectTarget(REFUND_MANA, self.source, ATTACH_POINT), 1.0)

                        if Avatar then
                            if GetUnitAbilityLevel(self.source, Avatar_BUFF) > 0 then
                                ResetUnitAbilityCooldown(self.source, StormBolt_ABILITY)
                            end
                        end
                    else
                        StunUnit(self.target, self.time, STUN_MODEL, STUN_POINT, false)
                    end
                end
            end

            return true
        end
    end

    do
        StormBolt = Class(Spell)

        function StormBolt:onTooltip(source, level, ability)
            return "|cffffcc00Muradin|r throw his hammer at an enemy unit, dealing |cff00ffff" .. N2S(StormBolt_GetDamage(source, level), 0) .. "|r |cff00ffffMagic|r damage and stunning the target for |cffffcc003|r seconds (|cffffcc001|r on |cffffcc00Heroes|r). If the target is already stunned, |cffffcc00Storm Bolt|r will do |cffffcc00" .. N2S(StormBolt_GetBonusDamage(level), 0) .. "%%|r bonus damage. In addintion, if |cffffcc00Storm Bolt|r kills the target, |cffffcc0050%|r of its mana cost is refunded."
        end

        function StormBolt:onCast()
            local hammer = Hammer.create(Spell.source.x, Spell.source.y, 60, Spell.target.x, Spell.target.y, 60)

            hammer.source = Spell.source.unit
            hammer.target = Spell.target.unit
            hammer.model = MISSILE_MODEL
            hammer.speed = MISSILE_SPEED
            hammer.scale = MISSILE_SCALE
            hammer.level = GetUnitAbilityLevel(Spell.source.unit, StormBolt_ABILITY)
            hammer.damage = StormBolt_GetDamage(Spell.source.unit, hammer.level)
            hammer.time = GetDuration(Spell.source.unit, Spell.target.unit, hammer.level)
            hammer.mana = StormBolt_GetMana(Spell.source.unit, hammer.level)

            hammer:launch()
        end

        function StormBolt.onInit()
            RegisterSpell(StormBolt.allocate(), StormBolt_ABILITY)
            RegisterSpell(StormBolt.allocate(), StormBolt_STORM_BOLT_RECAST)
        end
    end
end)