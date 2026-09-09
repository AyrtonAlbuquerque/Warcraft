scope GlovesOfSteel
    struct GlovesOfSteel extends Item
        static constant integer code = 'I015'

        real mana = 250
        real attackSpeed = 0.25

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), GlovesOfHaste.code, GlovesOfHaste.code, ManaCrystal.code, 0, 0)
        endmethod
    endstruct
endscope