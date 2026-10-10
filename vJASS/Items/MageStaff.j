scope MageStaff
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private function GetBonus takes unit source returns real
        return 2. * GetWidgetLevel(source)
    endfunction

    private function GetBonusDuration takes unit source returns real
        return 20.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    struct MageStaff extends Item
        static constant integer code = 'I018'

        real spellPower = 25
        real intelligence = 10
        real magicPenetrationFlat = 3

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc0025|r Spell Power\n+ |cffffcc0010|r Intelligence\n+ |cffffcc003|r Magic Penetration\n\n|cff00ff00Passive|r: |cffffcc00Power Surge|r: After casting an ability gain |cff00ffff" + N2S(GetBonus(u), 0) + " Spell Power|r for |cffffcc00" + N2S(GetBonusDuration(u), 0) + "|r seconds." 
        endmethod

        private static method onCast takes nothing returns nothing
            if UnitHasItemOfType(Spell.source.unit, code) then
                call AddUnitBonusTimed(Spell.source.unit, BONUS_SPELL_POWER, GetBonus(Spell.source.unit), GetBonusDuration(Spell.source.unit))
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), BraceletOfIntelligence.code, MageStick.code, MageStick.code, 0, 0)
            call RegisterAnySpellEvent(function thistype.onCast)
        endmethod
    endstruct
endscope