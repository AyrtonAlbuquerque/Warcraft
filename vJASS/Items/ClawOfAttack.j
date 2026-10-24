scope ClawOfAttack
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetAgilityBonus takes nothing returns real
        return 1.
    endfunction

    private constant function GetLifeStealBonus takes nothing returns real
        return 0.01
    endfunction

    private constant function GetMaxStacks takes nothing returns integer
        return 10
    endfunction

    private constant function GetDuration takes nothing returns real
        return 10.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct ClawOfAttack extends Item
        static constant integer code = 'I01K'
        private static integer array stacks
        private static thistype array array

        // Attributes
        real agility = 10
        real strength = 10

        private unit unit
        private integer index
        private timer timer

        private method destroy takes nothing returns nothing
            call ReleaseTimer(timer)
            call AddUnitBonus(unit, BONUS_AGILITY, -stacks[index] * GetAgilityBonus())
            call AddUnitBonus(unit, BONUS_LIFE_STEAL, -stacks[index] * GetLifeStealBonus())

            set stacks[index] = 0
            set array[index] = 0
            set timer = null
            set unit = null

            call deallocate()
        endmethod

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call destroy()
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this = array[Damage.source.id]

            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy then
                if this == 0 then
                    set this = thistype.allocate(0)
                    set unit = Damage.source.unit
                    set index = Damage.source.id
                    set timer = NewTimerEx(this)
                    set array[Damage.source.id] = this
                endif

                if stacks[Damage.source.id] < GetMaxStacks() then
                    set stacks[Damage.source.id] = stacks[Damage.source.id] + 1

                    call AddUnitBonus(Damage.source.unit, BONUS_AGILITY, GetAgilityBonus())
                    call AddUnitBonus(Damage.source.unit, BONUS_LIFE_STEAL, GetLifeStealBonus())
                endif

                call TimerStart(timer, GetDuration(), false, function thistype.onExpire)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), ClawsOfAgility.code, GauntletOfStrength.code, MaskOfDeath.code, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope