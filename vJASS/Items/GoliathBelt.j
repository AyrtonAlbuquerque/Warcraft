scope GoliathBelt
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetBonus takes nothing returns real
        return 1.
    endfunction

    private constant function GetManaRegenBonus takes nothing returns real
        return 0.5
    endfunction

    private constant function GetMaxBonus takes nothing returns real
        return 10.
    endfunction

    private constant function GetRange takes nothing returns real
        return 800.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct GoliathBelt extends Item
        static constant integer code = 'I01J'

        // Attributes
        real strength = 10
        real intelligence = 10

        private unit unit
        private real regen
        private real bonus
        private Group group
        private player player

        private method destroy takes nothing returns nothing
            set unit = null
            set player = null

            call group.destroy()
            call deallocate()
        endmethod

        private method onPeriod takes nothing returns boolean
            local real count

            if UnitHasItemOfType(unit, code) then
                set count = group.clear()
                    .inRange(GetUnitX(unit), GetUnitY(unit), GetRange())
                    .isAlive()
                    .enemyOf(player)
                    .isNot().ofType(UNIT_TYPE_STRUCTURE)
                    .sort()
                    .size

                if count > GetMaxBonus() then
                    set count = GetMaxBonus()
                endif

                call AddUnitBonus(unit, BONUS_STRENGTH, -bonus)
                call AddUnitBonus(unit, BONUS_MANA_REGEN, -regen)

                set bonus = count * GetBonus()
                set regen = count * GetManaRegenBonus()

                call AddUnitBonus(unit, BONUS_STRENGTH, bonus)
                call AddUnitBonus(unit, BONUS_MANA_REGEN, regen)
            endif


            return UnitHasItemOfType(unit, code)
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)

            if not HasStartedTimer(id) then
                set this = thistype.allocate(0)
                set unit = u
                set regen = 0
                set bonus = 0
                set group = Group.create()
                set player = GetOwningPlayer(u)

                call StartTimer(1, true, this, id)
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), LifeCrystal.code, BraceletOfIntelligence.code, GauntletOfStrength.code, 0, 0)
        endmethod
    endstruct
endscope