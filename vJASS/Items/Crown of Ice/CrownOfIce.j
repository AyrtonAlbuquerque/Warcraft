scope CrownOfIce
    struct CrownOfIce extends Item
        static constant integer code = 'I0AU'
    
        real damage = 100
        real agility = 50
        real strength = 50
        real intelligence = 50
        real spellPower = 200
    
        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope