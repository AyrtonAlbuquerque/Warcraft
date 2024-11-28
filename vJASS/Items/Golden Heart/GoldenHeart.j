scope GoldenHeart
    struct GoldenHeart extends Item
        static constant integer code = 'I0AV'
    
        real armor = 50
        real health = 50000
    
        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope