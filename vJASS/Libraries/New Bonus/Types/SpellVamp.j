scope SpellVamp
    globals
        integer BONUS_SPELL_VAMP
    endglobals
    
    private struct SpellVamp extends Bonus
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
            if Damage.amount > 0 and Damage.isSpell and vamp[Damage.source.id] > 0 and not Damage.target.isStructure then
                call SetWidgetLife(Damage.source.unit, (GetWidgetLife(Damage.source.unit) + (Damage.amount * vamp[Damage.source.id])))
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            set BONUS_SPELL_VAMP = RegisterBonus(thistype.allocate())
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope