scope PendantOfVigor
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetIntelligenceBonus takes nothing returns real
        return 1.
    endfunction

    private constant function GetAttackSpeedBonus takes nothing returns real
        return 0.05
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
    struct PendantOfVigor extends Item
        static constant integer code = 'I01L'
        private static integer array stacks
        private static thistype array array

        // Attributes
        real agility = 10
        real intelligence = 10

        private unit unit
        private integer index
        private timer timer

        private method destroy takes nothing returns nothing
            call ReleaseTimer(timer)
            call AddUnitBonus(unit, BONUS_INTELLIGENCE, -stacks[index] * GetIntelligenceBonus())
            call AddUnitBonus(unit, BONUS_ATTACK_SPEED, -stacks[index] * GetAttackSpeedBonus())

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

        private static method onCast takes nothing returns nothing
            local thistype this = array[Spell.source.id]

            if UnitHasItemOfType(Spell.source.unit, code) then
                if this == 0 then
                    set this = thistype.allocate(0)
                    set unit = Spell.source.unit
                    set index = Spell.source.id
                    set timer = NewTimerEx(this)
                    set array[Spell.source.id] = this
                endif

                if stacks[Spell.source.id] < GetMaxStacks() then
                    set stacks[Spell.source.id] = stacks[Spell.source.id] + 1

                    call AddUnitBonus(Spell.source.unit, BONUS_INTELLIGENCE, GetIntelligenceBonus())
                    call AddUnitBonus(Spell.source.unit, BONUS_ATTACK_SPEED, GetAttackSpeedBonus())
                endif

                call TimerStart(timer, GetDuration(), false, function thistype.onExpire)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), BraceletOfIntelligence.code, ClawsOfAgility.code, GlovesOfHaste.code, 0, 0)
            call RegisterAnySpellEvent(function thistype.onCast)
        endmethod
    endstruct
endscope