scope LegendaryBladeI
    struct BladeMissile extends Missile
		method onFinish takes nothing returns boolean
			if type == 0 then
				// call DamageOverTimeEx(source, target, damage, 2, ATTACK_TYPE_HERO, DAMAGE_TYPE_FIRE, "Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl", "origin")
			elseif type == 1 then
				call UnitDamageTarget(source, target, damage/3, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_DIVINE, null)
				call SetWidgetLife(source, GetWidgetLife(source) + damage)
				call ArcingTextTag.create(("|cff32cd32" + "+" + R2I2S(damage)), source, 0.015)
				call DestroyEffect(AddSpecialEffectTarget("HolyLight.mdx", source, "origin"))
			elseif type == 2 then
				call UnitDamageTarget(source, target, 1000, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_DIVINE, null)
				call DestroyEffectTimed(AddSpecialEffectTarget("WaterBreathDamage.mdx", target, "chest"), 1.5)
				call AddUnitBonusTimed(target, BONUS_MOVEMENT_SPEED, -0.3*GetUnitMoveSpeed(target), 1.5)
			elseif type == 3 then
				call AddUnitBonusTimed(target, BONUS_ARMOR, -50, 5.0)
			elseif type == 4 then
				call AddUnitBonusTimed(source, BONUS_MOVEMENT_SPEED, 522, 3)
				call DestroyEffectTimed(AddSpecialEffectTarget("Abilities\\Spells\\Other\\Tornado\\Tornado_Target.mdl", source, "origin"), 3)
			endif

			return true
		endmethod
	endstruct
    
    struct LegendaryBladeI extends Item
        static constant integer code = 'I073'
        static constant real step = 2.5*0.017453

		// Attributes
        real damage = 1000
        real attackSpeed = 0.5
        real spellPower = 500

        private static real array amount
        private static integer array attack
		
		private unit unit
		private real angle
		private integer index
		private Table table
	
        method destroy takes nothing returns nothing
			call DestroyEffect(table.effect[0])
			call table.destroy()
			call deallocate()

			set attack[index] = 0
			set amount[index] = 0
			set unit = null
		endmethod
		
		private method onPeriod takes nothing returns boolean
			if UnitHasItemOfType(unit, code) then
				set angle = angle + step
				
				call BlzSetSpecialEffectPosition(table.effect[0], GetUnitX(unit) + 150*Cos(angle), GetUnitY(unit) + 150*Sin(angle), GetUnitZ(unit) + 60)
			
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

				call StartTimer(0.05, true, self, id)
				call BlzSetSpecialEffectPosition(self.table.effect[0], x, y, z)
			endif
		endmethod

		private static method onDamage takes nothing returns nothing
			local real x
			local real y
			local real z
            local effect e
			local thistype this
			local BladeMissile m
	
			if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure then
				set amount[Damage.source.id] = Damage.amount
				set attack[Damage.source.id] = attack[Damage.source.id] + 1
	
				if attack[Damage.source.id] == 3 then
					set this = GetTimerInstance(Damage.source.id)

					if this != 0 then
						set attack[Damage.source.id] = 0
						set e = table.effect[0]
						set x = BlzGetLocalSpecialEffectX(e)
						set y = BlzGetLocalSpecialEffectY(e)
						set z = BlzGetLocalSpecialEffectZ(e)
						set m = BladeMissile.create(x, y, z, Damage.target.x, Damage.target.y, 40)
						set m.source = Damage.source.unit
						set m.target = Damage.target.unit
						set m.speed = 1000.
						set m.arc = 5.
						set m.model = "Abilities\\Weapons\\FireBallMissile\\FireBallMissile.mdl"
						set m.damage = amount[Damage.source.id] * 3
						set m.type = 0

						call m.launch()
					endif
				endif
			endif
			
			set e = null
		endmethod

		implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), WarriorBlade.code, SphereOfFire.code, 0, 0, 0)
        endmethod
    endstruct
endscope