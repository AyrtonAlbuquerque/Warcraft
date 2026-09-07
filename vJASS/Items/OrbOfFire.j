scope OrbOfFire
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetAoE takes nothing returns real
        return 200.
    endfunction

    private function GetDamage takes unit source returns real
        return 5. * GetWidgetLevel(source)
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct OrbOfFire extends Item
        static constant integer code = 'I00N'

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cff00ff00Passive|r: |cffffcc00Pyrotechny|r: Every attack deals |cff00ffff" + N2S(GetDamage(u), 0) + " Magic|r damage to enemy units within |cffffcc00" + N2S(GetAoE(), 0) + " AoE|r."
        endmethod

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\AIfb\\AIfbTarget.mdl", "weapon")
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) then
                call Group.create()
                    .inRange(Damage.target.x, Damage.target.y, GetAoE())
                    .isAlive()
                    .enemyOf(Damage.source.player)
                    .isNot().ofType(UNIT_TYPE_STRUCTURE)
                    .isNot().ofType(UNIT_TYPE_MAGIC_IMMUNE)
                    .damage(Damage.source.unit, GetDamage(Damage.source.unit), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, 0, 0)
                    .destroy()
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope