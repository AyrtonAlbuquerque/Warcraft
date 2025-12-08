scope ArcanaScepter
    struct ArcanaScepter extends Item
        static constant integer code = 'I0AL'

        real mana = 1000
        real health = 1000
        real manaRegen = 30
        real spellPower = 200
        real intelligence = 40
        real spellVamp = 0.2

        static method onDamage takes nothing returns nothing
            if UnitHasItemOfType(Damage.source.unit, code) and not Damage.target.isStructure and GetRandomReal(1, 100) <= 20 and Damage.amount > 0 then
                set Damage.amount = Damage.amount * 1.4   
                
                call AddUnitBonusTimed(Damage.source.unit, BONUS_SPELL_POWER, 20, 20)
                call CreateTextOnUnit(Damage.target.unit, (R2I2S(Damage.amount) + "!"), 1.5, 0, 255, 255, 255)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), HolyScepter.code, AncientSphere.code, 0, 0, 0)
        endmethod
    endstruct
endscope