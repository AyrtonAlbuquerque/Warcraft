scope BootsOfSpeed
    struct BootsOfSpeed extends Item
        static constant integer code= 'I00A'

        real movementSpeed = 25

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope