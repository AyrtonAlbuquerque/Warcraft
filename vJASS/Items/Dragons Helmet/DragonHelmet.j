scope DragonHelmet
    struct DragonHelmet extends Item
        static constant integer code = 'I05W'
        static constant integer ability = 'A04B'
        static real array bonus

        real health = 7500
        real strength = 100
        real healthRegen = 100

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc00100|r Strength\n+ |cffffcc00100|r Health Regeneration\n+ |cffffcc007500|r Health\n\n|cff00ff00Passive|r: |cffffcc00Dragon Endurance|r: Every|cffffcc00 5|r units killed wilhe this item is equipped grants |cffffcc001|r bonus |cff00ff00Health Regeneration|r permanently. |cffffcc00Hero|r kills grants |cffffcc005|r bonus|cff00ff00 health regeneration|r.\n\n|cff00ff00Active|r: |cffffcc00Dragon's Bless|r: When activated, the |cff00ff00Health Regeneration|r granted by this item passive effect is|cffffcc00 doubled|r for |cffffcc0020|r seconds.\n\n90 seconds cooldown.\n\nHealth Regeneration Bonus: |cff00ff00" + R2SW(bonus[id], 1, 1) + "|r")
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit killer = GetKillingUnit()
            local unit killed
            local integer index
        
            if UnitHasItemOfType(killer, code) then
                set killed = GetTriggerUnit()
                set index = GetUnitUserData(killer)

                if IsUnitType(killed, UNIT_TYPE_HERO) then
                    set bonus[index] = bonus[index] + 1
                    call AddUnitBonus(killer, BONUS_HEALTH_REGEN, 1)
                else
                    set bonus[index] = bonus[index] + 0.2
                    call AddUnitBonus(killer, BONUS_HEALTH_REGEN, 0.2)
                endif
            endif
        
            set killer = null
            set killed = null
        endmethod
        
        private static method onCast takes nothing returns nothing
            call AddUnitBonusTimed(Spell.source.unit, BONUS_HEALTH_REGEN, bonus[Spell.source.id], 20)
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call thistype.allocate(code, WarriorHelmet.code, EternityStone.code, 0, 0, 0)
        endmethod
    endstruct
endscope