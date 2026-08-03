scope ScrollOfMastery
    struct ScrollOfMastery extends Item
        static constant integer code = 'I00L'

        real spellPower = 10
        real cooldownReduction = 0.1

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer skill = GetSpellAbilityId()
            local boolean ultimate = BlzGetAbilityIntegerField(BlzGetUnitAbility(caster, skill), ABILITY_IF_REQUIRED_LEVEL) >= 10
        
            if UnitHasItemOfType(caster, code) then
                if not ultimate and GetRandomReal(1, 100) <= 10 then
                    call ResetUnitAbilityCooldown(caster, skill)
                    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdl", caster, "origin"))
                endif
            endif
        
            set caster = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), 0, 0, 0, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
        endmethod
    endstruct
endscope