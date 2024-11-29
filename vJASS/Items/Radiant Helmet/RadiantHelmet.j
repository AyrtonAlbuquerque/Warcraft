scope RadiantHelmet
	struct RadiantHelmet extends Item
		static constant integer code = 'I08C'

        private static timer timer = CreateTimer()
        private static integer key = -1
        private static real array regen
		private static boolean array check
        private static thistype array array
        private static integer array cooldown
	
		private unit unit
		private integer index
		private effect effect

        // Attributes
        real mana = 10000
        real health = 20000
        real strength = 250
        real healthRegen = 500

        private method remove takes integer i returns integer
			call DestroyEffect(effect)

			set array[i] = array[key]
			set key = key - 1
			set check[index] = false
			set unit = null
			set effect = null

			if key == -1 then
				call PauseTimer(timer)
			endif

			call super.destroy()

			return i - 1
		endmethod
	
		private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc0010000|r Mana\n+ |cffffcc0020000|r Health\n+ |cffffcc00500|r Health Regeneration\n+ |cffffcc00250|r Strength\n\n|cff00ff00Passive|r: |cffffcc00Radiant Strength|r: |cff00ff00Health Regeneration|r is increased by |cffffcc00" + R2I2S(regen[id]) + "|r.\n\n|cff00ff00Passive|r: |cffffcc00Resilient Attempt|r: When your Hero life drops below |cffffcc0050%%|r, |cffffcc00Radiant Strength|r effect is amplified to |cffffcc00100%%|r for |cffffcc0020|r seconds. |cffffcc0090|r seconds cooldown.\n\nCooldown: |cffffcc00" + R2I2S(R2I(cooldown[id]/10)) + "|r")
        endmethod

		private static method onPeriod takes nothing returns nothing
			local integer i = 0
			local thistype this
			
			loop
				exitwhen i > key
					set this = array[i]
	
					if UnitHasItemOfType(unit, code) then
						if cooldown[index] == 0 and GetUnitLifePercent(unit) <= 50 then
							set cooldown[index] = 900
							set effect = AddSpecialEffectTarget("Radiance Crimson.mdx", unit, "chest")
						endif
	
						if cooldown[index] >= 0 and cooldown[index] < 700 then
							set regen[index] = GetHeroStr(unit, true)*0.5

							if effect != null then
								call DestroyEffect(effect)
								set effect = null
							endif

							call SetWidgetLife(unit, GetWidgetLife(unit) + regen[index]*0.1)
						else
							set regen[index] = GetHeroStr(unit, true)
							call SetWidgetLife(unit, GetWidgetLife(unit) + regen[index]*0.1)
						endif
	
						if cooldown[index] > 0 then
							set cooldown[index] = cooldown[index] - 1
						endif
					else
						set i = remove(i)
					endif
				set i = i + 1
			endloop
		endmethod
	
		private method onPickup takes unit u, item i returns nothing
			local integer id = GetUnitUserData(u)
			local thistype self
	
			if not check[id] then
				set self = thistype.new()
				set self.unit = u
				set self.index = id
				set key = key + 1
				set array[key] = self
				set check[id] = true

				if key == 0 then
					call TimerStart(timer, 0.1, true, function thistype.onPeriod)
				endif
			endif
		endmethod

		private static method onInit takes nothing returns nothing
            call thistype.allocate(code, DragonHelmet.code, PhilosopherStone.code, 0, 0, 0)
		endmethod
	endstruct
endscope