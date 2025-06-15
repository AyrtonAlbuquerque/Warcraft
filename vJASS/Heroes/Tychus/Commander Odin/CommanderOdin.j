library CommanderOdin requires Ability, Periodic, optional FragGranade, optional AutomatedTurrent, optional Overkill, optional RunAndGun, optional OdinAttack, optional OdinAnnihilate, optional OdinIncinerate
    /* -------------------- Commander Odin v1.3 by Chopinski -------------------- */
    // Credits:
    //     Blizzard        - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Commander Odin ability
        private constant integer ABILITY = 'A006'
    endglobals

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct CommanderOdin extends Ability
        readonly static boolean array morphed

        private unit unit
        private boolean hide
        private integer level

        method destroy takes nothing returns nothing
            call deallocate()
            set unit = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
        return "|cffffcc00Tychus|r calls for a |cffffcc00Commander Odin|r to pilot, gaining |cffffcc00" + N2S(BlzGetAbilityRealLevelField(spell, ABILITY_RLF_ALTERNATE_FORM_HIT_POINT_BONUS, level - 1), 0) + "|r bonus |cffff0000Health|r and new abilities for |cffffcc00" + N2S(BlzGetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_HERO, level - 1), 1) + "|r seconds."
        endmethod

        private method onExpire takes nothing returns nothing
            if hide then
                static if LIBRARY_OdinAttack then
                    call SetUnitAbilityLevel(unit, OdinAttack_ABILITY, level)
                endif

                static if LIBRARY_OdinAnnihilate then
                    call SetUnitAbilityLevel(unit, OdinAnnihilate_ABILITY, level)
                endif

                static if LIBRARY_OdinIncinerate then
                    call SetUnitAbilityLevel(unit, OdinIncinerate_ABILITY, level)
                endif
            endif

            static if LIBRARY_FragGranade then
                call BlzUnitDisableAbility(unit, FragGranade_ABILITY, hide, hide)
            endif

            static if LIBRARY_AutomatedTurrent then
                call BlzUnitDisableAbility(unit, AutomatedTurrent_ABILITY, hide, hide)
            endif

            static if LIBRARY_Overkill then
                call BlzUnitDisableAbility(unit, Overkill_ABILITY, hide, hide)
            endif

            static if LIBRARY_RunAndGun then
                call BlzUnitDisableAbility(unit, RunAndGun_ABILITY, hide, hide)
            endif
        endmethod

        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set level = Spell.level
            set unit = Spell.source.unit
            set morphed[Spell.source.id] = not morphed[Spell.source.id]
            set hide = morphed[Spell.source.id]

            call StartTimer(BlzGetAbilityRealLevelField(Spell.ability, ABILITY_RLF_DURATION_NORMAL, Spell.level - 1) + 0.01, false, this, 0)
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary