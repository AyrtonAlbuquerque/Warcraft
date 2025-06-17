scope MagusOrb
    struct MagusOrb extends Item
        static constant integer code = 'I09O'

        // Attributes
        real agility = 500
        real strength = 500
        real intelligence = 500
        real manaRegen = 500
        real healthRegen = 500
        real spellPower = 500

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

                if damage >= GetWidgetLife(Damage.target.unit) or Damage.target.isHero then
                    set bonus = GetRandomInt(1, 4)
        
                    if bonus == 1 then //Fire
                        call AddUnitBonusTimed(Damage.source.unit, BONUS_HEALTH_REGEN, 1000, 10)
                        call DestroyEffectTimed(AddSpecialEffectTarget("Sweep_Fire_Small.mdx", Damage.source.unit, "hand left"), 10)
                        call DestroyEffectTimed(AddSpecialEffectTarget("Sweep_Fire_Small.mdx", Damage.source.unit, "hand right"), 10)
                    elseif bonus == 2 then //Water
                        call AddUnitBonusTimed(Damage.source.unit, BONUS_MANA_REGEN, 1000, 10)
                        call DestroyEffectTimed(AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdx", Damage.source.unit, "hand left"), 10)
                        call DestroyEffectTimed(AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdx", Damage.source.unit, "hand right"), 10)
                    elseif bonus == 3 then //Earth
                        call AddUnitBonusTimed(Damage.source.unit, BONUS_SPELL_POWER, 1000, 10)
                        call DestroyEffectTimed(AddSpecialEffectTarget("Sweep_Soul_Small.mdx", Damage.source.unit, "hand left"), 10)
                        call DestroyEffectTimed(AddSpecialEffectTarget("Sweep_Soul_Small.mdx", Damage.source.unit, "hand right"), 10)
                    elseif bonus == 4 then //Light
                        call AddUnitBonusTimed(Damage.source.unit, BONUS_DAMAGE, 1000, 10)
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