scope ElementalStone
	struct ElementalStone extends Item
		static constant integer code = 'I093'

		// Attributes
        real mana = 1000
        real health = 1000
        real manaRegen = 15
        real healthRegen = 25

        private static integer array bonus
		private static integer array stacks
		private static integer array counter
	
		private unit unit
		private player player
		private integer index
	
        method destroy takes nothing returns nothing
			set unit = null
            set player = null
            
            call deallocate()
		endmethod
	
		private method onTooltip takes unit u, item i, integer id returns string
			return "|cffffcc00Gives|r:\n+ |cffffcc001000|r Mana\n+ |cffffcc001000|r Health\n+ |cffffcc0025|r Health Regeneration\n+ |cffffcc0015|r Mana Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Income|r: While carrying |cffffcc00Elemental Stone|r, every second grants (|cffffcc005|r + |cffffcc001|r x |cffffcc00Stacks|r) |cffffcc00Gold|r. Every |cffffcc0010|r enemy units killed grants a stack, increasing the income by |cffffcc001|r. Hero Kills grants |cffffcc005|r Stacks.\n\nStacks: |cffffcc00" + I2S(stacks[id]) + "|r\nGold Granted: |cffffcc00" + I2S(bonus[id]) + "|r"
        endmethod

		private method onPeriod takes nothing returns boolean
			local integer amount

			if UnitHasItemOfType(unit, code)  then
				set amount = 5 + stacks[index]
				set bonus[index] = bonus[index] + amount

				call AddPlayerGold(player, amount)
			
				return true
			endif

			return false
		endmethod	
	
		private method onPickup takes unit u, item i returns nothing
			local integer id = GetUnitUserData(u)
			local thistype self
	
			if not HasStartedTimer(id) then
				set self = thistype.allocate(0)
				set self.unit = u
				set self.index = id
				set self.player = GetOwningPlayer(u)
                
				call StartTimer(1, true, self, id)
			endif
		endmethod

        private static method onDeath takes nothing returns nothing
			local unit killer = GetKillingUnit()
			local unit killed = GetTriggerUnit()
			local integer index = GetUnitUserData(killer)
	
			if UnitHasItemOfType(killer, code) and IsUnitEnemy(killed, GetOwningPlayer(killer)) then
				if IsUnitType(killed, UNIT_TYPE_HERO) then
					set stacks[index] = stacks[index] + 5
				else
					set counter[index] = counter[index] + 1

					if counter[index] >= 10 then
						set counter[index] = 0
						set stacks[index] = stacks[index] + 1
					endif
				endif
			endif
	
			set killer = null
			set killed = null
		endmethod

		implement Periodic

		private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterItem(allocate(code), ElementalShard.code, PhilosopherStone.code, 0, 0, 0)
		endmethod
	endstruct
endscope