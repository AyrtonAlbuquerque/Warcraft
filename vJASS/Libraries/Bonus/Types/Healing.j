library Healing requires Heal, NewBonus
    globals
        // The healing bonus
        integer BONUS_HEALING
        // The healing reduction bonus
        integer BONUS_HEALING_REDUCTION
    endglobals

    private struct Healing extends Bonus
        method get takes unit u returns real
            return GetUnitHealingIncrease(u)
        endmethod

        method Set takes unit u, real value returns real
            call SetUnitHealingIncrease(u, value)

            return value
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_HEALING = RegisterBonus(thistype.allocate())
        endmethod
    endstruct

    private struct HealingReduction extends Bonus
        method get takes unit u returns real
            return GetUnitHealingDecrease(u)
        endmethod

        method Set takes unit u, real value returns real
            call SetUnitHealingDecrease(u, value)

            return value
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_HEALING_REDUCTION = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endlibrary