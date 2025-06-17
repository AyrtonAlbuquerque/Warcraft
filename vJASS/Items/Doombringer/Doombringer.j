scope Doombringer
    struct Doombringer extends Item
        static constant integer code = 'I083'

        // Attributes    
        real damage = 1250
        real criticalDamage = 2
        real criticalChance = 0.2

        private static HashTable table
        private static integer array bonus
        private static integer array attack

        private integer index
        
        method destroy takes nothing returns nothing
            set bonus[index] = bonus[index] - 1250
            call deallocate()
        endmethod

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc001250|r Damage\n+ |cffffcc0020%%|r Critical Strike Chance\n+ |cffffcc00200%%|r Critical Strike Damage\n\n|cff00ff00Passive|r: |cffffcc00Death's Blow|r: Every |cffffcc00fifth|r attack is a guaranteed Critical Strike with |cffffcc00200%%|r Critical Damage Bonus within |cffffcc00400 AoE|r. If |cffffcc00Death's Blow|r kills the attacked enemy unit, damage is increased by |cffffcc001250|r for |cffffcc0010|r seconds.\n\nBonus Damage: |cffffcc00" + I2S(bonus[id]) + "|r"
        endmethod

        private static method onCritical takes nothing returns nothing
            local unit source = GetCriticalSource()
            local unit target = GetCriticalTarget()
            local player owner = GetOwningPlayer(source)
            local integer idx = GetUnitUserData(source)
            local real damage 
            local integer id
            local group g
            local unit v
            local thistype this

            if attack[idx] >= 4 and IsUnitEnemy(target, owner) then
                set g = CreateGroup()
                set id = GetHandleId(source)
                set damage = GetCriticalDamage()
                set attack[idx] = -1

                call UnitAddCriticalStrike(source, -100, -2)
                call DestroyEffect(AddSpecialEffectTarget("Damnation Orange.mdx", target, "origin"))
                call DestroyEffect(table[id].effect[0])
                call DestroyEffect(table[id].effect[1])
                call table.remove(id)

                call GroupEnumUnitsInRange(g, GetUnitX(target), GetUnitY(target), 400, null)

                loop
                    set v = FirstOfGroup(g)
                    exitwhen v == null
                        if IsUnitEnemy(v, owner) and UnitAlive(v) and not IsUnitType(v, UNIT_TYPE_STRUCTURE) then
                            call UnitDamageTarget(source, v, damage, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_MAGIC, null)
                        endif
                    call GroupRemoveUnit(g, v)
                endloop

                call DestroyGroup(g)

                if damage > GetWidgetLife(target) then
                    set this = thistype.allocate(0)
                    set index = idx
                    set bonus[idx] = bonus[idx] + 1250

                    call StartTimer(10, false, this, -1)
                    call AddUnitBonusTimed(source, BONUS_DAMAGE, 1250, 10)
                endif
            endif

            set g = null
            set owner = null
            set source = null
            set target = null
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure then
                set attack[Damage.source.id] = attack[Damage.source.id] + 1
        
                if attack[Damage.source.id] == 4 then
                    set table[Damage.source.handle].effect[0] = AddSpecialEffectTarget("Sweep_Fire_Small.mdx", Damage.source.unit, "hand left")
                    set table[Damage.source.handle].effect[1] = AddSpecialEffectTarget("Sweep_Fire_Small.mdx", Damage.source.unit, "hand right")

                    call AddUnitBonus(Damage.source.unit, BONUS_CRITICAL_CHANCE, 1)
                    call AddUnitBonus(Damage.source.unit, BONUS_CRITICAL_DAMAGE, 2)
                endif
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            set table = HashTable.create()

            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
            call RegisterItem(allocate(code), SphereOfFire.code, TriedgeSword.code, 0, 0, 0)
        endmethod
    endstruct
endscope