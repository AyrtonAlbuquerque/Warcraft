scope SphereOfAir
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
        static constant integer item    = 'I050'
		static constant integer ability = 'A04P'
	endmodule

    private constant function GetDamage takes nothing returns real
        return 50.
    endfunction

    private constant function GetDistance takes nothing returns real
        return 200.
    endfunction

    private constant function GetDuration takes nothing returns real
        return 0.5
    endfunction

    private constant function GetAngle takes nothing returns real
        return 90.
    endfunction

    private constant function GetAoE takes nothing returns real
        return 400.
    endfunction

    private constant function GetChance takes nothing returns real
        return 20.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct SphereOfAir extends Item
        implement Configuration

        real spellPowerFlat = 50

        method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0050 |rSpell Power\n\n|cff00ff00Passive|r: |cffffcc00Godspeed|r: Attacking grants |cffffcc00200% |rAttack Speed and |cffffcc0040% |rMovement Speed bonus.\n\n|cff00ff00Passive|r: |cffffcc00Gale|r: Attacks have |cffffcc0020%|r chance to knockback the target and all enemy units behind it within |cffffcc00400 |rAoE for |cffffcc00200 |runits over |cffffcc000.5|r seconds and dealing |cff0080ff" + AbilitySpellDamageEx(GetDamage(), u) + "|r bonus |cff0080ffMagic|r damage.")
        endmethod

        static method onDamage takes nothing returns nothing
            local group g
            local unit  u

            if UnitHasItemOfType(Damage.source.unit, item) and Damage.isEnemy then
                if GetRandomReal(1, 100) <= GetChance() then
                    set g = CreateGroup()

                    call UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                    call KnockbackUnit(Damage.target.unit, AngleBetweenCoordinates(Damage.source.x, Damage.source.y, Damage.target.x, Damage.target.y), GetDistance(), GetDuration(), "WindBlow.mdx", "origin", true, true, false, true)
                    call GroupEnumUnitsInRange(g, Damage.target.x, Damage.target.y, GetAoE(), null)
                    loop
                        set u = FirstOfGroup(g)
                        exitwhen u == null
                            if IsUnitInCone(u, Damage.target.x, Damage.target.y, GetAoE(), GetUnitFacing(Damage.source.unit), GetAngle()) then
                                if IsUnitEnemy(u, Damage.source.player) and UnitAlive(u) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                                    call UnitDamageTarget(Damage.source.unit, u, GetDamage(), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                                    call KnockbackUnit(u, AngleBetweenCoordinates(Damage.source.x, Damage.source.y, GetUnitX(u), GetUnitY(u)), GetDistance(), GetDuration(), "WindBlow.mdx", "origin", true, true, false, true)
                                endif
                            endif
                        call GroupRemoveUnit(g, u)
                    endloop
                    call DestroyGroup(g)
                endif
                call CastAbilityTarget(Damage.source.unit, ability, "bloodlust", 1)
            endif

            set g = null
        endmethod

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope