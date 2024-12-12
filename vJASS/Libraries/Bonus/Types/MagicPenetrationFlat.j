scope MagicPenetrationFlat
    globals
        integer BONUS_MAGIC_PENETRATION_FLAT
    endglobals
    
    private struct MagicPenetrationFlat extends Bonus
        method get takes unit u returns real
            return GetUnitMagicPenetration(u, true)
        endmethod

        method Set takes unit u, real value returns real
            return SetUnitMagicPenetration(u, value, true)
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod

        private static method onInit takes nothing returns nothing
            set BONUS_MAGIC_PENETRATION_FLAT = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endscope