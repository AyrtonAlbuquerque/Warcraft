scope MaskOfMadness
    struct MaskOfMadness extends Item
        static constant integer code = 'I024'

        real lifeSteal = 0.1

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), MaskOfDeath.code, 0, 0, 0, 0)
        endmethod
    endstruct
endscope