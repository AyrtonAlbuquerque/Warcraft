OnInit("BreathOfFire", function(requires)
    requires "Class"
    requires "Bonus"
    requires "Dummy"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires.optional "KegSmash"

    -- ---------------------------- Breath of Fire v1.5 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The Breath of Fire Ability
    BreathOfFire_ABILITY    = S2A('Chn3')
    -- The Breath of Fire model
    local MODEL             = "BreathOfFire.mdl"
    -- The Breath of Fire scale
    local SCALE             = 0.75
    -- The Breath of Fire Missile speed
    local SPEED             = 500.
    -- The Breath of Fire DoT period
    local PERIOD            = 1.
    -- The Breath of Fire DoT model
    local DOT_MODEL         = "Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl"
    -- The Breath of Fire DoT model attach point
    local ATTACH            = "origin"

    -- The Breath of Fire final AoE
    local function GetFinalArea(level)
        return 400. + 0.*level
    end

    -- The Breath of Fire cone width
    local function GetCone(level)
        return 60. + 0.*level
    end

    -- The Breath of Fire DoT/Brew Cloud ignite duration
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, BreathOfFire_ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The Breath of Fire travel distance, by default the ability cast range
    local function GetDistance(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, BreathOfFire_ABILITY), ABILITY_RLF_CAST_RANGE, level - 1)
    end

    -- The Breath of Fire DoT damage
    local function GetDoTDamage(source, level)
        return 10. * level + 0.25 * GetUnitBonus(source, BONUS_SPELL_POWER)
    end

    -- The Breath of Fire Brew Cloud ignite damage
    local function GetIgniteDamage(source, level)
        return 25. * level + 0.5 * GetUnitBonus(source, BONUS_SPELL_POWER)
    end

    -- The Breath of Fire Brew Cloud ignite damage interval
    local function GetIgniteInterval(level)
        return 1. + 0.*level
    end

    -- The Breath of Fire Damage
    local function GetDamage(source, level)
        return 50. + 50.*level + 0.75 * GetUnitBonus(source, BONUS_SPELL_POWER)
    end

    -- The Breath of Fire armor reduction
    local function GetArmorReduction(level)
        return 5 + 0*level
    end

    -- The Breath of Fire Damage Filter for enemy units
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        DoT = Class()

        local array = {}

        function DoT:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyEffect(self.effect)

            array[self.target] = nil

            self.timer = nil
            self.target = nil
            self.source = nil
            self.effect = nil
        end

        function DoT.create(source, target, level)
            local self = array[target]

            if not self then
                self = DoT.allocate()
                
                self.source = source
                self.target = target
                self.timer = CreateTimer()
                self.damage = GetDoTDamage(source, level)
                self.effect = AddSpecialEffectTarget(DOT_MODEL, target, ATTACH)
                array[target] = self

                if KegSmash then
                    if GetUnitAbilityLevel(target, KegSmash_BUFF) > 0 then
                        LinkBonusToBuff(target, BONUS_ARMOR, -GetArmorReduction(level), KegSmash_BUFF)
                    end
                end

                TimerStart(self.timer, PERIOD, true, function()
                    self.duration = self.duration - PERIOD

                    if self.duration > 0 then
                        if UnitAlive(self.target) then
                            if KegSmash then
                                if GetUnitAbilityLevel(self.target, KegSmash_BUFF) > 0 then
                                    UnitDamageTarget(self.source, self.target, 2*self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                                else
                                    UnitDamageTarget(self.source, self.target, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                                end
                            else
                                UnitDamageTarget(self.source, self.target, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                            end
                        else
                            self:destroy()
                        end
                    else
                        self:destroy()
                    end
                end)
            end

            self.duration = GetDuration(source, level)

            return self
        end
    end

    do
        Wave = Class(Missile)

        function Wave:onUnit(unit)
            if IsUnitInCone(unit, self.centerX, self.centerY, self.distance, self.face, self.fov) then
                if DamageFilter(self.owner, unit) then
                    if UnitDamageTarget(self.source, unit, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        DoT.create(self.source, unit, self.level)
                    end
                end
            end

            return false
        end

        function Wave:onPeriod()
            if KegSmash then
                GroupEnumUnitsOfPlayer(self.group, self.owner, nil)

                local unit = FirstOfGroup(self.group)

                while unit do
                    if GetUnitTypeId(unit) == Dummy.type and BrewCloud.active(unit) then
                        local d = DistanceBetweenCoordinates(self.x, self.y, GetUnitX(unit), GetUnitY(unit))

                        if d <= self.collision + KegSmash_GetAoE(self.source, self.level)/2 and IsUnitInCone(unit, self.centerX, self.centerY, 2*self.distance, self.face, 180) then
                            BrewCloud.ignite(unit, self.ignite_damage, self.ignite_duration, self.ignite_interval)
                        end
                    end

                    GroupRemoveUnit(self.group, unit)
                    unit = FirstOfGroup(self.group)
                end
            end

            return false
        end

        function Wave:onRemove()
            DestroyGroup(self.group)
            self.group = nil
        end
    end

    do
        BreathOfFire = Class(Spell)

        function BreathOfFire:onTooltip(unit, level, ability)
            return "|cffffcc00Chen|r breathes fire in a cone, dealing |cff00ffff" .. N2S(GetDamage(unit, level), 0) .. "|r |cff00ffffMagic|r damage to enemy units and setting them on fire, dealing |cff00ffff" .. N2S(GetDoTDamage(unit, level), 0) .. "|r |cff00ffffMagic|r damage every |cffffcc00" .. N2S(GetIgniteInterval(level), 1) .. "|r second. If the unit is under the effect of |cffffcc00Drunken Haze|r, the |cffffcc00DoT|r damage is doubled and reduces the unit armor by |cffffcc00" .. N2S(GetArmorReduction(level), 0) .. "|r. In addition, if the fire wave comes in contact with a |cffffcc00Brew Cloud|r it will ignite it, setting the terrain on fire, dealing |cff00ffff" .. N2S(GetIgniteDamage(unit, level), 0) .. "|r |cff00ffffMagic|r damage per second to enemy units within range.\n\nLasts |cffffcc00" .. N2S(GetDuration(unit, level), 0) .. "|r seconds."
        end

        function BreathOfFire:onCast()
            local distance = GetDistance(Spell.source.unit, Spell.level)
            local angle = AngleBetweenCoordinates(Spell.source.x, Spell.source.y, Spell.x, Spell.y)
            local effect = AddSpecialEffectEx(MODEL, Spell.source.x, Spell.source.y, 0, SCALE)
            local wave = Wave.create(Spell.source.x, Spell.source.y, 0, Spell.source.x + distance * math.cos(angle), Spell.source.y + distance * math.sin(angle), 0)

            wave.speed = SPEED
            wave.level = Spell.level
            wave.distance = distance
            wave.face = angle * bj_RADTODEG
            wave.source = Spell.source.unit 
            wave.owner = Spell.source.player
            wave.centerX = Spell.source.x
            wave.centerY = Spell.source.y
            wave.group = CreateGroup()
            wave.fov = GetCone(Spell.level)
            wave.damage = GetDamage(Spell.source.unit, Spell.level)
            wave.collision = GetFinalArea(Spell.level)
            wave.ignite_damage = GetIgniteDamage(Spell.source.unit, Spell.level)
            wave.ignite_duration = GetDuration(Spell.source.unit, Spell.level)
            wave.ignite_interval = GetIgniteInterval(Spell.level)

            BlzSetSpecialEffectYaw(effect, angle)
            DestroyEffect(effect)
            wave:launch()
        end

        function BreathOfFire.onInit()
            RegisterSpell(BreathOfFire.allocate(), BreathOfFire_ABILITY)
        end
    end
end)