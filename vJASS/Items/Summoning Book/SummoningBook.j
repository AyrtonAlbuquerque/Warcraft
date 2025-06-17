scope SummoningBook
    struct SummoningBook extends Item
        static constant integer code = 'I01U'

        real spellPower = 15
        real cooldownReduction = 0.1

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope