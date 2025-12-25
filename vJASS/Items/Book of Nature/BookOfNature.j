scope BookOfNature
    struct BookOfNature extends Item
        static constant integer code = 'I06H'
        static constant integer buff = 'B004'
        static constant string effect = "Abilities\\Spells\\NightElf\\MoonWell\\MoonWellCasterArt.mdl"
        
        real spellPower = 70
        real healthRegen = 15
        real intelligence = 15
        real cooldownReduction = 0.15

        private static method onCast takes nothing returns nothing
            if GetUnitAbilityLevel(Spell.source.unit, buff) > 0 then
                if Spell.source.isHero then
                    call SetWidgetLife(Spell.source.unit, Spell.source.health + 200 + (20 * GetHeroLevel(Spell.source.unit)))
                else
                    call SetWidgetLife(Spell.source.unit, Spell.source.health + 200 + (20 * GetUnitLevel(Spell.source.unit)))
                endif

                call DestroyEffect(AddSpecialEffectTarget(effect, Spell.source.unit, "origin"))
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
            call RegisterItem(allocate(code), SummoningBook.code, SphereOfNature.code, 0, 0, 0)
        endmethod
    endstruct
endscope