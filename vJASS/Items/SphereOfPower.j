scope SphereOfPower
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetDamageFactor takes nothing returns real
        return 0.05
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct SphereOfPower extends Item
        static constant integer code = 'I00M'
    
        real spellPower = 20
        real spellVamp = 0.02

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.amount > 0 then
                set Damage.amount = Damage.amount * (1 + GetDamageFactor())
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
            call RegisterSpellDamagingEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope