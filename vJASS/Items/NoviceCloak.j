scope NoviceCloak
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetDuration takes nothing returns real
        return 8.
    endfunction

    private constant function GetBonus takes nothing returns real
        return 1.
    endfunction

    private constant function GetMaxBonus takes nothing returns real
        return 5.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct NoviceCloak extends Item
        static constant integer code = 'I01E'
        
        // Attributes
        real mana = 350
        real healing = 0.15
        real magicResistance = 5

        private static real array bonus
        private static thistype array array

        private unit unit
        private timer timer
        private integer index

        method destroy takes nothing returns nothing
            call ReleaseTimer(timer)

            set unit = null
            set timer = null
            set bonus[index] = 0
            set array[index] = 0

            call deallocate()
        endmethod

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call AddUnitBonus(unit, BONUS_MAGIC_RESISTANCE, -bonus[index])
            call destroy()
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this = array[Damage.target.id]
        
            if UnitHasItemOfType(Damage.target.unit, code) then
                if bonus[Damage.target.id] < GetMaxBonus() then
                    set bonus[Damage.target.id] = bonus[Damage.target.id] + GetBonus()

                    call AddUnitBonus(Damage.target.unit, BONUS_MAGIC_RESISTANCE, GetBonus())
                endif

                if this == 0 then
                    set this = thistype.allocate(0)
                    set index = Damage.target.id
                    set unit = Damage.target.unit
                    set timer = NewTimerEx(this)
                    set array[Damage.target.id] = this
                endif

                call TimerStart(timer, GetDuration(), false, function thistype.onExpire)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), ManaCrystal.code, MantleOfResistance.code, VitalityStone.code, 0, 0)
            call RegisterSpellDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope