scope AssassinsDagger
    struct AssassinsDagger extends Item
        static constant integer code = 'I01R'

        real damage = 5
        real evasion = 0.1

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope