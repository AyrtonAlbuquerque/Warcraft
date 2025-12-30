OnInit("ChaosRain", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "Bonus"

    -- ------------------------------ Chaos Rain v1.6 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Chaos Rain ability
    local ABILITY        = S2A('Mnr5')
    -- The raw code of the Infernal unitu
    local INFERNAL       = S2A('umn1')
    -- The raw code of the Infernal Fire ability
    local INFERNAL_FIRE  = S2A('MnrB')
    -- The starting height of the missile
    local START_HEIGHT   = 1500
    -- The starting offset of the missile
    local START_OFFSET   = 3000
    -- The landing time of the falling missile
    local LANDING_TIME   = 1
    -- the missile model
    local MISSILE_MODEL  = "Units\\Demon\\Infernal\\InfernalBirth.mdl"
    -- The Missile scale
    local MISSILE_SCALE  = 1
    -- The stun model
    local STUN_MODEL     = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
    -- The stun model attach point
    local POINT          = "overhead"

    -- The amount of damage dealt when the missile lands
    local function GetDamage(source, level)
        if Bonus then
            return 250 * level + (0.6 + 0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 250. * level
        end
    end

    -- The amount of damage Infernal Fire deals per second
    local function GetInfernalFireDamage(source, level)
        if Bonus then
            return 50 * level + (0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 50. * level
        end
    end

    -- The max range that a missile can spawn
    -- By default it is the ability Area of Effect Field value
    local function GetAoE(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The impact aoe
    local function GetDamageAoE(source, level)
        return 200. + 0.*level
    end

    -- The amount of meteors spawned
    local function GetCount(source, level)
        return 10 + 20*level
    end

    -- The meteor spawn interval
    local function GetInterval(source, level)
        return 0.15 - 0.*level
    end

    -- The stun duration
    local function GetStunDuration(source, level)
        return 1. + 0.*level
    end

    -- The chance of a meteor to spawn a infernal
    local function GetChance(source, level)
        return 0.05 + 0.05*level
    end

    -- The infernal duration
    local function GetInfernalDuration(source, level)
        return 60. + 0.*level
    end

    -- The infernal damage
    local function GetInfernalDamage(source, level)
        if Bonus then
            return 50 * level + (0.1 + 0.05*level) * GetUnitBonus(source, BONUS_SPELL_POWER) + (0.6 + 0.1*level) * GetUnitBonus(source, BONUS_DAMAGE)
        else
            return 50. * level
        end
    end

    -- The infernal health
    local function GetInfernalHealth(source, level)
        return 1000 * level + (0.4 + 0.2*level) * BlzGetUnitMaxHP(source)
    end

    --The infernal Armor
    local function GetInfernalArmor(source, level)
        return 5. * level + BlzGetUnitArmor(source)
    end

    -- The damage filter
    local function DamageFilter(owner, target)
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    local Meteor = Class(Missile)

    do
        function Meteor:onDestructable(destructable)
            KillDestructable(destructable)

            return false
        end

        function Meteor:onFinish()
            local group = CreateGroup()

            if GetRandomReal(0, 1) <= GetChance(self.source, self.level) then
                local u = CreateUnit(self.owner, INFERNAL, self.x, self.y, 0)

                SetUnitAnimation(u, "Birth")
                QueueUnitAnimation(u, "Stand")
                BlzSetUnitBaseDamage(u, R2I(GetInfernalDamage(self.source, self.level)), 0)
                BlzSetUnitMaxHP(u, R2I(GetInfernalHealth(self.source, self.level)))
                BlzSetUnitArmor(u, GetInfernalArmor(self.source, self.level))
                SetUnitLifePercentBJ(u, 100)
                BlzSetAbilityRealLevelField(BlzGetUnitAbility(u, INFERNAL_FIRE), ABILITY_RLF_DAMAGE_PER_INTERVAL, 0, GetInfernalFireDamage(self.source, self.level))
                BlzUnitDisableAbility(u, INFERNAL_FIRE, true, true)
                BlzUnitDisableAbility(u, INFERNAL_FIRE, false, false)

                if GetInfernalDuration(self.source, self.level) > 0 then
                    UnitApplyTimedLife(u, S2A('BTLF'), GetInfernalDuration(self.source, self.level))
                end
            end

            GroupEnumUnitsInRange(group, self.x, self.y, self.collision, nil)

            local u = FirstOfGroup(group)

            while u do
                if DamageFilter(self.owner, u) then
                    if UnitDamageTarget(self.source, u, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                        StunUnit(u, self.stun, STUN_MODEL, POINT, false)
                    end
                end

                GroupRemoveUnit(group, u)
                u = FirstOfGroup(group)
            end

            DestroyGroup(group)

            return true
        end
    end

    do
        ChaosRain = Class(Spell)

        function ChaosRain:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)

            self.unit = nil
            self.timer = nil
        end

        function ChaosRain:onTooltip(source, level, ability)
            return "|cffffcc00Mannoroth|r conjures a |cffffcc00Chaos Rain|r from the skies. Each meteor deals |cff00ffff" .. N2S(GetDamage(source, level), 0) .. " Magic|r damage and stuns enemy units within |cffffcc00" .. N2S(GetDamageAoE(source, level), 0) .. " AoE|r for |cffffcc00" .. N2S(GetStunDuration(source, level), 1) .. "|r second. Additionally, each meteor has a |cffffcc00" .. N2S(GetChance(source, level)*100, 0) .. "%%|r chance to spawn an |cffffcc00Infernal|r. The |cffffcc00Infernal|r has |cffff0000" .. N2S(GetInfernalDamage(source, level), 0) .. " Damage|r, |cff00ff00" .. N2S(GetInfernalHealth(source, level), 0) .. " Health|r and |cffc0c0c0" .. N2S(GetInfernalArmor(source, level), 0) .. " Armor|r. Lasts for |cffffcc00" .. N2S(GetInfernalDuration(source, level), 1) .. "|r seconds."
        end

        function ChaosRain:onCast()
            local this = { destroy = ChaosRain.destroy }

            this.x = Spell.x
            this.y = Spell.y
            this.level = Spell.level
            this.unit = Spell.source.unit
            this.timer = CreateTimer()
            this.angle = AngleBetweenCoordinates(Spell.x, Spell.y, Spell.source.x, Spell.source.y)
            this.range = GetAoE(Spell.source.unit, Spell.level)
            this.count = GetCount(Spell.source.unit, Spell.level)

            TimerStart(this.timer, GetInterval(Spell.source.unit, Spell.level), true, function ()
                this.count = this.count - 1

                if this.count > 0 then
                    local theta = 2*bj_PI*GetRandomReal(0, 1)
                    local radius = GetRandomRange(this.range)
                    local x = this.x + radius*math.cos(theta)
                    local y = this.y + radius*math.sin(theta)
                    local meteor = Meteor.create(x + START_OFFSET*math.cos(this.angle), y + START_OFFSET*math.sin(this.angle), START_HEIGHT, x, y, 0)

                    meteor.source = this.unit
                    meteor.level = this.level
                    meteor.model = MISSILE_MODEL
                    meteor.scale = MISSILE_SCALE
                    meteor.duration = LANDING_TIME
                    meteor.collideZ = true
                    meteor.owner = GetOwningPlayer(this.unit)
                    meteor.stun = GetStunDuration(this.unit, this.level)
                    meteor.damage = GetDamage(this.unit, this.level)
                    meteor.collision = GetDamageAoE(this.unit, this.level)

                    meteor:launch()
                else
                    this:destroy()
                end
            end)
        end

        function ChaosRain.OnInit()
            RegisterSpell(ChaosRain.allocate(), ABILITY)
        end
    end
end)