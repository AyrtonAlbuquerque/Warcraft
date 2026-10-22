scope SpellbookOfWitchcraft
    struct SpellbookOfWitchcraft extends Item
        static constant integer code = 'I01C'

        real intelligence = 8
        real spellPower = 20
        real cooldownReduction = 0.15

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer skill = GetSpellAbilityId()
            local boolean ultimate = BlzGetAbilityIntegerField(BlzGetUnitAbility(caster, skill), ABILITY_IF_REQUIRED_LEVEL) >= 10
        
            if UnitHasItemOfType(caster, code) then
                if not ultimate and GetRandomReal(1, 100) <= 15 then
                    call ResetUnitAbilityCooldown(caster, skill)
                    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdl", caster, "origin"))
                endif
            endif
        
            set caster = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), BraceletOfIntelligence.code, ScrollOfMastery.code, ScrollOfMastery.code, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
        endmethod
    endstruct
endscope