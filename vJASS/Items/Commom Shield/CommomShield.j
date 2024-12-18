scope CommomShield
    struct CommomShield extends Item
        static constant integer code = 'I016'

        real block = 10

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope