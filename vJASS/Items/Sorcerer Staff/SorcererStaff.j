scope SorcererStaff
    struct SorcererStaff extends Item
        static constant integer code = 'I068'

        // Attributes
        real health = 5000
        real spellPower = 500
        real intelligence = 150

        private static HashTable table
        private static integer array bonus

        private integer index

        method destroy takes nothing returns nothing
            set bonus[index] = bonus[index] - 250

            if bonus[index] == 0 then
                call DestroyEffect(table[index].effect[0])
                call DestroyEffect(table[index].effect[1])
                set table[index].effect[0] = null
                set table[index].effect[1] = null
            endif

            call super.destroy()
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc00500|r Spell Power\n+ |cffffcc00150|r Intelligence\n+ |cffffcc005000|r Health\n\n|cff00ff00Passive|r: |cffffcc00Spell Vamp|r: Dealing |cff0000ffMagical|r damage, heals for |cffffcc002.5%%|r of damage dealt.\n\n|cff00ff00Passive|r: |cffffcc00Sorcerer Trait|r: After casting an ability, |cff0000ffSpell Power|r is increased by |cffffcc00250|r for |cffffcc0015|r seconds.\n\nCurrent Spell Power Bonus: |cff0080ff" + R2I2S(bonus[id]) + "|r")
        endmethod

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local thistype this

            if UnitHasItemOfType(caster, code) then
                set this = thistype.new()
                set index = GetUnitUserData(caster)
                set bonus[index] = bonus[index] + 250

                call StartTimer(15, false, this, -1)
                call AddUnitBonusTimed(caster, BONUS_SPELL_POWER_FLAT, 250, 15)

                if bonus[index] == 250 then
                    set table[index].effect[0] = AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdx", caster, "hand left")
                    set table[index].effect[1] = AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdx", caster, "hand right")
                endif
            endif

            set caster = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            set table = HashTable.create()

            call thistype.allocate(code, MageStaff.code, SphereOfPower.code, 0, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
        endmethod
    endstruct
endscope