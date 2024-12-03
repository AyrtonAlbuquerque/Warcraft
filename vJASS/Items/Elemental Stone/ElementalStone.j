scope ElementalStone
	struct ElementalStone extends Item
		static constant integer code = 'I093'

		// Attributes
        real mana = 30000
        real health = 30000
        real manaRegen = 750
        real healthRegen = 750

        private static integer array bonus
		private static integer array stacks
	
		private unit unit
		private player player
		private integer index
	
        method destroy takes nothing returns nothing
			set unit = null
            set player = null
            
            call super.destroy()
		endmethod
	
		private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc0030000|r Mana\n+ |cffffcc0030000|r Health\n+ |cffffcc00750|r Health Regeneration\n+ |cffffcc00750|r Mana Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Income|r: While carrying |cffffcc00Elemental Stone|r, every second grants |cffffcc00" + I2S(250 + 1*stacks[id]) + " Gold|r. Every enemy unit killed grants a stack, increasing the income by |cffffcc001|r. Hero Kills grants |cffffcc0050|r Stacks.\n\nStacks: |cffffcc00" + I2S(stacks[id]) + "|r\nGold Granted: |cffffcc00" + I2S(bonus[id]) + "|r")
        endmethod

		private method onPeriod takes nothing returns boolean
			local integer amount

			if UnitHasItemOfType(unit, code)  then
				set amount = 250 + stacks[index]
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
				set self = thistype.new()
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
					set stacks[index] = stacks[index] + 50
				else
					set stacks[index] = stacks[index] + 1
				endif
			endif
	
			set killer = null
			set killed = null
		endmethod

		implement Periodic

		private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call thistype.allocate(code, ElementalShard.code, PhilosopherStone.code, 0, 0, 0)
		endmethod
	endstruct
endscope