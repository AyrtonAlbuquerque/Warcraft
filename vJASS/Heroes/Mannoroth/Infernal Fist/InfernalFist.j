library InfernalFist requires Table, DamageInterface, NewBonus, Spell, Utilities, Modules
    /* --------------------- Infernal Fist v1.0 by Chopinski -------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Magtheridon96   - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Infernal Fist ability
        private constant integer ABILITY    = 'MnrA'
        // The bonus damage model
        private constant string  MODEL      = "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl"
    endglobals

    // The attack speed bonus
    private function GetBonusAttackSpeed takes unit source, integer level returns real
        return 1. + 0.*level
    endfunction 

    // The Attack speed bonus duration
    private function GetDuration takes unit source, integer level returns real
        return 5. + 0.*level
    endfunction

    // The bonus cooldown per target
    private function GetCooldown takes unit source, integer level returns real
        return 20. - 0.*level
    endfunction

    // The Max Health bonus damage
    private function GetDamage takes unit target, integer level returns real
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return 0.05 + 0.*level
        else
            return 0.10 + 0.*level
        endif
    endfunction

    // The number of attacks to apply max health damage
    private function GetAttackCount takes unit source, integer level returns integer
        return 3 - 0*level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct InfernalFist extends Spell
        private static HashTable table

        method destroy takes nothing returns nothing
            call deallocate()
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)
            
            if level > 0 and Damage.isEnemy then
                set table[Damage.source.id][Damage.target.id] = table[Damage.source.id][Damage.target.id] + 1

                if table[Damage.source.id][Damage.target.id] >= GetAttackCount(Damage.source.unit, level) then
                    set table[Damage.source.id][Damage.target.id] = 0
                    set Damage.amount = Damage.amount + (GetDamage(Damage.target.unit, level) * BlzGetUnitMaxHP(Damage.target.unit))

                    call DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.target.unit, "origin"))
                endif

                if not HasStartedTimer(Damage.source.id) then
                    call AddUnitBonusTimed(Damage.source.unit, BONUS_ATTACK_SPEED, GetBonusAttackSpeed(Damage.source.unit, level), GetDuration(Damage.source.unit, level))
                    call StartTimer(GetCooldown(Damage.source.unit, level), false, thistype.allocate(), Damage.source.id)
                endif
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            set table = HashTable.create()

            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary