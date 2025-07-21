library Sulfuras requires RegisterPlayerUnitEvent, Spell, NewBonus, Utilities
    /* ---------------------------------------- Sulfuras v1.6 --------------------------------------- */
    // Credits: 
    //     Blizzard      - icon (Edited by me)
    //     Magtheridon96 - RegisterPlayerUnitEvent
    /* ---------------------------------------- By Chopinski ---------------------------------------- */
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        //The raw code of the Sufuras Ability
        private constant integer ABILITY = 'A000'
    endglobals

    //Modify this function to change the amount of damage Ragnaros gains per kill
    private function GetBonus takes unit source, integer level returns integer
        if IsUnitType(source, UNIT_TYPE_HERO) then
            return 5*level
        else
            return 1
        endif
    endfunction

    // Every GetStackCount number of kills the damage will be increased by GetBonus
    private function GetStackCount takes unit source, integer level returns integer
        return 3 + 0*level
    endfunction

    //Modify this function to change when Ragnaros gains bonus damage based on the Death Event.
    private function UnitFilter takes player owner, unit target returns boolean
        return IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    struct Sulfuras extends Spell
        private static integer array count
        readonly static integer array stacks

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Ragnaros|r gains |cffffcc001|r damage for every |cffffcc00" + N2S(GetStackCount(source, level), 0) + "|r enemy unit killed by him. Hero kills grants |cffffcc005|r bonus damage.\n\nDamage Bonus: |cffffcc00" + I2S(stacks[GetUnitUserData(source)]) + "|r"
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit source = GetKillingUnit()
            local unit target
            local integer key
            local integer level
            local integer amount

            if GetUnitAbilityLevel(source, ABILITY) > 0 then
                set target = GetDyingUnit()

                if UnitFilter(GetOwningPlayer(source), target) then
                    set key = GetUnitUserData(source)
                    set level = GetUnitAbilityLevel(source, ABILITY)

                    if IsUnitType(target, UNIT_TYPE_HERO) then
                        set amount = GetBonus(target, level)
                        set stacks[key] = stacks[key] + amount

                        call AddUnitBonus(source, BONUS_DAMAGE, amount)
                    else
                        set count[key] = count[key] + 1

                        if count[key] >= GetStackCount(source, level) then
                            set count[key] = 0
                            set amount = GetBonus(target, level)
                            set stacks[key] = stacks[key] + amount

                            call AddUnitBonus(source, BONUS_DAMAGE, amount)
                        endif
                    endif
                endif
            endif

            set source = null
            set target = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endlibrary