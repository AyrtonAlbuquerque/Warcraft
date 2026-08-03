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
        private group group
        private effect effect
        private player player

        method destroy takes nothing returns nothing
            call DestroyEffect(effect)
            call DestroyGroup(group)
            call deallocate()

            set unit = null
            set effect = null
            set group = null
            set player = null
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cff00ff00Passive:|r Engulfs the Hero in fire dealing |cff00ffff" + N2S(GetDamage(u), 0) + " Magic|r damage per second to enemy units within |cffffcc00" + N2S(GetAoE(u), 0) + " AoE|r."
        endmethod

        private method onPeriod takes nothing returns boolean
            local unit u

            if UnitHasItemOfType(unit, code) then
                call GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), GetAoE(unit), null)

                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if IsUnitEnemy(u, player)  and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                            call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\NightElf\\Immolation\\ImmolationDamage.mdl", u, "chest"))
                            call UnitDamageTarget(unit, u, GetDamage(unit), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                        endif
                    call GroupRemoveUnit(group, u)
                endloop
            
                return true
            endif

            return false
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)

            if not HasStartedTimer(id) then
                set this = thistype.allocate(0)
                set unit = u
                set group = CreateGroup()
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