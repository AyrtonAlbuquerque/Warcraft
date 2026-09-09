scope CurvedBow
    struct CurvedBow extends Item
        static constant integer code = 'I016'
        private static constant integer ability = 'A003'

        real damage = 10
        real agility = 10

        private static method onAttack takes nothing returns nothing
            local unit source = GetAttacker()

            if UnitHasItemOfType(source, code) and IsUnitType(source, UNIT_TYPE_RANGED_ATTACKER) then
                if GetRandomInt(0, 100) <= 20 then
                    call UnitAddAbility(source, ability)
                else
                    call UnitRemoveAbility(source, ability)
                endif
            endif

            set source = null
        endmethod 

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), ClawsOfAgility.code, ClawsOfAgility.code, SimpleBow.code, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function thistype.onAttack)
        endmethod
    endstruct
endscope