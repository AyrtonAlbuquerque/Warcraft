scope GoldenPlatemail
    struct GoldenPlatemail extends Item
        static constant integer code = 'I01D'

        real armor = 3
        real health = 225

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, LifeCrystal.code, Platemail.code, Platemail.code, 0, 0)
        endmethod
    endstruct
endscope