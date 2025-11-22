scope FusionCrystal
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetMultiplier takes nothing returns real
        return 2.
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
        static constant integer code = 'I057'
        static constant integer ability = 'A03S'
        private static integer array charge

        real mana = 500
        real health = 500

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc00500|r Mana\n+ |cffffcc00500|r Health\n\n|cff00ff00Passive|r: |cffffcc00Charge|r: When killing a unit the number of charges of Fusion Crystal are increased by |cffffcc001|r.\n\n|cff00ff00Active|r: |cffffcc00Energy Release|r: When activated, all charges are consumed and for |cffffcc0010|r seconds, |cffff0000Health|r and |cff80ffffMana|r Regeneration are increased by |cffffcc00" + R2SW(GetMultiplier() * FusionCrystal.charge[id], 1, 1) + "|r.\n\n|cffffcc0090|r seconds Cooldown\n\nCharges: |cffffcc00" + I2S(FusionCrystal.charge[id]) + "|r"
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit killer = GetKillingUnit()
            local integer index = GetUnitUserData(killer) 
    
            if UnitHasItemOfType(killer, code) then
                set charge[index] = charge[index] + GetChargesCount()
            endif
        
            set killer = null
        endmethod
        
        private static method onCast takes nothing returns nothing
            if charge[Spell.source.id] > 0 then
                call AddUnitBonusTimed(Spell.source.unit, BONUS_HEALTH_REGEN, GetMultiplier()*charge[Spell.source.id], GetDuration())
                call AddUnitBonusTimed(Spell.source.unit, BONUS_MANA_REGEN, GetMultiplier()*charge[Spell.source.id], GetDuration())
                set charge[Spell.source.id] = 0
            else
                call ArcingTextTag.create(("|cff6495ed" + "No Charges"), Spell.source.unit, 0.015)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterItem(allocate(code), FusedLifeCrystals.code, InfusedManaCrystal.code, 0, 0, 0)
        endmethod
    endstruct
endscope