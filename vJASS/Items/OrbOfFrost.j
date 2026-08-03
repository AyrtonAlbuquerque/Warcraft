scope OrbOfFrost
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private function GetDamage takes unit source returns real
        return 10. * GetWidgetLevel(source)
    endfunction

    private constant function GetSlow takes nothing returns real
        return 0.1
    endfunction

    private constant function GetDuration takes nothing returns real
        return 2.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct OrbOfFrost extends Item
        static constant integer code = 'I00O'

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cff00ff00Passive|r: |cffffcc00Frostbite|r: Every attack deals |cff00ffff" + N2S(GetDamage(u), 0) + " Magic|r damage and |cffffcc00Slows|r the enemy |cffffcc00Movement Speed|r by |cffffcc00" + N2S(GetSlow() * 100, 0) + "%|r for |cffffcc00" + N2S(GetDuration(), 0) + "|r seconds."
        endmethod

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\AIob\\AIobTarget.mdl", "weapon")
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy then
                if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(Damage.source.unit), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call SlowUnit(Damage.target.unit, GetSlow(), GetDuration(), "Abilities\\Spells\\Other\\FrostDamage\\FrostDamage.mdl", "origin", false)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope