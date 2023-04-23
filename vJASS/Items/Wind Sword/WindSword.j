scope WindSword
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item    = 'I04D'
		static constant integer ability = 'A03K'
		static constant string order    = "bloodlust"
	endmodule

    private constant function GetDamage takes nothing returns real
        return 25.
    endfunction

    private constant function GetChance takes nothing returns real
        return 20.
    endfunction

    private constant function GetDistance takes nothing returns real
        return 200.
    endfunction

    private constant function GetDuration takes nothing returns real
        return 0.5
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct WindSword extends Item
        implement Configuration
    
        real damage = 25

        method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc00300|r Damage\n\n|cff00ff00Passive|r: |cffffcc00Godspeed|r: Attacking grants |cffffcc0020%|r Attack Speed and |cffffcc008%|r Movement Speed bonus.\n\n|cff00ff00Passive|r: |cffffcc00Wind Blow|r: Attacks have |cffffcc0020%|r chance to knockback the target |cffffcc00200|r units over |cffffcc000.5|r seconds and deal |cff00ffff" + AbilitySpellDamageEx(GetDamage(), u) + " Magic|r damage.")
        endmethod

        method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbSlow\\OrbSlow.mdl", "weapon")
        endmethod

        static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, item) and Damage.isEnemy then
                if GetRandomReal(1, 100) <= GetChance() and not Damage.target.isStructure then
                    if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                        call KnockbackUnit(Damage.target.unit, AngleBetweenCoordinates(Damage.source.x, Damage.source.y, Damage.target.x, Damage.target.y), GetDistance(), GetDuration(), "WindBlow.mdx", "origin", true, true, false, false)
                    endif
                endif
                call CastAbilityTarget(Damage.source.unit, ability, order, 1)
            endif
        endmethod

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope