scope SorcererRing
    struct SorcererRing extends Item
        static constant integer code = 'I02J'

        real mana = 175
        real manaRegen = 3
        real spellPower = 20

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), ManaCrystal.code, CrystalRing.code, CrystalRing.code, 0, 0)
        endmethod
    endstruct
endscope