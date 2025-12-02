scope TriedgeSword
    struct TriedgeSword extends Item
        static constant integer code = 'I076'

        private static integer array stacks
        private static integer array damageBonus
        private static integer array bonusChance
        private static integer array bonusDamage

        // Attributes
        real damage = 65
        real criticalDamage = 0.2
        real criticalChance = 0.1

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc0065|r Damage\n+ |cffffcc0010%%|r Critical Chance\n+ |cffffcc0020%%|r Critical Damage\n\n|cff00ff00Passive|r: |cffffcc00Critical Mass|r: After hitting a critical strike |cffffcc00Triedge|r gains |cffffcc003|r stacks, increasing |cffff0000Damage|r by |cffff000010|r, |cffff0000Criticial Chance|r by |cffffcc002%%|r and |cffff0000Critical Damage|r by |cffffcc003%%|r  per stack. Attacking an enemy unit consumes |cffffcc001|r stack. Max |cffffcc0010|r stacks.\n\nStacks: |cffffcc00" + I2S(stacks[id]) + "|r\nBonus Damage: |cffffcc00" + I2S(damageBonus[id]) + "|r\nBonus Critical Strike Chance: |cffffcc00" + I2S(bonusChance[id]) + "%%|r\nBonus Critical Strike Damage: |cffffcc00" + I2S(bonusDamage[id]) + "%%|r"
        endmethod

        private static method onDamage takes nothing returns nothing
            if stacks[Damage.source.id] > 0 then
                set stacks[Damage.source.id] = stacks[Damage.source.id] - 1
                set damageBonus[Damage.source.id] = damageBonus[Damage.source.id] - 10
                set bonusChance[Damage.source.id] = bonusChance[Damage.source.id] - 2
                set bonusDamage[Damage.source.id] = bonusDamage[Damage.source.id] - 3

                call AddUnitBonus(Damage.source.unit, BONUS_DAMAGE, -10)
                call AddUnitBonus(Damage.source.unit, BONUS_CRITICAL_CHANCE, -0.02)
                call AddUnitBonus(Damage.source.unit, BONUS_CRITICAL_DAMAGE, -0.03)
            endif
        endmethod

        private static method onCritical takes nothing returns nothing
            local unit source = GetCriticalSource()
            local unit target = GetCriticalTarget()
            local integer index = GetUnitUserData(source)
            local integer current = 3

            if UnitHasItemOfType(source, code) and IsUnitEnemy(target, GetOwningPlayer(source)) and stacks[index] < 11 then
                if stacks[index] + current > 11 then
                    set current = 11 - stacks[index]
                endif
                
                set stacks[index] = stacks[index] + current
                set damageBonus[index] = damageBonus[index] + (10 * current)
                set bonusChance[index] = bonusChance[index] + (2 * current)
                set bonusDamage[index] = bonusDamage[index] + (3 * current)

                call AddUnitBonus(source, BONUS_DAMAGE, 10*current)
                call AddUnitBonus(source, BONUS_CRITICAL_CHANCE, 0.02*current)
                call AddUnitBonus(source, BONUS_CRITICAL_DAMAGE, 0.03*current)
            endif

            set source = null
            set target = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
            call RegisterItem(allocate(code), OrcishAxe.code, KnightBlade.code, 0, 0, 0)
        endmethod
    endstruct
endscope