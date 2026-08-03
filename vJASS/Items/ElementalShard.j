scope ElementalShard
    struct ElementalShard extends Item
        static constant integer code = 'I00Z'

        real mana = 250
        real health = 250
        real manaRegen = 2
        real healthRegen = 4

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), LifeCrystal.code, ManaCrystal.code, HealingCrystal.code, 0, 0)
        endmethod
    endstruct
endscope