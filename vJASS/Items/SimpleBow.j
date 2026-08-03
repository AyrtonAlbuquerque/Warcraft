scope SimpleBow
    struct SimpleBow extends Item
        static constant integer code = 'I00J'
        private static constant integer ability = 'A003'

        real damage = 5

        private static method onAttack takes nothing returns nothing
            local unit source = GetAttacker()

            if UnitHasItemOfType(source, code) and IsUnitType(source, UNIT_TYPE_RANGED_ATTACKER) then
                if GetRandomInt(1, 100) <= 15 then
                    call UnitAddAbility(source, ability)
                else
                    call UnitRemoveAbility(source, ability)
                endif
            endif

            set source = null
        endmethod 

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function thistype.onAttack)
        endmethod
    endstruct
endscope