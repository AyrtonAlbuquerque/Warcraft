scope FireBow
	struct FireBow extends Item
		static constant integer code = 'I099'
	
		// Attributes
        real damage = 50
        real agility = 25
        real spellPower = 75

		private static HashTable table
		private static integer array struct
	
		private unit source
		private unit target
		private integer index
		private integer sourceId
		private integer targetId
	
		method destroy takes nothing returns nothing
			set struct[index] = struct[index] - 1
	
			call DestroyEffect(table[targetId].effect[0])
			call table.remove(targetId)
			
			if struct[index] <= 0 then
				set struct[index] = 0 
					
				call DestroyEffect(table[sourceId].effect[0])
				call table.remove(sourceId)
			endif
	
			set source = null
			set target = null

			call deallocate()
		endmethod
	
		private method onTooltip takes unit u, item i, integer id returns string
			return "|cffffcc00Gives:|r\n+ |cffffcc0025|r Agility\n+ |cffffcc0050|r Damage\n+ |cffffcc0075|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Multishot|r: Ranged units can attack |cffffcc004|r more targets.\n\n|cff00ff00Passive|r: |cffffcc00Far Sight|r: Increases Attack Range by |cffffcc00150|r.\n\n|cff00ff00Passive|r: |cffffcc00Holy Burn|r: Attacking units sets them on fire, dealing |cff00ffff" + N2S(100 + 5 * GetWidgetLevel(u) + 0.2 * GetUnitBonus(u, BONUS_SPELL_POWER), 0) + " Magic|r damage per second. Your Hero is also healed for |cffffcc00Half|r of the damage dealt per second for each unit affected by |cffffcc00Holy Burn|r.\n\n|cff00ff00Passive|r: |cffffcc00Incinerate|r: When a unit under the effect of |cffffcc00Holy Burn|r dies, it explodes dealing |cffffcc0010%%|r of its maximum health as damage to all nearby enemy units within |cffffcc00200 AoE|r.\n\nLasts for |cffffcc004|r seconds."
        endmethod

		private method onPeriod takes nothing returns boolean
			local real damage

			if table[targetId][sourceId] > 0 then
				if UnitAlive(target) then
					set table[targetId][sourceId] = table[targetId][sourceId] - 1
					set damage = (100 + 5 * GetWidgetLevel(source) + 0.2 * GetUnitBonus(source, BONUS_SPELL_POWER)) * 0.25

					if UnitDamageTarget(source, target, damage, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null) then
						call SetWidgetLife(source, GetWidgetLife(source) + damage * 0.5)
					endif
				else
					set table[targetId][sourceId] = 0
				endif
			
				return true
			endif

			return false
		endmethod
	
		private static method onDamage takes nothing returns nothing
			local thistype this
	
			if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure and Damage.amount < Damage.target.health then
				if table[Damage.target.handle][Damage.source.handle] == 0 then
					set this = thistype.allocate(0)
					set source = Damage.source.unit
					set target = Damage.target.unit
					set index = Damage.source.id
					set sourceId = Damage.source.handle
					set targetId = Damage.target.handle
					set struct[index] = struct[index] + 1
	
					if table[Damage.target.handle].effect[0] == null then
						set table[Damage.target.handle].effect[0] = AddSpecialEffectTarget("Ember Red.mdx", Damage.target.unit, "chest")
					endif
	
					if table[Damage.source.handle].effect[0] == null then
						set table[Damage.source.handle].effect[0] = AddSpecialEffectTarget("Ember Yellow.mdx", Damage.source.unit, "chest")
					endif

					call StartTimer(0.25, true, this, -1)
				endif
	
				set table[Damage.target.handle][Damage.source.handle] = 16
			endif
		endmethod	
	
		private static method onDeath takes nothing returns nothing
			local unit killed = GetDyingUnit()
			local unit killer = GetKillingUnit()
			local integer index  = GetUnitUserData(killed)
			local real damage
			local real x
			local real y
	
			if table[GetHandleId(killed)][GetHandleId(killer)] > 0 then
				set x = GetUnitX(killed)
				set y = GetUnitY(killed)
				set damage = BlzGetUnitMaxHP(killed) * 0.1
				set table[GetHandleId(killed)][GetHandleId(killer)] = 0
	
				call UnitDamageArea(killer, x, y, 200.0, damage, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, false, false, false)
				call DestroyEffect(AddSpecialEffect("Cannonball C.mdx", x, y))
			endif
	
			set killed = null
			set killer = null
		endmethod

		implement Periodic

		private static method onInit takes nothing returns nothing
			set table = HashTable.create()

			call RegisterAttackDamageEvent(function thistype.onDamage)
			call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterItem(allocate(code), SphereOfFire.code, EnflamedBow.code, 0, 0, 0)
		endmethod
	endstruct
endscope