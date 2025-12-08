scope HelmetOfEternity
	struct HelmetOfEternity extends Item
		static constant integer code = 'I0AI'

		// Attributes
		real mana = 1000
        real health = 1500
        real strength = 30
        real healthRegen = 50

		private unit unit
		private integer type
		private effect effect
	
		method destroy takes nothing returns nothing
			call DestroyEffect(effect)
			call deallocate()

			set unit = null
			set effect = null
		endmethod
	
		private method onPeriod takes nothing returns boolean
			local real percentage

			if UnitHasItemOfType(unit, code) then
				set percentage = GetUnitLifePercent(unit)

				call SetWidgetLife(unit, GetWidgetLife(unit) + 2 * R2I(100 - percentage))

				if percentage > 75 then
					if type != 0 then
						call DestroyEffect(effect)
						set effect = AddSpecialEffectTarget("Radiance_Royal.mdx", unit, "chest")
						set type = 0
					endif
				elseif percentage > 50 and percentage <= 75 then
					if type != 1 then
						call DestroyEffect(effect)
						set effect = AddSpecialEffectTarget("Radiance_Crimson.mdx", unit, "chest")
						set type = 1
					endif
				elseif percentage > 25 and percentage <= 50 then
					if type != 2 then
						call DestroyEffect(effect)
						set effect = AddSpecialEffectTarget("Radiance_Nature.mdx", unit, "chest")
						set type = 2
					endif
				elseif percentage <= 25 then
					if type != 3 then
						call DestroyEffect(effect)
						set effect = AddSpecialEffectTarget("Radiance_Holy.mdx", unit, "chest")
						set type = 3
					endif
				endif

				return true
			endif
			
			return false
		endmethod
	
		private method onPickup takes unit u, item i returns nothing
			local integer id = GetUnitUserData(u)
	
			if not HasStartedTimer(id) then
				set this = thistype.allocate(0)
				set unit = u
				set type = 0
				set effect = AddSpecialEffectTarget("Radiance_Royal.mdx", u, "chest")

				call StartTimer(0.1, true, this, id)
			endif
		endmethod

		implement Periodic

		private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), EternityStone.code, RadiantHelmet.code, 0, 0, 0)
		endmethod
	endstruct
endscope