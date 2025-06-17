scope FireBow
	struct FireBow extends Item
		static constant integer code = 'I099'
	
		// Attributes
        real damage = 750
        real agility = 500
        real spellPower = 500

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
	
		private method onPeriod takes nothing returns boolean
			if table[targetId][sourceId] > 0 then
				if UnitAlive(target) then
					set table[targetId][sourceId] = table[targetId][sourceId] - 1

					if UnitDamageTarget(source, target, 250, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null) then
						call SetWidgetLife(source, GetWidgetLife(source) + 125)
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
	
			if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure and Damage.amount < GetWidgetLife(Damage.target.unit) then
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
				set damage = BlzGetUnitMaxHP(killed)*0.1
				set table[GetHandleId(killed)][GetHandleId(killer)] = 0
	
				call UnitDamageArea(killer, x, y, 200.0, damage, ATTACK_TYPE_HERO, DAMAGE_TYPE_MAGIC, false, false, false)
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