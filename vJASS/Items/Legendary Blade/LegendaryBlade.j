scope LegendaryBladeI
    struct BladeMissile extends Missiles
		method onFinish takes nothing returns boolean
			if type == 0 then
				//call DamageOverTimeEx(source, target, damage, 2, ATTACK_TYPE_HERO, DAMAGE_TYPE_FIRE, "Abilities\\Spells\\Other\\BreathOfFire\\BreathOfFireDamage.mdl", "origin")
			elseif type == 1 then
				call UnitDamageTarget(source, target, damage/3, true, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_DIVINE, null)
				call SetWidgetLife(source, GetWidgetLife(source) + damage)
				call ArcingTextTag.create(("|cff32cd32" + "+" + R2I2S(damage)), source)
				call DestroyEffect(AddSpecialEffectTarget("HolyLight.mdx", source, "origin"))
			elseif type == 2 then
				call UnitDamageTarget(source, target, 1000, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_DIVINE, null)
				call DestroyEffectTimed(AddSpecialEffectTarget("WaterBreathDamage.mdx", target, "chest"), 1.5)
				call UnitAddMoveSpeedBonus(target, -0.3, 0, 1.5)
			elseif type == 3 then
				call AddUnitBonusTimed(target, BONUS_ARMOR, -50, 5.0)
			elseif type == 4 then
				call UnitAddMoveSpeedBonus(source, 0, 522, 3)
				call DestroyEffectTimed(AddSpecialEffectTarget("Abilities\\Spells\\Other\\Tornado\\Tornado_Target.mdl", source, "origin"), 3)
			endif

			return true
		endmethod
	endstruct
    
    struct LegendaryBladeI extends Item
        static constant integer code = 'I073'
        static constant real step = 2.5*0.017453

        private static timer timer = CreateTimer()
        private static integer key = -1
        private static real array amount
        private static integer array attack
        private static integer array struct
		private static thistype array array
		
		private unit unit
		private real angle
		private integer index
		private Table table

        // Attributes
        real damage = 1000
        real attackSpeed = 0.5
        real spellPowerFlat = 500
	
        private method remove takes integer i returns integer
			call DestroyEffect(table.effect[0])
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
		
		private static method onDamage takes nothing returns nothing
			local real x
			local real y
			local real z
            local effect e
			local BladeMissile m
			local thistype this
	
			if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure then
				set amount[Damage.source.id] = GetEventDamage()
				set attack[Damage.source.id] = attack[Damage.source.id] + 1
	
				if attack[Damage.source.id] == 3 then
					set this = struct[Damage.source.id]
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
			
			set e = null
		endmethod	
	
		private static method orbit takes nothing returns nothing
			local integer i = 0
			local thistype this
	
			loop
				exitwhen i > key
					set this = array[i]

					if UnitHasItemOfType(unit, code) then
						set angle = angle + step
						call BlzSetSpecialEffectPosition(table.effect[0], GetUnitX(unit) + 150*Cos(angle), GetUnitY(unit) + 150*Sin(angle), GetUnitZ(unit) + 60)
					else
						set i = remove(i)
					endif
				set i = i + 1
			endloop
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
				set self.angle = 0
				set self.index = id
				set key = key + 1
				set array[key] = self
				set struct[id] = self
				set self.table.effect[0] = AddSpecialEffect("Sweep_Fire_Small.mdl", x, y)

				call BlzSetSpecialEffectPosition(self.table.effect[0], x, y, z)

				if key == 0 then
					call TimerStart(timer, 0.05, true, function thistype.orbit)
				endif
			endif
		endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, WarriorBlade.code, SphereOfFire.code, 0, 0, 0)
        endmethod
    endstruct
endscope