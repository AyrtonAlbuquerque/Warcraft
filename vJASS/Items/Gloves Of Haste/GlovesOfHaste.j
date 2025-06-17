scope GlovesOfHaste
    struct GlovesOfHaste extends Item
        static constant integer code = 'I00C'

        real attackSpeed = 0.1

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope