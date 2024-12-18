scope MageStick
    struct MageStick extends Item
        static constant integer code = 'I02G'

        real mana = 150
        real manaRegen = 1.5
        real spellPower = 20

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, ManaCrystal.code, ManaCrystal.code, CrystalRing.code, 0, 0)
        endmethod
    endstruct
endscope