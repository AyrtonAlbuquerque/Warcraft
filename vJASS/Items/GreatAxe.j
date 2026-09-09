scope GreatAxe
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetAttackSpeedBonus takes nothing returns real
        return 0.5
    endfunction

    private constant function GetDuration takes nothing returns real
        return 3.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct GreatAxe extends Item
        static constant integer code = 'I013'

        // Attributes
        real damage = 18
        real criticalDamage = 0.35
        real criticalChance = 0.18
        real armorPenetration = 0.15

        private unit unit
        private real duration

        method destroy takes nothing returns nothing
            call AddUnitBonus(unit, BONUS_ATTACK_SPEED, -GetAttackSpeedBonus())
            call deallocate()

            set unit = null
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc0018|r Damage\n+ |cffffcc0018%|r Critical Chance\n+ |cffffcc0035%|r Critical Damage\n+ |cffffcc0015%|r Armor Penetration\n\n|cff00ff00Passive|r: |cffffcc00Frenzy|r: After hitting a critical strike gain |cffffcc00" + N2S(GetAttackSpeedBonus() * 100, 0) + "%|r |cffffcc00Attack Speed|r for |cffffcc00" + N2S(GetDuration(), 0) + "|r seconds."
        endmethod

        private method onPeriod takes nothing returns boolean
            set duration = duration - 0.25

            return duration > 0
        endmethod

        private static method onCritical takes nothing returns nothing
            local unit source = GetCriticalSource()
            local unit target = GetCriticalTarget()
            local integer id = GetUnitUserData(source) 
            local thistype this = GetTimerInstance(id)

            if UnitHasItemOfType(source, code) and IsUnitEnemy(target, GetOwningPlayer(source)) then
                if this == 0 then
                    set this = thistype.allocate(0)
                    set unit = source

                    call StartTimer(0.25, true, this, id)
                    call AddUnitBonus(source, BONUS_ATTACK_SPEED, GetAttackSpeedBonus())
                endif

                set duration = GetDuration()
            endif

            set source = null
            set target = null
        endmethod

        implement Periodic

        private static  method onInit takes nothing returns nothing
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
            call RegisterItem(allocate(code), IronAxe.code, IronAxe.code, RustySword.code, 0, 0) 
        endmethod
    endstruct
endscope