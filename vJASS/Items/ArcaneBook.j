scope ArcaneBook
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetChance takes nothing returns integer
        return 20
    endfunction

    private constant function GetBonus takes nothing returns real
        return 0.5
    endfunction

    private constant function GetDuration takes nothing returns real
        return 10.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct ArcaneBook extends Item
        static constant integer code = 'I021'
        private static integer ability = 'A00B'

        real manaRegen = 5
        real spellPower = 60
        real intelligence = 20
        real cooldownReduction = 0.2

        private static method onSpell takes nothing returns nothing
            local boolean ultimate = BlzGetAbilityIntegerField(Spell.ability, ABILITY_IF_REQUIRED_LEVEL) >= 10
        
            if UnitHasItemOfType(Spell.source.unit, code) and Spell.cooldown > 0 then
                if not ultimate and GetRandomReal(0, 100) <= GetChance() then
                    call BlzEndUnitAbilityCooldown(Spell.source.unit, Spell.id)
                    call DestroyEffect(AddSpecialEffectTarget("Abilities\\Spells\\Undead\\DeathPact\\DeathPactTarget.mdl", Spell.source.unit, "origin"))
                endif
            endif
        endmethod

        private static method onCast takes nothing returns nothing
            call AddUnitBonusTimed(Spell.source.unit, BONUS_COOLDOWN_REDUCTION, GetBonus(), GetDuration())
            call BlzStartUnitAbilityCooldown(Spell.source.unit, Spell.id, Spell.cooldown)
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), ElementalShard.code, MageStaff.code, SpellbookOfWitchcraft.code, 0, 0)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call RegisterAnySpellEvent(function thistype.onSpell)
        endmethod
    endstruct
endscope