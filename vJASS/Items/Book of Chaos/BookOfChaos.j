scope BookOfChaos
    struct BookOfChaos extends Item
        static constant integer code = 'I06N'
        static constant integer buff = 'B00C'

        real armor = 6
        real spellPower = 70
        real intelligence = 15
        real cooldownReduction = 0.15

        private static method onCast takes nothing returns nothing
            if GetUnitAbilityLevel(Spell.source.unit, buff) > 0 then
                call LinkBonusToBuff(Spell.source.unit, BONUS_ARMOR, 1, buff)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
            call RegisterItem(allocate(code), SummoningBook.code, SphereOfDarkness.code, 0, 0, 0)
        endmethod
    endstruct
endscope