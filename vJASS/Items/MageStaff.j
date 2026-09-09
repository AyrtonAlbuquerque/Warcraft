scope MageStaff
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private function GetHeal takes unit source returns real
        return 5. * GetWidgetLevel(source)
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    struct MageStaff extends Item
        static constant integer code = 'I018'
        static constant string effect = "Abilities\\Spells\\Human\\Heal\\HealTarget.mdl"

        real mana = 250
        real spellPower = 25
        real intelligence = 10

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc0025|r Spell Power\n+ |cffffcc0010|r Intelligence\n+ |cffffcc00250|r Mana\n\n|cff00ff00Passive|r: |cffffcc00Revitalize|r: After casting an ability heals for |cffff0000" + N2S(GetHeal(u), 0) + " Health|r."  
        endmethod

        private static method onCast takes nothing returns nothing
            if UnitHasItemOfType(Spell.source.unit, code) then
                if HealUnit(Spell.source.unit, Spell.source.unit, GetHeal(Spell.source.unit), HEALTH, false) then
                    call DestroyEffect(AddSpecialEffectTarget(effect, Spell.source.unit, "origin"))
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), BraceletOfIntelligence.code, ManaCrystal.code, MageStick.code, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
        endmethod
    endstruct
endscope