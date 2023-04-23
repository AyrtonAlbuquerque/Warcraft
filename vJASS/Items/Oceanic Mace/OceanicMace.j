scope OceanicMace
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item = 'I04A'
    endmodule

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
        implement Configuration
    
        real damage = 20

        method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "WaterOrb.mdl", "weapon")
        endmethod

        static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if UnitHasItemOfType(Damage.source.unit, item) and Damage.source.isMelee and damage > 0 and GetRandomReal(1, 100) <= GetChance() then
                call DestroyEffect(AddSpecialEffect("WaterEnchant.mdl", Damage.target.x, Damage.target.y))
                call UnitDamageArea(Damage.source.unit, Damage.target.x, Damage.target.y, GetAoE(), GetDamage(), ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, false, true, false)
            endif
        endmethod

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope