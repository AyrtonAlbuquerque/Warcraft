OnInit("InfernalCharge", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "Bonus"

    -- ---------------------------------- Infernal Charge v1.6 --------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Infernal Charge ability
    local ABILITY          = S2A('Mnr8')
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
    local function GetChargeDamage(source, level)
        if Bonus then
            return 200. + 0.*level + 1. * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 200. + 0.*level
        end
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

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Charge = Class(Missile)

        function Charge:onUnit(unit)
            if ChargeFilter(self.owner, unit) then
                if UnitDamageTarget(self.source, unit, self.damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, nil) then
                    KnockbackUnit(unit, AngleBetweenCoordinates(self.x, self.y, GetUnitX(unit), GetUnitY(unit)), self.distance, self.knockback, KNOCKBACK_MODEL, KNOCKBACK_ATTACH, true, true, false, false)
                end
            end

            return false
        end

        function Charge:onFinish()
            BlzPauseUnitEx(self.source, false)
            SetUnitTimeScale(self.source, 1)
            SetUnitAnimation(self.source, "Stand")

            return true
        end
    end

    do
        InfernalCharge = Class(Spell)

        function InfernalCharge:onTooltip(source, level, ability)
            return "|cffffcc00Pit Infernal|r charges in the pointed direction, knocking back and damaging enemy units, dealing |cff00ffff" .. N2S(GetChargeDamage(source, level), 0) .. "|r |cff00ffffMagic|r damage."
        end

        function InfernalCharge:onCast()
            local charge = Charge.create(Spell.source.x, Spell.source.y, 0, Spell.x, Spell.y, 0)

            charge.unit = Spell.source.unit
            charge.source = Spell.source.unit
            charge.duration = CHARGE_TIME
            charge.model = KNOCKBACK_MODEL
            charge.damage = GetChargeDamage(Spell.source.unit, Spell.level)
            charge.owner = GetOwningPlayer(Spell.source.unit)
            charge.collision = GetChargeAoE(Spell.level)
            charge.distance = GetKnockbackDistance(Spell.level)
            charge.knockback = GetKnockbackDuration(Spell.level)

            BlzPauseUnitEx(Spell.source.unit, true)
            SetUnitTimeScale(Spell.source.unit, TIME_SCALE)
            SetUnitAnimationByIndex(Spell.source.unit, ANIMATION_INDEX)
            charge:launch()
        end

        function InfernalCharge.onInit()
            RegisterSpell(InfernalCharge.allocate(), ABILITY)
        end
    end
end)