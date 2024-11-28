library Bladestorm requires SpellEffectEvent, PluginSpellEffect, TimerUtils
    /* ---------------------- Bladestorm v1.2 by Chopinski ---------------------- */
    // Credits:
    //     Bribe     - SpellEffectEvent
    //     Vexorian  - TimerUtils
    //     zbc       - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Bladestorm ability
        public  constant integer ABILITY    = 'A005'
        // The model path used in baldestorm
        private constant string  MODEL      = "Bladestorm.mdl"
        // The rate at which the bladestorm model is spammed
        private constant real    RATE       = 0.3
    endglobals

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Bladestorm
        timer   timer
        unit    unit
        real    duration
        real    count

        static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            if count < duration and UnitAlive(unit) and not IsUnitPaused(unit) then
                call DestroyEffect(AddSpecialEffectTarget(MODEL, unit, "origin"))
            else
                call ReleaseTimer(timer)
                call SetUnitTimeScale(unit, 1)
                set timer = null
                set unit  = null
                call deallocate()
            endif
            set count = count + RATE
        endmethod

        static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate()

            set timer    = NewTimerEx(this)
            set unit     = Spell.source.unit
            set duration = BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_HERO, Spell.level - 1) 
            set count    = 0
        
            call SetUnitTimeScale(unit, 3)
            call TimerStart(timer, RATE, true, function thistype.onPeriod)
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
        endmethod
    endstruct
endlibrary