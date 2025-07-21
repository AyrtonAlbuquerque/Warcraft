library Bash requires Spell, DamageInterface, CrowdControl, Utilities optional NewBonus
    /* ------------------------------------------ Bash v1.1 ----------------------------------------- */
    // Credits:
    //     PrinceYaser - Icon
    /* ---------------------------------------- By Chipinski ---------------------------------------- */

    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // The raw code of the bash ability
        private constant integer ABILITY = 'A006'
        // The stun model
        private constant string  MODEL   = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
        // The stun model attachment point
        private constant string  POINT   = "overhead"
    endglobals

    // The damage dealt
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DAMAGE_BONUS_HBH3, level - 1) + 0.25 * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DAMAGE_BONUS_HBH3, level - 1)
        endif
    endfunction

    // The proc chance
    private function GetChance takes unit source, integer level returns real
        return 10. + 5*level
    endfunction

    // The duration
    private function GetDuration takes unit source, unit target, integer level returns real
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_NORMAL, level - 1)
        endif
    endfunction

    // Filter for units
    private function UnitFilter takes player owner, unit target returns boolean
        return IsUnitEnemy(target, owner) and UnitAlive(target) and not IsUnitType(target, UNIT_TYPE_STRUCTURE) and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE)
    endfunction

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    private struct Bash extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "Gives a |cffffcc00" + N2S(GetChance(source, level), 0) + "%|r chance that an attack will do |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r bonus |cff00ffffMagic|r damage and stun an opponent for |cffffcc001|r (|cffffcc000.5|r for |cffffcc00Heroes|r) second."
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if level > 0 then
                if UnitFilter(Damage.source.player, Damage.target.unit) then
                    if GetRandomReal(0, 100) <= GetChance(Damage.source.unit, level) then
                        if UnitDamageTarget(Damage.source.unit, Damage.target.unit, GetDamage(Damage.source.unit, level), false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null) then
                            call StunUnit(Damage.target.unit, GetDuration(Damage.source.unit, Damage.target.unit, level), MODEL, POINT, false)
                        endif
                    endif
                endif
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary
