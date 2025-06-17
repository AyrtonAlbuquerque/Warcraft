scope GoldenSword
    struct GoldenSword extends Item
        static constant integer code = 'I01A'

        real damage = 24

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), RustySword.code, RustySword.code, RustySword.code, 0,  0)
        endmethod 
    endstruct 
endscope