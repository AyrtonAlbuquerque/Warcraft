scope WarriorBlade
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetDamageFactor takes nothing returns real
        return 1.1
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct WarriorBlade extends Item
        static constant integer code = 'I02M'

        real damage = 25
        real attackSpeed = 0.2

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if UnitHasItemOfType(Damage.source.unit, code) and damage > 0 then
                call BlzSetEventDamage(damage*GetDamageFactor())
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, GoldenSword.code, GlovesOfHaste.code, 0, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope