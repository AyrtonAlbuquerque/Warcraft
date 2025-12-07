scope ArcTrinity
    struct ArcTrinity extends Item
        static constant integer code = 'I0A0'
        
        // Attributes
        real damage = 150
        real criticalDamage = 0.3
        real criticalChance = -0.3

        private unit unit
        private integer duration
        private Table table

        method destroy takes nothing returns nothing
            call DestroyEffect(table.effect[0])
            call DestroyEffect(table.effect[1])
            call AddUnitBonus(unit, BONUS_SPELL_VAMP, -1)
            call AddUnitBonus(unit, BONUS_LIFE_STEAL, -1)
            call AddUnitBonus(unit, BONUS_DAMAGE, -100)
            call table.destroy()
            call deallocate()

            set unit = null
        endmethod

        private method onPeriod takes nothing returns boolean
            set duration = duration - 1

            return duration > 0
        endmethod

        private static method onCritical takes nothing returns nothing
            local unit source = GetCriticalSource()
            local unit target = GetCriticalTarget()
            local integer id = GetUnitUserData(source)
            local thistype this = GetTimerInstance(id)

            if UnitHasItemOfType(source, code) and IsUnitEnemy(target, GetOwningPlayer(source)) then
                if this == 0 then
                    set this = thistype.allocate(0)
                    set table = Table.create()
                    set unit = source
                    set table.effect[0] = AddSpecialEffectTarget("Sweep_Black_Frost_Small.mdx", source, "hand left")
                    set table.effect[1] = AddSpecialEffectTarget("Sweep_Fire_Small.mdx", source, "hand right")

                    call AddUnitBonus(source, BONUS_SPELL_VAMP, 1)
                    call AddUnitBonus(source, BONUS_LIFE_STEAL, 1)
                    call AddUnitBonus(source, BONUS_DAMAGE, 100)
                    call StartTimer(1, true, this, id)
                endif

                set duration = 10
            endif

            set target = null
            set source = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
            call RegisterItem(allocate(code), TriedgeSword.code, TriedgeSword.code, TriedgeSword.code, 0, 0)
        endmethod
    endstruct
endscope