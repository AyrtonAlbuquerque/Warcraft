scope Omnivamp
    globals
        integer BONUS_OMNIVAMP
    endglobals
    
    private struct Omnivamp extends Bonus
        readonly static real array vamp

        method get takes unit u returns real
            return vamp[GetUnitUserData(u)]
        endmethod

        method Set takes unit u, real value returns real
            set vamp[GetUnitUserData(u)] = value

            return value
        endmethod  

        method add takes unit u, real value returns real
            call Set(u, get(u) + value)

            return value
        endmethod

        private static method onDamage takes nothing returns nothing
            if Damage.amount > 0 and vamp[Damage.source.id] > 0 and not Damage.target.isStructure then
                call SetWidgetLife(Damage.source.unit, (GetWidgetLife(Damage.source.unit) + (Damage.amount * vamp[Damage.source.id])))
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set BONUS_OMNIVAMP = RegisterBonus(thistype.allocate())
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope