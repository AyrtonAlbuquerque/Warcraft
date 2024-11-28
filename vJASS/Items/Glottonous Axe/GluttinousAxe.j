scope GluttonousAxe
    struct GluttonousAxe extends Item
        static constant integer code = 'I0A6'

        real damage = 2250
        real lifeSteal = 0.5
        real criticalDamage = 4
        real criticalChance = 20

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc002250|r Damage\n+ |cffffcc0050%|r Life Steal\n+ |cffffcc0020%|r Critical Strike Chance\n+ |cffffcc00400%|r Critical Strike Damage\n\n|cff00ff00Passive|r: |cffffcc00Devouring Strike|r: After hitting a |cffffcc00Critical Strike|r, |cffffcc00Critical Chance|r and |cffffcc00Life Steal|r are increased by |cffffcc000.2%|r and |cffffcc00Critical Damage|r is increased by |cffffcc000.5%|r permanently.\n\nCritical Chance: |cffffcc00" + R2SW(GetUnitCriticalChance(u), 1, 2) + " %|r\nCritical Damage: |cffffcc00" + R2SW(100*GetUnitCriticalMultiplier(u), 1, 2) + " %|r\nLife Steal: |cffffcc00" + R2SW(100*GetUnitLifeSteal(u), 1, 2) + " %|r")
        endmethod

        private static method onCritical takes nothing returns nothing
            local unit source = GetCriticalSource()
            local unit target = GetCriticalTarget()

            if UnitHasItemOfType(source, code) and IsUnitEnemy(target, GetOwningPlayer(source)) then
                call UnitAddCriticalStrike(source, 0.2, 0.005)
                call UnitAddLifeSteal(source, 0.002)
            endif

            set source = null
            set target = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
            call thistype.allocate(code, ApocalypticMask.code, PhoenixAxe.code, 0, 0, 0)
        endmethod
    endstruct
endscope