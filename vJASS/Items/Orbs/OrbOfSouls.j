scope OrbOfSouls
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item = 'I01O'
        static constant string effect = "HealSmall.mdl"
    endmodule

    private constant function GetHeal takes nothing returns real
        return 5.
    endfunction

    private constant function GetDamage takes nothing returns real
        return 10.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct OrbOfSouls extends Item
        implement Configuration
    
        real damage = 10

        method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "GhostOrb.mdl", "weapon")
        endmethod

        static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, item) and Damage.isEnemy then
                if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call SetWidgetLife(Damage.source.unit, (GetWidgetLife(Damage.source.unit) + GetHeal()))
                    call ArcingTextTag.create(("|cff32cd32" + "+" + R2I2S(GetHeal())), Damage.source.unit)
                    call DestroyEffect(AddSpecialEffectTarget(effect, Damage.source.unit, "origin"))
                endif
            endif
        endmethod

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope