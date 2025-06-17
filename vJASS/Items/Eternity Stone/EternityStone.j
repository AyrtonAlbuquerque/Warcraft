scope EternityStone
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetHealthBonus takes nothing returns integer
        return 5
    endfunction

    private constant function GetRegenBonus takes nothing returns real
        return 0.2
    endfunction

    private constant function GetDuration takes nothing returns real
        return 60.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct EternityStone extends Item
        static constant integer code = 'I052'

        // Attributes
        real health = 400
        real healthRegen = 5

        private static integer array healthBonus
        private static real array regen

        private integer index
        
        method destroy takes nothing returns nothing
            set healthBonus[index] = healthBonus[index] - GetHealthBonus()
            set regen[index] = regen[index] - GetRegenBonus()

            call deallocate()
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc005|r Health Regeneration\n+ |cffffcc00400|r Health\n\n|cff00ff00Passive|r: |cffffcc00Eternal Youth|r: When killing a unit |cff00ff00Heatlh Regeneration|r is increased by |cffffcc000.2|r and |cffff0000Maximum Health|r is increased by |cffffcc005|r for |cffffcc0060|r seconds.\n\nHeath Bonus: |cffff0000" + I2S(EternityStone.healthBonus[id]) + "|r\nHealth Regeneration Bonus: |cff00ff00" + N2S(EternityStone.regen[id], 1) + "|r"
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit killer  = GetKillingUnit()
            local thistype this
        
            if UnitHasItemOfType(killer, code) then
                set this = thistype.allocate(0)
                set index = GetUnitUserData(killer)
                set healthBonus[index] = healthBonus[index] + GetHealthBonus()
                set regen[index] = regen[index] + GetRegenBonus()
        
                call StartTimer(GetDuration(), false, this, -1)
                call AddUnitBonusTimed(killer, BONUS_HEALTH, GetHealthBonus(), GetDuration())
                call AddUnitBonusTimed(killer, BONUS_HEALTH_REGEN, GetRegenBonus(), GetDuration())
            endif
        
            set killer = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterItem(allocate(code), FusedLifeCrystals.code, LifeEssenceCrystal.code, 0, 0, 0)
        endmethod
    endstruct
endscope