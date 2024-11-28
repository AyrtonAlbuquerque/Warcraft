scope FusedLifeCrystals
    struct FusedLifeCrystals extends Item
        static constant integer code = 'I01G'

        real health = 350

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, LifeCrystal.code, LifeCrystal.code, LifeCrystal.code, 0, 0)
        endmethod
    endstruct
endscope