scope GluttonousAxe
    struct GluttonousAxe extends Item
        static constant integer code = 'I0A6'
        private static real array steal
        private static real array chance
        private static real array dmg

        real damage = 100
        real lifeSteal = 0.25
        real criticalDamage = 0.4
        real criticalChance = 0.2

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc00100|r Damage\n+ |cffffcc0025%%|r Life Steal\n+ |cffffcc0020%%|r Critical Chance\n+ |cffffcc0040%%|r Critical Damage\n\n|cff00ff00Passive|r: |cffffcc00Devouring Strike|r: After hitting a |cffffcc00Critical Strike|r, |cffffcc00Critical Chance|r and |cffffcc00Life Steal|r are increased by |cffffcc000.05%%|r and |cffffcc00Critical Damage|r is increased by |cffffcc000.1%%|r permanently.\n\nCritical Chance: |cffffcc00" + N2S(100 * chance[id], 2) + " %%|r\nCritical Damage: |cffffcc00" + N2S(100 * dmg[id], 2) + " %%|r\nLife Steal: |cffffcc00" + N2S(100 * steal[id], 2) + " %%|r"
        endmethod

        private static method onCritical takes nothing returns nothing
            local unit source = GetCriticalSource()
            local unit target = GetCriticalTarget()

            if UnitHasItemOfType(source, code) and IsUnitEnemy(target, GetOwningPlayer(source)) then
                set dmg[Critical.source.id] = dmg[Critical.source.id] + 0.001
                set chance[Critical.source.id] = chance[Critical.source.id] + 0.0005
                set steal[Critical.source.id] = steal[Critical.source.id] + 0.0005

                call AddUnitBonus(source, BONUS_CRITICAL_CHANCE, 0.0005)
                call AddUnitBonus(source, BONUS_CRITICAL_DAMAGE, 0.001)
                call AddUnitBonus(source, BONUS_LIFE_STEAL, 0.0005)
            endif

            set source = null
            set target = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
            call RegisterItem(allocate(code), ApocalypticMask.code, PhoenixAxe.code, 0, 0, 0)
        endmethod
    endstruct
endscope