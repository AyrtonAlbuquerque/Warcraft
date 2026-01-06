OnInit("FragGranade", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Missiles"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "ArsenalUpgrade"

    -- ----------------------------- Frag Granade v1.5 by Chopinski ---------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Frag Granade ability
    FragGranade_ABILITY   = S2A('Tyc1')
    -- The Frag Granade model
    local MODEL           = "Abilities\\Weapons\\MakuraMissile\\MakuraMissile.mdl"
    -- The Frag Granade scale
    local SCALE           = 2.
    -- The Frag Granade speed
    local SPEED           = 1000.
    -- The Frag Granade arc
    local ARC             = 45.
    -- The Frag Granade Explosion model
    local EXPLOSION       = "Explosion.mdl"
    -- The Frag Granade Explosion model scale
    local EXP_SCALE       = 1.
    -- The Frag Granade proximity Period
    local PERIOD          = 0.25
    -- The Frag Granade stun model
    local STUN_MODEL      = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
    -- The Frag Granade stun model attach point
    local STUN_ATTACH     = "overhead"

    -- The Frag Granade armor reduction duraton
    local function GetArmorDuration(level)
        return 5. + 0.*level
    end

    -- The Frag Granade armor reduction
    local function GetArmor(level)
        return 2 + 2*level
    end

    -- The Frag Granade Explosion AOE
    local function GetAoE(level)
        return 150. + 50.*level
    end

    -- The Frag Granade Proximity AOE
    local function GetProximityAoE(level)
        return 100. + 0.*level
    end

    -- The Frag Granade damage
    local function GetDamage(source, level)
        return 50. + 50.*level + (0.1 * level) * GetUnitBonus(source, BONUS_SPELL_POWER) + (0.2 + 0.1*level) * GetUnitBonus(source, BONUS_DAMAGE)
    end

    -- The Frag Granade lasting duraton
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, FragGranade_ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The Frag Granade stun duration
    local function GetStunDuration(level)
        return 1.5 + 0.*level
    end

    -- The Damage Filter.
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Mine = Class()

        function Mine:destroy()
            self:explode()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyGroup(self.group)
            DestroyEffect(self.effect)
            DestroyEffect(AddSpecialEffectEx(EXPLOSION, self.x, self.y, 0, EXP_SCALE))

            self.unit = nil
            self.timer = nil
            self.group = nil
            self.effect = nil
            self.player = nil
        end

        function Mine:explode()
            GroupEnumUnitsInRange(self.group, self.x, self.y, self.aoe, nil)

            local u = FirstOfGroup(self.group)

            while u do
                if DamageFilter(self.player, u) then
                    if UnitDamageTarget(self.unit, u, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        AddUnitBonusTimed(u, BONUS_ARMOR, -self.armor, self.armor_duration)
                        
                        if self.stun > 0 then
                            StunUnit(u, self.stun, STUN_MODEL, STUN_ATTACH, false)
                        end
                    end
                end

                GroupRemoveUnit(self.group, u)
                u = FirstOfGroup(self.group)
            end
        end

        function Mine.create(source, owner, level, tx, ty, amount, area, reduction, armor_time, stun_time, timeout)
            local self = Mine.allocate()

            self.x = tx
            self.y = ty
            self.aoe = area
            self.unit = source
            self.player = owner
            self.damage = amount
            self.stun = stun_time
            self.armor = reduction
            self.duration = timeout
            self.armor_duration = armor_time
            self.timer = CreateTimer()
            self.group = CreateGroup()
            self.proximity = GetProximityAoE(level)
            self.effect = AddSpecialEffectEx(MODEL, self.x, self.y, 20, SCALE)

            BlzSetSpecialEffectTimeScale(self.effect, 0)
            TimerStart(self.timer, PERIOD, true, function ()
                self.duration = self.duration - PERIOD

                if self.duration > 0 then
                    GroupEnumUnitsInRange(self.group, self.x, self.y, self.proximity, nil)

                    local u = FirstOfGroup(self.group)

                    while u do
                        if DamageFilter(self.player, u) then
                            self:destroy()
                            break
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

    do
        Granade = Class(Missile)

        function Granade:onFinish()
            local i = 0

            GroupEnumUnitsInRange(self.group, self.x, self.y, self.aoe, nil)

            local u = FirstOfGroup(self.group)

            while u do
                if DamageFilter(self.owner, u) then
                    i = i + 1

                    if UnitDamageTarget(self.source, u, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                        AddUnitBonusTimed(u, BONUS_ARMOR, -self.armor, self.time)

                        if self.stun > 0 then
                            StunUnit(u, self.stun, STUN_MODEL, STUN_ATTACH, false)
                        end
                    end
                end

                GroupRemoveUnit(self.group, u)
                u = FirstOfGroup(self.group)
            end

            DestroyGroup(self.group)

            if i > 0 then
                DestroyEffect(AddSpecialEffectEx(EXPLOSION, self.x, self.y, 0, EXP_SCALE))
            else
                Mine.create(self.source, self.owner, self.level, self.x, self.y, self.damage, self.aoe, self.armor, self.time, self.stun, GetDuration(self.source, self.level))
            end

            return true
        end
    end

    do
        FragGranade = Class(Spell)

        function FragGranade:onTooltip(source, level, ability)
            return "|cffffcc00Tychus|r throws a |cffffcc00Frag Granade|r at the target location. Upon arrival, if there are enemy units nearby, the granade explodes dealing |cff00ffff" .. N2S(GetDamage(source, level),0) .. " Magic|r damage and shredding |cff808080" .. I2S(GetArmor(level)) .. " Armor|r for |cffffcc00" .. N2S(GetArmorDuration(level), 1) .. "|r seconds. If there are no enemies nearby, the granade will stay in the location and explode when an enemy unit comes nearby or its duration expires after |cffffcc00" .. N2S(GetDuration(source, level), 1) .. "|r seconds."
        end

        function FragGranade:onCast()
            local granade = Granade.create(Spell.source.x, Spell.source.y, 75, Spell.x, Spell.y, 0)

            granade.speed = SPEED
            granade.model = MODEL
            granade.scale = SCALE
            granade.arc = ARC
            granade.stun = 0
            granade.source = Spell.source.unit
            granade.owner = Spell.source.player
            granade.level = Spell.level
            granade.damage = GetDamage(Spell.source.unit, Spell.level)
            granade.aoe = GetAoE(Spell.level)
            granade.armor = GetArmor(Spell.level)
            granade.time = GetArmorDuration(Spell.level)
            granade.group = CreateGroup()

            if ArsenalUpgrade then
                if GetUnitAbilityLevel(Spell.source.unit, ArsenalUpgrade_ABILITY) > 0 then
                    granade.stun = GetStunDuration(Spell.level)
                end
            end

            granade:launch()
        end

        function FragGranade.onInit()
            RegisterSpell(FragGranade.allocate(), FragGranade_ABILITY)
        end
    end
end)