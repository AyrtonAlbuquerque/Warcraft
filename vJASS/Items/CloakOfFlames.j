scope CloakOfFlames
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private function GetAoE takes unit source returns real
        return 250.
    endfunction

    private function GetDamage takes unit source returns real
        return (5 * GetWidgetLevel(source)) + (0.1 * GetUnitBonus(source, BONUS_SPELL_POWER))
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    struct CloakOfFlames extends Item
        static constant integer code = 'I00E'

        private unit unit
        private Group group
        private effect effect
        private player player

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call group.destroy()
            call deallocate()

            set unit = null
            set effect = null
            set player = null
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cff00ff00Passive:|r Engulfs the Hero in fire dealing |cff00ffff" + N2S(GetDamage(u), 0) + " Magic|r damage per second to enemy units within |cffffcc00" + N2S(GetAoE(u), 0) + " AoE|r."
        endmethod

        private static method onDamage takes thistype this, unit u returns nothing
            call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\Immolation\\ImmolationDamage.mdl", u, "chest"))
        endmethod

        private method onPeriod takes nothing returns boolean
            if UnitHasItemOfType(unit, code) then
                call group.inRange(GetUnitX(unit), GetUnitY(unit), GetAoE(unit))
                    .isAlive()
                    .enemyOf(player)
                    .isNot().ofType(UNIT_TYPE_STRUCTURE)
                    .damage(unit, GetDamage(unit), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, this, thistype.onDamage)
                    .clear()
            
                return true
            endif

            return false
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)

            if not HasStartedTimer(id) then
                set this = thistype.allocate(0)
                set unit = u
                set group = Group.create()
                set player = GetOwningPlayer(u)
                set effect = AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\Immolation\\ImmolationTarget.mdl", u, "origin")

                call StartTimer(1, true, this, id)
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope