OnInit("CrushingWave", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "Bonus"
    requires.optional "WaterElemental"

    -- ---------------------------- Crushing Wave v1.2 by Chopinski ---------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY   = S2A('Jna1')
    -- The Wave model
    local MODEL     = "LivingTide.mdl"
    -- The Wave speed
    local SPEED     = 1250
    -- The wave model scale
    local SCALE     = 0.8

    -- The wave damage
    local function GetDamage(unit, level)
        if Bonus then
            return 100. + 100.*level + (0.15 + 0.15*level) * GetUnitBonus(unit, BONUS_SPELL_POWER)
        else
            return 100. + 100.*level
        end
    end

    -- The Wave collision
    local function GetCollision(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The water elemental search range
    local function GetAoE(unit, level)
        return 1000. + 0.*level
    end

    -- The wave travel distance
    local function GetTravelDistance(unit, level)
        return 1000. + 0.*level
    end

    -- The Wave slow amount
    local function GetSlowAmount(unit, level)
        return 0.1 + 0.1*level
    end

    -- The Slow duration
    local function GetSlowDuration(unit, level)
        return 1. + 0.25*level
    end

    -- The damae filter
    local function UnitFilter(player, target)
        return UnitAlive(target) and IsUnitEnemy(target, player) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    local Wave = Class(Missile)
    
    do
        function Wave:onUnit(unit)
            if UnitFilter(self.owner, unit) then
                if UnitDamageTarget(self.source, unit, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                    SlowUnit(unit, self.slow, self.timeout, nil, nil, false)
                end
            end

            return false
        end

        function Wave:onRemove()
            if self.unit then
                PauseUnit(self.unit, false)
                SetUnitAnimation(self.unit, "Stand")
                SetUnitInvulnerable(self.unit, false)
            end

            self.unit = nil
        end
    end

    do
        CrushingWave = Class(Spell)

        function CrushingWave.launch(x, y, z, tx, ty, tz, source, owner, level, elemental)
            local wave = Wave.create(x, y, z, tx, ty, tz)
            
            wave.model = MODEL
            wave.scale = SCALE
            wave.speed = SPEED
            wave.source = source
            wave.owner = owner
            wave.unit = elemental
            wave.damage = GetDamage(source, level)
            wave.collision = GetCollision(source, level)
            wave.slow = GetSlowAmount(source, level)
            wave.timeout = GetSlowDuration(source, level)

            if elemental then
                BlzSetUnitFacingEx(elemental, AngleBetweenCoordinates(x, y, tx, ty)*bj_RADTODEG)
                PauseUnit(elemental, true)
                SetUnitAnimationByIndex(elemental, 8)
                SetUnitInvulnerable(elemental, true)
            end

            wave:launch()
        end

        function CrushingWave:onTooltip(source, level, ability)
            return "|cffffcc00Jaina|r creates a |cffffcc00Crushing Wave|r towards the target direction, dealing |cff00ffff" .. N2S(GetDamage(source, level), 0) .. "|r |cff00ffffMagic|r damage and slowing all enemy units caught in it's path by |cffffcc00" .. N2S(GetSlowAmount(source, level) * 100, 0) .. "%%|r  for |cffffcc00" .. N2S(GetSlowDuration(source, level), 2) .. "|r seconds. If there are any of her |cffffcc00Water Elementals|r within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. " AoE|r range when she casts |cffffcc00Crushing Wave|r, the elementals will turn into |cffffcc00Crushing Waves|r themselves applying the same effects and dashing towards the target point."
        end

        function CrushingWave:onCast()
            local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local offset = GetTravelDistance(Spell.source.unit, Spell.level)

            self.launch(Spell.source.x, Spell.source.y, 0, Spell.source.x + offset * math.cos(angle), Spell.source.y + offset * math.sin(angle), 0, Spell.source.unit, Spell.source.player, Spell.level, nil)
            
            if WaterElemental then
                local group = CreateGroup()
                
                GroupEnumUnitsInRange(group, Spell.source.x, Spell.source.y, GetAoE(Spell.source.unit, Spell.level), nil)

                local u = FirstOfGroup(group)

                while u do
                    if UnitAlive(u) and GetUnitTypeId(u) == WaterElemental_ELEMENTAL then
                        if Elemental.owner(u) == Spell.source.unit then
                            self.launch(GetUnitX(u), GetUnitY(u), 0, Spell.x, Spell.y, 0, Spell.source.unit, Spell.source.player, Spell.level, u)
                        end
                    end

                    GroupRemoveUnit(group, u)
                    u = FirstOfGroup(group)
                end

                DestroyGroup(group)
            end
        end

        function CrushingWave.onInit()
            RegisterSpell(CrushingWave.allocate(), ABILITY)
        end
    end
end)