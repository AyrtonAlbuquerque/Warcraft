scope SummoningBook
    struct SummoningBook extends Item
        static constant integer code = 'I01U'

        real spellPowerFlat = 15
        real cooldownReduction = 0.1

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope