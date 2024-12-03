scope SapphireHammer
	struct SapphireHammer extends Item
		static constant integer code = 'I096'
		static constant string model = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        static constant string point = "overhead"
	
		// Attributes
        real damage = 750
        real strength = 500
        real spellPowerFlat = 400

		private static integer array bonus
	
		private unit unit
		private integer index
	
		method destroy takes nothing returns nothing
            set unit = null
            set bonus[index] = bonus[index] - 10

            call super.destroy()
		endmethod
	
		private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc00750|r Damage\n+ |cffffcc00400|r Spell Power\n+ |cffffcc00500|r Strength\n\n|cff00ff00Passive|r: |cffffcc00Cleave|r: Melee attacks cleave within |cffffcc00350 AoE|r, dealing |cffffcc0045%%|r of damage dealt.\n\n|cff00ff00Passive|r: |cffffcc00Unstopable Momentum|r: Every attack increases |cffff0000Strength|r by |cffffcc0010|r for |cffffcc0060|r seconds.\n\n|cff00ff00Passive|r: |cffffcc00Shattering Blow|r: Every attack has |cffffcc0020%%|r chance to shatter the earth around the target, dealing |cff00ffff" + AbilitySpellDamageEx((GetHeroStr(u, true)/2), u) + " Magic|r damage and stunning all enemy units within |cffffcc00400 AoE|r for |cffffcc003|r seconds |cffffcc00(1 for Heroes)|r and Healing the Hero for the same amount.\n\nStrength Bonus: |cffffcc00" + I2S(bonus[id]) + "|r")
        endmethod
	
		private static method onDamage takes nothing returns nothing
			local real damage
			local real heal
			local real x
            local real y
			local unit u
            local group g
			local thistype this
	
			if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure and Damage.source.isMelee then
				set this = thistype.new()
				set unit = Damage.source.unit
				set index = Damage.source.id
				set bonus[Damage.source.id] = bonus[Damage.source.id] + 10
	
				call StartTimer(60, false, this, -1)
				call AddUnitBonusTimed(Damage.source.unit, BONUS_STRENGTH, 10, 60)
                call DestroyEffect(AddSpecialEffectTarget("HealRed.mdx", Damage.source.unit, "origin"))
	
				if GetRandomReal(1, 100) <= 20 then
					set damage = GetHeroStr(Damage.source.unit, true)*0.5
					set heal = GetSpellDamage(damage, Damage.source.unit)
                    set g = CreateGroup()
	
					call DestroyEffect(AddSpecialEffect("cataclysm.mdx", Damage.target.x, Damage.target.y))
					call DestroyEffect(AddSpecialEffectTarget("SpellVampTarget.mdx", Damage.source.unit, "origin"))
                    call SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + heal)
                    call GroupEnumUnitsInRange(g, Damage.target.x, Damage.target.y, 400, null)

                    loop
                        set u = FirstOfGroup(g)
                        exitwhen u == null
                            if IsUnitEnemy(u, Damage.source.player) and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) and not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE) then
                                call StunUnit(u, 1, model, point, false)
                            endif
                        call GroupRemoveUnit(g, u)
                    endloop

                    call UnitDamageArea(Damage.source.unit, Damage.target.x, Damage.target.y, 400, damage, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, false, false, false)
                    call DestroyGroup(g)
				endif
            endif
            
            set g = null
		endmethod

		implement Periodic

		private static method onInit takes nothing returns nothing
			call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, HammerOfNature.code, SaphireShoulderPlate.code, 0, 0, 0)
		endmethod
	endstruct
endscope