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

        real spellPower = 50

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives:|r\n+ |cffffcc0050|r Spell Power\n\n|cff00ff00Passive|r: |cffffcc00Damage Amplification|r: All |cffff0000physical damage |ris amplified by |cffffcc0018%%.|r\n\n|cff00ff00Passive|r: |cffffcc00Flying Flames|r: Engulfs the Hero with flames, releasing flaming bolts to random enemy units within |cffffcc00600|r AoE every |cffffcc001|r second, dealing |cff0080ff" + N2S(50, 0) + "|r |cff0080ffMagic|r damage on impact and setting the target on fire, dealing |cff0080ff" + N2S(10, 0) + "|r |cff0080ffMagic|r damage per second.\n\nLasts for 10 seconds (4 on Heroes)."
        endmethod

        private static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and Damage.amount > 0 then
                set Damage.amount = Damage.amount * GetDamageFactor()
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), OrbOfFire.code, SphereOfPower.code, 0, 0, 0)
        endmethod
    endstruct
endscope