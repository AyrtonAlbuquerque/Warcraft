scope BlackArmor
    struct BlackArmor extends Item
        static constant integer code = 'I0AC'

        private static real array stored  
        private static integer array defense

        // Attributes
        real armor = 15
        real health = 1500

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc001500|r Health\n+ |cffffcc0015|r Armor\n\n|cff00ff00Passive|r: |cffffcc00Damage Reduction|r: All damage taken is reduced by |cffffcc0020%|r.\n\n|cff00ff00Passive|r: |cffffcc00Spiked Plate|r: When being attacked, returns |cffd45e19" + N2S(5 * GetWidgetLevel(u) + BlzGetUnitArmor(u), 0) + " Pure|r damage.\n\n|cff00ff00Passive|r: |cffffcc00Impenetrable|r: All damage reduced by |cffffcc00Damage Reduction|r effect is stored. When all damage stored reaches |cffffcc005000|r |cff808080Armor|r is increased by |cffffcc001|r permanently.\n\nArmor Bonus: |cffffcc00" + I2S(defense[id]) + "|r\nDamage Reduced: |cffffcc00" + R2I2S(stored[id]) + "|r"
        endmethod

        private static method onDamage takes nothing returns nothing
            local real reduced

            if UnitHasItemOfType(Damage.target.unit, code) and Damage.amount > 0 and Damage.isEnemy then
                set reduced = 0.2 * Damage.amount
                set Damage.amount = Damage.amount - reduced

                if (stored[Damage.target.id] + reduced) >= 5000 then
                    set defense[Damage.target.id] = defense[Damage.target.id] + 1

                    call AddUnitBonus(Damage.target.unit, BONUS_ARMOR, 1)
                    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Defend\\DefendCaster.mdl", Damage.target.unit, "origin"))

                    if (stored[Damage.target.id] + reduced) > 5000 then
                        set stored[Damage.target.id] = ((stored[Damage.target.id] + reduced) - 5000)
                    else
                        set stored[Damage.target.id] = 0
                    endif
                else
                    set stored[Damage.target.id] = stored[Damage.target.id] + reduced
                endif

                call UnitDamageTarget(Damage.target.unit, Damage.source.unit, 5 * Damage.source.level + Damage.source.armor, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), SphereOfDarkness.code, FlamingArmor.code, 0, 0, 0)
        endmethod
    endstruct
endscope