scope LightningSword
	struct LightningSword extends Item
		static constant integer code = 'I0AY'

		private static timer timer = CreateTimer()
		private static integer key  = -1
		private static thistype array array
		private static boolean array check
	
		private unit unit
		private player player
		private integer index

		// Attributes
		real damage = 2500
	
		private method remove takes integer i returns integer
			set array[i] = array[key]
			set key = key - 1
			set check[index] = false
			set unit = null
			set player = null

			if key == -1 then
				call PauseTimer(timer)
			endif

			call super.destroy()

			return i - 1
		endmethod
	
		private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc002500|r Damage\n\n|cff00ff00Passive|r: |cffffcc00Quick as Lightning|r: |cffffcc00Base Attack Time|r is reduced by |cffffcc000.5|r seconds.\n\n|cff00ff00Passive|r: |cffffcc00Lightning Embodiment|r: Every |cffffcc000.5|r seconds, a |cffffcc00Lightning|r will emanate from your Hero and hit a random enemy unit within |cffffcc00800 AoE|r, dealing |cff00ffff" + AbilitySpellDamageEx(2500, u) + " Magic|r damage.")
        endmethod

		private static method onPeriod takes nothing returns nothing
			local unit v
			local group g
			local integer i = 0
			local thistype this
			
			loop
				exitwhen i > key
					set this = array[i]
	
					if UnitHasItemOfType(unit, code) then
						if UnitAlive(unit) and not IsUnitPaused(unit) then
							set g = GetEnemyUnitsInRange(player, GetUnitX(unit), GetUnitY(unit), 800, false, false)
	
							if BlzGroupGetSize(g) > 0 then
								set v = GroupPickRandomUnit(g)

								if not IsUnitInvisible(unit, GetOwningPlayer(v)) then
									call DestroyLightningTimed(AddLightningEx("BLNL", true, GetUnitX(unit), GetUnitY(unit), (GetUnitZ(unit) + 60.0), GetUnitX(v), GetUnitY(v), (GetUnitZ(v) + 60.0)), 0.2)
								endif

								call UnitDamageTarget(unit, v, 2500, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, null)
								call DestroyEffect(AddSpecialEffectTarget("Shock4HD.mdx", v, "origin"))
							endif

							call DestroyGroup(g)
						endif
					else
						set i = remove(i)
					endif
				set i = i + 1
			endloop
	
			set v = null
			set g = null
		endmethod
	
		private method onPickup takes unit u, item i returns nothing
			local integer id = GetUnitUserData(u)
			local thistype self
	
			if not check[id] then
				set self = thistype.new()
				set self.unit = u
				set self.index = id
				set self.player = GetOwningPlayer(u)
				set key = key + 1
				set array[key] = self
				set check[id] = true

				if key == 0 then
					call TimerStart(timer, 0.5, true, function thistype.onPeriod)
				endif
			endif

			call LinkEffectToItem(u, i, "Shock4HD_NoSound.mdx", "origin")
			call BlzSetUnitAttackCooldown(u, BlzGetUnitAttackCooldown(u, 0) - 0.5, 0)
		endmethod

		private method onDrop takes unit u, item i returns nothing
			call BlzSetUnitAttackCooldown(u, BlzGetUnitAttackCooldown(u, 0) + 0.5, 0)
		endmethod

		private static method onInit takes nothing returns nothing
			call thistype.allocate(code, 0, 0, 0, 0, 0)
		endmethod
	endstruct
endscope