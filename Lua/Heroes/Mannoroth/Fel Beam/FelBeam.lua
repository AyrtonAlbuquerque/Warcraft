OnInit("FelBeam", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Missiles"
    requires "Utilities"

    -- ------------------------------- Fel Beam v1.6 by Chopinski ------------------------------ --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Fel Beam ability
    FelBeam_ABILITY     = S2A('Mnr2')
    -- The beam inicial z offset
    local START_HEIGHT  = 60
    -- The beam final z offset
    local END_HEIGHT    = 60
    -- The missile model
    local MISSILE_MODEL = "Fel_Beam.mdx"
    -- The size of the fel beam
    local MISSILE_SCALE = 0.5
    -- The beam missile speed
    local MISSILE_SPEED = 1250
    -- The Attack type of the damage dealt (Spell)
    local ATTACK_TYPE   = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt 
    local DAMAGE_TYPE   = DAMAGE_TYPE_MAGIC
    -- The curse model
    local CURSE_MODEL   = "FelCurse.mdx"
    -- The curse attachment point
    local CURSE_ATTACH  = "chest"

    -- The search range of units after a cursed unit dies
    local function GetSearchRange(level)
        return 1000. + 0.*level
    end
    
    -- The damage amount
    local function GetDamage(source, level)
        return 100. * level + (0.8 + 0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
    end

    -- The amount of armor reduced
    function FelBeam_GetArmorReduction(level)
        return level + 1
    end

    -- How long the curse lasts
    function FelBeam_GetCurseDuration(level)
        return 15. + 0.*level
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Curse = Class()

        local array = {}
        Curse.cursed = {}

        function Curse:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyEffect(self.effect)
            AddUnitBonus(self.unit, BONUS_ARMOR, self.armor)

            self.unit = nil
            self.timer = nil
            self.effect = nil
            Curse.cursed[self.unit] = nil
        end

        function Curse.create(target, duration, amount)
            local self = array[target]

            if not self then
                self = Curse.allocate()
                
                self.unit = target
                self.armor = amount
                self.timer = CreateTimer()
                self.effect = AddSpecialEffectTarget(CURSE_MODEL, target, CURSE_ATTACH)
                array[target] = self

                AddUnitBonus(target, BONUS_ARMOR, -amount)
                TimerStart(self.timer, 0.5, true, function ()
                    self.duration = self.duration - 0.5

                    if self.duration <= 0 or not UnitAlive(self.unit) then
                        self:destroy()
                    end
                end)
            end

            self.duration = duration

            return self
        end
    end

    do
        Beam = Class(Missile)

        function Beam:onFinish()
            if UnitAlive(self.target) then
                Curse.cursed[self.target] = true

                if UnitDamageTarget(self.source, self.target, self.damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, nil) then
                    Curse.create(self.target, self.curse_duration, self.armor)
                end
            end

            return true
        end
    end

    do
        FelBeam = Class(Spell)

        local source = {}

        function FelBeam.launch(beam, caster, target, level)
            beam.source = caster
            beam.target = target
            beam.model = MISSILE_MODEL
            beam.scale = MISSILE_SCALE
            beam.speed = MISSILE_SPEED
            beam.id = GetUnitUserData(target)
            beam.damage = GetDamage(caster, level)
            beam.owner = GetOwningPlayer(caster)
            beam.armor = FelBeam_GetArmorReduction(level)
            beam.curse_duration = FelBeam_GetCurseDuration(level)
            source[target] = caster

            beam:launch()
        end

        function FelBeam:onTooltip(source, level, ability)
            return "|cffffcc00Mannoroth|r launch at the target unit a |cffffcc00Fel Beam|r, that apply |cffffcc00Fel Curse|r and deals |cff00ffff" .. N2S(GetDamage(source, level), 0) .. "|r |cff00ffffMagic|r damage. The cursed unit have it's armor reduced by |cffffcc00" .. N2S(GetArmorReduction(level), 0) .. "|r and if it dies under the effect of |cffffcc00Fel Curse|r curse, another |cffffcc00Fel Beam|r will spawn from it's location and seek a nearby enemy unit within |cffffcc00" .. N2S(GetSearchRange(level), 0) .. " AoE|r.\n\nLast for |cffffcc00" .. N2S(FelBeam_GetCurseDuration(level), 1) .. "|r seconds."
        end

        function FelBeam:onCast()
            local beam = Beam.create(Spell.source.x, Spell.source.y, START_HEIGHT, Spell.target.x, Spell.target.y, END_HEIGHT)
            
            FelBeam.launch(beam, Spell.source.unit, Spell.target.unit, Spell.level)
        end

        function FelBeam.onDeath()
            local killed = GetTriggerUnit()
            local caster = source[killed]
            local level
        
            if Curse.cursed[killed] then
                if not source[killed] then
                    caster = GetKillingUnit()
                    level  = 1
                else
                    level = GetUnitAbilityLevel(caster, FelBeam_ABILITY)
                end
        
                local x = GetUnitX(killed)
                local y = GetUnitY(killed)
                local z = GetUnitFlyHeight(killed) + START_HEIGHT
                local g = GetEnemyUnitsInRange(GetOwningPlayer(caster), x, y, GetSearchRange(level), false, false)

                if BlzGroupGetSize(g) > 0 then
                    local u = GroupPickRandomUnit(g)
                    local beam = Beam.create(x, y, z, GetUnitX(u), GetUnitY(u), END_HEIGHT)

                    FelBeam.launch(beam, caster, u, level)
                end

                DestroyGroup(g)

                source[killed] = nil
                Curse.cursed[killed] = nil
            end
        end

        function FelBeam.onInit()
            RegisterSpell(FelBeam.allocate(), FelBeam_ABILITY)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, FelBeam.onDeath)
        end
    end
end)