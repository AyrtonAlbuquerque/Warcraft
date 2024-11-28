scope IronAxe
    struct IronAxe extends Item
        static constant integer code = 'I01S'

        real damage = 5
        real criticalChance = 10
        real criticalDamage = 0.2

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope