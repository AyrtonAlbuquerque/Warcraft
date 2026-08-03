scope GauntletOfStrength
    struct GauntletOfStrength extends Item
        static constant integer code = 'I008'

        real strength = 5

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope