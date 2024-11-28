scope OrbOfLightning
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetDamage takes nothing returns real
        return 50.
    endfunction

    private constant function GetChance takes nothing returns real
        return 20.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct OrbOfLightning extends Item
        static constant integer code = 'I01N'
        static constant integer ability = 'A01O'
        static constant string order = "purge"
    
        real damage = 10

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\AIlb\\AIlbTarget.mdl", "weapon")
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and GetRandomReal(1, 100) <= GetChance() then
                if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(), false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_LIGHTNING, null) then
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