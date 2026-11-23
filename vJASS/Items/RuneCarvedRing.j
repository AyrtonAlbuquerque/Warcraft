scope RuneCarvedRing
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    function GetBonus takes unit source returns real
        return 0.02 * BlzGetUnitMaxMana(source)
    endfunction

    private function GetBonusMana takes unit source returns integer
        if IsUnitType(source, UNIT_TYPE_HERO) or GetWidgetLevel(source) >= 6 then
            return 10
        else
            return 3
        endif
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct RuneCarvedRing extends Item
        static constant integer code = 'I020'
        private static integer array bonus

        // Attributes
        real mana = 500
        real healing = 0.2
        real manaRegen = 8
        real spellPower = 50

        private unit unit
        private real regen

        private method destroy takes nothing returns nothing
            call AddUnitBonus(unit, BONUS_HEALTH_REGEN, -regen)

            set unit = null

            call deallocate()
        endmethod

        method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc00500|r Mana\n+ |cffffcc0020%|r Healing\n+ |cffffcc0050|r Spell Power\n+ |cffffcc008|r Mana Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Inner Focus|r: Gain |cff00ff00" + N2S(GetBonus(u), 0) + " Health Regeneration|r\n\n|cff00ff00Passive|r: |cffffcc00Limitless Flow|r: Killing an enemy unit increases |cff00ffffMax Mana|r by |cff00ffff3|r (|cff00ffff10|r for |cffffcc00Heroes|r or |cffffcc00High Level|r units).\n\nBonus Mana: |cff00ffff" + N2S(bonus[id], 0) + "|r"
        endmethod

        private method onPeriod takes nothing returns boolean
            local real value = GetBonus(unit)

            call AddUnitBonus(unit, BONUS_HEALTH_REGEN, value - regen)

            set regen = value

            return UnitHasItemOfType(unit, code)
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)

            if not HasStartedTimer(id) and BlzGetUnitMaxMana(u) > 0 then
                set this = thistype.allocate(0)
                set unit = u
                set regen = GetBonus(u)

                call AddUnitBonus(u, BONUS_HEALTH_REGEN, regen)
                call StartTimer(0.5, true, this, id)
            endif
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit source = GetKillingUnit()
            local integer id = GetUnitUserData(source)
            local integer mana

            if UnitHasItemOfType(source, code) then
                set mana = GetBonusMana(GetTriggerUnit())
                set bonus[id] = bonus[id] + mana

                call AddUnitBonus(source, BONUS_MANA, mana)
            endif

            set source = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), SphereOfPower.code, VitalityStone.code, PrismaticRing.code, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endscope