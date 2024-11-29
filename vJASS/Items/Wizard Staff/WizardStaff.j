scope WizardStaff
    struct WizardStaff extends Item
        static constant integer code = 'I07R'
        static integer array bonus

        real health = 10000
        real intelligence = 250
        real manaRegen = 300
        real spellPowerFlat = 750

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc00750|r Spell Power\n+ |cffffcc00250|r Intelligence\n+ |cffffcc0010000|r Health\n+ |cffffcc00300|r Mana Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Spell Vamp|r: Dealing |cff00ffffMagical|r damage, heals for |cffffcc005%%|r of damage dealt.\n\n|cff00ff00Passive|r: |cffffcc00Sorcery Mastery|r: After casting an ability, |cff00ffffSpell Power|r is increased by |cffffcc0025|r permanently.\n\nSpell Power Bonus: |cffffcc00" + I2S(bonus[id]) + "|r")
        endmethod

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer index = GetUnitUserData(caster)
            local integer id = GetSpellAbilityId()
            local boolean potion = id == 'AIre'
            local boolean blink = id == 'A00H'

            if UnitHasItemOfType(caster, code) and not potion and not blink then
                set bonus[index] = bonus[index] + 25
                call UnitAddSpellPowerFlat(caster, 25)
            endif

            set caster = null
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, SphereOfPower.code, SorcererStaff.code, 0, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
        endmethod
    endstruct
endscope