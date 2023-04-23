scope DesertRing
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private module Configuration
		static constant integer item    = 'I03Y'
        static constant integer ability = 'A03C'
        static constant integer buff    = 'B00F'
        static constant string  order   = "curse"
	endmodule

    private constant function GetChance takes nothing returns real
        return 20.
    endfunction

    private constant function GetMissChance takes nothing returns real
        return 15.
    endfunction

    private constant function GetDamage takes nothing returns real
        return 25.
    endfunction

    private constant function GetDamageReduction takes nothing returns real
        return 0.85
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct DesertRing extends Item
        implement Configuration

        real manaRegen = 4
        real spellPowerFlat = 25
        real mana = 250

        static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, item) and Damage.isEnemy and GetRandomReal(1, 100) <= GetChance() then
                if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(), false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null) then
                    if GetUnitAbilityLevel(Damage.target.unit, buff) == 0 then
                        call LinkBonusToBuff(Damage.target.unit, BONUS_MISS_CHANCE, GetMissChance(), buff)
                    endif

                    call CastAbilityTarget(Damage.target.unit, ability, order, 1)
                endif
            endif
        endmethod

        static method onDebuff takes nothing returns nothing
            if GetUnitAbilityLevel(Damage.source.unit, buff) > 0 then
                call BlzSetEventDamage(GetEventDamage()*GetDamageReduction())
            endif
        endmethod

        static method onInit takes nothing returns nothing
            call thistype.allocate(item)
            call RegisterAnyDamageEvent(function thistype.onDebuff)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endscope