scope SteelArmor
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
		static constant integer item = 'I031'
	endmodule

    private constant function GetReductionFactor takes nothing returns real
        return 0.9
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct SteelArmor extends Item
        implement Configuration
    
        real health = 500
        real armor = 4

        static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.target.unit, item) then
                call BlzSetEventDamage(GetEventDamage()*GetReductionFactor())
            endif
        endmethod

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAnyDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope