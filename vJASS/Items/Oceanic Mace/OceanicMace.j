scope OceanicMace
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetAoE takes nothing returns real
        return 300.
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
    struct OceanicMace extends Item
        static constant integer code = 'I04A'
    
        real damage = 20

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "WaterOrb.mdl", "weapon")
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if UnitHasItemOfType(Damage.source.unit, code) and Damage.source.isMelee and damage > 0 and GetRandomReal(1, 100) <= GetChance() then
                call DestroyEffect(AddSpecialEffect("WaterEnchant.mdl", Damage.target.x, Damage.target.y))
                call UnitDamageArea(Damage.source.unit, Damage.target.x, Damage.target.y, GetAoE(), GetDamage(), ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, false, true, false)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, OrbOfWater.code, EnhancedHammer.code, 0, 0, 0)
        endmethod
    endstruct
endscope