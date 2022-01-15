library Sulfuras requires RegisterPlayerUnitEvent, NewBonus
    /* ----------------------- Sulfuras v1.5 by Chopinski ----------------------- */
    // Credits: 
    //     Blizzard      - icon (Edited by me)
    //     Magtheridon96 - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        //The raw code of the Sufuras Ability
        private constant integer ABILITY       = 'A000'
        //If true when Ragnaros kills a unit, the ability tooltip will change
        //to show the amount of bonus damage acumulated
        private constant boolean CHANGE_TOOLTIP = true
        // The amount of stacks Sulfuras trait has
        public integer array     stacks
    endglobals

    //Modify this function to change the amount of damage Ragnaros gains per kill
    private function GetBonus takes integer level, unit dying returns integer
        if IsUnitType(dying, UNIT_TYPE_HERO) then
            return 5*level
        else
            return level
        endif
    endfunction

    //Modify this function to change when Ragnaros gains bonus damage based
    //on the Death Event.
    private function Filtered takes unit killing, unit dying returns boolean
        return IsUnitEnemy(dying, GetOwningPlayer(killing)) and GetUnitAbilityLevel(killing, ABILITY) > 0
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Sulfuras
        private static method toolTip takes integer bonus, integer lvl returns nothing
            local string s 

            set s = ("|cffffcc00Ragnaros|r gains |cffffcc001 damage (5 for Heroes)|r for every enemy unit killed by him.

Damage Bonus: |cffffcc00" + I2S(bonus) + "|r")
            call BlzSetAbilityExtendedTooltip(ABILITY, s, lvl - 1)
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit    killed = GetDyingUnit()
            local unit    killer = GetKillingUnit()
            local integer index  = GetUnitUserData(killer)
            local integer level  = GetUnitAbilityLevel(killer, ABILITY)
            local integer amount

            if Filtered(killer, killed) then
                set amount        = GetBonus(level, killed)
                set stacks[index] = stacks[index] + amount

                call AddUnitBonus(killer, BONUS_DAMAGE, amount)
                if CHANGE_TOOLTIP then
                    call toolTip(stacks[index], level)
                endif
            endif

            set killer = null
            set killed = null
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endlibrary