scope ApocalypticMask
	struct ApocalypticMask extends Item
		static constant integer code = 'I089'
	
		// Attributes
        real damage = 1500
        real lifeSteal = 0.5

		private unit unit
		private integer index
		private integer duration
	
		method destroy takes nothing returns nothing
			call super.destroy()
			set unit = null
		endmethod
	
		private method onPeriod takes nothing returns boolean
			set duration = duration - 1

			if duration == 0 then
				call AddUnitBonus(unit, BONUS_ARMOR, 25)
			endif

			return duration > 0
		endmethod
	
		private static method onDamage takes nothing returns nothing
			local thistype this 
	
			if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure then
				set this = GetTimerInstance(Damage.target.id)
				
				if this == 0 then
					set this = thistype.new()
					set unit = Damage.target.unit
					set index = Damage.target.id
	
					call StartTimer(1, true, this, index)
					call AddUnitBonus(unit, BONUS_ARMOR, -25)
				endif
	
				set duration = 10
			endif
		endmethod	

		implement Periodic

		private static method onInit takes nothing returns nothing
			call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, HellishMask.code, SphereOfDarkness.code, 0, 0, 0)
		endmethod
	endstruct
endscope