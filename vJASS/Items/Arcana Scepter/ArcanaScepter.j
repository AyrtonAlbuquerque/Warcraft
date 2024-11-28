scope ArcanaScepter
    struct ArcanaScepter extends Item
        static constant integer code = 'I0AL'

        real mana = 15000
        real health = 15000
        real manaRegen = 750
        real intelligence = 750
        real spellPowerFlat = 1500

        static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if UnitHasItemOfType(Damage.source.unit, code) and not Damage.target.isStructure and GetRandomReal(1, 100) <= 20 and damage > 0 then
                set damage = 4*damage   
                
                call BlzSetEventDamage(damage)
                call AddUnitBonusTimed(Damage.source.unit, BONUS_SPELL_POWER_FLAT, 200, 20)
                call CreateTextOnUnit(Damage.target.unit, (R2I2S(damage) + "!"), 1.5, 0, 255, 255, 255)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellDamageEvent(function thistype.onDamage)
            call thistype.allocate(code, HolyScepter.code, AncientSphere.code, 0, 0, 0)
        endmethod
    endstruct
endscope