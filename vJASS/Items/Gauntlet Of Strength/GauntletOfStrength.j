scope GauntletOfStrength
    struct GauntletOfStrength extends Item
        static constant integer code = 'I00G'

        real strength = 5

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope