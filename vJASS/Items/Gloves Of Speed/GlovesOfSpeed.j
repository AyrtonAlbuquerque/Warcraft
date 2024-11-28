scope GlovesOfSpeed
    struct GlovesOfSpeed extends Item
        static constant integer code = 'I02A'

        real attackSpeed = 0.25

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, GlovesOfHaste.code, GlovesOfHaste.code, 0, 0, 0)
        endmethod
    endstruct
endscope