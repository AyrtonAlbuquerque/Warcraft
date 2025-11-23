scope BookOfLight
    struct BookOfLight extends Item
        static constant integer code = 'I06K'
        static constant integer ability = 'A04H'
        static constant integer buff = 'B00B'

        real manaRegen = 10
        real intelligence = 15
        real spellPower = 70
        real cooldownReduction = 0.15
        
        private static method onCast takes nothing returns nothing
            call LinkBonusToBuff(Spell.source.unit, BONUS_OMNIVAMP, 0.15, buff)
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call RegisterItem(allocate(code), SummoningBook.code, SphereOfDivinity.code, 0, 0, 0)
        endmethod
    endstruct
endscope