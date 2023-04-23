scope ChillingAxe
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item = 'I03P'
        static constant real period  = 0.25
    endmodule

    private constant function GetDamage takes nothing returns real
        return 25.
    endfunction

    private constant function GetDuration takes nothing returns real
        return 1.5
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct ChillingAxe extends Item
        implement Configuration
    
        real criticalChance = 15
        real criticalDamage = 0.35
        real damage = 35

        method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\AIob\\AIobTarget.mdl", "weapon")
        endmethod

        static method onCritical takes nothing returns nothing
            local unit source = GetCriticalSource()
            local unit target = GetCriticalTarget()

            if UnitHasItemOfType(source, item) and IsUnitEnemy(target, GetOwningPlayer(source)) then
                call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl", target, "origin"))
                call UnitDamageTarget(source, target, GetDamage(), false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_COLD, null)
                call StunUnit(target, GetDuration(), "Abilities\\Spells\\Undead\\FreezingBreath\\FreezingBreathTargetArt.mdl", "origin", false)
            endif

            set source = null
            set target = null
        endmethod

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
        endmethod
    endstruct
endscope