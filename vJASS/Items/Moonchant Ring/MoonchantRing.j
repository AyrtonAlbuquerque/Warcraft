scope MoonchantRing
    struct MoonchantRing extends Item
        static constant integer code = 'I08I'
        static integer array charges

        real mana  = 800
        real health = 600
        real manaRegen = 15
        real intelligence = 15

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc00800|r Mana\n+ |cffffcc00600|r Health\n+ |cffffcc0015|r Mana Regeneration\n+ |cffffcc0015|r Intelligence\n\n|cff00ff00Passive|r: |cffffcc00Moonchant Wisdom|r: Whenever your Hero, allied unit or enemy unit casts a spell within |cffffcc00800 AoE|r, |cffffcc00Moonchant Ring|r gains |cffffcc00|cffffcc00|r1|r charge.\n\n|cff00ff00Active|r: |cffffcc00Moonchant Well|r: When activated, all |cffffcc00Moonchant Ring|r charges are consumed, recovering |cffffcc00" + I2S(50 * charges[id]) + "|r |cffff0000Health|r and |cff00ffffMana|r.\n\nCharges: |cffffcc00" + I2S(charges[id]) + "|r"
        endmethod

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer index = GetUnitUserData(caster)
            local integer skill = GetSpellAbilityId()
            local boolean potion = skill == 'AIre'
            local boolean blink = skill == 'A00H'
            local boolean self = skill == 'A011'
            local group g
            local unit v

            if not potion and not blink and not self then
                set g = CreateGroup()

                call GroupEnumUnitsInRange(g, GetUnitX(caster), GetUnitY(caster), 800.00, null)

                loop
                    set v = FirstOfGroup(g)
                    exitwhen v == null
                        if UnitHasItemOfType(v, code) then
                            set charges[GetUnitUserData(v)] = charges[GetUnitUserData(v)] + 1
                        endif
                    call GroupRemoveUnit(g, v)
                endloop

                call DestroyGroup(g)
            elseif self then
                call DestroyEffectTimed(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIhe\\AIheTarget.mdl", caster, "origin"), 1)
                call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl", caster, "origin"))
                call SetWidgetLife(caster, GetWidgetLife(caster) + (50 * charges[index]))
                call AddUnitMana(caster, (50 * charges[index]))
                
                set charges[index] = 0
            endif

            set g = null
            set caster = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), FusionCrystal.code, RingOfConversion.code, 0, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
        endmethod
    endstruct
endscope