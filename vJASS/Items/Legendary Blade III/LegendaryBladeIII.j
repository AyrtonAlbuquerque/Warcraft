scope LegendaryBladeIII
	struct LegendaryBladeIII extends Item
		static constant integer code = 'I08X'
		static constant real  step = 2.5*0.017453

		private static timer timer = CreateTimer()
		private static integer key = -1
		private static thistype array array
		private static integer array struct
		private static integer array attack
		private static real array amount
		
		private unit unit
		private real angle
		private integer index
		private Table table

		// Attributes
        real damage = 1750
        real attackSpeed = 2
        real spellPowerFlat = 1250
	
		private method remove takes integer i returns integer
			call DestroyEffect(table.effect[0])
			call DestroyEffect(table.effect[1])
			call DestroyEffect(table.effect[2])
			call table.destroy()

			set array[i] = array[key]
			set key = key - 1
			set attack[index] = 0
			set amount[index] = 0
			set struct[index] = 0
			set unit = null

			if key == -1 then
				call PauseTimer(timer)
			endif

			call super.destroy()

			return i - 1
		endmethod	
	
		private static method orbit takes nothing returns nothing
			local real x
			local real y
			local real z
			local integer i = 0
			local thistype this
	
			loop
				exitwhen i > key
					set this = array[i]
	
					if UnitHasItemOfType(unit, code) then
						set angle = angle + step
						set x = GetUnitX(unit)
						set y = GetUnitY(unit)
						set z = GetUnitZ(unit)

						call BlzSetSpecialEffectPosition(table.effect[0], x + 150*Cos(angle), y + 150*Sin(angle), z + 60)
						call BlzSetSpecialEffectPosition(table.effect[1], x + 150*Cos(angle + 120*0.017453), y + 150*Sin(angle + 120*0.017453), z + 60)
						call BlzSetSpecialEffectPosition(table.effect[2], x + 150*Cos(angle + 240*0.017453), y + 150*Sin(angle + 240*0.017453), z + 60)
					else
						set i = remove(i)
					endif
				set i = i + 1
			endloop
		endmethod

		private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc001500|r Damage\n+ |cffffcc001000|r Spell Power\n+ |cffffcc00150%|r Attack Speed\n\n|cff00ff00Passive|r: |cffffcc00Flaming Blade|r: Every |cffffcc004|r attacks a fireball will strike the target dealing |cffffcc003x your last damage dealt over 2 seconds|r.\n\n|cff00ff00Passive|r: |cffffcc00Holy Blade|r: Every |cffffcc004|r attacks a lightball will strike the target dealing the same amount of damage of your last damage dealt by a basic attack and will heal the carrier by |cffffcc003x|r that amount.\n\n|cff00ff00Passive|r: |cffffcc00Water Bolt|r: Every |cffffcc004|r attacks a water bolt will strike the target dealing |cff00ffff" + AbilitySpellDamageEx(1000, u) + " Magic|r damage and will slow the target by |cffffcc0030%|r for |cffffcc001,5|r seconds.")
        endmethod

		private static method onDamage takes nothing returns nothing
			local real x
			local real y
			local real z
			local effect e
			local integer i
			local BladeMissile missile
			local thistype this
	
			if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure then
				set amount[Damage.source.id] = GetEventDamage()
				set attack[Damage.source.id]  = attack[Damage.source.id] + 1
	
				if attack[Damage.source.id] == 4 then
					set i = 0
					set attack[Damage.source.id] = 0
					set this = struct[Damage.source.id]

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
							set missile.arc = 5.
							set missile.damage = amount[Damage.source.id] * 3
							set missile.type = i

							if i == 0 then
								set missile.model  = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
							elseif i == 1 then
								set missile.model  = "Abilities\\Spells\\Other\\HealingSpray\\HealBottleMissile.mdl"
							else
								set missile.model  = "Abilities\\Weapons\\WaterElementalMissile\\WaterElementalMissile.mdl"
								set missile.damage = 1000
							endif
		
							call missile.launch()
						set i = i + 1
					endloop
				endif
			endif
			
			set e = null
		endmethod
	
		private method onPickup takes unit u, item i returns nothing
			local real x
			local real y
			local real z
			local thistype self
			local integer id = GetUnitUserData(u)
	
			if struct[id] == 0 then
				set x = GetUnitX(u)
				set y = GetUnitY(u)
				set z = GetUnitZ(u) + 60
				set self = thistype.new()
				set self.table = Table.create()
				set self.unit = u
				set self.angle = 0.
				set self.index = id
				set key = key + 1
				set array[key] = self
				set struct[id] = self
				set self.table.effect[0] = AddSpecialEffect("Sweep_Fire_Small.mdl", x, y)
				set self.table.effect[1] = AddSpecialEffect("Sweep_Holy_Small.mdl", x, y)
				set self.table.effect[2] = AddSpecialEffect("Sweep_Black_Frost_Small.mdl", x, y)

				call BlzSetSpecialEffectPosition(self.table.effect[0], x, y, z)
				call BlzSetSpecialEffectPosition(self.table.effect[1], x, y, z)
				call BlzSetSpecialEffectPosition(self.table.effect[2], x, y, z)

				if key == 0 then
					call TimerStart(timer, 0.05, true, function thistype.orbit)
				endif
			endif
		endmethod

		private static method onInit takes nothing returns nothing
			call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, SphereOfWater.code, LegendaryBladeII.code, 0, 0, 0)
		endmethod
	endstruct
endscope