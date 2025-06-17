scope NatureStaff
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetReturnFactor takes nothing returns real
        return 0.15
    endfunction

    private constant function GetDamage takes nothing returns real
        return 25.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct NatureStaff extends Item
        static constant integer code = 'I044'
        static constant integer buff = 'B00H'
        static constant integer ability = 'A03G'

        real health = 300
        real intelligence = 10

        private static method onDamage takes nothing returns nothing
            if GetUnitAbilityLevel(Damage.source.unit, buff) > 0 and Damage.amount > 0 and not (Damage.source.unit == Damage.target.unit) then
                call UnitDamageTarget(Damage.target.unit, Damage.source.unit, Damage.amount*GetReturnFactor(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
            endif
        endmethod

        private static method onAttackDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy then
                if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call CastAbilityTarget(Damage.target.unit, ability, "faeriefire", 1)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterAttackDamageEvent(function thistype.onAttackDamage)
            call RegisterItem(allocate(code), OrbOfThorns.code, MageStaff.code, 0, 0, 0)
        endmethod
    endstruct
endscope