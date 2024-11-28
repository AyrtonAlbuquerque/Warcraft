scope MageStaff
    struct MageStaff extends Item
        static constant integer code = 'I03G'

        real health = 275
        real intelligence = 8
        real spellVamp = 0.05
        real spellPowerFlat = 25

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, BraceletOfIntelligence.code, FusedLifeCrystals.code, MageStick.code, 0, 0)
        endmethod
    endstruct
endscope