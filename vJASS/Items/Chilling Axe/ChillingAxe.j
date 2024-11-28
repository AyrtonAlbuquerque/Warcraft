scope ChillingAxe
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
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
        static constant integer code = 'I03P'
    
        real damage = 35
        real criticalChance = 15
        real criticalDamage = 0.35

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\AIob\\AIobTarget.mdl", "weapon")
        endmethod

        private static method onCritical takes nothing returns nothing
            local unit source = GetCriticalSource()
            local unit target = GetCriticalTarget()

            if UnitHasItemOfType(source, code) and IsUnitEnemy(target, GetOwningPlayer(source)) then
                call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Undead\\FrostNova\\FrostNovaTarget.mdl", target, "origin"))
                call UnitDamageTarget(source, target, GetDamage(), false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_COLD, null)
                call StunUnit(target, GetDuration(), "Abilities\\Spells\\Undead\\FreezingBreath\\FreezingBreathTargetArt.mdl", "origin", false)
            endif

            set source = null
            set target = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
            call thistype.allocate(code, OrbOfFrost.code, OrcishAxe.code, 0, 0, 0)
        endmethod
    endstruct
endscope