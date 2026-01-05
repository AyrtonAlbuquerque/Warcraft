OnInit("OdinAnnihilate", function (requires)
    requires "Class"
    requires "Spell"
    requires "Missiles"
    requires "Utilities"
    requires.optional "Bonus"

    -- --------------------------- Odin Annihilate v1.3 by Chopinski --------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Odin Annihilate ability
    OdinAnnihilate_ABILITY = S2A('Tyc8')
    -- The Missile model
    local MODEL   = "Interceptor Shell.mdl"
    -- The Missile scale
    local SCALE   = 0.6
    -- The Missile speed
    local SPEED   = 1000.
    -- The Missile height offset
    local HEIGHT  = 200.

    -- The Explosion AoE
    local function GetAoE(level)
        return 200. + 0.*level
    end

    -- The max aoe at which rockets can strike, by default the ability aoe field
    local function GetMaxAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, OdinAnnihilate_ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The explosion damage
    local function GetDamage(source, level)
        if Bonus then
            return 50. * level + (0.8 + 0.2*level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 50. * level
        end
    end

    -- The numebr of rockets.
    local function GetRocketCount(level)
        return 10 + 5*level
    end

    -- The interval at which rockets are spawnned.
    local function GetInterval(level)
        return 0.2 + 0.*level
    end

    -- The rocket missile arc.
    local function GetArc(level)
        return GetRandomReal(30, 60)
    end

    -- The rocket missile curve.
    local function GetCurve(level)
        return GetRandomReal(-20, 20)
    end

    -- The Damage Filter.
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    local Rocket = Class(Missile)
    
    do
        function Rocket:onFinish()
            DestroyEffect(AddSpecialEffect(MODEL,self.x, self.y))
            GroupEnumUnitsInRange(self.group, self.x, self.y, self.aoe, nil)

            local u = FirstOfGroup(self.group)

            while u do
                if DamageFilter(self.owner, u) then
                    UnitDamageTarget(self.owner, u, self.damage, true, true, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                end

                GroupRemoveUnit(self.group, u)
                u = FirstOfGroup(self.group)
            end

            DestroyGroup(self.group)

            return true
        end
    end

    do
        OdinAnnihilate = Class(Spell)

        function OdinAnnihilate:destroy()
            PauseTimer(self.timer)
            DestroyTimer(self.timer)

            self.unit = nil
            self.timer = nil
        end

        function OdinAnnihilate:onTooltip(source, level, ability)
            return "|cffffcc00Odin|r unleashes a barrage of |cffffcc00" .. N2S(GetRocketCount(level), 0) .. "|r rockets towards the target area, dealing |cff00ffff" .. N2S(GetDamage(source, level), 0) .. "|r Magic|r damage each rocket."
        end

        function OdinAnnihilate:onCast()
            local this = { destroy = OdinAnnihilate.destroy }
            
            this.x = Spell.x
            this.y = Spell.y
            this.level = Spell.level
            this.unit = Spell.source.unit
            this.player = Spell.source.player
            this.timer = CreateTimer()
            this.count = GetRocketCount(Spell.level)
            this.aoe = GetMaxAoE(Spell.source.unit, Spell.level)

            TimerStart(this.timer, GetInterval(Spell.level), true, function ()
                this.count = this.count - 1

                if this.count > 0 then
                    local range = GetRandomRange(this.aoe)
                    local rocket = Rocket.create(GetUnitX(this.unit), GetUnitY(this.unit), HEIGHT, GetRandomCoordInRange(this.x, range, true), GetRandomCoordInRange(this.y, range, false), 50)

                    rocket.model = MODEL
                    rocket.scale = SCALE
                    rocket.speed = SPEED
                    rocket.source = this.unit
                    rocket.owner = this.player
                    rocket.arc = GetArc(this.level) * bj_DEGTORAD
                    rocket.aoe = GetAoE(this.level)
                    rocket.group = CreateGroup()
                    rocket.curve = GetCurve(this.level) * bj_DEGTORAD
                    rocket.damage = GetDamage(this.unit, this.level)

                    rocket:launch()
                else
                    this:destroy()
                end
            end)
        end

        function OdinAnnihilate.onInit()
            RegisterSpell(OdinAnnihilate.allocate(), OdinAnnihilate_ABILITY)
        end
    end
end)