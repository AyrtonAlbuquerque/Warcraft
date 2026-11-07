scope EssenceStaff
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetBonusIntelligence takes nothing returns integer
        return 2
    endfunction

    private constant function GetBonusSpellPower takes nothing returns integer
        return 2
    endfunction

    private constant function GetBonusDamage takes nothing returns real
        return 0.15
    endfunction

    private constant function GetDuration takes nothing returns real
        return 10.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct EssenceStaff extends Item
        static constant integer code = 'I01Q'
        private static thistype array array
        private static real array power

        // Attributes
        real intelligence = 20
        real spellPower = 60
        real spellVamp = 0.04
        real magicPenetrationFlat = 5

        private unit unit
        private timer timer
        private integer index
        private integer bonus

        private method destroy takes nothing returns nothing
            call ReleaseTimer(timer)
            call SetUnitItemTypeCharges(unit, code, 0)
            call AddUnitBonus(unit, BONUS_INTELLIGENCE, -bonus)

            set unit = null
            set timer = null
            set array[index] = 0

            call deallocate()
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc0020|r Intelligence\n+ |cffffcc0060|r Spell Power\n+ |cffffcc004%|r Spell Vamp\n+ |cffffcc005|r Magic Penetration\n\n|cff00ff00Passive|r: |cffffcc00Essence Shift|r: After casting an ability gain |cff00ffff" + N2S(GetBonusIntelligence(), 0) + " Intelligence|r for |cffffcc00" + N2S(GetDuration(), 0) + "|r seconds and |cff00ffff" + N2S(GetBonusSpellPower(), 0) + " Spell Power|r permanently. Each kill refreshes the duration of |cff00ffffIntelligence|r gained.\n\n|cff00ff00Passive|r: |cffffcc00Intelect Supremacy|r: Increases |cff00ffffMagic|r damage by |cffffcc00" + N2S(GetBonusDamage() * 100, 0) + "%|r to enemy units with less |cff00ffffIntelligence|r.\n\nBonus |cff00ffffSpell Power|r: " + N2S(power[id], 0)
        endmethod

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call destroy()
        endmethod

        private method onPickup takes unit u, item i returns nothing
            set this = array[GetUnitUserData(u)]

            if this != 0 and GetItemTypeId(i) == code then
                call SetItemCharges(i, bonus)
            endif
        endmethod

        private method onDrop takes unit u, item i returns nothing
            set this = array[GetUnitUserData(u)]

            if this != 0 and GetItemTypeId(i) == code then
                call SetItemCharges(i, 0)
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = array[Spell.source.id]

            if UnitHasItemOfType(Spell.source.unit, code) and Spell.cooldown > 0 then
                if this == 0 then
                    set this = thistype.allocate(0)
                    set unit = Spell.source.unit
                    set index = Spell.source.id
                    set bonus = 0
                    set timer = NewTimerEx(this)
                    set array[Spell.source.id] = this
                endif

                set bonus = bonus + GetBonusIntelligence()
                set power[Spell.source.id] = power[Spell.source.id] + GetBonusSpellPower()

                call AddUnitBonus(Spell.source.unit, BONUS_SPELL_POWER, GetBonusSpellPower())
                call AddUnitBonus(Spell.source.unit, BONUS_INTELLIGENCE, GetBonusIntelligence())
                call SetUnitItemTypeCharges(Spell.source.unit, code, bonus)
                call TimerStart(timer, GetDuration(), false, function thistype.onExpire)
            endif
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.source.intelligence > Damage.target.intelligence then
                set Damage.amount = Damage.amount * (1 + GetBonusDamage())
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), SphereOfPower.code, MageStaff.code, PendantOfVigor.code, 0, 0)
            call RegisterSpellDamagingEvent(function thistype.onDamage)
            call RegisterAnySpellEvent(function thistype.onCast)
        endmethod
    endstruct
endscope