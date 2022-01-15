library WindWalk requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, NewBonusUtils, CriticalStrike
    /* ----------------------- Wind Walk v1.2 by Chopinski ---------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     Bribe          - SpellEffectEvent
    //     Anachron       - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Wind Walk ability
        public  constant integer    ABILITY   = 'A001'
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
    private struct WindWalk extends array
        static boolean array check

        private static method onCast takes nothing returns nothing
            call LinkBonusToBuff(Spell.source.unit, BONUS_HEALTH_REGEN, GetRegenBonus(Spell.level), BUFF)
        endmethod

        private static method onAttack takes nothing returns nothing
            local unit    source = GetAttacker()
            local integer level  = GetUnitAbilityLevel(source, BUFF)
            local integer idx    = GetUnitUserData(source)

            if check[idx] and level == 0 then
                set check[idx] = false
                call UnitAddCriticalStrike(source, -100, -1)
            elseif not check[idx] and level > 0 then
                set check[idx] = true
                call UnitAddCriticalStrike(source, 100, 1)
            endif

            set source = null
        endmethod

        private static method onCritical takes nothing returns nothing
            local unit    source = GetCriticalSource()
            local integer idx    = GetUnitUserData(source)

            if check[idx] then
                set check[idx] = false
                call UnitAddCriticalStrike(source, -100, -1)
            endif

            set source = null
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function thistype.onAttack)
            call RegisterCriticalStrikeEvent(function thistype.onCritical)
        endmethod
    endstruct
endlibrary