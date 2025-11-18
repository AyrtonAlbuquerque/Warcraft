scope WarriorShield
    struct WarriorShield extends Item
        static constant integer code = 'I03D'

        real armor = 3
        real block = 30
        real health = 400

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), FusedLifeCrystals.code, GoldenPlatemail.code, HardenedShield.code, 0, 0)
        endmethod
    endstruct
endscope