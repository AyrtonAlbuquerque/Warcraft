library AdaptedWarrior requires Spell, Evasion, NewBonus, DamageInterface, RegisterPlayerUnitEvent, Utilities
    /* -------------------- Adapted Warrior v1.3 by Chopinski ------------------- */
    // Credits:
    //     FrIkY          - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Adapted Warrior ability
        private constant integer ABILITY        = 'A000'
        // The Mana Burn model
        private constant string  MODEL          = "Abilities\\Spells\\Human\\Feedback\\SpellBreakerAttack.mdl"
        // The Mana Burn bonus model
        private constant string  BONUS_MODEL    = "ManaBurn.mdl"
        // The Mana Burn attachment point
        private constant string  ATTACH_POINT   = "origin"
    endglobals

    // The Attack Speed bonus amount
    private function GetAttackSpeedBonus takes integer level returns real
        return 0.05 + 0.*level
    endfunction

    // The Attack Speed bonus duration
    private function GetAttackSpeedDuration takes integer level returns real
        return 10. + 0.*level
    endfunction

    // The Movement Speed bonus amount
    private function GetMovementSpeedBonus takes integer level returns integer
        return 5 + 0*level
    endfunction

    // The Movement Speed bonus duration
    private function GetMovementSpeedDuration takes integer level returns real
        return 10. + 0.*level
    endfunction

    // The amount of mana burned in each attack
    private function GetManaBurned takes integer level returns real
        return 10.*level
    endfunction

    // The mana percentage for bonus damage
    private function GetManaPercent takes integer level returns real
        return 40. + 0.*level
    endfunction

    // The Auto Level up
    private function GetLevel takes integer level returns boolean
        return level == 5 or level == 10 or level == 15 or level == 20
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct AdaptedWarrior extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "When |cffffcc00Illidan|r evades an attack, his |cffffcc00Attack Speed|r is increased by |cffffcc00" + N2S(GetAttackSpeedBonus(level), 0) + "%|r and |cffffcc00Movement Speed|r is increased by |cffffcc00" + N2S(GetMovementSpeedBonus(level), 0) + "|r for |cffffcc00" + N2S(GetMovementSpeedDuration(level), 0) + "|r seconds. Additionally |cffffcc00Illidan|r attacks destroy |cff00ffff" + N2S(GetManaBurned(level), 0) + " Mana|r per hit. The mana combusts, dealing |cff00ffffMagic|r damage to the attacked unit. If the attacked unit mana is below |cffffcc00" + N2S(GetManaPercent(level), 0) + "%|r, the combusted mana deals |cffd45e19Pure|r damage instead."
        endmethod

        private static method onEvade takes nothing returns nothing
            local unit source = GetMissingUnit()
            local unit target = GetEvadingUnit()
            local integer level = GetUnitAbilityLevel(target, ABILITY)
            local boolean enemy = IsUnitEnemy(target, GetOwningPlayer(source))
        
            if level > 0 and enemy then
                call AddUnitBonusTimed(target, BONUS_ATTACK_SPEED, GetAttackSpeedBonus(level), GetAttackSpeedDuration(level))
                call AddUnitBonusTimed(target, BONUS_MOVEMENT_SPEED, GetMovementSpeedBonus(level), GetMovementSpeedDuration(level))
            endif
        
            set source = null
            set target = null
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)
            local real burn

            if Damage.isEnemy and not Damage.target.isMagicImmune and level > 0 and BlzGetUnitMaxMana(Damage.target.unit) > 0 then
                set burn = GetManaBurned(level)

                call AddUnitMana(Damage.target.unit, -burn)

                if GetUnitManaPercent(Damage.target.unit) < GetManaPercent(level) then
                    call DestroyEffect(AddSpecialEffectTarget(BONUS_MODEL, Damage.target.unit, ATTACH_POINT))
                    call UnitDamageTarget(Damage.source.unit, Damage.target.unit, burn, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null)
                else
                    call DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.target.unit, ATTACH_POINT))
                    call UnitDamageTarget(Damage.source.unit, Damage.target.unit, burn, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                endif
            endif
        endmethod

        private static method onLevel takes nothing returns nothing
            local unit source = GetTriggerUnit()

            if GetLevel(GetHeroLevel(source)) then
                call IncUnitAbilityLevel(source, ABILITY)
            endif

            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterEvasionEvent(function thistype.onEvade)
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endlibrary