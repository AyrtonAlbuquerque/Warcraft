OnInit("Stampede", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "Bonus"

    -- ------------------------------- Stampede v1.2 by Chopinski ------------------------------ --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The ability raw code
    local ABILITY       = S2A('Rex8')
    -- The missile model
    local MODEL         = "Abilities\\Spells\\Other\\Stampede\\StampedeMissile.mdl"
    -- The missile scale
    local SCALE         = 0.8
    -- The model used to indicate the aoe effect
    local AOE_MODEL     = "RemorselessWinter.mdl"
    -- The blind model attachment point
    local AOE_SCALE     = 1.7
    -- The missile speed
    local SPEED         = 1000
    -- The stun model
    local STUN_MODEL    = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
    -- The stun model attach point
    local STUN_ATTACH   = "overhead"

    -- The amount of damage dealt when a boar hits an enemy
    local function GetDamage(source, level)
        if Bonus then
            return 75. * level + (0.6 + 0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 75. * level
        end
    end

    -- The stun duration
    local function GetStunDuration(level)
        return 0.25 * level
    end

    -- The ability duration
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The ability aoe
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The missile spawn interval
    local function GetSpawnInterval(level)
        return 0.5 - 0.1 * level
    end

    -- The missile collision size
    local function GetCollisionSize(level)
        return 64. + 0. * level
    end

    -- The unit filter
    local function UnitFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Lizard = Class(Missile)

        function Lizard:onUnit(unit)
            if UnitFilter(self.owner, unit) then
                if UnitDamageTarget(self.source, unit, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                    StunUnit(unit, self.stun, STUN_MODEL, STUN_ATTACH, false)
                end
            end

            return false
        end
    end

    do
        Stampede = Class(Spell)

        function Stampede:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)
            DestroyEffect(self.effect)

            self.unit = nil
            self.timer = nil
            self.effect = nil
            self.player = nil
        end

        function Stampede:onTooltip(source, level, ability)
            return "|cffffcc00Rexxar|r calls forth a rampaging horde of lizards. The lizards spawn from a random direction within |cffffcc00" .. N2S(GetAoE(source, level), 0) .. " AoE|r every |cffffcc00" .. N2S(GetSpawnInterval(level), 1) .. "|r seconds and when coming in contact with an enemy unit they will do |cff00ffff" .. N2S(GetDamage(source, level), 0) .. "|r |cff00ffffMagic|r damage and stun the target for |cffffcc00" .. N2S(GetStunDuration(level), 0) .. "|r seconds. Lasts for |cffffcc00" .. N2S(GetDuration(source, level), 0) .. "|r seconds."
        end

        function Stampede:onCast()
            local this = { destroy = Stampede.destroy }

            this.x = Spell.x
            this.y = Spell.y
            this.level = Spell.level
            this.unit = Spell.source.unit
            this.player = Spell.source.player
            this.collision = GetCollisionSize(this.level)
            this.duration = GetDuration(this.unit, this.level)
            this.damage = GetDamage(this.unit, this.level)
            this.tick = GetSpawnInterval(this.level)
            this.stun = GetStunDuration(this.level)
            this.aoe = GetAoE(this.unit, this.level)/2
            this.effect = AddSpecialEffectEx(AOE_MODEL, this.x, this.y, 0, AOE_SCALE)
            this.timer = CreateTimer()

            TimerStart(this.timer, this.tick, true, function ()
                this.duration = this.duration - this.tick

                if this.duration > 0 then
                    local fx = GetRandomCoordInRange(this.x, this.aoe, true)
                    local fy = GetRandomCoordInRange(this.y, this.aoe, false)
                    local angle = AngleBetweenCoordinates(fx, fy, this.x, this.y)
                    local lizard = Lizard.create(fx, fy, 0, this.x + this.aoe * math.cos(angle), this.y + this.aoe * math.sin(angle), 0)

                    lizard.model = MODEL
                    lizard.scale = SCALE
                    lizard.speed = SPEED
                    lizard.stun = this.stun
                    lizard.source = this.unit
                    lizard.owner = this.player
                    lizard.damage = this.damage
                    lizard.collision = this.collision

                    lizard:launch()
                else
                    this:destroy()
                end
            end)
        end

        function Stampede.onInit()
            RegisterSpell(Stampede.allocate(), ABILITY)
        end
    end
end)