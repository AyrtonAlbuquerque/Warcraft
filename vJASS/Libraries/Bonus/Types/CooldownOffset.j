scope CooldownOffset
    globals
        integer BONUS_COOLDOWN_OFFSET
    endglobals
    
    private struct CooldownOffset extends Bonus
        method get takes unit u returns real
            return GetUnitCooldownOffset(u)
        endmethod

        method Set takes unit u, real value returns real
            call SetUnitCooldownOffset(u, value)
            
            return value
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_COOLDOWN_OFFSET = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endscope