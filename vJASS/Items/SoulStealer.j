scope SoulStealer
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetBonus takes nothing returns integer
        return 1
    endfunction

    private constant function GetPermanentLevel takes nothing returns integer
        return 6
    endfunction

    private constant function GetDuration takes nothing returns real
        return 10.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct SoulStealer extends Item
        static constant integer code = 'I01N'
        private static thistype array array

        // Attributes
        real damage = 15
        real agility = 15
        real strength = 15
        real intelligence = 15
        real attackSpeed = 0.2

        private unit unit
        private timer timer
        private integer index
        private integer bonus

        private method destroy takes nothing returns nothing
            call ReleaseTimer(timer)
            call SetUnitItemTypeCharges(unit, code, 0)
            call AddUnitBonus(unit, BONUS_AGILITY, -bonus)
            call AddUnitBonus(unit, BONUS_STRENGTH, -bonus)
            call AddUnitBonus(unit, BONUS_INTELLIGENCE, -bonus)

            set unit = null
            set timer = null
            set array[index] = 0

            call deallocate()
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

        private static method onDeath takes nothing returns nothing
            local unit source = GetKillingUnit()
            local integer id = GetUnitUserData(source)
            local thistype this = array[id]

            if UnitHasItemOfType(source, code) then
                if this == 0 then
                    set this = thistype.allocate(0)
                    set unit = source
                    set index = id
                    set bonus = 0
                    set timer = NewTimerEx(this)
                    set array[id] = this
                endif

                if IsUnitType(source, UNIT_TYPE_HERO) or GetWidgetLevel(GetTriggerUnit()) >= GetPermanentLevel() then
                    call UnitAddStat(source, GetBonus(), GetBonus(), GetBonus())
                else
                    set bonus = bonus + GetBonus()

                    call AddUnitBonus(source, BONUS_AGILITY, GetBonus())
                    call AddUnitBonus(source, BONUS_STRENGTH, GetBonus())
                    call AddUnitBonus(source, BONUS_INTELLIGENCE, GetBonus())
                endif
                
                call SetUnitItemTypeCharges(source, code, bonus)
                call TimerStart(timer, GetDuration(), false, function thistype.onExpire)
            endif

            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), HunterScythe.code, GoliathBelt.code, WarriorBlade.code, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endscope