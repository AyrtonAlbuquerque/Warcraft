scope ManaCrystal
    struct ManaCrystal extends Item
        static constant integer code = 'I003'

        real mana = 200

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope