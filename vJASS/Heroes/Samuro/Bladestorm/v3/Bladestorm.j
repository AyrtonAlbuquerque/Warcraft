library Bladestorm requires Spell, Modules, Utilities optional NewBonus
    /* ---------------------- Bladestorm v1.4 by Chopinski ---------------------- */
    // Credits:
    //     zbc - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Bladestorm ability
        public  constant integer ABILITY    = 'Smr1'
        // The model path used in baldestorm
        private constant string  MODEL      = "BladestormHots.mdl"
        // The damage period
        private constant real    PERIOD     = 0.25
        // The time scale during bladestorm
        private constant real    TIME_SCALE = 1
    endglobals

    // The Bladestorm damage per second
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 100. * level + 0.15 * level * GetUnitBonus(source, BONUS_DAMAGE)
        else
            return 100. * level
        endif
    endfunction

    // The BladeStorm AoE
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    // The Bladestorm duration
    public function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Bladestorm extends Spell
        private unit unit
        private integer level
        private real duration
        private effect effect

        method destroy takes nothing returns nothing
            call SetUnitTimeScale(unit, 1)
            call DestroyEffect(effect)
            call deallocate()
            
            set unit = null
            set effect = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "Causes a bladestorm of destructive force around |cffffcc00Samuro|r, dealing |cffff0000" + N2S(GetDamage(source, level), 0) + "|r |cffff0000Physical|r damage per second to enemy units within |cffffcc00" + N2S(GetAoE(source, level), 0) + " AoE|r. Lasts |cffffcc00" + N2S(GetDuration(source, level), 0) + "|r seconds."
        endmethod

        private method onPeriod takes nothing returns boolean
            set duration = duration - PERIOD

            if duration > 0 and UnitAlive(unit) and not IsUnitPaused(unit) then
                call UnitDamageArea(unit, GetUnitX(unit), GetUnitY(unit), GetAoE(unit, level), GetDamage(unit, level) * PERIOD, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, false, false, false)

                return true
            endif
            
            return false
        endmethod

        private method onCast takes nothing returns nothing
            set this = thistype.allocate()
            set unit = Spell.source.unit
            set level = Spell.level
            set duration = GetDuration(unit, level)
            set effect = AddSpecialEffectTarget(MODEL, unit, "origin")
        
            call SetUnitTimeScale(unit, TIME_SCALE)
            call StartTimer(PERIOD, true, this, 0)
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary