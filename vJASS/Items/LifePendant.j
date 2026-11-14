scope LifePendant
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetMovementBonus takes nothing returns integer
        return 5
    endfunction

    private constant function GetAttackSpeedBonus takes nothing returns real
        return 0.05
    endfunction

    private constant function GetHealTreshold takes nothing returns real
        return 100.
    endfunction

    private constant function GetMaxStacks takes nothing returns integer
        return 10
    endfunction

    private constant function GetDuration takes nothing returns real
        return 15.
    endfunction

    private constant function GetShieldHealFactor takes nothing returns real
        return 0.2
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct LifePendant extends Item
        static constant integer code = 'I01U'
        private static thistype array array

        // Attributes
        real mana = 400
        real health = 400
        real healing = 0.25
        real shielding = 0.25

        private unit unit
        private timer timer
        private real as
        private integer ms
        private integer index
        private integer stacks

        private method destroy takes nothing returns nothing
            call ReleaseTimer(timer)
            call SetUnitItemTypeCharges(unit, code, 0)
            call AddUnitBonus(unit, BONUS_ATTACK_SPEED, -as)
            call AddUnitBonus(unit, BONUS_MOVEMENT_SPEED, -ms)

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
                call SetItemCharges(i, stacks)
            endif
        endmethod

        private method onDrop takes unit u, item i returns nothing
            set this = array[GetUnitUserData(u)]

            if this != 0 and GetItemTypeId(i) == code then
                call SetItemCharges(i, 0)
            endif
        endmethod

        private static method onHeal takes nothing returns nothing
            local unit target = GetHealingTarget()
            local integer id = GetUnitUserData(target)
            local thistype this = array[id]

            if UnitHasItemOfType(target, code) and GetHealingAmount() >= GetHealTreshold() then
                if this == 0 then
                    set this = thistype.allocate(0)
                    set as = 0
                    set ms = 0
                    set unit = target
                    set index = id
                    set stacks = 0
                    set timer = NewTimerEx(this)
                    set array[id] = this
                endif

                if stacks < GetMaxStacks() then
                    set stacks = stacks + 1
                    set as = as + GetAttackSpeedBonus()
                    set ms = ms + GetMovementBonus()

                    call AddUnitBonus(target, BONUS_ATTACK_SPEED, GetAttackSpeedBonus())
                    call AddUnitBonus(target, BONUS_MOVEMENT_SPEED, GetMovementBonus())
                    call SetUnitItemTypeCharges(target, code, stacks)
                endif
                
                call TimerStart(timer, GetDuration(), false, function thistype.onExpire)
            endif

            set target = null
        endmethod

        private static method onDamage takes nothing returns nothing
            call HealUnit(GetShieldingTarget(), GetShieldingTarget(), GetShieldingLost() * GetShieldHealFactor(), HEALTH, true)
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), HomecomingOrb.code, VitalityStone.code, ElementalShard.code, PendantOfVigor.code, 0)
            call RegisterShieldDamageEvent(function thistype.onDamage)
            call RegisterHealingEvent(function thistype.onHeal)
        endmethod
    endstruct
endscope