scope RustySword
    struct RustySword extends Item
        static constant integer code = 'I00E'

        real damage = 7

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope