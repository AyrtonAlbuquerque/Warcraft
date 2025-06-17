scope Platemail
    struct Platemail extends Item
        static constant integer code = 'I00F'

        real armor = 2

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope