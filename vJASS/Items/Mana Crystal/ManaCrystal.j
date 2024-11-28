scope ManaCrystal
    struct ManaCrystal extends Item
        static constant integer code = 'I00J'

        real mana = 100

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope