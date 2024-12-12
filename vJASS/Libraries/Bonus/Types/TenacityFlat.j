scope TenacityFlat
    globals
        integer BONUS_TENACITY_FLAT
    endglobals
    
    private struct TenacityFlat extends Bonus
        method get takes unit u returns real
            return GetUnitTenacityFlat(u)
        endmethod

        method Set takes unit u, real value returns real
            call SetUnitTenacityFlat(u, value)
            
            return value
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_TENACITY_FLAT = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endscope