scope OrbOfVenom
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetDuration takes nothing returns real
        return 5.
    endfunction

    private function GetDamage takes unit source returns real
        return 10. * GetWidgetLevel(source)
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct OrbOfVenom extends Item
        static constant integer code = 'I00Q'

        private unit unit
        private unit source
        private effect effect
        private real duration

        method destroy takes nothing returns nothing
            call deallocate()
            call DestroyEffect(effect)

            set unit = null
            set source = null
            set effect = null
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cff00ff00Passive|r: |cffffcc00Venomous|r: Every attack poisons the enemy dealing |cff00ffff" + N2S(GetDamage(u), 0) + " Magic|r damage per second for |cffffcc00" + N2S(GetDuration(), 0) + "|r seconds."
        endmethod

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbVenom\\OrbVenom.mdl", "weapon")
        endmethod

        private method onPeriod takes nothing returns boolean            
            if duration > 0 and UnitAlive(unit) then
                call UnitDamageTarget(source, unit, GetDamage(source), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
            endif

            set duration = duration - 1

            return duration > 0 and UnitAlive(unit)
        endmethod
    
        private static method onDamage takes nothing returns nothing
            local thistype this = GetTimerInstance(Damage.target.id)
            
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure then
                if this == 0 then
                    set this = thistype.allocate(0)
                    set unit = Damage.target.unit
                    set source = Damage.source.unit
                    set effect = AddSpecialEffectTarget("Abilities\\Weapons\\PoisonSting\\PoisonStingTarget.mdl", unit, "origin")
                    
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