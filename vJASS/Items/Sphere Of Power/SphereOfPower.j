scope SphereOfPower
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetDamageFactor takes nothing returns real
        return 1.15
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct SphereOfPower extends Item
        static constant integer code = 'I04G'
    
        real spellPowerFlat = 30

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if UnitHasItemOfType(Damage.source.unit, code) and damage > 0 then
                call BlzSetEventDamage(damage * GetDamageFactor())
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope