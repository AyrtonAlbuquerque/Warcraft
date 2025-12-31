OnInit("SulfurasSmash", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missile"
    requires "Utilities"
    requires "CrowdControl"
    requires "TimedHandles"
    requires.optional "Bonus"
    requires.optional "Sulfuras"
    requires.optional "Afterburner"

    -- ---------------------------- Sulfuras Smash v1.7 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Sulfuras Smash ability
    local ABILITY             = S2A('Rgn5')
    -- The landing time of the falling sulfuras
    local LANDING_TIME        = 0.75
    -- The distance from the casting point from 
    -- where the sulfuras spawns
    local LAUNCH_OFFSET       = 3000
    -- The starting height of sufuras
    local START_HEIGHT        = 2000
    -- Sufuras Model
    local SULFURAS_MODEL      = "Sulfuras.mdl"
    -- Sulfuras Impact effect model
    local IMPACT_MODEL        = "Smash.mdl"
    -- The stun model
    local STUN_MODEL          = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
    -- Teh stun model attchement point
    local STUN_POINT          = "overhead"
    -- Sufuras size
    local SULFURAS_SCALE      = 1.5
    -- Size of the impact model
    local IMPACT_SCALE        = 2.
    -- How long will the impact model lasts
    local IMPACT_DURATION     = 10.
    -- The Attack type of the damage dealt (Spell)
    local ATTACK_TYPE         = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt
    local DAMAGE_TYPE         = DAMAGE_TYPE_MAGIC

    -- The stun time for units at the center of impact
    local function GetStunTime(unit)
        if Sulfuras then
            return 1 + 0.25 * R2I((Sulfuras.stacks[unit] or 0) * 0.05)
        else
            return 1.5
        end
    end
    
    -- The AoE for damage, by default is the AoE editor field of the ability
    local function GetNormalAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The AoE for enemies in the center of impact that will be stunned and take doubled damage
    local function GetCenterAoE(level)
        return 200. + 0.*level
    end

    -- Ability impact damage
    local function GetDamage(source, level)
        if Bonus then
            return 250 * level + (0.8 + 0.2 * level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 250 * level
        end
    end

    -- Filter for units that will be damage on impact
    local function DamageFilter(source, target)
        return UnitAlive(target) and IsUnitEnemy(target, GetOwningPlayer(source)) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    local Hammer = Class(Missile)
    
    do
        function Hammer:onFinish()
            local group = CreateGroup()

            GroupEnumUnitsInRange(group, self.x, self.y, GetNormalAoE(self.source, self.level), nil)

            local u = FirstOfGroup(group)

            while u do
                if DamageFilter(self.source, u) then
                    if DistanceBetweenCoordinates(self.x, self.y, GetUnitX(u), GetUnitY(u)) <= self.aoe then
                        if UnitDamageTarget(self.source, u, 2*self.damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, nil) then
                            StunUnit(u, self.stun, STUN_MODEL, STUN_POINT, false)
                        end
                    else
                        UnitDamageTarget(self.source, u, self.damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, nil)
                    end
                end

                GroupRemoveUnit(group, u)
                u = FirstOfGroup(group)
            end

            DestroyGroup(group)
            DestroyEffectTimed(AddSpecialEffectEx(IMPACT_MODEL, self.x, self.y, 0, IMPACT_SCALE), IMPACT_DURATION)

            if Afterburner then
                Afterburn(self.x, self.y, self.ource)
            end

            return true
        end
    end

    do
        SulfurasSmash = Class(Spell)

        function SulfurasSmash:onTooltip(source, level, ability)
            return "|cffffcc00Ragnaros|r hurls |cffffcc00Sulfuras|r at the target area, landing after |cffffcc00" .. N2S(LANDING_TIME, 2) .. " seconds|r and damaging enemy units for |cff00ffff" .. N2S(GetDamage(source, level), 0) .. " Magic|r damage. Enemy units in the center are stunned for |cffffcc00" .. N2S(GetStunTime(source), 2) .. "|r seconds and take twice as much damage."
        end

        function SulfurasSmash:onCast()
            local angle = AngleBetweenCoordinates(Spell.x, Spell.y, GetUnitX(Spell.source.unit), GetUnitY(Spell.source.unit))
            local sulfuras = Hammer.create(Spell.x + LAUNCH_OFFSET*Cos(angle), Spell.y + LAUNCH_OFFSET*Sin(angle), START_HEIGHT, Spell.x, Spell.y, 0)
            
            sulfuras.model = SULFURAS_MODEL
            sulfuras.scale = SULFURAS_SCALE
            sulfuras.duration = LANDING_TIME
            sulfuras.source = Spell.source.unit
            sulfuras.level = Spell.level
            sulfuras.owner = Spell.source.player
            sulfuras.damage = GetDamage(Spell.source.unit, Spell.level)
            sulfuras.stun = GetStunTime(Spell.source.unit)
            sulfuras.aoe = GetCenterAoE(Spell.level)

            sulfuras:launch()
        end

        function SulfurasSmash.onInit()
            RegisterSpell(SulfurasSmash.allocate(), ABILITY)
        end
    end
end)