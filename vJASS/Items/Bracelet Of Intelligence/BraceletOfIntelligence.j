scope BraceletOfIntelligence
    struct BraceletOfIntelligence extends Item
        static constant integer code = 'I00H'

        real intelligence = 5

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope