scope IronAxe
    struct IronAxe extends Item
        static constant integer code = 'I01S'

        real damage = 5
        real criticalChance = 0.1
        real criticalDamage = 0.2

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope