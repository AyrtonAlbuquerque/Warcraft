scope AncientStone
    struct AncientStone extends Item
        static constant integer code = 'I05D'

        real mana = 500
        real health = 500
        real manaRegen = 10
        real healthRegen = 10
        real spellPowerFlat = 50

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, WizardStone.code, 0, 0, 0, 0)
        endmethod
    endstruct
endscope