--[[ requires Evasion, NewBonusUtils
    /* -------------------- Adapted Warrior v1.2 by Chopinski ------------------- */
    // Credits:
    //     FrIkY          - Icon
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Adapted Warrior ability
    local ABILITY = FourCC('A000')

    -- The Attack Speed bonus amount
    local function GetAttackSpeedBonus(level)
        return 0.05 + 0.*level
    end

    -- The Attack Speed bonus duration
    local function GetAttackSpeedDuration(level)
        return 10. + 0.*level
    end

    -- The Movement Speed bonus amount
    local function GetMovementSpeedBonus(level)
        return 5 + 0*level
    end

    -- The Movement Speed bonus duration
    local function GetMovementSpeedDuration(level)
        return 10. + 0.*level
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterEvasionEvent(function()
            local source = GetMissingUnit()
            local target = GetEvadingUnit()
            local level = GetUnitAbilityLevel(target, ABILITY)
        
            if level > 0 and IsUnitEnemy(target, GetOwningPlayer(source)) then
                AddUnitBonusTimed(target, BONUS_ATTACK_SPEED, GetAttackSpeedBonus(level), GetAttackSpeedDuration(level))
                AddUnitBonusTimed(target, BONUS_MOVEMENT_SPEED, GetMovementSpeedBonus(level), GetMovementSpeedDuration(level))
            end
        end)
    end)
end