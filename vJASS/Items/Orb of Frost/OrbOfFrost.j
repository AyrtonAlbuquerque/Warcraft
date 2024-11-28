scope OrbOfFrost
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetDamage takes nothing returns real
        return 10.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct OrbOfFrost extends Item
        static constant integer code = 'I01L'
        static constant integer ability = 'A026'
        static constant string order = "cripple"
    
        real damage = 10

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\AIob\\AIobTarget.mdl", "weapon")
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy then
                if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(), false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_COLD, null) then
                    call CastAbilityTarget(Damage.target.unit, ability, order, 1)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope