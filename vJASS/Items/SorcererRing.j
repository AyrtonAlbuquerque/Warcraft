scope SorcererRing
    struct SorcererRing extends Item
        static constant integer code = 'I00K'

        real manaRegen = 0.5
        real spellPower = 10

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope