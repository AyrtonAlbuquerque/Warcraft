scope SorcererStaff
    struct SorcererStaff extends Item
        static constant integer code = 'I068'

        // Attributes
        real health = 300
        real spellPower = 50
        real spellVamp = 0.08
        real intelligence = 15

        private static HashTable table
        private static integer array bonus

        private integer index

        method destroy takes nothing returns nothing
            set bonus[index] = bonus[index] - 10

            if bonus[index] == 0 then
                call DestroyEffect(table[index].effect[0])
                call DestroyEffect(table[index].effect[1])
                set table[index].effect[0] = null
                set table[index].effect[1] = null
            endif

            call deallocate()
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc0050|r Spell Power\n+ |cffffcc008%%|r Spell Vamp\n+ |cffffcc0015|r Intelligence\n+ |cffffcc00300|r Health\n\n|cff00ff00Passive|r: |cffffcc00Sorcerer Trait|r: After casting an ability, |cff00ffffSpell Power|r is increased by |cff00ffff10|r for |cffffcc0015|r seconds.\n\nCurrent Spell Power Bonus: |cff00ffff" + N2S(bonus[id], 0) + "|r"
        endmethod

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local thistype this

            if UnitHasItemOfType(caster, code) then
                set this = thistype.allocate(0)
                set index = GetUnitUserData(caster)
                set bonus[index] = bonus[index] + 10

                call StartTimer(15, false, this, -1)
                call AddUnitBonusTimed(caster, BONUS_SPELL_POWER, 10, 15)

                if bonus[index] == 10 then
                    set table[index].effect[0] = AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdx", caster, "hand left")
                    set table[index].effect[1] = AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdx", caster, "hand right")
                endif
            endif

            set caster = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            set table = HashTable.create()

            call RegisterItem(allocate(code), MageStaff.code, SphereOfPower.code, 0, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
        endmethod
    endstruct
endscope