library CommanderOdin requires SpellEffectEvent, PluginSpellEffect, TimerUtils, optional FragGranade, optional AutomatedTurrent, optional Overkill, optional RunAndGun, optional OdinAttack, optional OdinAnnihilate, optional OdinIncinerate
    /* -------------------- Commander Odin v1.2 by Chopinski -------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    //     Vexorian        - TimerUtils
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
    struct CommanderOdin
        readonly static boolean array morphed

        timer   timer
        unit    unit
        integer level
        boolean hide

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

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

            call ReleaseTimer(timer)
            call deallocate()

            set timer = null
            set unit  = null
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()

            set morphed[Spell.source.id] = not morphed[Spell.source.id]
            set timer = NewTimerEx(this)
            set unit  = Spell.source.unit
            set level = Spell.level
            set hide  = morphed[Spell.source.id]

            call TimerStart(timer, BlzGetAbilityRealLevelField(BlzGetUnitAbility(Spell.source.unit, ABILITY), ABILITY_RLF_DURATION_NORMAL, Spell.level - 1) + 0.01, false, function thistype.onExpire)
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary