scope AssassinsDagger
    struct AssassinsDagger extends Item
        static constant integer code = 'I01R'

        real damage = 5
        real evasionChance = 10

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope