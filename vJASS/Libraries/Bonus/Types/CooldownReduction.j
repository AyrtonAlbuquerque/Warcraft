scope CooldownReductionBonus
    globals
        integer BONUS_COOLDOWN_REDUCTION
    endglobals
    
    private struct CooldownReduction extends Bonus
        method get takes unit u returns real
            return GetUnitCooldownReduction(u)
        endmethod

        method Set takes unit u, real value returns real
            call SetUnitCooldownReduction(u, value)

            return value
        endmethod

        method add takes unit u, real value returns real
            if value >= 0 then
                call UnitAddCooldownReduction(u, value)
            else
                call UnitRemoveCooldownReduction(u, -value)
            endif

            return value
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_COOLDOWN_REDUCTION = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endscope