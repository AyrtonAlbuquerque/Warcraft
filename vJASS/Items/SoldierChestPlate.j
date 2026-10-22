scope SoldierChestPlate
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetDamageReduction takes nothing returns real
        return 0.1
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct SoldierChestPlate extends Item
        static constant integer code = 'I01F'
        
        // Attributes
        real armor = 3
        real health = 350
        real magicResistance = 3

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.target.unit, code) and Damage.amount > 0 and Damage.damagetype != DAMAGE_TYPE_UNIVERSAL then
                set Damage.amount = Damage.amount * (1 - GetDamageReduction())
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), LifeCrystal.code, Platemail.code, MantleOfResistance.code, 0, 0)
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope