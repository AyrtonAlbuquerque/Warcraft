scope LegendaryBladeII
	struct LegendaryBladeII extends Item
		static constant integer code = 'I080'
		static constant real step = 2.5*0.017453

		// Attributes
        real damage = 50
        real attackSpeed = 0.4
        real spellPower = 70

		private static real array amount
		private static integer array attack
		
		private unit unit
		private real angle
		private integer index
		private Table table
	
		method destroy takes nothing returns nothing
			call DestroyEffect(table.effect[0])
			call DestroyEffect(table.effect[1])
			call table.destroy()
			call deallocate()

			set attack[index] = 0
			set amount[index] = 0
			set unit = null
		endmethod

		private method onPeriod takes nothing returns boolean
			local real x
			local real y
			local real z
	
			if UnitHasItemOfType(unit, code) then
				set x = GetUnitX(unit)
				set y = GetUnitY(unit)
				set z = GetUnitZ(unit)
				set angle = angle + step

				call BlzSetSpecialEffectPosition(table.effect[0], x + 150*Cos(angle), y + 150*Sin(angle), z + 60)
				call BlzSetSpecialEffectPosition(table.effect[1], x + 150*Cos(angle + bj_PI), y + 150*Sin(angle + bj_PI), z + 60)
			
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

				call StartTimer(0.05, true, self, id)
				call BlzSetSpecialEffectPosition(self.table.effect[0], x, y, z)
				call BlzSetSpecialEffectPosition(self.table.effect[1], x, y, z)
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
	
				if attack[Damage.source.id] == 3 then
					set i = 0
					set attack[Damage.source.id] = 0
					set this = GetTimerInstance(Damage.source.id)

					if this != 0 then
						loop
							exitwhen i > 1
								set e = table.effect[i]
								set x = BlzGetLocalSpecialEffectX(e)
								set y = BlzGetLocalSpecialEffectY(e)
								set z = BlzGetLocalSpecialEffectZ(e)
								set missile = BladeMissile.create(x, y, z, Damage.target.x, Damage.target.y, 40)
								set missile.source = Damage.source.unit
								set missile.target = Damage.target.unit
								set missile.speed = 1000.
								set missile.arc = 5. * bj_DEGTORAD
								set missile.damage = amount[Damage.source.id]
								set missile.type = i

								if i == 0 then
									set missile.model  = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
								else
									set missile.model  = "Abilities\\Spells\\Other\\HealingSpray\\HealBottleMissile.mdl"
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
            call RegisterItem(allocate(code), SphereOfDivinity.code, LegendaryBladeI.code, 0, 0, 0)
		endmethod
	endstruct
endscope