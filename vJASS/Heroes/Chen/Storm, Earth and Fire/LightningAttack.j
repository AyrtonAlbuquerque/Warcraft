library LightningAttack requires DamageInterface, Utilities, Spell, Utilities optional NewBonus
    /* ------------------- Lightning Attack v1.3 by Chopinski ------------------- */
    // Credits:
    //     CRAZYRUSSIAN    - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of Lightning Attack ability
        public  constant integer ABILITY      = 'ChnD'
        // The Lightning Attack lightning model
        private constant string  LIGHTNING    = "CLSB"
        // The Lightning Attack damage model
        private constant string  IMPACT_MODEL = "Abilities\\Weapons\\Bolt\\BoltImpact.mdl"
        // The Lightning Attack damage model attach point
        private constant string  ATTACH       = "origin"
    endglobals

    // The number of bounces
    private function GetBounces takes integer level returns integer
        return 4 + 0*level
    endfunction

    // The damage per bounce
    private function GetDamage takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 150. * level + (0.2 * level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 150. * level
        endif
    endfunction

    // The search range of bouncing lightning
    private function GetAoE takes integer level returns real
        return 400. + 0.*level
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct LightningAttack extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Storm|r attacks creates a |cffffcc00Chain Lightning|r, bouncing up to |cffffcc00" + N2S(GetBounces(level), 0) + "|r targets and dealing |cff00ffff" + N2S(GetDamage(source, level), 0) + "|r |cff00ffffMagic|r damage to each."
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if Damage.isEnemy and not Damage.target.isStructure and level > 0 then
                call CreateChainLightning(Damage.source.unit, Damage.target.unit, GetDamage(Damage.source.unit, level), GetAoE(level), 0.2, 0.1, GetBounces(level), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, LIGHTNING, IMPACT_MODEL, ATTACH, false)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary