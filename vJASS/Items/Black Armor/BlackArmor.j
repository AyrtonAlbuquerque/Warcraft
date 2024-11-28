scope BlackArmor
    struct BlackArmor extends Item
        static constant integer code = 'I0AC'

        private static real array stored  
        private static integer array defense

        // Attributes
        real armor = 15
        real health = 40000

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc0040000|r Health\n+ |cffffcc0015|r Armor\n\n|cff00ff00Passive|r: |cffffcc00Damage Reduction|r: All damage taken are reduced by |cffffcc0020%|r.\n\n|cff00ff00Passive|r: |cffffcc00Spiked Plate|r: When being attacked, returns |cffffcc00" + R2SW(0.5*GetUnitBonus(u, BONUS_ARMOR), 1, 1) + "%|r (|cffffcc00" + R2S(3*GetUnitBonus(u, BONUS_ARMOR)) + "% against non-Hero|r) of the damage taken as |cffd45e19Pure|r damage.\n\n|cff00ff00Passive|r: |cffffcc00Impenetrable|r: All damage reduced by |cffffcc00Damage Reduction|r effect is stored. When all damage stored reaches |cffffcc0050000|r, your Hero |cff808080Armor|r is increased by |cffffcc001|r.\n\nArmor Bonus: |cffffcc00" + I2S(defense[id]) + "|r\nDamage Reduced: |cffffcc00" + R2I2S(stored[id]) + "|r")
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()
            local real reduced

            if UnitHasItemOfType(Damage.target.unit, code) and damage > 0 and Damage.isEnemy then
                set reduced = 0.2*damage
                set damage = damage - reduced

                call BlzSetEventDamage(damage)
                if (stored[Damage.target.id] + reduced) >= 50000 then
                    set defense[Damage.target.id] = defense[Damage.target.id] + 1
                    call AddUnitBonus(Damage.target.unit, BONUS_ARMOR, 1)
                    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Human\\Defend\\DefendCaster.mdl", Damage.target.unit, "origin"))

                    if (stored[Damage.target.id] + reduced) > 50000 then
                        set stored[Damage.target.id] = ((stored[Damage.target.id] + reduced) - 50000)
                    else
                        set stored[Damage.target.id] = 0
                    endif
                else
                    set stored[Damage.target.id] = stored[Damage.target.id] + reduced
                endif

                if Damage.source.isHero then
                    set damage = (damage * GetUnitBonus(Damage.target.unit, BONUS_ARMOR) * 0.005)
                else
                    set damage = (damage * GetUnitBonus(Damage.target.unit, BONUS_ARMOR) * 0.03)
                endif

                call UnitDamageTarget(Damage.target.unit, Damage.source.unit, damage, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, SphereOfDarkness.code, FlamingArmor.code, 0, 0, 0)
        endmethod
    endstruct
endscope