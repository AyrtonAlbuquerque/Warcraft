scope RadiantHelmet
	struct RadiantHelmet extends Item
		static constant integer code = 'I08C'

		// Attributes
        real mana = 600
        real health = 1000
        real strength = 200
        real healthRegen = 30

        private static real array regen
        private static integer array cooldown
	
		private unit unit
		private integer index
		private effect effect

        method destroy takes nothing returns nothing
			call DestroyEffect(effect)
			call deallocate()

			set unit = null
			set effect = null
		endmethod
	
		private method onTooltip takes unit u, item i, integer id returns string
			return "|cffffcc00Gives|r:\n+ |cffffcc00600|r Mana\n+ |cffffcc001000|r Health\n+ |cffffcc0030|r Health Regeneration\n+ |cffffcc0020|r Strength\n\n|cff00ff00Passive|r: |cffffcc00Radiant Strength|r: |cff00ff00Health Regeneration|r is increased by |cffffcc00" + N2S(regen[id], 0) + "|r.\n\n|cff00ff00Passive|r: |cffffcc00Resilient Attempt|r: When |cffff0000Health|r drops below |cffffcc0050%%|r, |cffffcc00Radiant Strength|r effect is amplified to |cffffcc0050%%|r for |cffffcc0020|r seconds. |cffffcc0090|r seconds cooldown.\n\nCooldown: |cffffcc00" + N2S(R2I(cooldown[id]/10), 0) + "|r"
        endmethod

		private method onPeriod takes nothing returns boolean
			if UnitHasItemOfType(unit, code) then
				if cooldown[index] == 0 and GetUnitLifePercent(unit) <= 50 then
					set cooldown[index] = 900
					set effect = AddSpecialEffectTarget("Radiance_Crimson.mdl", unit, "chest")
				endif

				if cooldown[index] >= 0 and cooldown[index] < 700 then
					set regen[index] = GetHeroStr(unit, true) * 0.25

					if effect != null then
						call DestroyEffect(effect)
						set effect = null
					endif

					call SetWidgetLife(unit, GetWidgetLife(unit) + regen[index]*0.1)
				else
					set regen[index] = GetHeroStr(unit, true) * 0.5
					call SetWidgetLife(unit, GetWidgetLife(unit) + regen[index]*0.1)
				endif

				if cooldown[index] > 0 then
					set cooldown[index] = cooldown[index] - 1
				endif
			
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

				call StartTimer(0.1, true, self, id)
			endif
		endmethod

		implement Periodic

		private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), DragonHelmet.code, PhilosopherStone.code, 0, 0, 0)
		endmethod
	endstruct
endscope