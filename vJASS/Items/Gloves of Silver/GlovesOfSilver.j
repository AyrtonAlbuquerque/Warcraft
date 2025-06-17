scope GlovesOfSilver
    struct GlovesOfSilver extends Item
        static constant integer code = 'I03A'

        real attackSpeed = 0.5

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), GlovesOfSpeed.code, GlovesOfSpeed.code, 0, 0, 0)
        endmethod
    endstruct
endscope