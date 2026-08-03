scope OrbOfLightning
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private function GetDamage takes unit source returns real
        return 50. * GetWidgetLevel(source)
    endfunction

    private constant function GetChance takes nothing returns real
        return 20.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct OrbOfLightning extends Item
        static constant integer code = 'I00R'

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cff00ff00Passive|r: |cffffcc00Shock|r: Every attack has |cffffcc00" + N2S(GetChance(), 0) + "%|r chance to shock the target dealing |cff00ffff" + N2S(GetDamage(u), 0) + " Magic|r damage."
        endmethod

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\AIlb\\AIlbTarget.mdl", "weapon")
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and GetRandomReal(1, 100) <= GetChance() then
                if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(Damage.source.unit), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call DestroyEffectTimed(AddSpecialEffectTarget("Abilities\\Spells\\Orc\\Purge\\PurgeBuffTarget.mdl", Damage.target.unit, "origin"), 1)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope