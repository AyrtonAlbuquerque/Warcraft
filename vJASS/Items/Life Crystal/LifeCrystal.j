scope LifeCrystal
    struct LifeCrystal extends Item
        static constant integer code = 'I00B'

        real health = 100

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope