scope WarlockRing
    struct WarlockRing extends Item
        static constant integer code = 'I09C'

        real mana = 25000
        real health = 15000
        real manaRegen = 750
        real intelligence = 500

        private method onTooltip takes unit u, item i, integer id returns nothing
            call BlzSetItemExtendedTooltip(i, "|cffffcc00Gives|r:\n+ |cffffcc0025000|r Mana\n+ |cffffcc0015000|r Health\n+ |cffffcc00750|r Mana Regeneration\n+ |cffffcc00500|r Intelligence\n\n|cff00ff00Passive|r: |cffffcc00Arcane Power|r: All |cff00ffffMagic|r damage dealt is amplified by |cff00ffff" + R2I2S((GetHeroInt(u, true) * 0.5)) + "|r.")
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if UnitHasItemOfType(Damage.source.unit, code) and damage > 0 then
                set damage = damage + GetHeroInt(Damage.source.unit, true)*0.5
                call BlzSetEventDamage(damage) 
            endif
        endmethod  

        private static method onInit takes nothing returns nothing
            call RegisterSpellDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, SphereOfDarkness.code, MoonchantRing.code, 0, 0, 0)
        endmethod
    endstruct
endscope