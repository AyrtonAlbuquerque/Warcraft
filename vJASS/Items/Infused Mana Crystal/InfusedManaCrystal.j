scope InfusedManaCrystal
    struct InfusedManaCrystal extends Item
        static constant integer code = 'I027'

        real mana = 350

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, ManaCrystal.code, ManaCrystal.code, ManaCrystal.code, 0, 0)
        endmethod
    endstruct
endscope