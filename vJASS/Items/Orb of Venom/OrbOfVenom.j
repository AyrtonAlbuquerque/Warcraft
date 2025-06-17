scope OrbOfVenom
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetDuration takes nothing returns real
        return 5.
    endfunction

    private constant function GetDamage takes nothing returns real
        return 10.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct OrbOfVenom extends Item
        static constant integer code = 'I01K'
        static constant string effect = "Abilities\\Weapons\\PoisonSting\\PoisonStingTarget.mdl"
    
        // Attributes
        real damage = 10

        private unit unit
        private unit source
        private real duration

        method destroy takes nothing returns nothing
            set unit = null
            set source = null
        endmethod

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbVenom\\OrbVenom.mdl", "weapon")
        endmethod

        private method onPeriod takes nothing returns boolean
            set duration = duration - 1
            
            if duration > 0 then
                if UnitDamageTarget(source, unit, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call DestroyEffect(AddSpecialEffectTarget(effect, unit, "origin"))
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
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope