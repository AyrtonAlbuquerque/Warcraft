scope NatureStaff
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item    = 'I044'
        static constant integer buff    = 'B00H'
        static constant integer ability = 'A03G'
    endmodule

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
        implement Configuration

        real spellPowerPercent = 0.1
        real health = 300
        real intelligence = 10

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if GetUnitAbilityLevel(Damage.source.unit, buff) > 0 and damage > 0 and not (Damage.source.unit == Damage.target.unit) then
                call UnitDamageTarget(Damage.target.unit, Damage.source.unit, damage*GetReturnFactor(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
            endif
        endmethod

        private static method onAttackDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, item) and Damage.isEnemy then
                if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                    call CastAbilityTarget(Damage.target.unit, ability, "faeriefire", 1)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterAttackDamageEvent(function thistype.onAttackDamage)
        endmethod
    endstruct
endscope