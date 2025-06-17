scope SimpleBow
    struct SimpleBow extends Item
        static constant integer code = 'I01T'

        real agility = 5

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope