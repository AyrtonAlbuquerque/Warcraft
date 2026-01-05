OnInit("WhirlwindSpin", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "Bonus"

    -- ---------------------------- WhirlwindSpin v1.3 by Chopinski ---------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY          = S2A('Yul2')
    -- The Model
    local MODEL            = "DragonSpin.mdl"
    -- The model scale
    local SCALE            = 0.6
    -- The knock back model
    local KNOCKBACK_MODEL  = "WindBlow.mdl"
    -- The knock back attachment point
    local ATTACH_POINT     = "origin"

    -- The AOE
    local function GetAoE(unit, level)
         return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The Damage dealt
    local function GetDamage(source, level)
        if Bonus then
            return 75. + 75. * level + (0.9 + 0.1*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 75. + 75. * level
        end
    end

    -- The Knock Back duration
    local function GetKnockBackDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end
    
    -- The caster time scale. Speed or slow down aniamtions.
    local function GetTimeScale(unit, level)
        return 3.
    end
    
    -- The amoount of time until time scale is reset
    local function GetTimeScaleTime(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_FOLLOW_THROUGH_TIME, level - 1)
    end

    -- The Damage Filter.
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        WhirlwindSpin = Class(Spell)

        function WhirlwindSpin:destroy()
            SetUnitTimeScale(self.unit, 1)
            
            self.unit = nil
        end

        function WhirlwindSpin:onTooltip(source, level, ability)
            return "|cffffcc00Yu'lon|r violently spins around it's location creating an outward force that deals |cff00ffff" .. N2S(GetDamage(source, level), 0) .. "|r Magic damage. and pushes all enemy units back. Additionaly, |cffffcc00Whirlwind Spin|r resets |cffffcc00Dragon Dash|r cooldown."
        end

        function WhirlwindSpin:onCast()
            local group = CreateGroup()
            local damage = GetDamage(Spell.source.unit, Spell.level)
            local aoe = GetAoE(Spell.source.unit, Spell.level)
            local duration = GetKnockBackDuration(Spell.source.unit, Spell.level)

            if DragonDash then
                ResetUnitAbilityCooldown(Spell.source.unit, DragonDash_ABILITY)
            end

            DestroyEffect(AddSpecialEffectEx(MODEL, Spell.source.x, Spell.source.y, 0, SCALE))
            GroupEnumUnitsInRange(group, Spell.source.x, Spell.source.y, aoe, nil)

            local u = FirstOfGroup(group)

            while u do
                if DamageFilter(Spell.source.player, u) then
                    local x = GetUnitX(u)
                    local y = GetUnitY(u)
                    local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, x, y)
                    local distance = DistanceBetweenCoordinates(Spell.source.x, Spell.source.y, x, y)
                    
                    if UnitDamageTarget(Spell.source.unit, u, damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        KnockbackUnit(u, angle, aoe - distance, duration, KNOCKBACK_MODEL, ATTACH_POINT, true, true, false, false)
                    end
                end

                GroupRemoveUnit(group, u)
                u = FirstOfGroup(group)
            end

            DestroyGroup(group)
            
            local this = { destroy = WhirlwindSpin.destroy }

            this.unit = Spell.source.unit
            
            SetUnitTimeScale(this.unit, GetTimeScale(this.unit, Spell.level))
            TimerStart(CreateTimer(), GetTimeScaleTime(this.unit, Spell.level), false, function ()
                this:destroy()
                DestroyTimer(GetExpiredTimer())
            end)
        end

        function WhirlwindSpin.onInit()
            RegisterSpell(WhirlwindSpin.allocate(), ABILITY)
        end
    end
end)