scope SorcererStaff
    struct SorcererStaff extends Item
        static constant integer code = 'I068'
        static integer array bonus

        private static thistype array array
        private static integer key = -1
        private static timer timer = CreateTimer()
        private static HashTable table

        private unit unit
        private integer index
        private integer duration

        // Attributes
        real health = 5000
        real intelligence = 150
        real spellPowerFlat = 500

        private method remove takes integer i returns integer
            set bonus[index] = bonus[index] - 250
            call AddUnitBonus(unit, BONUS_SPELL_POWER_FLAT, -250)

            if bonus[index] == 0 then
                call DestroyEffect(table[index].effect[0])
                call DestroyEffect(table[index].effect[1])
                set table[index].effect[0] = null
                set table[index].effect[1] = null
            endif

            set array[i] = array[key]
            set key = key - 1
            set unit = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call super.destroy()

            return i - 1
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc00500|r Spell Power\n+ |cffffcc00150|r Intelligence\n+ |cffffcc005000|r Health\n\n|cff00ff00Passive|r: |cffffcc00Spell Vamp|r: Dealing |cff0000ffMagical|r damage, heals for |cffffcc002.5%|r of damage dealt.\n\n|cff00ff00Passive|r: |cffffcc00Sorcerer Trait|r: After casting an ability, |cff0000ffSpell Power|r is increased by |cffffcc00250|r for |cffffcc0015|r seconds.\n\nCurrent Spell Power Bonus: |cff0080ff" + R2I2S(bonus[id]) + "|r")
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer  i = 0
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if duration <= 0 then
                        set i = remove(i)
                    endif

                    set duration = duration - 1
                set i = i + 1
            endloop
        endmethod

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local thistype this

            if UnitHasItemOfType(caster, code) then
                set this = thistype.new()
                set unit = caster
                set index = GetUnitUserData(caster)
                set duration = 15
                set key = key + 1
                set array[key] = this
                set bonus[index] = bonus[index] + 250

                call AddUnitBonus(caster, BONUS_SPELL_POWER_FLAT, 250)

                if bonus[index] == 0 then
                    set table[index].effect[0] = AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdx", caster, "hand left")
                    set table[index].effect[1] = AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdx", caster, "hand right")
                endif

                if key == 0 then
                    call TimerStart(timer, 1, true, function thistype.onPeriod)
                endif
            endif

            set caster = null
        endmethod

        private static method onInit takes nothing returns nothing
            set table = HashTable.create()

            call thistype.allocate(code, MageStaff.code, SphereOfPower.code, 0, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
        endmethod
    endstruct
endscope