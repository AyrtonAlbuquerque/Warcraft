scope CooldownReductionFlat
    globals
        integer BONUS_COOLDOWN_REDUCTION_FLAT
    endglobals
    
    private struct CooldownReductionFlat extends Bonus
        method get takes unit u returns real
            return GetUnitCooldownReductionFlat(u)
        endmethod

        method Set takes unit u, real value returns real
            call SetUnitCooldownReductionFlat(u, value)
            
            return value
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_COOLDOWN_REDUCTION_FLAT = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endscope