OnInit("FelBlast", function (requires)
    requires "Class"
    requires "Spell"
    requires "Utilities"
    requires.optional "Bonus"
    requires.optional "FelBeam"

    -- ------------------------------ Fel Blast v1.6 by Chopinski ------------------------------ --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the fel blast ability
    local ABILITY       = S2A('Mnr4')
    -- The amount of time it takes to do the damage
    local BLAST_DELAY   = 0.75
    -- The blast model
    local BLAST_MODEL   = "NetherBlast.mdx"
    -- The size of the blast model
    local BLAST_SCALE   = 1.
    -- The Attack type of the damage dealt (Spell)
    local ATTACK_TYPE   = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt 
    local DAMAGE_TYPE   = DAMAGE_TYPE_MAGIC

    -- The damage amount of the blast
    local function GetDamage(unit, level)
        if Bonus then
            return 50. * level + GetHeroStr(unit, true) * (1 + 0.25*level) + 0.5 * GetUnitBonus(unit, BONUS_SPELL_POWER)
        else
            return 50. * level + GetHeroStr(unit, true) * (1 + 0.25*level)
        end
    end

    -- The damage area of effect. By default is the ability AoE field in the editor
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The filter for units that will be damaged by the fel blast
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        FelBlast = Class(Spell)

        function FelBlast:destroy()
            self.unit = nil
            self.owner = nil
        end

        function FelBlast:onTooltip(source, level, ability)
            return "|cffffcc00Mannoroth|r blasts the target area with Fel Fire dealing |cff00ffff" .. N2S(GetDamage(source, level), 0) .. "|r |cff00ffffMagic|r damage and cursing all enemy units within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. " AoE|r with |cffffcc00Fel Curse|r. When a unit affected by |cffffcc00Fel Curse|r dies, it will spawn a |cffffcc00Fel Beam|r to a random target within |cffffcc001000 AoE|r."
        end

        function FelBlast:onCast()
            local this = FelBlast.allocate()

            this.x = Spell.x
            this.y = Spell.y
            this.unit = Spell.source.unit
            this.owner  = Spell.source.player
            this.damage = GetDamage(this.unit, Spell.level)
            this.radius = GetAoE(this.unit, Spell.level)

            if FelBeam then
                this.armor = FelBeam_GetArmorReduction(GetUnitAbilityLevel(this.unit, FelBeam_ABILITY))
                this.duration = FelBeam_GetCurseDuration(GetUnitAbilityLevel(this.unit, FelBeam_ABILITY))
            end
        
            DestroyEffect(AddSpecialEffectEx(BLAST_MODEL, this.x, this.y, 0, BLAST_SCALE))
            TimerStart(CreateTimer(), BLAST_DELAY, false, function ()
                local group = GetEnemyUnitsInRange(this.owner, this.x, this.y, this.radius, false, false)
                local u = FirstOfGroup(group)

                while u do
                    if DamageFilter(this.owner, u) then
                        if FelBeam then
                            Curse.cursed[u] = true
                            FelBeam.source[u] = this.unit

                            Curse.create(u, this.duration, this.armor)
                        end

                        UnitDamageTarget(this.unit, u, this.damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, nil)
                    end

                    GroupRemoveUnit(group, u)
                    u = FirstOfGroup(group)
                end

                DestroyGroup(group)
                DestroyTimer(GetExpiredTimer())
                this:destroy()
            end)
        end

        function FelBlast.onInit()
            RegisterSpell(FelBlast.allocate(), ABILITY)
        end
    end
end)