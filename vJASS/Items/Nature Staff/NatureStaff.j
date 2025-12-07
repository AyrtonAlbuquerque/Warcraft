scope NatureStaff
    struct NatureStaff extends Item
        static constant integer code = 'I044'

        real health = 300
        real spellPower = 40
        real intelligence = 10

        private static method onDamage takes nothing returns nothing
            if Damage.amount > 0 and Damage.isEnemy and UnitHasItemOfType(Damage.source.unit, code) then
                set Damage.amount = Damage.amount * 1.1
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellDamagingEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), OrbOfThorns.code, MageStaff.code, 0, 0, 0)
        endmethod
    endstruct
endscope