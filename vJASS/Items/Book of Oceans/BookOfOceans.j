scope BookOfOceans
    struct BookOfOceans extends Item
        static constant integer code = 'I06E'
        static constant integer buff = 'B003'
        static constant string effect = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl"
        
        real mana = 350
        real spellPower = 70
        real intelligence = 15
        real cooldownReduction = 0.15

        private static method onCast takes nothing returns nothing
            if GetUnitAbilityLevel(Spell.source.unit, buff) > 0 and Spell.cost > 0 then
                call AddUnitMana(Spell.source.unit, Spell.cost * 0.5)
                call DestroyEffect(AddSpecialEffectTarget(effect, Spell.source.unit, "origin"))
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
            call RegisterItem(allocate(code), SummoningBook.code, SphereOfWater.code, 0, 0, 0)
        endmethod
    endstruct
endscope