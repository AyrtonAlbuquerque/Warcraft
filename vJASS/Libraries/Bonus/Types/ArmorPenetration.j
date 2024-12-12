scope ArmorPenetration
    globals
        integer BONUS_ARMOR_PENETRATION
    endglobals
    
    private struct ArmorPenetration extends Bonus
        method get takes unit u returns real
            return GetUnitArmorPenetration(u, false)
        endmethod

        method Set takes unit u, real value returns real
            return SetUnitArmorPenetration(u, value, false)
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod

        private static method onInit takes nothing returns nothing
            set BONUS_ARMOR_PENETRATION = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endscope