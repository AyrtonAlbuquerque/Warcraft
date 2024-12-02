scope ElementalSphere
	private struct Essence extends Missiles
		integer index
	
		method onFinish takes nothing returns boolean
			if type == 0 then
				set ElementalSphere.fire[index] = ElementalSphere.fire[index] + 1
				call AddUnitBonus(source, BONUS_HEALTH, 50)
				call AddUnitBonus(source, BONUS_HEALTH_REGEN, 5.0)
			elseif type == 1 then
				set ElementalSphere.water[index] = ElementalSphere.water[index] + 1
				call AddUnitBonus(source, BONUS_MANA, 50)
				call AddUnitBonus(source, BONUS_MANA_REGEN, 5.0)
			elseif type == 2 then
				set ElementalSphere.life[index] = ElementalSphere.life[index] + 1
				call UnitAddSpellPowerFlat(source, 10)
			elseif type == 3 then
				set ElementalSphere.air[index] = ElementalSphere.air[index] + 1
				call UnitAddEvasionChance(source, 0.1)
				call UnitAddMoveSpeedBonus(source, 0, 1, 0)
			elseif type == 4 then
				set ElementalSphere.dark[index] = ElementalSphere.dark[index] + 1
				call AddUnitBonus(source, BONUS_DAMAGE, 10)
			endif
	
			return true
		endmethod
	endstruct
	
	struct ElementalSphere extends Item
		static constant integer code = 'I0AO'
		static constant string AIR = "Sweep_Wind_Small.mdl"
		static constant string FIRE = "Sweep_Fire_Small.mdl"
		static constant string WATER = "Sweep_Black_Frost_Small.mdl"
		static constant string LIFE = "Sweep_Soul_Small.mdl"
		static constant string DARK = "Sweep_Astral_Small.mdl"

		private static string array essence
		private static group group = CreateGroup()

		static integer array fire
		static integer array water
		static integer array air
		static integer array life
		static integer array dark

		private effect effect
		private boolean launched
		private integer type
		private real duration
		private real x
		private real y

		// Attributes
		real spellPowerFlat = 2000

		method destroy takes nothing returns nothing
            call DestroyEffect(effect)
			call super.destroy()

            set effect = null
        endmethod

		private method launch takes real x, real y, unit target, integer essenceType returns boolean
			local Essence missile = Essence.create(x, y, 50, GetUnitX(target), GetUnitY(target), 100)
	
			set missile.source = target
            set missile.target = target
            set missile.type = essenceType
            set missile.model = "Abilities\\Weapons\\SorceressMissile\\SorceressMissile.mdl"
            set missile.speed = 800
            set missile.owner = GetOwningPlayer(target)
            set missile.index = GetUnitUserData(target)
	
			call missile.launch()

			return true
		endmethod

		static method create takes integer i, real x, real y returns thistype
			local thistype this = thistype.new()

			set type = i
			set .x = x
			set .y = y
			set effect = AddSpecialEffect(essence[i], x, y)
			set duration = 20
			set launched = false

			call StartTimer(0.5, true, this, -1)

			return this
		endmethod

		private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc002000|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Elemental Essence|r: When a enemy unit dies, it will spawn in its location one |cffffcc00Elemental Essence|r. Any Hero carrying |cffffcc00Elemental Sphere|r will collect all essences within |cffffcc00800 AoE|r, gaining its effects permanently depending on the essence collected. Dying Heroes spawns all 5 essences. Essences lasts for |cffffcc0020|r seconds.\n\n|cffff0000Fire Essence|r: |cffff0000Health|r is increased by |cffffcc0050|r and |cff00ff00Health Regeneration|r is increased by |cffffcc005|r.\n\n|cff00ffffWater Essence|r: |cff00ffffMana|r is increased by |cffffcc0050|r and |cff00ffffMana Regeneration|r is increased by |cffffcc005|r.\n\n|cff808080Air Essence|r: |cffff00ffEvasion|r is increased by |cffffcc000.1%%|r and |cffffcc00Movement Speed|r is increased by |cffffcc001|r.\n\n|cff00ff00Life Essence|r: |cff00ffffSpell Power|r is increased by |cffffcc0010|r.\n\ncff6f2583Dark Essence|r: |cffff0000Damage|r is increased by |cffffcc0010|r.\n\n|cffff0000Fire|r: " + I2S(fire[id]) + "\n|cff00ffffWater|r: " + I2S(water[id]) + "\n|cff808080Air|r: " + I2S(air[id]) + "\n|cff00ff00Life|r: " + I2S(life[id]) + "\n|cff6f2583Dark|r: " + I2S(dark[id]))
        endmethod

		private method onPeriod takes nothing returns boolean
			local unit u
			local integer i = 0
			local integer size = BlzGroupGetSize(group)
			
			if duration > 0 then
				if size > 0 then
					loop
						exitwhen i == size or launched
							set u = BlzGroupUnitAt(group, i)

							if IsUnitInRangeXY(u, x, y, 800) then
								set launched = launch(x, y, u, type)
							endif
						set i = i + 1
					endloop

					set u = null

					return not launched
				endif

				set duration = duration - 0.5

				return true
			endif

			return false
		endmethod
		
		private method onPickup takes unit u, item i returns nothing
			if IsUnitType(u, UNIT_TYPE_HERO) and not IsUnitIllusionEx(u) then
				if not IsUnitInGroup(u, group) then
					call GroupAddUnit(group, u)
				endif
			endif
		endmethod

		private method onDrop takes unit u, item i returns nothing
			if IsUnitType(u, UNIT_TYPE_HERO) and not IsUnitIllusionEx(u) then
				if IsUnitInGroup(u, group) and not UnitHasItemOfType(u, code) then
					call GroupRemoveUnit(group, u)
				endif
			endif
		endmethod

		private static method onDeath takes nothing returns nothing
			local unit u = GetDyingUnit()
			local integer i = 0

			if BlzGroupGetSize(group) > 0 and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitIllusionEx(u) then
				if IsUnitType(u, UNIT_TYPE_HERO) then
					loop
						exitwhen i == 5
							call create(i, GetUnitX(u) + GetRandomReal(0, 75), GetUnitY(u) + GetRandomReal(0, 75))
						set i = i + 1						
					endloop
				else
					call create(GetRandomInt(0, 4), GetUnitX(u), GetUnitY(u))
				endif
			endif
			
			set u = null
		endmethod

		implement Periodic

		private static method onInit takes nothing returns nothing
			set essence[0] = FIRE
			set essence[1] = WATER
			set essence[2] = LIFE
			set essence[3] = AIR
			set essence[4] = DARK

			call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call thistype.allocate(code, SphereOfFire.code, SphereOfWater.code, SphereOfNature.code, SphereOfAir.code, SphereOfDarkness.code)
		endmethod
	endstruct
endscope