OnInit("ExplosiveRune", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires.optional "CDR"
    requires.optional "Bonus"
    requires.optional "Afterburner"

    -- ---------------------------- Explosive Rune v1.7 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Explosive Rune Ability
    local ABILITY             = S2A('Rgn1')
    -- The number of charges of the ability
    local CHARGES_COUNT       = 4
    -- The number of charges of the ability
    local CHARGES_COOLDOWN    = 15.0
    -- The Explosion delay
    local EXPLOSION_DELAY     = 1.5
    -- The Explosion effect path
    local EXPLOSION_EFFECT    = "Conflagrate.mdl"
    -- The Attack type of the damage dealt (Spell)
    local ATTACK_TYPE         = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt
    local DAMAGE_TYPE         = DAMAGE_TYPE_MAGIC
    -- If true will damage structures
    local DAMAGE_STRUCTURES   = false
    -- If true will damage allies
    local DAMAGE_ALLIES       = false
    -- If true will damage magic immune unit if the
    -- ATTACK_TYPE is not spell damage
    local DAMAGE_MAGIC_IMMUNE = false

    -- The damage amount of the explosion
    local function GetDamage(source, level)
        if Bonus then
            return (50. + 50.*level) + 0.75*GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return (50. + 50.*level)
        end
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        ExplosiveRune = Class(Spell)

        local array = {}
        local charges = {}

        function ExplosiveRune:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)

            array[self.unit] = nil
            charges[self.unit] = nil

            self.unit = nil
            self.timer = nil
        end

        function ExplosiveRune:onTooltip(source, level, ability)
            return "Ragnaros creates an |cffffcc00Explosive Rune|r in the target location that explodes after |cffffcc00" .. N2S(EXPLOSION_DELAY, 1) .. "|r seconds, dealing |cff00ffff" .. N2S(GetDamage(source, level), 0) .. " Magic|r damage to enemy units within |cffffcc00" .. N2S(BlzGetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, level - 1), 0) .. " AoE|r. Holds up to |cffffcc00" .. I2S(CHARGES_COUNT) .. "|r charges. Gains |cffffcc001|r charge every |cffffcc00" .. N2S(CHARGES_COOLDOWN, 1) .. "|r seconds.\n\nCharges: |cffffcc00" .. I2S(charges[source]) .. "|r"
        end

        function ExplosiveRune:onCast()
            local this = {
                x = Spell.x,
                y = Spell.y,
                unit = Spell.source.unit,
                damage = GetDamage(Spell.source.unit, Spell.level),
                aoe = BlzGetAbilityRealLevelField(Spell.ability, ABILITY_RLF_AREA_OF_EFFECT, Spell.level - 1)
            }

            if (charges[this.unit] or 0) > 0 then
                charges[this.unit] = charges[this.unit] - 1

                if charges[this.unit] >= 1 then
                    ResetUnitAbilityCooldown(this.unit, ABILITY)
                else
                    if CDR then
                        CalculateAbilityCooldown(this.unit, ABILITY, Spell.level, TimerGetRemaining(array[this.unit].timer))
                    else
                        BlzSetAbilityRealLevelField(Spell.ability, ABILITY_RLF_COOLDOWN, Spell.level - 1, TimerGetRemaining(array[this.unit].timer))
                        IncUnitAbilityLevel(this.unit, ABILITY)
                        DecUnitAbilityLevel(this.unit, ABILITY)
                    end
                end
            end

            TimerStart(CreateTimer(), EXPLOSION_DELAY, false, function ()
                if Afterburner then
                    Afterburn(this.x, this.y, this.unit)
                end

                UnitDamageArea(this.unit, this.x, this.y, this.aoe, this.damage, ATTACK_TYPE, DAMAGE_TYPE, DAMAGE_STRUCTURES, DAMAGE_MAGIC_IMMUNE, DAMAGE_ALLIES)
                DestroyEffect(AddSpecialEffect(EXPLOSION_EFFECT, this.x, this.y))
                DestroyTimer(GetExpiredTimer())
            end)
        end

        function ExplosiveRune:onLearn(source, skill, level)
            if not array[source] then
                local this = { destroy = ExplosiveRune.destroy }
                
                this.unit = source
                this.timer = CreateTimer()
                array[source] = this
                charges[source] = CHARGES_COUNT

                TimerStart(this.timer, CHARGES_COOLDOWN, true, function ()
                    if GetUnitAbilityLevel(this.unit, ABILITY) > 0 then
                        if charges[this.unit] < CHARGES_COUNT and charges[this.unit] >= 0 then
                            charges[this.unit] = charges[this.unit] + 1

                            BlzEndUnitAbilityCooldown(this.unit, ABILITY)
                        end
                    else
                        this:destroy()
                    end
                end)
            end
        end

        function ExplosiveRune.onInit()
            RegisterSpell(ExplosiveRune.allocate(), ABILITY)
        end
    end
end)