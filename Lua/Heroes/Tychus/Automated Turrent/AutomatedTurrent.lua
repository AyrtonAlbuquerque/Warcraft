OnInit("AutomatedTurrent", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"
    requires "Missiles"
    requires "Utilities"
    requires.optional "ArsenalUpgrade"

    -- -------------------------- Automated Turrent v1.3 by Chipinski -------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the Automated Turrent ability
    AutomatedTurrent_ABILITY    = S2A('Tyc2')
    -- The raw code of the Automated Turrent Missile ability
    local MISSILE               = S2A('Tyc6')
    -- The raw code of the Automated Turrent unit
    local UNIT                  = S2A('tyc0')
    -- The Missile model
    local MODEL                 = "Airstrike Rocket.mdl"
    -- The Missile scale
    local SCALE                 = 0.5
    -- The Missile speed
    local SPEED                 = 1000.

    -- The Automated Turrent duration
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, AutomatedTurrent_ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The Automated Turrent max hp
    local function GetMaxHealth(level, source)
        return R2I(100 + 100*level + BlzGetUnitMaxHP(source)*0.2)
    end

    -- The Automated Turrent base damage.
    local function GetUnitDamage(level, source)
        return R2I(5 * level + (0.1 + 0.1*level) * GetUnitBonus(source, BONUS_DAMAGE))
    end

    -- The number of Automated Turrents created
    local function GetAmount(level)
        return 1 + 0*level
    end

    -- The number of attacks necessary for a missile to be released
    local function GetAttackCount(unit, level)
        if ArsenalUpgrade then
            if GetUnitAbilityLevel(unit, ArsenalUpgrade_ABILITY) > 0 then
                return 18 - 2*level
            else
                return 22 - 2*level
            end
        else
            return 22 - 2*level
        end
    end

    -- The Missile max aoe for random location
    local function GetMaxAoE(level)
        return 150. + 0.*level
    end

    -- The Missile damage aoe
    local function GetAoE(level)
        return 150. + 0.*level
    end

    -- The Automated Turrent missile damage.
    local function GetDamage(source, level)
        return 25.*level + (0.25 * level) * GetUnitBonus(source, BONUS_SPELL_POWER)
    end

    -- The Automated Turrent missile arc.
    local function GetArc(level)
        return GetRandomReal(0, 20)
    end

    -- The Automated Turrent missile curve.
    local function GetCurve(level)
        return GetRandomReal(-15, 15)
    end

    -- The Damage Filter.
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player)
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        TurrentMissile = Class(Missile)

        function TurrentMissile:onFinish()
            GroupEnumUnitsInRange(self.group, self.x, self.y, self.aoe, nil)

            local u = FirstOfGroup(self.group)

            while u do
                if DamageFilter(self.owner, u) then
                    UnitDamageTarget(self.source, u, self.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                end

                GroupRemoveUnit(self.group, u)
                u = FirstOfGroup(self.group)
            end

            DestroyGroup(self.group)
            
            return true
        end
    end
    
    do
        AutomatedTurrent = Class(Spell)

        local owner = {}
        local array = {}

        function AutomatedTurrent:onTooltip(source, level, ability)
            return "|cffffcc00Tychus|r summons an immobile |cffffcc00Automated Turrent|r at the target location The turrent has |cffff0000" .. I2S(GetUnitDamage(level, source)) .. " Attack Damage|r and |cffff0000" .. I2S(GetMaxHealth(level, source)) .. " Health|r. Every |cffffcc00" .. I2S(GetAttackCount(source, level)) .. "|r attacks, |cffffcc00Automated Turrent|r releases a |cffffcc00Missile|r to a random spot within |cffffcc00" .. N2S(GetMaxAoE(level), 0) .. " AoE|r of it's primary target. The |cffffcc00Missile|r damages enemy units within |cffffcc00" .. N2S(GetAoE(level), 0) .. " AoE|r, dealing |cff00ffff" .. N2S(GetDamage(source, level), 0) .. " Magic|r damage."
        end

        function AutomatedTurrent:onCast()
            for i = 0, GetAmount(Spell.level) - 1 do
                local unit = CreateUnit(Spell.source.player, UNIT, Spell.x, Spell.y, 0)
                
                owner[unit] = Spell.source.unit
                array[unit] = 0

                SetUnitAbilityLevel(unit, MISSILE, Spell.level)
                BlzSetUnitBaseDamage(unit, GetUnitDamage(Spell.level, Spell.source.unit), 0)
                BlzSetUnitMaxHP(unit, GetMaxHealth(Spell.level, Spell.source.unit))
                SetUnitLifePercentBJ(unit, 100)
                UnitApplyTimedLife(unit, S2A('BTLF'), GetDuration(Spell.source.unit, Spell.level))
            end
        end

        function AutomatedTurrent.onDamage()
            local level = GetUnitAbilityLevel(Damage.source.unit, MISSILE)

            if level > 0 and Damage.isEnemy then
                array[Damage.source.unit] = (array[Damage.source.unit] or 0) + 1

                if array[Damage.source.unit] >= GetAttackCount(Damage.source.unit, level) then
                    local range = GetRandomRange(GetMaxAoE(level))
                    local missile = TurrentMissile.create(Damage.source.x, Damage.source.y, Damage.source.z + 80, GetRandomCoordInRange(Damage.target.x, range, true), GetRandomCoordInRange(Damage.target.y, range, false), 0)
                    
                    array[Damage.source.unit] = 0

                    missile.model = MODEL
                    missile.scale = SCALE
                    missile.speed = SPEED
                    missile.source = Damage.source.unit
                    missile.owner = Damage.source.player
                    missile.arc = GetArc(level) * bj_DEGTORAD
                    missile.curve = GetCurve(level) * bj_DEGTORAD
                    missile.damage = GetDamage(owner[Damage.source.unit], level)
                    missile.group = CreateGroup()
                    missile.aoe = GetAoE(level)

                    missile:launch()
                end
            end
        end

        function AutomatedTurrent.onInit()
            RegisterSpell(AutomatedTurrent.allocate(), AutomatedTurrent_ABILITY)
            RegisterAttackDamageEvent(AutomatedTurrent.onDamage)
        end
    end
end)