--[[ requires RegisterPlayerUnitEvent, NewBonus
    /* ----------------------- Sulfuras v1.5 by Chopinski ----------------------- */
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
    -- The amount of stacks Sulfuras trait has
    Sulfuras_stacks = {}
    
    -- Modify this function to change the amount of damage Ragnaros gains per kill
    local function GetBonus(level, unit)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
            return 5*level
        else
            return level
        end
    end

    -- Modify this function to change when Ragnaros gains bonus damage based
    -- on the Death Event.
    local function Filtered(killer, killed)
        return IsUnitEnemy(killed, GetOwningPlayer(killer)) and GetUnitAbilityLevel(killer, ABILITY) > 0
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function()
            local killed = GetDyingUnit()
            local killer = GetKillingUnit()
            local index  = GetUnitUserData(killer)
            local level  = GetUnitAbilityLevel(killer, ABILITY)
            local amount

            if Filtered(killer, killed) then
                if not Sulfuras_stacks[index] then Sulfuras_stacks[index] = 0 end
                amount = GetBonus(level, killed)
                Sulfuras_stacks[index] = Sulfuras_stacks[index] + amount

                AddUnitBonus(killer, BONUS_DAMAGE, amount)
                if CHANGE_TOOLTIP then
                    local string = ("|cffffcc00Ragnaros|r gains |cffffcc001 damage (5 for Heroes)|r for every enemy unit killed by him.\n\n" ..
                    "Damage Bonus: |cffffcc00" .. I2S(Sulfuras_stacks[index]) .. "|r")

                    BlzSetAbilityExtendedTooltip(ABILITY, string, level - 1)
                end
            end
        end)
    end)
end