OnInit("ForsakenArrow", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "Bonus"
    requires.optional "BlackArrow"

    -- ---------------------------------- Forsaken Arrow v1.5 ---------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Screaming Banshees ability
    local ABILITY         = S2A('Svn5')
    -- The missile model
    local MISSILE_MODEL   = "DeathShot.mdl"
    -- The missile size
    local MISSILE_SCALE   = 0.8
    -- The missile speed
    local MISSILE_SPEED   = 2000.
    -- The Explosion model
    local EXPLOSION_MODEL = "DarkNova.mdl"
    -- The Explosion size
    local EXPLOSION_SCALE = 0.5
    -- The fear model
    local FEAR_MODEL      = "Fear.mdl"
    -- The the fear attachment point
    local ATTACH_FEAR     = "overhead"
    -- The attack type of the damage dealt
    local ATTACK_TYPE     = ATTACK_TYPE_NORMAL  
    -- The damage type of the damage dealt
    local DAMAGE_TYPE     = DAMAGE_TYPE_MAGIC
    -- The Black Fire model
    local BURN_MODEL      = "BlackFire.mdl"
    -- The Black Fire size
    local BURN_SCALE      = 0.75

    -- The Explosion AoE
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The duration of the Fear, Silence and Slow. By Defauklt its the field value in the abiltiy
    local function GetDuration(caster, target, level)
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(caster, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(caster, ABILITY), ABILITY_RLF_DURATION_NORMAL, level - 1)
        end
    end

    -- The slow amount
    local function GetSlow(unit, level)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
            return 0.5 + 0.*level
        else
            return 0.5 + 0.*level
        end
    end

    -- The damage when passing through units
    local function GetCollisionDamage(source, level)
        if Bonus then
            return 125 * level + (0.25 * level) * GetHeroAgi(source, true) + 0.25 * level * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 125 * level + (0.25 * level) * GetHeroAgi(source, true)
        end
    end

    -- The damage when exploding
    local function GetExplosionDamage(source, level)
        if Bonus then
            return 250 * level + (0.5 * level) * GetHeroAgi(source, true) + (0.25 + 0.25*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 250 * level + (0.5 * level) * GetHeroAgi(source, true)
        end
    end

    -- The burn damage per second
    local function GetBurnDamage(source, level)
        if Bonus then
            return 75. * level + (0.15 * level * GetUnitBonus(source, BONUS_SPELL_POWER))
        else
            return 75. * level
        end
    end

    -- The burn duration
    local function GetBurnDuration(source, level)
        return 4. + 2.*level
    end

    -- The burn interval
    local function GetBurnInterval(level)
        return 1.0
    end

    -- The missile collision size
    local function GetCollisionSize(level)
        return 200. + 0.*level
    end

    -- Filter
    local function Filtered(player, unit)
        return IsUnitEnemy(unit, player) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        BlackFire = Class()

        function BlackFire:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyEffect(self.effect)
            DestroyGroup(self.group)

            self.unit = nil
            self.timer = nil
            self.group = nil
            self.effect = nil
        end

        function BlackFire.create(source, x, y, damage, aoe, duration)
            local self = BlackFire.allocate()

            self.x = x
            self.y = y
            self.unit = source
            self.aoe = aoe
            self.damage = damage
            self.duration = duration
            self.timer = CreateTimer()
            self.group = CreateGroup()
            self.player = GetOwningPlayer(source)
            self.period = GetBurnInterval(GetUnitAbilityLevel(source, ABILITY))
            self.effect = AddSpecialEffectEx(BURN_MODEL, x, y, 0, BURN_SCALE)

            TimerStart(self.timer, self.period, true, function ()
                self.duration = self.duration - self.period

                if self.duration > 0 then
                    GroupEnumUnitsInRange(self.group, self.x, self.y, self.aoe, nil)

                    local u = FirstOfGroup(self.group)

                    while u do
                         if Filtered(self.player, u) then
                            UnitDamageTarget(self.unit, u, self.damage, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, nil)
                        end

                        GroupRemoveUnit(self.group, u)
                        u = FirstOfGroup(self.group)
                    end
                else
                    self:destroy()
                end
            end)

            return self
        end
    end

    local Arrow = Class(Missile)

    do
        function Arrow:onPeriod()
            self.tick = (self.tick or 0) + 1

            if self.tick == 4 then
                self.tick = 0

                BlackFire.create(self.source, self.x, self.y, GetBurnDamage(self.source, self.level), self.aoe, GetBurnDuration(self.source, self.level))
            end

            return false
        end

        function Arrow:onUnit(unit)
            if Filtered(self.owner, unit) then
                if UnitDamageTarget(self.source, unit, self.damage, true, false, ATTACK_TYPE, DAMAGE_TYPE, nil) and self.curse then
                    if BlackArrow then
                        BlackArrow.curse(unit, self.source, self.owner)
                    end
                end
            end

            return false
        end

        function Arrow:onFinish()
            local group = CreateGroup()

            DestroyEffect(AddSpecialEffectEx(EXPLOSION_MODEL, self.x, self.y, self.z, EXPLOSION_SCALE))
            GroupEnumUnitsInRange(group, self.x, self.y, self.aoe, nil)

            local u = FirstOfGroup(group)

            while u do
                if Filtered(self.owner, u) then
                    if UnitDamageTarget(self.source, u, self.explosion, true, false, ATTACK_TYPE, DAMAGE_TYPE, nil) then
                        local duration = GetDuration(self.source, u, self.level)

                        if BlackArrow then
                            if self.curse then
                                BlackArrow.curse(u, self.source, self.owner)
                            end
                        end

                        SilenceUnit(u, duration, nil, nil, false)
                        FearUnit(u, duration, FEAR_MODEL, ATTACH_FEAR, false)
                        SlowUnit(u, GetSlow(u, self.level), duration, nil, nil, false)
                    end
                end

                GroupRemoveUnit(group, u)
                u = FirstOfGroup(group)
            end

            DestroyGroup(group)
            BlackFire.create(self.source, self.x, self.y, GetBurnDamage(self.source, self.level), self.aoe, GetBurnDuration(self.source, self.level))

            return true
        end
    end

    do
        ForsakenArrow = Class(Spell)

        function ForsakenArrow:onTooltip(source, level, ability)
            return "|cffffcc00Sylvanas|r shoots a |cffffcc00Forsaken Arrow|r at the targeted area. On its path any enemy unit that comes in contact with it gets cursed and takes |cff00ffff" .. N2S(GetCollisionDamage(source, level), 0) .. "|r |cff00ffffMagic|r damage. The arrow also leaves a trail of |cffffcc00Black Fire|r that burns enemy units for |cffd45e19" .. N2S(GetBurnDamage(source, level), 0) .. " True|r damage per second for |cffffcc00" .. N2S(GetBurnDuration(source, level), 1) .. "|r seconds.  When it reaches its destination the |cffffcc00Forsaken Arrow|r explodes, dealing |cff00ffff" .. N2S(GetExplosionDamage(source, level), 0) .. "|r |cff00ffffMagic|r damage, |cffffcc00fearing, silencing and slowing|r all enemies whithin |cffffcc00" .. N2S(GetAoE(source, level), 0) .. "|r AoE for |cffffcc005|r (|cffffcc002.5|r for Heroes) seconds."
        end

        function ForsakenArrow:onCast()
            local arrow = Arrow.create(Spell.source.x, Spell.source.y, 50, Spell.x, Spell.y, 50)

            arrow.speed = MISSILE_SPEED
            arrow.model = MISSILE_MODEL
            arrow.scale = MISSILE_SCALE
            arrow.level = Spell.level
            arrow.source = Spell.source.unit
            arrow.owner = Spell.source.player
            arrow.vision = 500
            arrow.aoe = GetAoE(Spell.source.unit, Spell.level)
            arrow.damage = GetCollisionDamage(Spell.source.unit, Spell.level)
            arrow.collision = GetCollisionSize(Spell.level)
            arrow.explosion = GetExplosionDamage(Spell.source.unit, Spell.level)

            if BlackArrow then
                arrow.curse_level = GetUnitAbilityLevel(Spell.source.unit, BlackArrow_ABILITY)
                arrow.curse = arrow.curse_level > 0
                arrow.ability = BlackArrow_BLACK_ARROW_CURSE
                arrow.curse_duration = BlackArrow_GetCurseDuration(arrow.curse_level)
            else
                arrow.curse = false
            end

            arrow:launch()
        end

        function ForsakenArrow.onInit()
            RegisterSpell(ForsakenArrow.allocate(), ABILITY)
        end
    end
end)