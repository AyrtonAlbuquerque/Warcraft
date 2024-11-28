scope OrbOfWind
    struct OrbOfWind extends Item
        static constant integer code = 'I01P'
        static constant integer ability = 'A01R'
        static constant string order = "bloodlust"
    
        real damage = 10

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbSlow\\OrbSlow.mdl", "weapon")
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy then
                call CastAbilityTarget(Damage.source.unit, ability, order, 1)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope