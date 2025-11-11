library Enraged requires RegisterPlayerUnitEvent, DamageInterface, NewBonus, Indexer, Spell, Utilities
    /* ------------------------ Enraged v1.1 by Chopinski ----------------------- */
    // Credits:
    //     Nyx-Studio      - Icon
    //     Magtheridon96   - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY = 'Rex6'
    endglobals
    
    // The movement speed bonus
    private function GetBonusMovementSpeed takes integer level returns real
        return 1. + 0.*level
    endfunction

    // The attack speed bonus (0.02 = 2%)
    private function GetBonusAttackSpeed takes integer level returns real
        return 0.02 + 0.*level
    endfunction
    
    // The damage bonus (0.01 = 1%)
    private function GetDamageBonus takes integer level returns real
        return 0.01 + 0.*level
    endfunction

    // The health percentage that increases the bonusses (1 == 1%)
    private function GetHealthPercentage takes integer level returns real
        return 1. - 0.*level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Enraged extends Spell
        private static real array speed
        private static real array damage
        private static real array movement

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Misha|r gains |cffffcc00" + N2S(GetBonusAttackSpeed(level) * 100, 0) + "%|r attack speed, |cffffcc00" + N2S(GetBonusMovementSpeed(level), 0) + "|r movement speed and deals |cffffcc00" + N2S(GetDamageBonus(level) * 100, 0) + "%|r more damage for every |cffffcc00" + N2S(GetHealthPercentage(level) * 100, 0) + "%|r of missing health."
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if level > 0 and Damage.amount > 0 then
                set damage[Damage.source.id] = ((100 - GetUnitLifePercent(Damage.source.unit)) * GetDamageBonus(level)) / GetHealthPercentage(level)
                set Damage.amount = Damage.amount * (1 + damage[Damage.source.id])
            endif
        endmethod

        private static method onAttack takes nothing returns nothing
            local unit source = GetAttacker()
            local integer i = GetUnitUserData(source)
            local integer level = GetUnitAbilityLevel(source, ABILITY)

            if level > 0 then
                call AddUnitBonus(source, BONUS_ATTACK_SPEED, -speed[i])
                call AddUnitBonus(source, BONUS_MOVEMENT_SPEED, -movement[i])

                set speed[i] = ((100 - GetUnitLifePercent(source)) * GetBonusAttackSpeed(level)) / GetHealthPercentage(level)
                set movement[i] = ((100 - GetUnitLifePercent(source)) * GetBonusMovementSpeed(level)) / GetHealthPercentage(level)

                call AddUnitBonus(source, BONUS_ATTACK_SPEED, speed[i])
                call AddUnitBonus(source, BONUS_MOVEMENT_SPEED, movement[i])
            endif
        endmethod

        private static method onIndex takes nothing returns nothing
            local integer i = GetUnitUserData(GetIndexUnit())

            set speed[i] = 0
            set damage[i] = 0
            set movement[i] = 0
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterUnitIndexEvent(function thistype.onIndex)
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function thistype.onAttack)
        endmethod
    endstruct
endlibrary