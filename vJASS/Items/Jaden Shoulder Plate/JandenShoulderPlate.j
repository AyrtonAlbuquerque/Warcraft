scope JadenShoulderPlate 
	struct JadenShoulderPlate extends Item 
		static constant integer code = 'I08F' 

		real health = 1000 
		real strength = 25	
	
		private static method onDamage takes nothing returns nothing 
			if UnitHasItemOfType(Damage.target.unit, code) then 
				if Damage.source.isHero and GetRandomInt(1, 100) <= 75 then 
					call DestroyEffect(AddSpecialEffectTarget("PowerUp.mdx", Damage.target.unit, "origin")) 
					call AddUnitBonusTimed(Damage.target.unit, BONUS_STRENGTH, 6, 120) 
					call AddUnitBonusTimed(Damage.target.unit, BONUS_AGILITY, 6, 120) 
					call AddUnitBonusTimed(Damage.target.unit, BONUS_INTELLIGENCE, 6, 120) 
				elseif not Damage.source.isHero and GetRandomInt(1, 100) <= 10 then 
					call DestroyEffect(AddSpecialEffectTarget("PowerUp.mdx", Damage.target.unit, "origin")) 
					call AddUnitBonusTimed(Damage.target.unit, BONUS_STRENGTH, 3, 60) 
					call AddUnitBonusTimed(Damage.target.unit, BONUS_AGILITY, 3, 60) 
					call AddUnitBonusTimed(Damage.target.unit, BONUS_INTELLIGENCE, 3, 60) 
				endif 
			endif 
		endmethod 

		private static method onInit takes nothing returns nothing 
			call RegisterAttackDamageEvent(function thistype.onDamage) 
			call RegisterItem(allocate(code), EmeraldShoulderPlate.code, SaphireShoulderPlate.code, 0, 0, 0) 
		endmethod 
	endstruct 
endscope