library AdaptiveStrike requires RegisterPlayerUnitEvent, NewBonus
    /* -------------------- Adaptive Strike v1.2 by Chopinski ------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Magtheridon96   - RegisterPlayerUnitEvent
    //     Mythic          - Culling Slash and Cleave Effects
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Adaptive Strike ability
        private constant integer ABILITY = 'A003'
        // The Adaptive Strike Slash model
        private constant string  SLASH   = "Culling Slash.mdl"
        // The Adaptive Strike Cleave model
        private constant string  CLEAVE  = "Culling Cleave.mdl"
    endglobals

    // The Adaptive Strike proc chance
    private function GetChance takes integer level returns boolean
        return GetRandomInt(level, 4) <= level
    endfunction

    // The Adaptive Strike damage
    private function GetDamage takes unit source, integer level returns real
        return 50*level + GetUnitBonus(source, BONUS_DAMAGE)*0.5
    endfunction

    // The Adaptive Strike AoE
    private function GetAoE takes boolean slash, integer level returns real
        if slash then
            return 250. + 0.*level
        else
            return 250. + 0.*level
        endif
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct AdaptiveStrike extends array
        static integer array state

        static method onDamage takes nothing returns nothing
            local integer level

            if state[Damage.source.id] != 0 then
                set level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)
                if state[Damage.source.id] == 1 then
                    call UnitDamageCone(Damage.source.unit, Damage.source.x, Damage.source.y, GetUnitFacing(Damage.source.unit), 150, GetAoE(false, level), GetDamage(Damage.source.unit, level), ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, false, true, false)
                else
                    call UnitDamageArea(Damage.source.unit, Damage.source.x, Damage.source.y, GetAoE(true, level), GetDamage(Damage.source.unit, level), ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, false, true, false)
                endif
                set state[Damage.source.id] = 0
            endif
        endmethod

        static method onAttack takes nothing returns nothing
            local unit    source = GetAttacker()
            local integer level  = GetUnitAbilityLevel(source, ABILITY)
            local integer i
        
            if level > 0 and IsUnitType(source, UNIT_TYPE_MELEE_ATTACKER) and GetChance(level) then
                set i = GetUnitUserData(source)
                set state[i] = GetRandomInt(1, 2)
                if state[i] == 1 then
                    call SetUnitAnimationByIndex(source, 4)
                    call QueueUnitAnimation(source, "Stand Ready")
                    call DestroyEffect(AddSpecialEffectTarget(CLEAVE, source, "origin"))
                else
                    call SetUnitAnimationByIndex(source, 5)
                    call QueueUnitAnimation(source, "Stand Ready")
                    call DestroyEffect(AddSpecialEffectTarget(SLASH, source, "origin"))
                endif
            endif
        
            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function thistype.onAttack)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary