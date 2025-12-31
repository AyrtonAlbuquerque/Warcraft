OnInit("AxeThrow", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "Bonus"

    -- ------------------------------ Axe Throw v1.3 by Chopinski ------------------------------ --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY   = S2A('Rex1')
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
        if Bonus then
            return 50. + 50. * level + ((0.4 + 0.1 * level) * GetUnitBonus(source, BONUS_SPELL_POWER)) + ((0.4 + 0.1 * level) * GetUnitBonus(source, BONUS_DAMAGE))
        else
            return 50. + 50. * level
        end
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

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Axe = Class(Missile)

        function Axe:onUnit(unit)
            if UnitAlive(unit) then
                if DamageFilter(self.owner, unit) then
                    if UnitDamageTarget(self.source, unit, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        DestroyEffect(AddSpecialEffectTarget(HIT_MODEL, unit, ATTACH))

                        if not UnitAlive(unit) then
                            StartUnitAbilityCooldown(self.source, ABILITY, BlzGetUnitAbilityCooldownRemaining(self.source, ABILITY) - self.reduction)
                        else
                            SlowUnit(unit, self.slow, self.time, nil, nil, false)
                        end
                    end
                end
            end
            
            return false
        end

        function Axe:onFinish()
            if not self.deflected then
                self.deflected = true
                self:deflectTarget(self.source)
            end
            
            return false
        end
    end

    do
        AxeThrow = Class(Spell)

        function AxeThrow:onTooltip(source, level, ability)
            return "|cffffcc00Rexxar|r thow his axes in an arc, dealing |cff00ffff" .. N2S(GetDamage(source, level), 0) .. "|r |cff00ffffMagic|r damage and slowing enemy units hit by |cffffcc00" .. N2S(GetSlowAmount(level) * 100, 0) .. "%%|r for |cffffcc00" .. N2S(GetSlowDuration(level), 1) .. "|r seconds. Upon reacinhg the targeted destination, the axes return to |cffffcc00Rexxar|r. Every unit killed by the axes reduces cooldown by |cffffcc00" .. N2S(GetCooldownReduction(level), 1) .. "|r seconds."
        end

        function AxeThrow:onCast()
            local a = 1
            
            for i = 0, GetAxeCount(Spell.level) do
                local axe = Axe.create(Spell.source.x, Spell.source.y, 100, Spell.x, Spell.y, 100)

                axe.model = MODEL
                axe.scale = SCALE
                axe.speed = SPEED
                axe.deflected = false
                axe.source = Spell.source.unit
                axe.owner = Spell.source.player
                axe.arc = GetArc(Spell.level)
                axe.curve = a*GetCurve(Spell.level)*bj_DEGTORAD
                axe.collision = GetAoE(Spell.source.unit, Spell.level)
                axe.damage = GetDamage(Spell.source.unit, Spell.level)
                axe.slow = GetSlowAmount(Spell.level)
                axe.time = GetSlowDuration(Spell.level)
                axe.reduction = GetCooldownReduction(Spell.level)
                a = -a
                
                axe:launch()
            end
        end

        function AxeThrow.onInit()
            RegisterSpell(AxeThrow.allocate(), ABILITY)
        end
    end
end)