scope LightningSword
	struct LightningSword extends Item
		static constant integer code = 'I0AY'
		private static boolean array check
	
		private unit unit
		private player player
		private integer index

		// Attributes
		real damage = 2500
	
		method destroy takes nothing returns nothing
			set unit = null
			set player = null

			call super.destroy()
		endmethod

		private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc002500|r Damage\n\n|cff00ff00Passive|r: |cffffcc00Quick as Lightning|r: |cffffcc00Base Attack Time|r is reduced by |cffffcc000.5|r seconds.\n\n|cff00ff00Passive|r: |cffffcc00Lightning Embodiment|r: Every |cffffcc000.5|r seconds, a |cffffcc00Lightning|r will emanate from your Hero and hit a random enemy unit within |cffffcc00800 AoE|r, dealing |cff00ffff" + AbilitySpellDamageEx(2500, u) + " Magic|r damage.")
        endmethod

		private method onPeriod takes nothing returns boolean
			local unit u
			local group g

			if UnitHasItemOfType(unit, code) then
				if UnitAlive(unit) and not IsUnitPaused(unit) then
					set g = GetEnemyUnitsInRange(player, GetUnitX(unit), GetUnitY(unit), 800, false, false)

					if BlzGroupGetSize(g) > 0 then
						set u = GroupPickRandomUnit(g)

						if not IsUnitInvisible(unit, GetOwningPlayer(u)) then
							call DestroyLightningTimed(AddLightningEx("BLNL", true, GetUnitX(unit), GetUnitY(unit), (GetUnitZ(unit) + 60.0), GetUnitX(u), GetUnitY(u), (GetUnitZ(u) + 60.0)), 0.2)
						endif

						call UnitDamageTarget(unit, u, 2500, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, null)
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
			local thistype self
	
			if not HasStartedTimer(id) then
				set self = thistype.new()
				set self.unit = u
				set self.index = id
				set self.player = GetOwningPlayer(u)

				call StartTimer(0.5, true, self, id)
			endif

			call LinkEffectToItem(u, i, "Shock4HD_NoSound.mdx", "origin")
			call BlzSetUnitAttackCooldown(u, BlzGetUnitAttackCooldown(u, 0) - 0.5, 0)
		endmethod

		private method onDrop takes unit u, item i returns nothing
			call BlzSetUnitAttackCooldown(u, BlzGetUnitAttackCooldown(u, 0) + 0.5, 0)
		endmethod

		implement Periodic

		private static method onInit takes nothing returns nothing
			call thistype.allocate(code, 0, 0, 0, 0, 0)
		endmethod
	endstruct
endscope