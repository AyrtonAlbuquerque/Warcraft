scope OrbOfFire
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetAoE takes nothing returns real
        return 150.
    endfunction

    private constant function GetDamage takes nothing returns real
        return 10.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct OrbOfFire extends Item
        static constant integer code = 'I01J'

        real damage = 10

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\AIfb\\AIfbTarget.mdl", "weapon")
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) then
                call UnitDamageArea(Damage.source.unit, Damage.target.x, Damage.target.y, GetAoE(), GetDamage(), ATTACK_TYPE_HERO, DAMAGE_TYPE_FIRE, false, true, false)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope