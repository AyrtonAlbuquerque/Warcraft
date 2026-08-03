scope HeavyHammer
    struct HeavyHammer extends Item
        static constant integer code = 'I00I'

        real damage = 5

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope