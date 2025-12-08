scope GoldenHeart
    struct GoldenHeart extends Item
        static constant integer code = 'I0AV'
    
        real armor = 25
        real health = 2500
    
        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope