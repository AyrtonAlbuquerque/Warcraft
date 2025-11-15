library RunAndGun requires Spell, RegisterPlayerUnitEvent, NewBonus, TimedHandles, optional ArsenalUpgrade
    /* ---------------------- Run And Gun v1.3 by Chopinski --------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     TriggerHappy    - TimerUtils
    //     Magtheridon96   - RegisterPlayerUnitEvent
    //     Mythic          - Effect
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Run and Gun ability
        public  constant integer ABILITY = 'Tyc4'
        // The Buff model
        private constant string  MODEL   = "Valiant Charge Royal.mdl"
        // The Buff attachment point
        private constant string  ATTACH  = "origin"
    endglobals

    // The Run and Gun duration.
    private function GetDuration takes unit source, integer level returns real
        static if LIBRARY_ArsenalUpgrade then
            if GetUnitAbilityLevel(source, ArsenalUpgrade_ABILITY) > 0 then
                return 5. + 0.*level
            else
                return 2.5 + 0.*level
            endif
        else
            return 2.5 + 0.*level
        endif
    endfunction

    // The Run and Gun Movement Speed bonus per kill.
    private function GetBonus takes integer level, boolean hero returns integer
        if hero then
            return 20*level
        else
            return 5*level
        endif
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct RunAndGun extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "When killing an enemy unit |cffffcc00Tychus|r gains |cffffcc00" + N2S(5 * level, 0) + "|r (|cffffcc00" + N2S(20 * level, 0) + "|r for Heroes) bonus |cffffff00Movement Speed|r for |cffffcc00" + N2S(GetDuration(source, level), 1) + "|r seconds."
        endmethod

        private static method onDeath takes nothing returns nothing
            local real duration
            local unit killed = GetTriggerUnit()
            local unit killer = GetKillingUnit()
            local integer level = GetUnitAbilityLevel(killer, ABILITY)

            if IsUnitEnemy(killed, GetOwningPlayer(killer)) and level > 0 then
                set duration = GetDuration(killer, level)

                call AddUnitBonusTimed(killer, BONUS_MOVEMENT_SPEED, GetBonus(level, IsUnitType(killed, UNIT_TYPE_HERO)), duration)
                call DestroyEffectTimed(AddSpecialEffectTarget(MODEL, killer, ATTACH), duration)
            endif

            set killed = null
            set killer = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
endlibrary