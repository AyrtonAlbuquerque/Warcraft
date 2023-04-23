scope DemonicMask
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
		static constant integer item    = 'I03J'
		static constant integer ability = 'A031'
		static constant integer buff    = 'B00D'
		static constant string  order   = "faeriefire"
	endmodule

    private constant function GetChance takes nothing returns real
        return 20.
    endfunction

    private constant function GetDamage takes nothing returns real
        return 25.
    endfunction

    private constant function GetMissChance takes nothing returns real
        return 20.
    endfunction

    private constant function GetArmorReduction takes nothing returns real
        return 2.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct DemonicMask extends Item
        implement Configuration

        real lifeSteal = 0.12
        real damage = 25

        method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbDarkness\\OrbDarkness.mdl", "weapon")
        endmethod

        static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, item) and Damage.isEnemy and not Damage.target.isStructure and GetRandomReal(1, 100) <= GetChance() then
                if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(), false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null) then
                    if GetUnitAbilityLevel(Damage.target.unit, buff) == 0 then
                        call LinkBonusToBuff(Damage.target.unit, BONUS_MISS_CHANCE, GetMissChance(), buff)
                        call LinkBonusToBuff(Damage.target.unit, BONUS_ARMOR, -GetArmorReduction(), buff)
                    endif

                    call CastAbilityTarget(Damage.target.unit, ability, order, 1)
                endif
            endif
        endmethod

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope