scope FusionCrystal
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
		static constant integer item    = 'I057'
        static constant integer ability = 'A03S'
	endmodule

    private constant function GetMultiplier takes nothing returns real
        return 0.5
    endfunction

    private constant function GetChargesCount takes nothing returns integer
        return 1
    endfunction

    private constant function GetDuration takes nothing returns real
        return 10.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct FusionCrystal extends Item
        implement Configuration

        real health = 500
        real mana = 500

        private static integer array charges

        method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc00500|r Mana\n+ |cffffcc00500|r Health\n\n|cff00ff00Passive|r: |cffffcc00Charge|r: When killing a unit the number of charges of Fusion Crystal are increased by |cffffcc001|r.\n\n|cff00ff00Active|r: |cffffcc00Energy Release|r: When activated, all charges are consumed and for |cffffcc0010|r seconds, |cffff0000Health|r and |cff80ffffMana|r Regeneration are increased by |cffffcc00" + R2SW(GetMultiplier() * FusionCrystal.charges[id], 1, 1) + "|r.\n\n90 seconds Cooldown\n\nCharges: |cffffcc00" + I2S(FusionCrystal.charges[id]) + "|r")
        endmethod

        static method onDeath takes nothing returns nothing
            local unit killer = GetKillingUnit()
            local integer index = GetUnitUserData(killer) 
    
            if UnitHasItemOfType(killer, item) then
                set charges[index] = charges[index] + GetChargesCount()
            endif
        
            set killer = null
        endmethod
        
        static method onCast takes nothing returns nothing
            if charges[Spell.source.id] > 0 then
                call AddUnitBonusTimed(Spell.source.unit, BONUS_HEALTH_REGEN, GetMultiplier()*charges[Spell.source.id], GetDuration())
                call AddUnitBonusTimed(Spell.source.unit, BONUS_MANA_REGEN, GetMultiplier()*charges[Spell.source.id], GetDuration())
                set charges[Spell.source.id] = 0
            else
                call ArcingTextTag.create(("|cff6495ed" + "No Charges"), Spell.source.unit)
            endif
        endmethod

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endscope