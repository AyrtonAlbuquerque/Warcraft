scope AncientStone
    struct AncientStone extends Item
        static constant integer code = 'I01I'

        real mana = 600
        real health = 600
        real manaRegen = 10
        real spellPower = 50
        real healthRegen = 10

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), WizardStone.code, 0, 0, 0, 0)
        endmethod
    endstruct
endscope