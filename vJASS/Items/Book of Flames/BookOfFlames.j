scope BookOfFlames
    struct BookOfFlames extends Item
        static constant integer code = 'I06B'
        static constant integer buff = 'B001'
        static constant integer ability = 'A04E'

        real cooldownReduction = 0.15
        real intelligence = 15
        real spellPower = 70
        real damage = 25

        private static method onDamage takes nothing returns nothing
            if GetUnitAbilityLevel(Damage.source.unit, buff) > 0 then
                set Damage.amount = Damage.amount * 1.15
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellDamagingEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), SummoningBook.code, SphereOfFire.code, 0, 0, 0)
        endmethod
    endstruct
endscope