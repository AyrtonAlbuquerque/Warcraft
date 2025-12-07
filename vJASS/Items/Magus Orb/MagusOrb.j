scope MagusOrb
    struct MagusOrb extends Item
        static constant integer code = 'I09O'

        // Attributes
        real intelligence = 25
        real manaRegen = 20
        real healthRegen = 20
        real spellPower = 175

        private static HashTable table

        private unit unit
        private integer handle

        method destroy takes nothing returns nothing
            if UnitHasItemOfType(unit, code) then
                set table[handle].effect[0] = AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdx", unit, "hand left")
                set table[handle].effect[1] = AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdx", unit, "hand right")
            else
                call DestroyEffect(table[handle].effect[0])
                call DestroyEffect(table[handle].effect[1])
                set table[handle].effect[0] = null
                set table[handle].effect[1] = null
            endif

            call deallocate()

            set unit = null
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc0025|r Intelligence\n+ |cffffcc00175|r Spell Power\n+ |cffffcc0020|r Health Regeneration\n+ |cffffcc0020|r Mana Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Magnum Arcana|r: Every |cffffcc0010|r seconds the next instance of |cff00ffffMagic|r damage dealt is doubled.\n\n|cff00ff00Passive|r: |cffffcc00Magistrum Divinos|r: When killing an enemy unit or attacking an enemy Hero with |cffffcc00Magnum Arcana|r, one of the following elemental effects are granted for |cffffcc0010|r seconds:\n\n|cffff0000Fire|r: |cff00ff00Health Regeneration|r is increased by |cff00ff00" + N2S(5 * GetWidgetLevel(u), 0) + "|r.\n\n|cff00ffffWater|r: |cff00ffffMana Regeneration|r is increased by |cff00ffff" + N2S(5 * GetWidgetLevel(u), 0) + "|r.\n\n|cff8b4513Earth|r: |cffff0000Damage|r is increased by |cffff0000" + N2S(5 * GetWidgetLevel(u), 0) + "|r.\n\n|cffffff00Light|r: |cff00ffffSpell Power|r is increased by |cff00ffff" + N2S(5 * GetWidgetLevel(u), 0) + "|r."
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = 2*Damage.amount
            local integer bonus
            local thistype this
        
            if UnitHasItemOfType(Damage.source.unit, code) and damage > 0 and Damage.isEnemy and not HasStartedTimer(Damage.source.id) then
                set this = thistype.allocate(0)
                set unit = Damage.source.unit
                set handle = Damage.source.handle
                set Damage.amount = damage

                call DestroyEffect(table[handle].effect[0])
                call DestroyEffect(table[handle].effect[1])
                call DestroyEffect(AddSpecialEffect("Blink Purple Caster.mdx", Damage.target.x, Damage.target.y))
                call StartTimer(10, false, this, Damage.source.id)

                if damage >= Damage.target.health or Damage.target.isHero then
                    set bonus = GetRandomInt(1, 4)
        
                    if bonus == 1 then //Fire
                        call AddUnitBonusTimed(Damage.source.unit, BONUS_HEALTH_REGEN, 5 * Damage.source.level, 10)
                        call DestroyEffectTimed(AddSpecialEffectTarget("Sweep_Fire_Small.mdx", Damage.source.unit, "hand left"), 10)
                        call DestroyEffectTimed(AddSpecialEffectTarget("Sweep_Fire_Small.mdx", Damage.source.unit, "hand right"), 10)
                    elseif bonus == 2 then //Water
                        call AddUnitBonusTimed(Damage.source.unit, BONUS_MANA_REGEN, 5 * Damage.source.level, 10)
                        call DestroyEffectTimed(AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdx", Damage.source.unit, "hand left"), 10)
                        call DestroyEffectTimed(AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdx", Damage.source.unit, "hand right"), 10)
                    elseif bonus == 3 then //Earth
                        call AddUnitBonusTimed(Damage.source.unit, BONUS_SPELL_POWER, 5 * Damage.source.level, 10)
                        call DestroyEffectTimed(AddSpecialEffectTarget("Sweep_Soul_Small.mdx", Damage.source.unit, "hand left"), 10)
                        call DestroyEffectTimed(AddSpecialEffectTarget("Sweep_Soul_Small.mdx", Damage.source.unit, "hand right"), 10)
                    elseif bonus == 4 then //Light
                        call AddUnitBonusTimed(Damage.source.unit, BONUS_DAMAGE, 5 * Damage.source.level, 10)
                        call DestroyEffectTimed(AddSpecialEffectTarget("Sweep_Holy_Small.mdx", Damage.source.unit, "hand left"), 10)
                        call DestroyEffectTimed(AddSpecialEffectTarget("Sweep_Holy_Small.mdx", Damage.source.unit, "hand right"), 10)
                    endif
                endif

                set table[handle].effect[0] = null
                set table[handle].effect[1] = null
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            set table = HashTable.create()

            call RegisterSpellDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), ElementalSpin.code, AncientSphere.code, 0, 0, 0)
        endmethod
    endstruct
endscope