scope SphereOfDarkness
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
		static constant integer item    = 'I04W'
		static constant integer ability = 'A03R'
	endmodule

    private constant function GetDamage takes nothing returns real
        return 100.
    endfunction

    private constant function GetChance takes nothing returns real
        return 30.
    endfunction

    private constant function GetDuration takes nothing returns real
        return 10.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct SphereOfDarkness extends Item
        implement Configuration

        real spellPowerFlat = 50

        method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0050|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Dark Curse|r: Every attack has |cffffcc0030%|r chance to Deal |cff0080ff" + AbilitySpellDamageEx(GetDamage(), u) + "|r |cff0080ffMagic|r damage and cast |cffffcc00Dark Curse|r in the target, reducing its armor and all aliied units within |cffffcc00600|r AoE by |cffffcc0010|r.\n\nLasts for 10 seconds.")
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, item) and Damage.isEnemy and GetRandomReal(1, 100) <= GetChance() then
                call UnitAddAbilityTimed(Damage.target.unit, ability, GetDuration(), 1, true)
                call UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope