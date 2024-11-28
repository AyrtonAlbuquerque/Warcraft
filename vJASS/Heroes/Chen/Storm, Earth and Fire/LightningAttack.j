library LightningAttack requires DamageInterface, Utilities
    /* ------------------- Lightning Attack v1.2 by Chopinski ------------------- */
    // Credits:
    //     CRAZYRUSSIAN    - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of Lightning Attack ability
        public  constant integer ABILITY      = 'A009'
        // The Lightning Attack lightning model
        private constant string  LIGHTNING    = "CLSB"
        // The Lightning Attack damage model
        private constant string  IMPACT_MODEL = "Abilities\\Weapons\\Bolt\\BoltImpact.mdl"
        // The Lightning Attack damage model attach point
        private constant string  ATTACH       = "origin"
    endglobals

    // The number of bounces
    private function GetBounces takes integer level returns integer
        return 3 + 0*level
    endfunction

    // The damage per bounce
    private function GetDamage takes integer level returns real
        return 50.*level
    endfunction

    // The search range of bouncing lightning
    private function GetAoE takes integer level returns real
        return 300. + 0.*level
    endfunction
    
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct LightningAttack extends array
        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if Damage.isEnemy and not Damage.target.isStructure and level > 0 then
                call CreateChainLightning(Damage.source.unit, Damage.target.unit, GetDamage(level), GetAoE(level), 0.2, 0.1, GetBounces(level), ATTACK_TYPE_NORMAL, DAMAGE_TYPE_LIGHTNING, LIGHTNING, IMPACT_MODEL, ATTACH, false)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary