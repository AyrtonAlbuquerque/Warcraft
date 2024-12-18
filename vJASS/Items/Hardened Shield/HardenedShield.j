scope HardenedShield
    struct HardenedShield extends Item
        static constant integer code = 'I017'

        real armor = 2
        real block = 15
        real health = 200

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, CommomShield.code, LifeCrystal.code, Platemail.code, 0, 0)
        endmethod
    endstruct
endscope