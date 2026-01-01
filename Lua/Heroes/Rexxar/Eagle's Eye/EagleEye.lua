OnInit("EagleEye", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Missiles"
    requires "Utilities"

    -- ----------------------------- Eagle's Eye v1.2 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The ability raw code
    local ABILITY       = S2A('Rex4')
    -- The missile model
    local MODEL         = "Green Crow.mdl"
    -- The missile scale
    local SCALE         = 0.6
    -- The model used for the blind effect
    local BLIND_MODEL   = "Burning Rage Red.mdl"
    -- The blind model attachment point
    local ATTACH        = "overhead"
    -- The model used when the eagle hits its target
    local DEATH_MODEL   = "Ephemeral Slash Silver.mdl"
    -- The death model scale
    local DEATH_SCALE   = 1.5
    -- The missile speed
    local SPEED         = 1500
    -- The missile final height
    local HEIGHT        = 350
    -- The eagle search period
    local PERIOD        = 0.5

    -- The amount of vision granted while the missile travels and the aoe used to detect units
    local function GetVisionRange(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The amount of damage dealt when single target
    local function GetDamage(source, level)
        if Bonus then
            return 100. + 50. * level + (0.6 + 0.1*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 100. + 50. * level
        end
    end

    -- The
    local function GetAoE(unit, level)
        return 250. + 50. * level
    end

    -- The amount of damage dealt when targeted at the ground
    local function GetAoEDamage(source, level)
        if Bonus then
            return 50. * level + 0.5 * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 50. * level
        end
    end

    -- The amount of vision reduced
    local function GetVisionReduction(unit, level)
        return 1400. + 100. * level
    end

    -- The duration of the vision debuff
    local function GetReductionDuraiton(unit, level)
        return 5. + 0. * level
    end

    -- The duration that the ealge will stay in place searching
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The unit detection filter
    local function UnitFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- The unit damage filter
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Eagle = Class(Missile)

        function Eagle:onFinish()
            if not self.target then
                self.timer = CreateTimer()
                self.group = CreateGroup()

                self:pause(true)
                TimerStart(self.timer, PERIOD, true, function()
                    self.timeout = self.timeout - PERIOD

                    if self.timeout > 0 then
                        GroupEnumUnitsInRange(self.group, self.x, self.y, self.vision, nil)

                        local u = FirstOfGroup(self.group)

                        while u do
                            if UnitFilter(self.owner, u) then
                                self:deflect(GetUnitX(u), GetUnitY(u), 50)
                                self.target = u
                                self:pause(false)

                                PauseTimer(self.timer)
                                DestroyTimer(self.timer)
                                break
                            end

                            GroupRemoveUnit(self.group, u)
                            u = FirstOfGroup(self.group)
                        end
                    else
                        PauseTimer(self.timer)
                        DestroyTimer(self.timer)
                        self:terminate()
                    end
                end)

                return false
            else
                if self.targeted then
                    if UnitAlive(self.target) then
                        if UnitDamageTarget(self.source, self.target, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                            if UnitAlive(self.target) then
                                AddUnitBonusTimed(self.target, BONUS_SIGHT_RANGE, -self.reduction, self.time)
                                DestroyEffectTimed(AddSpecialEffectTarget(BLIND_MODEL, self.target, ATTACH), self.time)
                            end
                        end
                    end
                else
                    GroupEnumUnitsInRange(self.group, self.x, self.y, self.aoe, nil)

                    local u = FirstOfGroup(self.group)

                    while u do
                        if DamageFilter(self.owner, u) then
                            if UnitDamageTarget(self.source, u, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                                if UnitAlive(u) then
                                    AddUnitBonusTimed(u, BONUS_SIGHT_RANGE, -self.reduction, self.time)
                                    DestroyEffectTimed(AddSpecialEffectTarget(BLIND_MODEL, u, ATTACH), self.time)
                                end
                            end
                        end

                        GroupRemoveUnit(self.group, u)
                        u = FirstOfGroup(self.group)
                    end

                    DestroyEffect(AddSpecialEffectEx(DEATH_MODEL, self.x, self.y, 50, DEATH_SCALE))
                end

                self.alpha = 0

                return true
            end
        end

        function Eagle:onRemove()
            DestroyGroup(self.group)

            self.group = nil
            self.timer = nil
        end
    end

    do
        EagleEye = Class(Spell)

        function EagleEye:onTooltip(source, level, ability)
            return "|cffffcc00Rexxar|r sends an eagle to the targeted enemy |cff00ff00unit|r or |cff00ff00location|r. In its path the eagle reveals the surrounding area. Upon reaching the targeted unit, the eagle will blind it, reducing its sight range by |cffffcc00" .. N2S(GetVisionReduction(source, level), 0) .. "|r for |cffffcc00" .. N2S(GetReductionDuraiton(source, level), 0) .. "|r seconds and dealing |cff00ffff" .. N2S(GetDamage(source, level), 0) .. " Magic|r damage. When reaching the targeted location the eagle will remain in its position for |cffffcc00" .. N2S(GetDuration(source, level), 0) .. "|r seconds , revealing |cffffcc00" .. N2S(GetVisionRange(source, level), 0) .. " AoE|r. When any enemy unit comes in range, the eagle will lunge towards it, dealing |cff00ffff" .. N2S(GetAoEDamage(source, level), 0) .. " Magic|r damage and blinding all enemy units within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. " AoE|r."
        end

        function EagleEye:onCast()
            local eagle

            if not Spell.target.unit then
                eagle = Eagle.create(Spell.source.x, Spell.source.y, 50, Spell.x, Spell.y, HEIGHT)
                eagle.targeted = false
                eagle.aoe = GetAoE(Spell.source.unit, Spell.level)
                eagle.damage = GetAoEDamage(Spell.source.unit, Spell.level)
            else
                eagle = Eagle.create(Spell.source.x, Spell.source.y, 50, Spell.target.x, Spell.target.y, 50)
                eagle.targeted = true
                eagle.target = Spell.target.unit
                eagle.damage = GetDamage(Spell.source.unit, Spell.level)
            end

            eagle.model = MODEL
            eagle.scale = SCALE
            eagle.speed = SPEED
            eagle.source = Spell.source.unit
            eagle.owner = Spell.source.player
            eagle.level = Spell.level
            eagle.vision = GetVisionRange(Spell.source.unit, Spell.level)
            eagle.time = GetReductionDuraiton(Spell.source.unit, Spell.level)
            eagle.reduction = GetVisionReduction(Spell.source.unit, Spell.level)
            eagle.timeout = GetDuration(Spell.source.unit, Spell.level)

            eagle:launch()
        end

        function EagleEye.onInit()
            RegisterSpell(EagleEye.allocate(), ABILITY)
        end
    end
end)