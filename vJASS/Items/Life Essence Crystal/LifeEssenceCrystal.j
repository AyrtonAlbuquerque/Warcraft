scope LifeEssenceCrystal
    struct LifeEssenceCrystal extends Item
        static constant integer code = 'I00L'

        real healthRegen = 2

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope