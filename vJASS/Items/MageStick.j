scope MageStick
    struct MageStick extends Item
        static constant integer code = 'I00D'

        real spellPower = 15

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope