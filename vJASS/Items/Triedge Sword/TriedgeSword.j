scope TriedgeSword
    struct TriedgeSword extends Item
        static constant integer code = 'I076'

        private static integer array stacks
        private static integer array damageBonus
        private static integer array bonusChance
        private static integer array bonusDamage

        // Attributes
        real damage = 100
        real criticalDamage = 1
        real criticalChance = 0.1

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc00100|r Damage\n+ |cffffcc0010%%|r Critical Strike Chance\n+ |cffffcc00100%%|r Critical Strike Damage\n\n|cff00ff00Passive|r: |cffffcc00Critical Mass|r: After hitting a critical strike |cffffcc00Triedge|r gains |cffffcc003|r stacks, increasing damage by |cffffcc00250|r, Criticial Strike Chance by |cffffcc002%%|r and Critical Strike Damage by |cffffcc0010%%|r per stack. Attacking an enemy unit consumes 1 stack. Max |cffffcc0010|r stacks.\n\nStacks: |cffffcc00" + I2S(stacks[id]) + "|r\nBonus Damage: |cffffcc00" + I2S(damageBonus[id]) + "|r\nBonus Critical Strike Chance: |cffffcc00" + I2S(bonusChance[id]) + "%%|r\nBonus Critical Strike Damage: |cffffcc00" + I2S(bonusDamage[id]) + "%%|r")
        endmethod

        private static method onDamage takes nothing returns nothing
            if stacks[Damage.source.id] > 0 then
                set stacks[Damage.source.id] = stacks[Damage.source.id] - 1
                set damageBonus[Damage.source.id] = damageBonus[Damage.source.id] - 250
                set bonusChance[Damage.source.id] = bonusChance[Damage.source.id] - 2
                set bonusDamage[Damage.source.id] = bonusDamage[Damage.source.id] - 10

                call AddUnitBonus(Damage.source.unit, BONUS_DAMAGE, -250)
                call UnitAddCriticalStrike(Damage.source.unit, -0.2, -0.1)
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
                set damageBonus[index] = damageBonus[index] + (250 * current)
                set bonusChance[index] = bonusChance[index] + (2 * current)
                set bonusDamage[index] = bonusDamage[index] + (10 * current)

                call AddUnitBonus(source, BONUS_DAMAGE, 250*current)
                call UnitAddCriticalStrike(source, 0.2*current, 0.1*current)
            endif

            set source = null
            set target = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
            call thistype.allocate(code, OrcishAxe.code, KnightBlade.code, 0, 0, 0)
        endmethod
    endstruct
endscope