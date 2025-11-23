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
        // The raw code of the Bladestorm buff
        public  constant integer BUFF       = 'BSm0'
        // The model path used in baldestorm
        private constant string  MODEL      = "BladestormHots.mdl"
        // If true, the bladestorm model will be spawned at the damage period
        private constant boolean SPAM       = false
        // The damage period
        private constant real    PERIOD     = 0.25
        // The time scale during bladestorm
        private constant real    TIME_SCALE = 1
    endglobals

    // The Bladestorm damage per second
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 50. * level + 0.1 * level * GetUnitBonus(source, BONUS_DAMAGE)
        else
            return 50. * level
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
        private effect effect

        method destroy takes nothing returns nothing
            call SetUnitTimeScale(unit, 1)
            call UnitRemoveAbility(unit, 'Abun')
            call IssueImmediateOrderById(unit, 852590)
            call QueueUnitAnimation(unit, "Stand Ready")
            call AddUnitAnimationProperties(unit, "spin", false)
            call DestroyEffect(effect)
            call deallocate()
            
            set unit = null
            set effect = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "Causes a bladestorm of destructive force around |cffffcc00Samuro|r, dealing |cffff0000" + N2S(GetDamage(source, level), 0) + "|r |cffff0000Physical|r damage per second to enemy units within |cffffcc00" + N2S(GetAoE(source, level), 0) + " AoE|r. Drains |cff00ffff" + N2S(GetManaCost(source, level), 0) + " mana|r per second while activated."
        endmethod

        private method onPeriod takes nothing returns boolean
            local integer cost = GetManaCost(unit, level)

            if GetUnitAbilityLevel(unit, BUFF) > 0 and GetUnitState(unit, UNIT_STATE_MANA) >= cost then
                call AddUnitMana(unit, -cost * PERIOD)
                call UnitDamageArea(unit, GetUnitX(unit), GetUnitY(unit), GetAoE(unit, level), GetDamage(unit, level) * PERIOD, ATTACK_TYPE_HERO, DAMAGE_TYPE_NORMAL, false, false, false)

                if not SPAM then
                    call DestroyEffect(AddSpecialEffectTarget(MODEL, unit, "origin"))
                endif

                return true
            endif
            
            return false
        endmethod

        private method onCast takes nothing returns nothing
            if not HasStartedTimer(Spell.source.id) then
                set this = thistype.allocate()
                set unit = Spell.source.unit
                set level = Spell.level
            
                call SetUnitTimeScale(unit, TIME_SCALE)
                call UnitAddAbility(unit, 'Abun')
                call StartTimer(PERIOD, true, this, Spell.source.id)
                call AddUnitAnimationProperties(unit, "spin", true)

                if SPAM then
                    set effect = AddSpecialEffectTarget(MODEL, unit, "origin")
                endif
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
        endmethod
    endstruct
endlibrary