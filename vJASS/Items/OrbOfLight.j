scope OrbOfLight
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private function GetHeal takes unit source returns real
        return 2. * GetWidgetLevel(source)
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct OrbOfLight extends Item
        static constant integer code = 'I00P'

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cff00ff00Passive|r: |cffffcc00Blessing|r: Every attack heals |cffffcc00" + N2S(GetHeal(u), 0) + "|r |cffff0000Health|r and |cff00ffffMana|r."
        endmethod

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbSlow\\OrbSlow.mdl", "weapon")
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and not Damage.target.isStructure then
                call SetWidgetLife(Damage.source.unit, Damage.source.health + GetHeal(Damage.source.unit))
                call AddUnitMana(Damage.source.unit, GetHeal(Damage.source.unit))
                call DestroyEffect(AddSpecialEffectTarget("HolyStrike.mdl", Damage.source.unit, "origin"))
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope