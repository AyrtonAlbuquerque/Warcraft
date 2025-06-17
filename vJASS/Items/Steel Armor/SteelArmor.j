scope SteelArmor
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetReductionFactor takes nothing returns real
        return 0.9
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct SteelArmor extends Item
        static constant integer code = 'I031'
    
        real armor = 4
        real health = 500

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.target.unit, code) then
                call BlzSetEventDamage(GetEventDamage()*GetReductionFactor())
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), FusedLifeCrystals.code, GoldenPlatemail.code, 0, 0, 0)
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope