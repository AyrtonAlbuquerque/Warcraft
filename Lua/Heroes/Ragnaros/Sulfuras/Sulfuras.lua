--[[ requires RegisterPlayerUnitEvent, NewBonus
    /* ----------------------- Sulfuras v1.6 by Chopinski ----------------------- */
    // Credits: 
    //     Blizzard      - icon (Edited by me)
    //     Magtheridon96 - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Sufuras Ability
    local ABILITY        = FourCC('A000')
    -- If true when Ragnaros kills a unit, the ability tooltip will change
    -- to show the amount of bonus damage acumulated
    local CHANGE_TOOLTIP = true
    
    -- Modify this function to change the amount of damage Ragnaros gains per kill
    local function GetBonus(unit, level)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
            return 5*level
        else
            return level
        end
    end

    -- Every GetStackCount number of kills the damage will be increased by GetBonus
    local function GetStackCount(unit, level)
        return 3 + 0*level
    end

    -- Modify this function to change when Ragnaros gains bonus damage based on the Death Event.
    local function UnitFilter(player, target)
        return IsUnitEnemy(target, player) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    Sulfuras = setmetatable({}, {})
    local mt = getmetatable(Sulfuras)
    mt.__index = mt

    Sulfuras.stacks = {}

    local count = {}
    
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function()
            local source = GetKillingUnit()

            if GetUnitAbilityLevel(source, ABILITY) > 0 then
                local target = GetDyingUnit()

                if UnitFilter(GetOwningPlayer(source), target) then
                    local level = GetUnitAbilityLevel(source, ABILITY)
                    local amount

                    if IsUnitType(target, UNIT_TYPE_HERO) then
                        amount = GetBonus(target, level)
                        Sulfuras.stacks[source] = (Sulfuras.stacks[source] or 0) + amount

                        AddUnitBonus(source, BONUS_DAMAGE, amount)
                    else
                        count[source] = (count[source] or 0) + 1

                        if count[source] >= GetStackCount(source, level) then
                            count[source] = 0
                            amount = GetBonus(target, level)
                            Sulfuras.stacks[source] = (Sulfuras.stacks[source] or 0) + amount

                            AddUnitBonus(source, BONUS_DAMAGE, amount)
                        end
                    end

                    if CHANGE_TOOLTIP then
                        local string = ("|cffffcc00Ragnaros|r gains |cffffcc001|r damage for every |cffffcc003|r enemy unit killed by him. Hero kills grants |cffffcc005|r bonus damage.\n\n" ..
                                "Damage Bonus: |cffffcc00" .. (Sulfuras.stacks[source] or 0) .. "|r")

                        BlzSetAbilityExtendedTooltip(ABILITY, string, level - 1)
                    end
                end
            end
        end)
    end)
end