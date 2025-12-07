scope WeaverII
    struct WeaverII extends Item
        static constant integer code = 'I09R'

        real mana = 1000
        real health = 1000
        real manaRegen = 20
        real healthRegen = 20
        real intelligence = 30
        real spellPower = 180

        private method onTooltip takes unit u, item i, integer id returns string
            return "|cffffcc00Gives|r:\n+ |cffffcc001000|r Mana\n+ |cffffcc001000|r Health\n+ |cffffcc0030|r Intelligence\n+ |cffffcc00180|r Spell Power\n+ |cffffcc0020|r Mana Regeneration\n+ |cffffcc0020|r Health Regeneration\n\n|cff00ff00Passive|r: |cffffcc00Atemporal|r: After casting an |cffffcc00active|r ability, your Hero have a |cffffcc0020%%|r chance to reset this ability cooldown |cffffcc00(10% for Ultimates)|r.\n\n|cff00ff00Active|r: |cffffcc00Waeve of Time|r: When activated, all abilities cooldowns are reseted.\n\n|cff00ff00Active|r: |cffffcc00Timed Scale|r: Upon activating |cffffcc00Weave of Time|r, |cff00ffffIntelligence|r in increased by |cff00ffff" + N2S(3 * GetWidgetLevel(u), 0) + "|r for |cffffcc0060|r seconds.\n\n|cffffcc00240|r seconds cooldown."
        endmethod

        private static method onCast takes nothing returns nothing
            local unit caster = GetTriggerUnit()
            local integer id = GetSpellAbilityId()
            local boolean ultimate = BlzGetAbilityIntegerField(BlzGetUnitAbility(caster, id), ABILITY_IF_REQUIRED_LEVEL) >= 10
            local boolean potion = id == 'AIre'
            local boolean self = id == 'A01G'
        
            if self then
                call AddUnitBonusTimed(caster, BONUS_INTELLIGENCE, 3 * GetWidgetLevel(caster), 60)
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
            call RegisterItem(allocate(code), Weaver.code, 0, 0, 0, 0)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
        endmethod
    endstruct
endscope