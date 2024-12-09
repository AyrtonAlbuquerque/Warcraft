scope MissChance
    globals
        integer BONUS_MISS_CHANCE
    endglobals
    
    private struct Miss extends Bonus
        method get takes unit u returns real
            return GetUnitMissChance(u)
        endmethod

        method Set takes unit u, real value returns real
            return SetUnitMissChance(u, value)
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod
    
        private static method onInit takes nothing returns nothing
            set BONUS_MISS_CHANCE = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endscope