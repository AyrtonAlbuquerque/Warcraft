scope WarlockRing
    struct WarlockRing extends Item
        static constant integer code = 'I09C'

        real mana = 1000
        real health = 800
        real manaRegen = 20
        real intelligence = 25

        private unit unit
        private real bonus

        method destroy takes nothing returns nothing
            call deallocate()

            set unit = null
        endmethod

        private method onPeriod takes nothing returns boolean
            local integer count = UnitCountItemOfType(unit, code)

			call AddUnitBonus(unit, BONUS_SPELL_POWER, -bonus)

            if count > 0 then
                set bonus = GetUnitBonus(unit, BONUS_SPELL_POWER) * 0.25 * count

                call AddUnitBonus(unit, BONUS_SPELL_POWER, bonus)
            endif

			return count > 0
		endmethod

        private method onPickup takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)

            if not HasStartedTimer(id) then
                set this = thistype.allocate(0)
                set unit = u
                set bonus = 0

                call StartTimer(1, true, this, id)
            endif
        endmethod 

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), SphereOfDarkness.code, MoonchantRing.code, 0, 0, 0)
        endmethod
    endstruct
endscope