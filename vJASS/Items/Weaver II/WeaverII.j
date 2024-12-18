scope WeaverII
    struct WeaverII extends Item
        static constant integer code = 'I09R'

        real mana = 20000
        real health = 20000
        real manaRegen = 300
        real healthRegen = 300
        real intelligence = 500
        real spellPower = 1000

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer id = GetSpellAbilityId()
            local boolean ultimate = BlzGetAbilityIntegerField(BlzGetUnitAbility(caster, id), ABILITY_IF_REQUIRED_LEVEL) >= 10
            local boolean potion = id == 'AIre'
            local boolean self = id == 'A01G'
        
            if self then
                call AddUnitBonusTimed(caster, BONUS_INTELLIGENCE, 500, 60)
                call UnitResetCooldown(caster)
            elseif UnitHasItemOfType(caster, code) and not potion then
                if ultimate and GetRandomReal(1, 100) <= 10 then
                    call ResetUnitAbilityCooldown(caster, id)
                    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Items\\RitualDagger\\RitualDaggerTarget.mdl", caster, "origin"))
                elseif not ultimate and GetRandomReal(1, 100) <= 20 then
                    call ResetUnitAbilityCooldown(caster, id)
                    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdl", caster, "origin"))
                endif
            endif
        
            set caster = null
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, Weaver.code, 0, 0, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
        endmethod
    endstruct
endscope