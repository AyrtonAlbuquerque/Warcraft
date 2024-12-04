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

        // Atributes
        real health = 375
        real strength = 8

        private static real array amount
        
        private unit unit
        private integer index

        method destroy takes nothing returns nothing
            call ArcingTextTag.create(("|cffff0000-" + R2I2S(GetBonusStrength())), unit)
            call super.destroy()

            set amount[index] = amount[index] - GetBonusStrength()
            set unit = null
        endmethod

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc00375|r Health\n+ |cffffcc008|r Strength\n\n|cff00ff00Passive|r: |cffffcc00Strong Arm:|r Every attack taken has |cffffcc0010%%|r chance to increase Hero |cffff0000Strength|r by |cffffcc001|r for 15 seconds.\n\nCurrent Strength Bonus: |cffff0000" + R2I2S(EmeraldShoulderPlate.amount[id]) + "|r")
        endmethod

        private static method onDamage takes nothing returns nothing
            local thistype this

            if UnitHasItemOfType(Damage.target.unit, code) and GetRandomReal(1, 100) <= GetChance() then
                set this = thistype.new()
                set unit = Damage.target.unit
                set index = Damage.target.id
                set amount[index] = amount[index] + GetBonusStrength()

                call StartTimer(GetDuration(), false, this, -1)
                call DestroyEffect(AddSpecialEffectTarget(effect, Damage.target.unit, "origin"))
                call AddUnitBonusTimed(Damage.target.unit, BONUS_STRENGTH, GetBonusStrength(), GetDuration())
                call ArcingTextTag.create(("|cffff0000+" + R2I2S(GetBonusStrength())), Damage.target.unit)
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, GauntletOfStrength.code, GauntletOfStrength.code, FusedLifeCrystals.code, 0, 0)
        endmethod
    endstruct
endscope