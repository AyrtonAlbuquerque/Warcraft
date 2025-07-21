scope CooldownReductionBonus
    globals
        integer BONUS_COOLDOWN_OFFSET
        integer BONUS_COOLDOWN_REDUCTION
        integer BONUS_COOLDOWN_REDUCTION_FLAT
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

    private struct CooldownReduction extends Bonus
        method get takes unit u returns real
            return GetUnitCooldownReduction(u)
        endmethod

        method Set takes unit u, real value returns real
            call SetUnitCooldownReduction(u, value)

            return value
        endmethod

        method add takes unit u, real value returns real
            if not UnitRemoveCooldownReduction(u, -value) then
                call UnitAddCooldownReduction(u, value)
            endif

            return value
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_COOLDOWN_REDUCTION = RegisterBonus(thistype.allocate())
        endmethod
    endstruct

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