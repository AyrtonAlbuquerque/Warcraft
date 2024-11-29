scope SphereOfFire
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetDamageFactor takes nothing returns real
        return 1.18
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct SphereOfFire extends Item
        static constant integer code = 'I04H'

        real spellPowerFlat = 50

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives:|r\n+ |cffffcc0050|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Damage Amplification|r: All |cffff0000physical damage |ris amplified by |cffffcc0018%%.|r\n\n|cff00ff00Passive|r: |cffffcc00Flying Flames|r: Engulfs the Hero with flames, releasing flaming bolts to random enemy units within |cffffcc00600|r AoE every |cffffcc001|r second, dealing |cff0080ff" + AbilitySpellDamageEx(50, u) + "|r |cff0080ffMagic|r damage on impact and setting the target on fire, dealing |cff0080ff" + AbilitySpellDamageEx(10, u) + "|r |cff0080ffMagic|r damage per second.\n\nLasts for 10 seconds (4 on Heroes).")
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if UnitHasItemOfType(Damage.source.unit, code) and damage > 0 then
                call BlzSetEventDamage(damage * GetDamageFactor())
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, OrbOfFire.code, SphereOfPower.code, 0, 0, 0)
        endmethod
    endstruct
endscope