scope HomecomingOrb
    struct HomecomingOrb extends Item
        static constant integer code = 'I00F'

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope