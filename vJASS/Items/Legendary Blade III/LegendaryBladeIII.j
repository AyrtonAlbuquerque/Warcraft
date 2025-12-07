scope LegendaryBladeIII
	struct LegendaryBladeIII extends Item
		static constant integer code = 'I08X'
		static constant real step = 2.5*0.017453

		// Attributes
        real damage = 50
        real attackSpeed = 0.5
        real spellPower = 100

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
			call table.destroy()
			call deallocate()

			set attack[index] = 0
			set amount[index] = 0
			set unit = null
		endmethod	

		private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc0050|r Damage\n+ |cffffcc00100|r Spell Power\n+ |cffffcc0050%%|r Attack Speed\n\n|cff00ff00Passive|r: |cffffcc00Flaming Blade|r: Every |cffffcc004|r attacks a fireball will strike the target dealing |cffffcc003x your last damage dealt over 2 seconds|r.\n\n|cff00ff00Passive|r: |cffffcc00Holy Blade|r: Every |cffffcc004|r attacks a lightball will strike the target dealing the same amount of damage of your last damage dealt by a basic attack and will heal the carrier by |cffffcc001.2x|r that amount.\n\n|cff00ff00Passive|r: |cffffcc00Water Bolt|r: Every |cffffcc004|r attacks a water bolt will strike the target dealing |cff00ffff" + N2S(150 + 5 * GetWidgetLevel(u) + (0.025 * GetWidgetLevel(u) * GetUnitBonus(u, BONUS_SPELL_POWER)), 0) + " Magic|r damage and will slow the target by |cffffcc0030%%|r for |cffffcc001,5|r seconds."
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
				call BlzSetSpecialEffectPosition(table.effect[1], x + 150*Cos(angle + 120*0.017453), y + 150*Sin(angle + 120*0.017453), z + 60)
				call BlzSetSpecialEffectPosition(table.effect[2], x + 150*Cos(angle + 240*0.017453), y + 150*Sin(angle + 240*0.017453), z + 60)
			
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
				set self.angle = 0
				set self.index = id
				set self.table.effect[0] = AddSpecialEffect("Sweep_Fire_Small.mdl", x, y)
				set self.table.effect[1] = AddSpecialEffect("Sweep_Holy_Small.mdl", x, y)
				set self.table.effect[2] = AddSpecialEffect("Sweep_Black_Frost_Small.mdl", x, y)

				call StartTimer(0.05, true, self, id)
				call BlzSetSpecialEffectPosition(self.table.effect[0], x, y, z)
				call BlzSetSpecialEffectPosition(self.table.effect[1], x, y, z)
				call BlzSetSpecialEffectPosition(self.table.effect[2], x, y, z)
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
							exitwhen i > 2
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
								elseif i == 1 then
									set missile.model  = "Abilities\\Spells\\Other\\HealingSpray\\HealBottleMissile.mdl"
								else
									set missile.model  = "Abilities\\Weapons\\WaterElementalMissile\\WaterElementalMissile.mdl"
									set missile.damage = 150 + 5 * Damage.source.level + (0.025 * Damage.source.level * GetUnitBonus(Damage.source.unit, BONUS_SPELL_POWER))
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
            call RegisterItem(allocate(code), SphereOfWater.code, LegendaryBladeII.code, 0, 0, 0)
		endmethod
	endstruct
endscope