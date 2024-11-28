scope MaskOfDeath
    struct MaskOfDeath extends Item
        static constant integer code = 'I00U'

        real lifeSteal = 0.05

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope