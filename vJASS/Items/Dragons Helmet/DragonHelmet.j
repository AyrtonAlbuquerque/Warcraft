scope DragonHelmet
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private function GetBonusRegen takes unit source returns real
        if IsUnitType(source, UNIT_TYPE_HERO) then
            return 5.
        else
            return 0.5
        endif
    endfunction

    private function GetKillCount takes nothing returns integer
        return 5
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    struct DragonHelmet extends Item
        static real array bonus
        static integer array kills
        static constant integer code = 'I05W'
        static constant integer ability = 'A04B'

        real health = 500
        real strength = 12
        real healthRegen = 15

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc0012|r Strength\n+ |cffffcc0015|r Health Regeneration\n+ |cffffcc00500|r Health\n\n|cff00ff00Passive|r: |cffffcc00Dragon Endurance|r: Every |cffffcc00" + I2S(GetKillCount()) + "|r units killed wilhe this item is equipped grants |cff00ff000.5 Health Regeneration|r bonus permanently. |cffffcc00Hero|r kills grants |cff00ff005 Health Regeneration|r.\n\n|cff00ff00Active|r: |cffffcc00Dragon's Bless|r: When activated, the |cff00ff00Health Regeneration|r granted by |cffffcc00Dragon Endurance|r effect is |cffffcc00Doubled|r for |cffffcc0020|r seconds.\n\n|cffffcc0090|r seconds cooldown.\n\nHealth Regeneration Bonus: |cff00ff00" + R2SW(bonus[id], 1, 1) + "|r"
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit killer = GetKillingUnit()
            local integer index = GetUnitUserData(killer)
        
            if UnitHasItemOfType(killer, code) then
                set kills[index] = kills[index] + 1

                if kills[index] >= GetKillCount() then
                    set kills[index] = 0
                    set bonus[index] = bonus[index] + GetBonusRegen(GetTriggerUnit())
                        
                    call AddUnitBonus(killer, BONUS_HEALTH_REGEN, GetBonusRegen(GetTriggerUnit()))
                endif
            endif
        
            set killer = null
        endmethod
        
        private static method onCast takes nothing returns nothing
            call AddUnitBonusTimed(Spell.source.unit, BONUS_HEALTH_REGEN, bonus[Spell.source.id], 20)
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterItem(allocate(code), WarriorHelmet.code, EternityStone.code, 0, 0, 0)
        endmethod
    endstruct
endscope