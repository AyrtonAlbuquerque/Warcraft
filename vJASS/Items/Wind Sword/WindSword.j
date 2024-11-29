scope WindSword
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
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
        static constant integer code = 'I04D'
        static constant integer ability = 'A03K'
		static constant string order = "bloodlust"
    
        real damage = 25

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc00300|r Damage\n\n|cff00ff00Passive|r: |cffffcc00Godspeed|r: Attacking grants |cffffcc0020%%|r Attack Speed and |cffffcc008%%|r Movement Speed bonus.\n\n|cff00ff00Passive|r: |cffffcc00Wind Blow|r: Attacks have |cffffcc0020%%|r chance to knockback the target |cffffcc00200|r units over |cffffcc000.5|r seconds and deal |cff00ffff" + AbilitySpellDamageEx(GetDamage(), u) + " Magic|r damage.")
        endmethod

        private method onPickup takes unit u, item i returns nothing
            call LinkEffectToItem(u, i, "Abilities\\Spells\\Items\\OrbSlow\\OrbSlow.mdl", "weapon")
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.isEnemy then
                if GetRandomReal(1, 100) <= GetChance() and not Damage.target.isStructure then
                    if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                        call KnockbackUnit(Damage.target.unit, AngleBetweenCoordinates(Damage.source.x, Damage.source.y, Damage.target.x, Damage.target.y), GetDistance(), GetDuration(), "WindBlow.mdx", "origin", true, true, false, false)
                    endif
                endif
                
                call CastAbilityTarget(Damage.source.unit, ability, order, 1)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, OrbOfWind.code, GoldenSword.code, 0, 0, 0)
        endmethod
    endstruct
endscope