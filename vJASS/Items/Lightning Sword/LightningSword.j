scope LightningSword
	struct LightningSword extends Item
		static constant integer code = 'I0AY'
		private static boolean array check
	
		private unit unit
		private player player
		private integer index

		// Attributes
		real damage = 250
	
		method destroy takes nothing returns nothing
			set unit = null
			set player = null

			call deallocate()
		endmethod

		private method onTooltip takes unit u, item i, integer id returns string
			return "|cffffcc00Gives|r:\n+ |cffffcc00250|r Damage\n\n|cff00ff00Passive|r: |cffffcc00Quick as Lightning|r: |cffffcc00Base Attack Time|r is reduced by |cffffcc000.5|r seconds.\n\n|cff00ff00Passive|r: |cffffcc00Lightning Embodiment|r: Every |cffffcc000.5|r seconds, a |cffffcc00Lightning|r will emanate from your Hero and hit a random enemy unit within |cffffcc00800 AoE|r, dealing |cff00ffff" + N2S(200 + (20 * GetWidgetLevel(u)) + (0.05 * GetWidgetLevel(u) * GetUnitBonus(u, BONUS_SPELL_POWER)), 0) + " Magic|r damage."
        endmethod

		private method onPeriod takes nothing returns boolean
			local unit u
			local group g
			local real amount

			if UnitHasItemOfType(unit, code) then
				if UnitAlive(unit) and not IsUnitPaused(unit) then
					set g = GetEnemyUnitsInRange(player, GetUnitX(unit), GetUnitY(unit), 800, false, false)
					set amount = 200 + (20 * GetWidgetLevel(unit)) + (0.05 * GetWidgetLevel(unit) * GetUnitBonus(unit, BONUS_SPELL_POWER))

					if BlzGroupGetSize(g) > 0 then
						set u = GroupPickRandomUnit(g)

						if not IsUnitInvisible(unit, GetOwningPlayer(u)) then
							call DestroyLightningTimed(AddLightningEx("BLNL", true, GetUnitX(unit), GetUnitY(unit), (GetUnitZ(unit) + 60.0), GetUnitX(u), GetUnitY(u), (GetUnitZ(u) + 60.0)), 0.2)
						endif

						call UnitDamageTarget(unit, u, amount, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
						call DestroyEffect(AddSpecialEffectTarget("Shock4HD.mdx", u, "origin"))
					endif

					call DestroyGroup(g)

					set u = null
					set g = null
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
				set index = id
				set player = GetOwningPlayer(u)

				call StartTimer(0.5, true, this, id)
			endif

			call LinkEffectToItem(u, i, "Shock4HD_NoSound.mdx", "origin")
			call BlzSetUnitAttackCooldown(u, BlzGetUnitAttackCooldown(u, 0) - 0.5, 0)
		endmethod

		private method onDrop takes unit u, item i returns nothing
			call BlzSetUnitAttackCooldown(u, BlzGetUnitAttackCooldown(u, 0) + 0.5, 0)
		endmethod

		implement Periodic

		private static method onInit takes nothing returns nothing
			call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
		endmethod
	endstruct
endscope