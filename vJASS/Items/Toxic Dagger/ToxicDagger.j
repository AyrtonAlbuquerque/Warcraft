scope ToxicDagger
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetDuration takes nothing returns real
        return 5.
    endfunction

    private constant function GetDamage takes nothing returns real
        return 20.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct ToxicDagger extends Item
        static constant integer code = 'I047'
    
        // Attributes
        real damage = 30

        private unit unit
        private unit source
        private real duration

        method destroy takes nothing returns nothing
            call deallocate()
            
            set unit = null
            set source = null
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc0030|r Damage\n\n|cff00ff00Passive|r: |cffffcc00Toxic Blade|r: Attacking enemies poison them dealing |cff0080ff" + N2S(GetDamage(), 0) + " Magic|r damage per second.\n\nLasts for 5 seconds."
        endmethod

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbVenom\\OrbVenom.mdl", "weapon")
        endmethod

        private method onPeriod takes nothing returns boolean
            set duration = duration - 1
            
            if duration > 0 then
                if UnitDamageTarget(source, unit, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\PoisonSting\\PoisonStingTarget.mdl", unit, "origin"))
                endif
            endif

            return duration > 0
        endmethod
    
        private static method onDamage takes nothing returns nothing
            local thistype this = GetTimerInstance(Damage.target.id)
        
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure then
                if this == 0 then
                    set this = thistype.allocate(0)
                    set unit = Damage.target.unit
                    set source = Damage.source.unit
                    
                    call StartTimer(1, true, this, Damage.target.id)
                endif

                set duration = GetDuration()
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), OrbOfVenom.code, GoldenSword.code, 0, 0 ,0)
        endmethod
    endstruct
endscope