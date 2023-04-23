scope EternityStone
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
		static constant integer item = 'I052'
	endmodule

    private constant function GetHealthBonus takes nothing returns integer
        return 5
    endfunction

    private constant function GetRegenBonus takes nothing returns real
        return 0.2
    endfunction

    private constant function GetDuration takes nothing returns real
        return 30.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct EternityStone extends Item
        implement Configuration

        real health = 400
        real healthRegen = 5

        private static integer array healthBonus
        private static real array regen

        private timer timer
        private unit unit
        private integer index
        
        method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc005|r Health Regeneration\n+ |cffffcc00400|r Health\n\n|cff00ff00Passive|r: |cffffcc00Eternal Youth|r: When killing a unit |cff00ff00Heatlh Regeneration|r is increased by |cffffcc000.2|r and |cffff0000Maximum Health|r is increased by |cffffcc005|r for |cffffcc0030|r seconds.\n\nHeath Bonus: |cffff0000" + I2S(EternityStone.healthBonus[id]) + "|r\nHealth Regeneration Bonus: |cff00ff00" + R2SW(EternityStone.regen[id], 1, 1) + "|r")
        endmethod

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call AddUnitBonus(unit, BONUS_HEALTH, -GetHealthBonus())
            call AddUnitBonus(unit, BONUS_HEALTH_REGEN, -GetRegenBonus())
            call ReleaseTimer(timer)

            set healthBonus[index] = healthBonus[index] - GetHealthBonus()
            set regen[index] = regen[index] - GetRegenBonus()
            set unit = null
            set timer = null

            call deallocate()
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit killer  = GetKillingUnit()
            local thistype this
        
            if UnitHasItemOfType(killer, item) then
                set this = thistype.allocate(item)
                set timer = NewTimerEx(this)
                set unit = killer
                set index = GetUnitUserData(killer)
                set healthBonus[index] = healthBonus[index] + GetHealthBonus()
                set regen[index] = regen[index] + GetRegenBonus()
        
                call AddUnitBonus(killer, BONUS_HEALTH, GetHealthBonus())
                call AddUnitBonus(killer, BONUS_HEALTH_REGEN, GetRegenBonus())
                call TimerStart(timer, GetDuration(), false, function thistype.onExpire)
            endif
        
            set killer = null
        endmethod
        
        private static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endscope