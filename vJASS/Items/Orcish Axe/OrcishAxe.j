scope OrcishAxe
    struct OrcishAxe extends Item
        static constant integer code = 'I02S'

        real damage = 28
        real criticalChance = 0.12
        real criticalDamage = 0.3

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, IronAxe.code, GoldenSword.code, 0, 0, 0)
        endmethod
    endstruct
endscope