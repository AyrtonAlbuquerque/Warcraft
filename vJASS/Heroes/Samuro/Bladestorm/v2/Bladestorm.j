library Bladestorm requires Spell, Periodic, Utilities optional NewBonus
    /* ---------------------- Bladestorm v1.3 by Chopinski ---------------------- */
    // Credits:
    //     zbc - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Bladestorm ability
        public  constant integer ABILITY    = 'A009'
        // The raw code of the Bladestorm buff
        public  constant integer BUFF       = 'B000'
        // The model path used in baldestorm
        private constant string  MODEL      = "Bladestorm.mdl"
        // The rate at which the bladestorm model is spammed
        private constant real    RATE       = 0.25
    endglobals

    // The Bladestorm damage per second
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 25. * level + 0.1 * level * GetUnitBonus(source, BONUS_DAMAGE)
        else
            return 25. * level
        endif
    endfunction

    // The BladeStorm AoE
    private function GetAoE takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction

    private function GetManaCost takes unit source, integer level returns integer
        return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_ILF_MANA_COST, level - 1)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Bladestorm extends Spell
        private unit unit
        private integer level

        method destroy takes nothing returns nothing
            call SetUnitTimeScale(unit, 1)
            call UnitRemoveAbility(unit, 'Abun')
            call IssueImmediateOrderById(unit, 852590)
            call QueueUnitAnimation(unit, "Stand Ready")
            call AddUnitAnimationProperties(unit, "spin", false)
            call deallocate()
            
            set unit = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "Causes a bladestorm of destructive force around |cffffcc00Samuro|r, dealing |cffff0000" + N2S(GetDamage(source, level), 0) + "|r |cffff0000Physical|r damage per second to enemy units within |cffffcc00" + N2S(GetAoE(source, level), 0) + " AoE|r. Drains |cff00ffff" + N2S(GetManaCost(source, level), 0) + " mana|r per second while activated."
        endmethod

        private method onPeriod takes nothing returns boolean
            local integer cost = GetManaCost(unit, level)

            if GetUnitAbilityLevel(unit, BUFF) > 0 and GetUnitState(unit, UNIT_STATE_MANA) >= cost then
                call AddUnitMana(unit, -cost * RATE)
                call DestroyEffect(AddSpecialEffectTarget(MODEL, unit, "origin"))
                call UnitDamageArea(unit, GetUnitX(unit), GetUnitY(unit), GetAoE(unit, level), GetDamage(unit, level) * RATE, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, false, false, false)

                return true
            endif
            
            return false
        endmethod

        private method onCast takes nothing returns nothing
            if not HasStartedTimer(Spell.source.id) then
                set this = thistype.allocate()
                set unit = Spell.source.unit
                set level = Spell.level
            
                call SetUnitTimeScale(unit, 3)
                call UnitAddAbility(unit, 'Abun')
                call StartTimer(RATE, true, this, Spell.source.id)
                call AddUnitAnimationProperties(unit, "spin", true)
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary