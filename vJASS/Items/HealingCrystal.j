scope HealingCrystal
    struct HealingCrystal extends Item
        static constant integer code = 'I00C'

        real manaRegen = 1
        real healthRegen = 2

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope