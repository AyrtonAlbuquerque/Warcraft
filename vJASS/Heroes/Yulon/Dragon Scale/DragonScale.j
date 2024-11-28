library DragonScale requires RegisterPlayerUnitEvent, DamageInterface
    /* --------------------- Dragon Scale v1.1 by Chopinski --------------------- */
    // Credits:
    //     Arowanna        - Icon
    //     Magtheridon96   - RegisterPlayerUnitEvent
    //     AZ              - Model
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the ability
        private constant integer ABILITY        = 'A000'
        // The model
        private constant string  MODEL          = "GreenFlare.mdl"
        // The attachment point
        private constant string  ATTACH_POINT   = "origin"
    endglobals

    // The maximum bonus damage per level
    private function GetBonus takes integer level returns real
        return 50.*level
    endfunction

    // The damage reduction per level
    private function GetDamageReduction takes integer level returns real
        return 0.2 + 0.*level
    endfunction

    // The Dragon Scale level up base on hero level
    private function GetLevel takes integer level returns boolean
        return level == 5 or level == 10 or level == 15
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct DragonScale extends array
        private static real array energy

        private static method onSpellDamage takes nothing returns nothing
            local real damage = GetEventDamage()
            local integer level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)
            local real amount

            if damage > 0 and level > 0 and Damage.isEnemy and energy[Damage.source.id] > 0 then
                set amount = GetBonus(level)
                
                if amount >= energy[Damage.source.id] then
                    set amount = energy[Damage.source.id]
                endif
                
                set damage = damage + amount
                set energy[Damage.source.id] = energy[Damage.source.id] - amount
                
                call DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.target.unit, ATTACH_POINT))
                call BlzSetEventDamage(damage)
            endif
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()
            local integer level = GetUnitAbilityLevel(Damage.target.unit, ABILITY)
            local real amount

            if damage > 0 and level > 0 and Damage.isEnemy then
                set amount = damage*GetDamageReduction(level)
                set damage = damage - amount
                set energy[Damage.target.id] = energy[Damage.target.id] + amount 
                
                call BlzSetEventDamage(damage)
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
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterSpellDamageEvent(function thistype.onSpellDamage)
        endmethod
    endstruct
endlibrary