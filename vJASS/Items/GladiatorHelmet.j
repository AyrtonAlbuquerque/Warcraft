scope GladiatorHelmet
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private function GetStrengthBonus takes unit source returns integer
        if IsUnitType(source, UNIT_TYPE_HERO) then
            return 5
        else
            return 1
        endif
    endfunction

    private function GetManaRegenBonus takes unit source returns real
        if IsUnitType(source, UNIT_TYPE_HERO) or GetWidgetLevel(source) >= 6 then
            return 1.
        else
            return 0.3
        endif
    endfunction

    private function GetHealthRegenBonus takes unit source returns real
        if IsUnitType(source, UNIT_TYPE_HERO) or GetWidgetLevel(source) >= 6 then
            return 5.
        else
            return 1.
        endif
    endfunction

    private constant function GetRange takes nothing returns real
        return 800.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct GladiatorHelmet extends Item
        static constant integer code = 'I01R'

        // Attributes
        real strength = 20
        real tenacity = 0.2
        real manaRegen = 4
        real healthRegen = 10

        private real mr
        private real hr
        private real str
        private unit unit
        private group group
        private player player

        private method destroy takes nothing returns nothing
            call DestroyGroup(group)
            call AddUnitBonus(unit, BONUS_STRENGTH, -str)
            call AddUnitBonus(unit, BONUS_MANA_REGEN, -mr)
            call AddUnitBonus(unit, BONUS_HEALTH_REGEN, -hr)

            set unit = null
            set player = null

            call deallocate()
        endmethod

        private method onPeriod takes nothing returns boolean
            local unit u

            if UnitHasItemOfType(unit, code) then
                call AddUnitBonus(unit, BONUS_STRENGTH, -str)
                call AddUnitBonus(unit, BONUS_MANA_REGEN, -mr)
                call AddUnitBonus(unit, BONUS_HEALTH_REGEN, -hr)
                call GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), GetRange(), null)
                call GroupRemoveUnit(group, unit)

                set mr = 0
                set hr = 0
                set str = 0

                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                            if IsUnitEnemy(u, player) then
                                set mr = mr + GetManaRegenBonus(u)
                                set hr = hr + GetHealthRegenBonus(u)
                            else
                                set str = str + GetStrengthBonus(u)
                            endif
                        endif
                    call GroupRemoveUnit(group, u)
                endloop

                call AddUnitBonus(unit, BONUS_STRENGTH, str)
                call AddUnitBonus(unit, BONUS_MANA_REGEN, mr)
                call AddUnitBonus(unit, BONUS_HEALTH_REGEN, hr)
            endif


            return UnitHasItemOfType(unit, code)
        endmethod

        private method onPickup takes unit u, item i returns nothing
            local integer id = GetUnitUserData(u)

            if not HasStartedTimer(id) then
                set this = thistype.allocate(0)
                set mr = 0
                set hr = 0
                set str = 0
                set unit = u
                set group = CreateGroup()
                set player = GetOwningPlayer(u)

                call StartTimer(1, true, this, id)
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), WarriorHelmet.code, GoliathBelt.code, ElementalShard.code, 0, 0)
        endmethod
    endstruct
endscope