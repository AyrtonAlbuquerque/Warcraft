scope CrystalRing
    struct CrystalRing extends Item
        static constant integer code = 'I00K'

        real manaRegen = 1
        real spellPowerFlat = 10

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope