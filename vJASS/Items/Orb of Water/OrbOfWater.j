scope OrbOfWater
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetAoE takes nothing returns real
        return 150.
    endfunction

    private constant function GetDamage takes nothing returns real
        return 50.
    endfunction

    private constant function GetChance takes nothing returns real
        return 20.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct OrbOfWater extends Item
        static constant integer code = 'I01M'
        static constant string effect = "WaterEnchant.mdl"
    
        real damage = 10

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "WaterOrb.mdl", "weapon")
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and GetRandomReal(1, 100) <= GetChance() then
                call DestroyEffect(AddSpecialEffectTarget(effect, Damage.target.unit, "origin"))
                call UnitDamageArea(Damage.source.unit, Damage.target.x, Damage.target.y, GetAoE(), GetDamage(), ATTACK_TYPE_HERO, DAMAGE_TYPE_ENHANCED, false, true, false)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope