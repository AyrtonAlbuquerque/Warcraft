scope EmeraldShoulderPlate
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetChance takes nothing returns real
        return 10.
    endfunction

    private constant function GetDuration takes nothing returns real
        return 15.
    endfunction

    private constant function GetBonusStrength takes nothing returns real
        return 1.
    endfunction
    
    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct EmeraldShoulderPlate extends Item
        static constant integer code = 'I02Y'
        static constant string effect = "HealRed.mdl"
        static constant real period = 1

        private static real array amount
        private static thistype array array
		private static integer key = -1
        private static timer timer = CreateTimer()
        
        private unit unit
        private integer index
        private real duration

        // Atributes
        real health = 375
        real strength = 8

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc00375|r Health\n+ |cffffcc008|r Strength\n\n|cff00ff00Passive|r: |cffffcc00Strong Arm:|r Every attack taken has |cffffcc0010%%|r chance to increase Hero |cffff0000Strength|r by |cffffcc001|r for 15 seconds.\n\nCurrent Strength Bonus: |cffff0000" + R2I2S(EmeraldShoulderPlate.amount[id]) + "|r")
        endmethod

        private method remove takes integer i returns integer
            call AddUnitBonus(unit, BONUS_STRENGTH, -GetBonusStrength())
            call ArcingTextTag.create(("|cffff0000-" + R2I2S(GetBonusStrength())), unit)

            set amount[index] = amount[index] - GetBonusStrength()
            set array[i] = array[key]
            set key = key - 1
            set unit = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call super.destroy()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer  i = 0
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if duration <= 0 then
                        set i = remove(i)
                    endif

                    set duration = duration - period
                set i = i + 1
            endloop
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this

            if UnitHasItemOfType(Damage.target.unit, code) and GetRandomReal(1, 100) <= GetChance() then
                set this = thistype.new()
                set unit = Damage.target.unit
                set index = Damage.target.id
                set duration = GetDuration()
                set key = key + 1
                set array[key] = this
                set amount[index] = amount[index] + GetBonusStrength()

                call DestroyEffect(AddSpecialEffectTarget(effect, Damage.target.unit, "origin"))
                call AddUnitBonus(Damage.target.unit, BONUS_STRENGTH, GetBonusStrength())
                call ArcingTextTag.create(("|cffff0000+" + R2I2S(GetBonusStrength())), Damage.target.unit)

                if key == 0 then
                    call TimerStart(timer, period, true, function thistype.onPeriod)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, GauntletOfStrength.code, GauntletOfStrength.code, FusedLifeCrystals.code, 0, 0)
        endmethod
    endstruct
endscope