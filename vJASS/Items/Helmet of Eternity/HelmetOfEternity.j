scope HelmetOfEternity
	struct HelmetOfEternity extends Item
		static constant integer code = 'I0AI'

		private static integer key = -1
		private static thistype array array
		private static boolean array check
		private static timer timer = CreateTimer()
	
		private unit unit
		private integer index
		private integer type
		private effect effect

		// Attributes
		real mana = 15000
        real health = 30000
        real strength = 500
        real healthRegen = 1000
	
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
	
		private static method onPeriod takes nothing returns nothing
			local integer i = 0
			local real percentage
			local thistype this
			
			loop
				exitwhen i > key
					set this = array[i]
	
					if UnitHasItemOfType(unit, code) then
						set percentage = GetUnitLifePercent(unit)
	
						if percentage > 75 then
							if type != 0 then
								call DestroyEffect(effect)
								set effect = AddSpecialEffectTarget("Radiance_Royal.mdx", unit, "chest")
								set type   = 0
							endif
						elseif percentage > 50 and percentage <= 75 then
							call SetWidgetLife(unit, GetWidgetLife(unit) + 50)
							if type != 1 then
								call DestroyEffect(effect)
								set effect = AddSpecialEffectTarget("Radiance_Crimson.mdx", unit, "chest")
								set type   = 1
							endif
						elseif percentage > 25 and percentage <= 50 then
							call SetWidgetLife(unit, GetWidgetLife(unit) + 100)
							if type != 2 then
								call DestroyEffect(effect)
								set effect = AddSpecialEffectTarget("Radiance_Nature.mdx", unit, "chest")
								set type   = 2
							endif
						elseif percentage <= 25 then
							call SetWidgetLife(unit, GetWidgetLife(unit) + 150)
							if type != 3 then
								call DestroyEffect(effect)
								set effect = AddSpecialEffectTarget("Radiance_Holy.mdx", unit, "chest")
								set type   = 3
							endif
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
				set unit = u
				set index = id
				set type = 0
				set effect = AddSpecialEffectTarget("Radiance_Royal.mdx", u, "chest")
				set key = key + 1
				set array[key] = self
				set check[id] = true

				if key == 0 then
					call TimerStart(timer, 0.1, true, function thistype.onPeriod)
				endif
			endif
		endmethod

		private static method onInit takes nothing returns nothing
            call thistype.allocate(code, EternityStone.code, RadiantHelmet.code, 0, 0, 0)
		endmethod
	endstruct
endscope