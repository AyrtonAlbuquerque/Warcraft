scope ToxicDagger
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
		static constant integer item = 'I047'
        static constant real period  = 1.
	endmodule

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
        implement Configuration
    
        real damage = 30

        private static integer array array
    
        private timer timer
        private unit unit
        private unit source
        private integer key
        private real duration
    
        method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0030|r Damage\n\n|cff00ff00Passive|r: |cffffcc00Toxic Blade|r: Attacking enemies poison them dealing |cff0080ff" + AbilitySpellDamageEx(GetDamage(), u) + " Magic|r damage per second.\n\nLasts for 5 seconds.")
        endmethod

        method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbVenom\\OrbVenom.mdl", "weapon")
        endmethod

        static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            if duration > 0 then
                set duration = duration - period
                
                if UnitDamageTarget(source, unit, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Weapons\\PoisonSting\\PoisonStingTarget.mdl", unit, "origin"))
                endif
            else
                call ReleaseTimer(timer)
                call deallocate()
                
                set array[key] = 0
                set timer = null
                set unit = null
                set source = null
            endif
        endmethod
    
        static method onDamage takes nothing returns nothing
            local thistype this
        
            if UnitHasItemOfType(Damage.source.unit, item) and Damage.isEnemy and not Damage.target.isStructure then
                if array[Damage.target.id] != 0 then
                    set this = array[Damage.target.id]
                else
                    set this = thistype.allocate(item)
                    set timer = NewTimerEx(this)
                    set unit = Damage.target.unit
                    set source = Damage.source.unit
                    set key = Damage.target.id
                    set array[key] = this
                    
                    call TimerStart(timer, period, true, function thistype.onPeriod)
                endif

                set duration = GetDuration()
            endif
        endmethod

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope