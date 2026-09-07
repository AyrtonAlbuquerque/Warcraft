scope WarriorBlade
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetDamageFactor takes nothing returns real
        return 0.1
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct WarriorBlade extends Item
        static constant integer code = 'I011'

        real damage = 20
        real attackSpeed = 0.15

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.amount > 0 then
                set Damage.amount = Damage.amount * (1 + GetDamageFactor())
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), RustySword.code, RustySword.code, GlovesOfHaste.code, 0, 0)
            call RegisterAttackDamagingEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope