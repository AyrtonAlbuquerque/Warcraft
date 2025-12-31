OnInit("Enraged", function (requires)
    requires "Class"
    requires "Spell"
    requires "Bonus"
    requires "Damage"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- ------------------------------- Enraged v1.1 by Chopinski ------------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY = S2A('Rex6')

    -- The raw code of the ability
    local function GetBonusMovementSpeed(level)
        return 1. + 0. * level
    end

    -- The attack speed bonus (0.02 = 2%)
    local function GetBonusAttackSpeed(level)
        return 0.02 + 0. * level
    end

    -- The damage bonus (0.01 = 1%)
    local function GetDamageBonus(level)
        return 0.01 + 0. * level
    end

    -- The health percentage that increases the bonusses (1 == 1%)
    local function GetHealthPercentage(level)
        return 1. - 0. * level
    end
    
    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        Enraged = Class(Spell)

        local speed = {}
        local damage = {}
        local movement = {}

        function Enraged:onTooltip(source, level, ability)
            return "|cffffcc00Misha|r gains |cffffcc00" .. N2S(GetBonusAttackSpeed(level) * 100, 0) .. "%%|r attack speed, |cffffcc00" .. N2S(GetBonusMovementSpeed(level), 0) .. "|r movement speed and deals |cffffcc00" .. N2S(GetDamageBonus(level) * 100, 0) .. "%%|r more damage for every |cffffcc00" .. N2S(GetHealthPercentage(level) * 100, 0) .. "%|r of missing health."
        end

        function Enraged.onDamage()
            local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if level > 0 and Damage.amount > 0 then
                damage[Damage.source.unit] = ((100 - GetUnitLifePercent(Damage.source.unit)) * GetDamageBonus(level)) / GetHealthPercentage(level)
                Damage.amount = Damage.amount * (1 + damage[Damage.source.unit])
            end
        end

        function Enraged.onAttack()
            local source = GetAttacker()
            local level = GetUnitAbilityLevel(source, ABILITY)

            if level > 0 then
                AddUnitBonus(source, BONUS_ATTACK_SPEED, -(speed[source] or 0))
                AddUnitBonus(source, BONUS_MOVEMENT_SPEED, -(movement[source] or 0))

                speed[source] = ((100 - GetUnitLifePercent(source)) * GetBonusAttackSpeed(level)) / GetHealthPercentage(level)
                movement[source] = ((100 - GetUnitLifePercent(source)) * GetBonusMovementSpeed(level)) / GetHealthPercentage(level)

                AddUnitBonus(source, BONUS_ATTACK_SPEED, speed[source])
                AddUnitBonus(source, BONUS_MOVEMENT_SPEED, movement[source])
            end
        end

        function Enraged.onIndex()
            speed[GetIndexUnit()] = nil
            damage[GetIndexUnit()] = nil
            movement[GetIndexUnit()] = nil
        end

        function Enraged.onInit()
            RegisterSpell(Enraged.allocate(), ABILITY)
            RegisterUnitIndexEvent(Enraged.onIndex)
            RegisterAttackDamageEvent(Enraged.onDamage)
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, Enraged.onAttack)
        end
    end
end)