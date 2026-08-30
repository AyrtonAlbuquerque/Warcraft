library Shielding requires Shield, NewBonus
    globals
        // The shielding bonus
        integer BONUS_SHIELDING
        // The shielding reduction bonus
        integer BONUS_SHIELDING_REDUCTION
    endglobals

    private struct Shielding extends Bonus
        method get takes unit u returns real
            return GetUnitShieldingIncrease(u)
        endmethod

        method Set takes unit u, real value returns real
            call SetUnitShieldingIncrease(u, value)

            return value
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_SHIELDING = RegisterBonus(thistype.allocate())
        endmethod
    endstruct

    private struct ShieldingReduction extends Bonus
        method get takes unit u returns real
            return GetUnitShieldingDecrease(u)
        endmethod

        method Set takes unit u, real value returns real
            call SetUnitShieldingDecrease(u, value)

            return value
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_SHIELDING_REDUCTION = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endlibrary