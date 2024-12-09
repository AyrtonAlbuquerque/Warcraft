scope TenacityOffset
    globals
        integer BONUS_TENACITY_OFFSET
    endglobals
    
    private struct TenacityOffset extends Bonus
        method get takes unit u returns real
            return GetUnitTenacityOffset(u)
        endmethod

        method Set takes unit u, real value returns real
            call SetUnitTenacityOffset(u, value)
            
            return value
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_TENACITY_OFFSET = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endscope