library AdaptiveStrike requires RegisterPlayerUnitEvent, DamageInterface, NewBonus, Spell, Utilities
    /* -------------------- Adaptive Strike v1.4 by Chopinski ------------------- */
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
        private constant integer ABILITY = 'Idn3'
        // The Adaptive Strike Slash model
        private constant string  SLASH   = "Culling Slash.mdl"
        // The Adaptive Strike Cleave model
        private constant string  CLEAVE  = "Culling Cleave.mdl"
    endglobals

    // The Adaptive Strike proc chance
    private function GetChance takes integer level returns real
        return 25. * level
    endfunction 

    // The Adaptive Strike damage
    private function GetDamage takes unit source, integer level returns real
        return 25 * level + 0.5 * GetUnitBonus(source, BONUS_DAMAGE)
    endfunction

    // The Adaptive Strike AoE
    private function GetAoE takes boolean slash, integer level returns real
        if slash then
            return 300. + 0.*level
        else
            return 300. + 0.*level
        endif
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct AdaptiveStrike extends Spell
        private static integer array state

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Illidan|r attacks have a |cffffcc00" + N2S(GetChance(level), 0) + "%|r chance to become |cffffcc00Adaptive|r, varying between a |cffffcc00Cleave|r in front or a |cffffcc00Slash|r around when in his normal form, dealing |cffd45e19" + N2S(GetDamage(source, level), 0) + "|r |cffd45e19Pure|r damage to units within |cffffcc00" + N2S(GetAoE(false, level), 0) + " AoE|r. In addition, |cffffcc00Illidan|r |cffffcc00Dark|r form attacks becomes an area of effect attack, applying on hit effects to all units damaged."
        endmethod

        private static method onAttack takes nothing returns nothing
            local unit source = GetAttacker()
            local integer id = GetUnitUserData(source)
            local integer level = GetUnitAbilityLevel(source, ABILITY)
        
            if level > 0 and IsUnitType(source, UNIT_TYPE_MELEE_ATTACKER) and GetRandomReal(0, 100) <= GetChance(level) then
                set state[id] = GetRandomInt(1, 2)

                if state[id] == 1 then
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

        private static method onDamage takes nothing returns nothing
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

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function thistype.onAttack)
        endmethod
    endstruct
endlibrary