scope VitalityStone
    struct VitalityStone extends Item
        static constant integer code = 'I01D'

        real healing = 0.15
        real shielding = 0.15

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope