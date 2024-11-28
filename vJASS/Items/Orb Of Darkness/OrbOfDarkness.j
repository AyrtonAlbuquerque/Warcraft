scope OrbOfDarkness
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetChance takes nothing returns real
        return 15.
    endfunction

    private constant function GetDamage takes nothing returns real
        return 10.
    endfunction

    private constant function GetMissChance takes nothing returns real
        return 10.
    endfunction

    private constant function GetArmor takes nothing returns real
        return -1.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct OrbOfDarkness extends Item
        static constant integer code = 'I01Y'
        static constant integer ability = 'A025'
        static constant integer buff = 'B009'
        static constant string order = "faeriefire"

        real damage = 10

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbDarkness\\OrbDarkness.mdl", "weapon")
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy and GetRandomReal(1, 100) <= GetChance() then
                if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(), false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_MAGIC, null) then
                    if GetUnitAbilityLevel(Damage.target.unit, buff) == 0 then
                        call LinkBonusToBuff(Damage.target.unit, BONUS_MISS_CHANCE, GetMissChance(), buff)
                        call LinkBonusToBuff(Damage.target.unit, BONUS_ARMOR, GetArmor(), buff)
                    endif
                    
                    call CastAbilityTarget(Damage.target.unit, ability, order, 1)
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope