scope TenacityBonus
    globals
        integer BONUS_TENACITY
    endglobals
    
    private struct Tenacity extends Bonus
        method get takes unit u returns real
            return GetUnitTenacity(u)
        endmethod

        method Set takes unit u, real value returns real
            call SetUnitTenacity(u, value)
            
            return value
        endmethod

        method add takes unit u, real value returns real
            if not UnitRemoveTenacity(u, -value) then
                call UnitAddTenacity(u, value)
            endif

            return value
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_TENACITY = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endscope