scope CrownOfIce
    struct CrownOfIce extends Item
        static constant integer code = 'I0AU'
    
        real damage = 1000
        real agility = 1000
        real strength = 1000
        real intelligence = 1000
        real spellPowerFlat = 2000
    
        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope