library Bladestorm requires Spell, Periodic optional NewBonus
    /* ---------------------- Bladestorm v1.3 by Chopinski ---------------------- */
    // Credits:
    //     zbc - Icon
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
    private struct Bladestorm extends Spell
        private unit unit
        private real duration

        method destroy takes nothing returns nothing
            call SetUnitTimeScale(unit, 1)
            call deallocate()
            
            set unit = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return ""
        endmethod

        private method onPeriod takes nothing returns boolean
            set duration = duration - RATE

            if duration > 0 and UnitAlive(unit) and not IsUnitPaused(unit) then
                call DestroyEffect(AddSpecialEffectTarget(MODEL, unit, "origin"))
                return true
            endif
            
            return false
        endmethod

        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set unit = Spell.source.unit
            set duration = BlzGetAbilityRealLevelField(Spell.ability, ABILITY_RLF_DURATION_HERO, Spell.level - 1)
        
            call SetUnitTimeScale(unit, 3)
            call StartTimer(RATE, true, this, 0)
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary