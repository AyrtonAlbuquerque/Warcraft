scope TenacityBonus
    globals
        integer BONUS_TENACITY
        integer BONUS_TENACITY_FLAT
        integer BONUS_TENACITY_OFFSET
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