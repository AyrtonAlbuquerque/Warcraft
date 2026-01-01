OnInit("Stampede", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires "CrowdControl"
    requires.optional "Bonus"

    -- ------------------------------- Stampede v1.3 by Chopinski ------------------------------ --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The ability raw code
    local ABILITY     = S2A('Rex5')
    -- The missile model
    local MODEL       = "Abilities\\Spells\\Other\\Stampede\\StampedeMissile.mdl"
    -- The missile scale
    local SCALE       = 0.8
    -- The missile speed
    local SPEED       = 800
    -- The stun model
    local STUN_MODEL  = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
    -- The stun model attach point
    local STUN_ATTACH = "overhead"

    -- The amount of damage dealt when a boar hits an enemy
    local function GetDamage(source, level)
        if Bonus then
            return 125. * level + (0.2 * level * GetUnitBonus(source, BONUS_SPELL_POWER)) + ((0.8 + 0.2 * level) * GetHeroStr(source, true))
        else
            return 125. * level
        end
    end

    -- The stun duration
    local function GetStunDuration(level)
        return 0.25 * level
    end

    -- The ability duration
    local function GetDuration(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end
    
    -- The ability aoe
    local function GetAoE(source, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The missile spawn interval
    local function GetSpawnInterval(level)
        return 0.125 - 0.025*level
    end

    -- The missile collision size
    local function GetCollisionSize(level)
        return 64. + 0.*level
    end

    -- The unit filter
    local function UnitFilter(owner, target)
        return UnitAlive(target) and IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
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

            self.unit = nil
            self.timer = nil
            self.player = nil
        end

        function Stampede:onTooltip(source, level, ability)
            return "|cffffcc00Rexxar|r calls forth a rampaging horde of lizards that follows him. The lizards spawns every |cffffcc00" .. N2S(GetSpawnInterval(level), 3) .. "|r seconds and when coming in contact with an enemy unit they will do |cff00ffff" .. N2S(GetDamage(source, level), 0) .. "|r |cff00ffffMagic|r damage and stun the target for |cffffcc00" .. N2S(GetStunDuration(level), 2) .. "|r seconds. Lasts for |cffffcc00" .. N2S(GetDuration(source, level), 1) .. "|r seconds."
        end

        function Stampede:onCast()
            local this = { destroy = Stampede.destroy }

            this.offset = 1
            this.unit = Spell.source.unit
            this.player = Spell.source.player
            this.collision = GetCollisionSize(Spell.level)
            this.duration = GetDuration(this.unit, Spell.level)
            this.damage = GetDamage(this.unit, Spell.level)
            this.period = GetSpawnInterval(Spell.level)
            this.stun = GetStunDuration(Spell.level)
            this.aoe = GetAoE(this.unit, Spell.level)/2
            this.timer = CreateTimer()

            TimerStart(this.timer, this.period, true, function ()
                this.duration = this.duration - this.period

                if this.duration > 0 then
                    this.offset = -this.offset

                    local angle = GetUnitFacing(this.unit) * bj_DEGTORAD
                    local x = GetUnitX(this.unit) + this.aoe * math.cos(angle + bj_PI) + GetRandomReal(0, this.aoe) * math.cos(angle + this.offset*bj_PI/2)
                    local y = GetUnitY(this.unit) + this.aoe * math.sin(angle + bj_PI) + GetRandomReal(0, this.aoe) * math.sin(angle + this.offset*bj_PI/2)
                    local lizard = Lizard.create(x, y, 0, x + 2*this.aoe*math.cos(angle), y + 2*this.aoe*math.sin(angle), 0)

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