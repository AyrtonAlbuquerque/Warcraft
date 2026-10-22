scope PrismaticRing
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private function GetHeal takes unit source returns real
        return 5. * GetWidgetLevel(source)
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    struct PrismaticRing extends Item
        static constant integer code = 'I01B'

        real mana = 300
        real manaRegen = 3
        real spellPower = 20

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc00300|r Mana\n+ |cffffcc0020|r Spell Power\n+ |cffffcc002|r Mana Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Recovery|r: After casting an ability |cff00ff00Heals|r for |cffff0000" + N2S(GetHeal(u), 0) + " Health|r."
        endmethod

        private static method onCast takes nothing returns nothing
            if UnitHasItemOfType(Spell.source.unit, code) and Spell.cooldown > 0 then
                if HealUnit(Spell.source.unit, Spell.source.unit, GetHeal(Spell.source.unit), HEALTH, false) then
                    call DestroyEffectTimed(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Heal\\HealTarget.mdl", Spell.source.unit, "origin"), 2)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), SorcererRing.code, ElementalShard.code, 0, 0, 0)
            call RegisterAnySpellEvent(function thistype.onCast)
        endmethod
    endstruct
endscope