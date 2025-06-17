scope OrbOfThorns
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetReturnFactor takes nothing returns real
        return 0.1
    endfunction

    private constant function GetDamage takes nothing returns real
        return 10.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct OrbOfThorns extends Item
        static constant integer code = 'I01W'
        static constant integer ability = 'A01Y'
        static constant integer buff = 'B006'
        static constant string order = "faeriefire"
    
        real damage = 10

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbCorruption\\OrbCorruption.mdl", "weapon")
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if damage > 0 and GetUnitAbilityLevel(Damage.source.unit, buff) > 0 and not (Damage.source.unit == Damage.target.unit) then
                call UnitDamageTarget(Damage.target.unit, Damage.source.unit, damage*GetReturnFactor(), false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null)
            endif
        endmethod

        private static method onAttackDamage takes nothing returns nothing
            if GetEventDamage() > 0 and UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy then
                if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(), false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_PLANT, null) then
                    call CastAbilityTarget(Damage.target.unit, ability, order, 1)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterAttackDamageEvent(function thistype.onAttackDamage)
        endmethod
    endstruct
endscope