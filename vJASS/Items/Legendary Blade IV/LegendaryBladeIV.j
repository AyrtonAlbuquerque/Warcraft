scope LegendaryBladeIV
	struct LegendaryBladeIV extends Item
		static constant integer code = 'I09U'
		static constant real step = 2.5*0.017453

		// Attributes
		real damage = 1750
        real attackSpeed = 2
        real spellPower = 1250

		private static integer array attack
		private static real array amount
		
		private unit unit
		private real angle
		private integer index
		private Table table
	
		method destroy takes nothing returns nothing
			call DestroyEffect(table.effect[0])
			call DestroyEffect(table.effect[1])
			call DestroyEffect(table.effect[2])
			call DestroyEffect(table.effect[3])
			call table.destroy()
			call deallocate()

			set attack[index] = 0
			set amount[index] = 0
			set unit = null
		endmethod
	
		private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc001750|r Damage\n+ |cffffcc001250|r Spell Power\n+ |cffffcc00200%|r Attack Speed\n\n|cff00ff00Passive|r: |cffffcc00Flaming Blade|r: Every |cffffcc004|r attacks a fireball will strike the target dealing |cffffcc003x your last damage dealt over 2 seconds|r.\n\n|cff00ff00Passive|r: |cffffcc00Holy Blade|r: Every |cffffcc004|r attacks a lightball will strike the target dealing the same amount of damage of your last damage dealt by a basic attack and will heal the carrier by |cffffcc003x|r that amount.\n\n|cff00ff00Passive|r: |cffffcc00Water Blade|r: Every |cffffcc004|r attacks a water bolt will strike the target dealing |cff00ffff" + N2S(1000, 0) + " Magic|r damage and will slow the target by |cffffcc0030%|r for |cffffcc001,5|r seconds.\n\n|cff00ff00Passive|r: |cffffcc00Dark Blade|r: Every |cffffcc004|r attacks a dark bolt will strike the target reducing its armor by |cffffcc0050|r for |cffffcc005|r seconds."
        endmethod

		private method onPeriod takes nothing returns boolean
			local real x
			local real y
			local real z

			if UnitHasItemOfType(unit, code) then
				set angle = angle + step
				set x = GetUnitX(unit)
				set y = GetUnitY(unit)
				set z = GetUnitZ(unit)

				call BlzSetSpecialEffectPosition(table.effect[0], x + 150*Cos(angle), y + 150*Sin(angle), z + 60)
				call BlzSetSpecialEffectPosition(table.effect[1], x + 150*Cos(angle + 90*0.017453), y + 150*Sin(angle + 90*0.017453), z + 60)
				call BlzSetSpecialEffectPosition(table.effect[2], x + 150*Cos(angle + bj_PI), y + 150*Sin(angle + bj_PI), z + 60)
				call BlzSetSpecialEffectPosition(table.effect[3], x + 150*Cos(angle + 270*0.017453), y + 150*Sin(angle + 270*0.017453), z + 60)
			
				return true
			endif

			return false
		endmethod

		private method onPickup takes unit u, item i returns nothing
			local real x
			local real y
			local real z
			local thistype self
			local integer id = GetUnitUserData(u)

			if not HasStartedTimer(id) then
				set x = GetUnitX(u)
				set y = GetUnitY(u)
				set z = GetUnitZ(u) + 60
				set self = thistype.allocate(0)
				set self.table = Table.create()
				set self.unit = u
				set self.angle = 0.
				set self.index = id
				set self.table.effect[0] = AddSpecialEffect("Sweep_Fire_Small.mdl", x, y)
				set self.table.effect[1] = AddSpecialEffect("Sweep_Holy_Small.mdl", x, y)
				set self.table.effect[2] = AddSpecialEffect("Sweep_Black_Frost_Small.mdl", x, y)
				set self.table.effect[3] = AddSpecialEffect("Sweep_Astral_Small.mdl", x, y)

				call BlzSetSpecialEffectPosition(self.table.effect[0], x, y, z)
				call BlzSetSpecialEffectPosition(self.table.effect[1], x, y, z)
				call BlzSetSpecialEffectPosition(self.table.effect[2], x, y, z)
				call BlzSetSpecialEffectPosition(self.table.effect[3], x, y, z)
				call StartTimer(0.05, true, self, id)
			endif
		endmethod

		private static method onDamage takes nothing returns nothing
			local real x
			local real y
			local real z
			local effect e
			local integer i
			local thistype this
			local BladeMissile missile

			if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure then
				set amount[Damage.source.id] = Damage.amount
				set attack[Damage.source.id]  = attack[Damage.source.id] + 1
	
				if attack[Damage.source.id] == 4 then
					set i = 0
					set attack[Damage.source.id] = 0
					set this = GetTimerInstance(Damage.source.id)
					
					if this != 0 then
						loop
							exitwhen i > 3
								set e = table.effect[i]
								set x = BlzGetLocalSpecialEffectX(e)
								set y = BlzGetLocalSpecialEffectY(e)
								set z = BlzGetLocalSpecialEffectZ(e)
								set missile = BladeMissile.create(x, y, z, Damage.target.x, Damage.target.y, 40)
								set missile.source = Damage.source.unit
								set missile.target = Damage.target.unit
								set missile.speed  = 1000.
								set missile.arc = 5.
								set missile.damage = amount[Damage.source.id] * 3
								set missile.type = i

								if i == 0 then
									set missile.model  = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
								elseif i == 1 then
									set missile.model  = "Abilities\\Spells\\Other\\HealingSpray\\HealBottleMissile.mdl"
								elseif i == 2 then
									set missile.model  = "Abilities\\Weapons\\WaterElementalMissile\\WaterElementalMissile.mdl"
									set missile.damage = 1000
								else
									set missile.model  = "Abilities\\Spells\\Other\\BlackArrow\\BlackArrowMissile.mdl"
									set missile.damage = 0
								endif
			
								call missile.launch()
							set i = i + 1
						endloop
					endif
				endif
			endif
			
			set e = null
		endmethod	

		implement Periodic

		private static method onInit takes nothing returns nothing
			call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), SphereOfDarkness.code, LegendaryBladeIII.code, 0, 0, 0)
		endmethod
	endstruct
endscope