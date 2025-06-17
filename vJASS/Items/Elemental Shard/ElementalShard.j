scope ElementalShard
    struct ElementalShard extends Item
        static constant integer code = 'I00T'

        real mana = 175
        real health = 175
        real manaRegen = 3
        real healthRegen = 3

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), LifeCrystal.code, ManaCrystal.code, LifeEssenceCrystal.code, CrystalRing.code, 0)
        endmethod
    endstruct
endscope