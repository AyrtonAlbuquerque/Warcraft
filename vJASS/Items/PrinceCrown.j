scope PrinceCrown
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetBonusSpellPower takes nothing returns real
        return 25.
    endfunction

    private constant function GetBonusSpellVamp takes nothing returns real
        return 0.05
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct PrinceCrown extends Item
        static constant integer code = 'I01G'
        static constant integer buff = 'B003'
        static constant integer ability = 'A008'

        // Attributes
        real spellPower = 25
        real intelligence = 10

        private static method onCast takes nothing returns nothing
            call LinkBonusToBuff(Spell.source.unit, BONUS_SPELL_POWER, GetBonusSpellPower(), buff)
            call LinkBonusToBuff(Spell.source.unit, BONUS_SPELL_VAMP, GetBonusSpellVamp(), buff)
        endmethod
        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), BraceletOfIntelligence.code, SorcererRing.code, SphereOfPower.code, 0, 0)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
        endmethod
    endstruct
endscope