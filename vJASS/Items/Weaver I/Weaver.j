scope Weaver
    struct Weaver extends Item
        static constant integer code = 'I08U'

        real mana = 800
        real health = 800
        real manaRegen = 15
        real healthRegen = 15
        real intelligence = 20
        real spellPower = 150

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer skill = GetSpellAbilityId()
            local boolean ultimate = BlzGetAbilityIntegerField(BlzGetUnitAbility(caster, skill), ABILITY_IF_REQUIRED_LEVEL) >= 10
            local boolean potion = skill == 'AIre'
            local boolean self = skill == 'A019'
        
            if self then
                call UnitResetCooldown(caster)
            elseif UnitHasItemOfType(caster, code) and not potion then
                if ultimate and GetRandomReal(1, 100) <= 5 then
                    call ResetUnitAbilityCooldown(caster, skill)
                    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\RitualDagger\\RitualDaggerTarget.mdl", caster, "origin"))
                elseif not ultimate and GetRandomReal(1, 100) <= 15 then
                    call ResetUnitAbilityCooldown(caster, skill)
                    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdl", caster, "origin"))
                endif
            endif
        
            set caster = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), BookOfChaos.code, AncientSphere.code, 0, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
        endmethod
    endstruct
endscope