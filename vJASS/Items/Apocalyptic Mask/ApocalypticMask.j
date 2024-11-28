scope ApocalypticMask
	struct ApocalypticMask extends Item
		static constant integer code = 'I089'
		
		private static timer timer = CreateTimer()
		private static integer key  = -1
		private static thistype array array
		private static thistype array struct
	
		private unit unit
		private integer index
		private integer duration

		// Attributes
        real damage = 1500
        real lifeSteal = 0.5
	
		private method remove takes integer i returns integer
			set struct[index] = 0
			set array[i] = array[key]
			set key = key - 1
			set duration  = 0
			set unit = null

			if key == -1 then
				call PauseTimer(timer)
			endif

			call super.destroy()

			return i - 1
		endmethod
	
		private static method onPeriod takes nothing returns nothing
			local integer i = 0
			local thistype this
	
			loop
				exitwhen i > key
					set this = array[i]
	
					if duration == 0 then
						call AddUnitBonus(unit, BONUS_ARMOR, 25)
						set i = remove(i)
					endif

					set duration = duration - 1
				set i = i + 1
			endloop
		endmethod
	
		private static method onDamage takes nothing returns nothing
			local thistype this
	
			if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure then
				if struct[Damage.target.id] != 0 then
					set this = struct[Damage.target.id]
				else
					set this = thistype.new()
					set unit = Damage.target.unit
					set index = Damage.target.id
					set key = key + 1
					set array[key] = this
					set struct[index] = this
	
					call AddUnitBonus(unit, BONUS_ARMOR, -25)  

					if key == 0 then
						call TimerStart(timer, 1, true, function thistype.onPeriod)
					endif
				endif
	
				set duration = 10
			endif
		endmethod	

		private static method onInit takes nothing returns nothing
			call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, HellishMask.code, SphereOfDarkness.code, 0, 0, 0)
		endmethod
	endstruct
endscope