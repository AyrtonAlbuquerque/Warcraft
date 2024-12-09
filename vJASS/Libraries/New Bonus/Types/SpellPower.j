scope SpellPower
    globals
        integer BONUS_SPELL_POWER
    endglobals
    
    private struct SpellPower extends Bonus
        readonly static real array power

        method get takes unit u returns real
            return power[GetUnitUserData(u)]
        endmethod

        method Set takes unit u, real value returns real
            set power[GetUnitUserData(u)] = value

            return value
        endmethod

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod

        private static method onInit takes nothing returns nothing
            set BONUS_SPELL_POWER = RegisterBonus(thistype.allocate())
        endmethod
    endstruct
endscope