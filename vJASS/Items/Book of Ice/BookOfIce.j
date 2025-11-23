scope BookOfIce
    struct BookOfIce extends Item
        static constant integer code = 'I055'
        static constant integer buff = 'B00K'
        static constant string effect = "Abilities\\Spells\\Undead\\FrostArmor\\FrostArmorDamage.mdl"

        real health = 350
        real spellPower = 70
        real intelligence = 15
        real cooldownReduction = 0.15
        
        private static method onDamage takes nothing returns nothing
            if GetUnitAbilityLevel(Spell.source.unit, buff) > 0 and Spell.isEnemy then
                call SlowUnit(Spell.target.unit, 0.2, 2, effect, "origin", false)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellDamageEvent(function thistype.onDamage)
            call RegisterItem(allocate(code), SummoningBook.code, SphereOfAir.code, 0, 0, 0)
        endmethod
    endstruct
endscope