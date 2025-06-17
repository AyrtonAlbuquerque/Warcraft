scope GlaiveScythe
    struct GlaiveScythe extends Item
        static constant integer code = 'I02D'

        real agility = 7
        real strength = 7
        real intelligence = 7

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), BraceletOfIntelligence.code, GauntletOfStrength.code, ClawsOfAgility.code, 0, 0)
        endmethod
    endstruct
endscope