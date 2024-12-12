scope MagicPenetration
    globals
        integer BONUS_MAGIC_PENETRATION
    endglobals
    
    private struct MagicPenetration extends Bonus
        method get takes unit u returns real
            return GetUnitMagicPenetration(u, false)
        endmethod

        method Set takes unit u, real value returns real
            return SetUnitMagicPenetration(u, value, false)
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod

        private static method onInit takes nothing returns nothing
            set BONUS_MAGIC_PENETRATION = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endscope