scope WizardStaff
    struct WizardStaff extends Item
        static constant integer code = 'I07R'
        static integer array bonus

        real health = 400
        real intelligence = 20
        real manaRegen = 15
        real spellPower = 90
        real spellVamp = 0.1

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc0090|r Spell Power\n+ |cffffcc0020|r Intelligence\n+ |cffffcc00400|r Health\n+ |cffffcc0015|r Mana Regeneration\n+ |cffffcc0010%%|r Spell Vamp\n\n|cff00ff00Passive|r: |cffffcc00Sorcery Mastery|r: After casting an ability, |cff00ffffSpell Power|r is increased by |cffffcc001|r permanently.\n\nSpell Power Bonus: |cff00ffff" + I2S(bonus[id]) + "|r"
        endmethod

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer index = GetUnitUserData(caster)
            local integer id = GetSpellAbilityId()
            local boolean potion = id == 'AIre'
            local boolean blink = id == 'A00H'

            if UnitHasItemOfType(caster, code) and not potion and not blink then
                set bonus[index] = bonus[index] + 1
                call AddUnitBonus(caster, BONUS_SPELL_POWER, 1)
            endif

            set caster = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), SphereOfPower.code, SorcererStaff.code, 0, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
        endmethod
    endstruct
endscope