scope GobletOfFire
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetSpellPowerFactor takes nothing returns real
        return 0.3
    endfunction

    private constant function GetManaFactor takes nothing returns real
        return 0.3
    endfunction

    private constant function GetDuration takes nothing returns real
        return 6.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct GobletOfFire extends Item
        static constant integer code = 'I01T'
        private static integer array array
        private static effect array effect
        private static real array power

        // Attributes
        real mana = 1000
        real health = 1000
        real manaRegen = 10

        private unit unit
        private real regen
        private real bonus
        private timer timer
        private integer index
        private real duration

        private method destroy takes nothing returns nothing
            call ReleaseTimer(timer)
            call AddUnitBonus(unit, BONUS_SPELL_POWER, -bonus)

            set array[index] = array[index] - 1
            set power[index] = power[index] - bonus

            if array[index] <= 0 then
                call DestroyEffect(effect[index])
                set effect[index] = null
            endif

            set unit = null
            set timer = null

            call deallocate()
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc001000|r Mana\n+ |cffffcc001000|r Health\n+ |cffffcc0010|r Mana Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Binding Vow|r: After casting an ability gain |cffffcc00" + N2S(GetManaFactor() * 100, 0) + "%|r of its |cff00ffffMana Cost|r as |cff00ffffSpell power|r and recover the same amount of mana over |cffffcc00" + N2S(GetDuration(), 0) + "|r seconds.\n\nBonus |cff00ffffSpell Power|r: " + N2S(power[id], 0)
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            if duration > 0 then
                call HealUnit(unit, unit, regen, MANA, false)
            else
                call destroy()
            endif

            set duration = duration - 1
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this

            if UnitHasItemOfType(Spell.source.unit, code) and Spell.cooldown > 0 and Spell.cost > 0 then
                set this = thistype.allocate(0)
                set unit = Spell.source.unit
                set index = Spell.source.id
                set timer = NewTimerEx(this)
                set duration = GetDuration()
                set bonus = Spell.cost * GetSpellPowerFactor()
                set regen = (Spell.cost * GetManaFactor()) / duration

                if array[Spell.source.id] == 0 then
                    set effect[Spell.source.id] = AddSpecialEffectTarget("Abilities\\Spells\\Other\\Drain\\ManaDrainTarget.mdl", Spell.source.unit, "origin")
                endif

                set array[Spell.source.id] = array[Spell.source.id] + 1
                set power[Spell.source.id] = power[Spell.source.id] + bonus

                call AddUnitBonus(Spell.source.unit, BONUS_SPELL_POWER, bonus)
                call TimerStart(timer, 1, true, function thistype.onPeriod)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), ManaCrystal.code, ElementalShard.code, AncientStone.code, 0, 0)
            call RegisterAnySpellEvent(function thistype.onCast)
        endmethod
    endstruct
endscope