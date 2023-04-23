scope OrbOfSands
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item    = 'I01V'
        static constant integer ability = 'A020'
        static constant integer buff    = 'B007'
        static constant string order    = "faeriefire"
    endmodule

    private constant function GetChance takes nothing returns real
        return 15.
    endfunction

    private constant function GetDamage takes nothing returns real
        return 10.
    endfunction

    private constant function GetReductionFactor takes nothing returns real
        return 0.9
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct OrbOfSands extends Item
        implement Configuration
    
        real damage = 10

        method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "SandOrb.mdl", "weapon")
        endmethod

        static method onAttackDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, item) and Damage.isEnemy and GetRandomReal(1, 100) <= GetChance() then
                if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(), false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null) then
                    call CastAbilityTarget(Damage.target.unit, ability, order, 1)
                endif
            endif
        endmethod

        static method onDamage takes nothing returns nothing
            if GetUnitAbilityLevel(Damage.source.unit, buff) > 0 then
                call BlzSetEventDamage(GetEventDamage()*GetReductionFactor())
            endif
        endmethod

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterAttackDamageEvent(function thistype.onAttackDamage)
        endmethod
    endstruct
endscope