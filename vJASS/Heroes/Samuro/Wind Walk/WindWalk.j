library WindWalk requires RegisterPlayerUnitEvent, Spell, NewBonus, DamageInterface, Utilities
    /* ----------------------- Wind Walk v1.3 by Chopinski ---------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     Anachron       - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Wind Walk ability
        public  constant integer    ABILITY   = 'Smr9'
        // The raw code of the Wind Walk buff
        private constant integer    BUFF      = 'BOwk'
    endglobals

    // The health regeneration bonus
    private function GetRegenBonus takes integer level returns real
        return 15. + 5.*level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct WindWalk extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "Allows |cffffcc00Samuro|r to become invisible, and move |cffffcc00" + N2S(BlzGetAbilityRealLevelField(spell, ABILITY_RLF_MOVEMENT_SPEED_INCREASE_PERCENT_OWK2, level -1) * 100, 0) + "%|r faster for |cffffcc00" + N2S(BlzGetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_HERO, level -1), 1) + "|r seconds. While invisible, |cffffcc00Samuro|r has |cff00ff00" + N2S(GetRegenBonus(level), 0) + "|r increased |cff00ff00Health Regeneration|r. When |cffffcc00Samuro|r attacks a unit to break invisibility, he will hit a |cffffcc00Critical Strike|r with |cffffcc00100%|r bonus |cffffcc00Critical Damage|r and |cffff0000" + N2S(BlzGetAbilityRealLevelField(spell, ABILITY_RLF_BACKSTAB_DAMAGE, level -1), 0) + "|r bonus damage on that attack."
        endmethod

        private method onCast takes nothing returns nothing
            call LinkBonusToBuff(Spell.source.unit, BONUS_HEALTH_REGEN, GetRegenBonus(Spell.level), BUFF)
            call LinkBonusToBuff(Spell.source.unit, BONUS_CRITICAL_CHANCE, 1, BUFF)
            call LinkBonusToBuff(Spell.source.unit, BONUS_CRITICAL_DAMAGE, 1, BUFF)
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary