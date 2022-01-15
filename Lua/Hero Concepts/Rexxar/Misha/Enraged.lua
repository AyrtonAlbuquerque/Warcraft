--[[ requires RegisterPlayerUnitEvent, DamageInterface, NewBonus,
    /* ------------------------ Enraged v1.0 by Chopinski ----------------------- */
    // Credits:
    //     Nyx-Studio      - Icon
    //     Magtheridon96   - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY = FourCC('A007')

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

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    local speed = {}
    local damage = {}
    local movement = {}

    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function()
            local unit = GetAttacker()
            local level = GetUnitAbilityLevel(unit, ABILITY)

            if level > 0 then
                AddUnitBonus(unit, BONUS_ATTACK_SPEED, -speed[unit])
                AddUnitBonus(unit, BONUS_MOVEMENT_SPEED, -movement[unit])
                speed[unit] = ((100 - GetUnitLifePercent(unit)) * GetBonusAttackSpeed(level)) / GetHealthPercentage(level)
                movement[unit] = ((100 - GetUnitLifePercent(unit)) * GetBonusMovementSpeed(level)) / GetHealthPercentage(level)
                AddUnitBonus(unit, BONUS_MOVEMENT_SPEED, movement[unit])
                AddUnitBonus(unit, BONUS_ATTACK_SPEED, speed[unit])
            end
        end)

        RegisterAttackDamageEvent(function()
            local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)
            local amount = GetEventDamage()

            if level > 0 and amount > 0 then
                damage[Damage.source.unit] = ((100 - GetUnitLifePercent(Damage.source.unit)) * GetDamageBonus(level)) / GetHealthPercentage(level)
                BlzSetEventDamage(amount * (1 + damage[Damage.source.unit]))
            end
        end)

        RegisterUnitIndexEvent(function()
            local unit = GetIndexUnit()

            speed[unit] = 0
            damage[unit] = 0
            movement[unit] = 0
        end)
    end)
end