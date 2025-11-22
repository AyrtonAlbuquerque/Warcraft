scope OrbOfSouls
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
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
        static constant integer code = 'I01O'
        static constant string effect = "HealSmall.mdl"
    
        real damage = 10

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "GhostOrb.mdl", "weapon")
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy then
                if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call SetWidgetLife(Damage.source.unit, (GetWidgetLife(Damage.source.unit) + GetHeal()))
                    call AddUnitMana(Damage.source.unit, GetHeal())
                    call ArcingTextTag.create(("|cff32cd32" + "+" + R2I2S(GetHeal())), Damage.source.unit, 0.015)
                    call DestroyEffect(AddSpecialEffectTarget(effect, Damage.source.unit, "origin"))
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope