library FortifyingBrew requires DamageInterface, SpellEffectEvent, PluginSpellEffect, NewBonusUtils, Utilities
    /* -------------------- Fortifying Brew v1.3 by Chopinski ------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Fortifying Brew ability
        private constant integer ABILITY    = 'A00E'
        // The raw code of the Fortifying Brew Reduction ability
        private constant integer REDUCTION  = 'A00F'
        // The raw code of the Fortifying Brew buff
        private constant integer BUFF       = 'B001'
    endglobals

    // The Fortifying Brew health/mana regen bonus duration per cast
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The Fortifying Brew health regen bonus
    private function GetHealthRegen takes integer level returns real
        return 2.*level
    endfunction

    // The Fortifying Brew mana regen bonus
    private function GetManaRegen takes integer level returns real
        return 1.*level
    endfunction

    // The Fortifying Brew damage reduction
    private function GetDamageReduction takes integer level returns real
        return 0.075 + 0.025*level
    endfunction

    // The Fortifying Brew level up base on hero level
    private function GetLevel takes integer level returns boolean
        return level == 5 or level == 10 or level == 15 or level == 20
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct FortifyingBrew extends array
        private static method onCast takes nothing returns nothing
            local unit source = GetTriggerUnit()
            local integer level = GetUnitAbilityLevel(source, ABILITY)
            local real duration

            if level > 0 then
                set duration = GetDuration(source, level)

                call UnitAddAbilityTimed(source, REDUCTION, duration, 1, true)
                call AddUnitBonusTimed(source, BONUS_HEALTH_REGEN, GetHealthRegen(level), duration)
                call AddUnitBonusTimed(source, BONUS_MANA_REGEN, GetManaRegen(level), duration)
            endif

            set source = null
        endmethod

        private static method onLevel takes nothing returns nothing
            local unit source = GetTriggerUnit()

            if GetLevel(GetHeroLevel(source)) then
                call IncUnitAbilityLevel(source, ABILITY)
            endif

            set source = null
        endmethod

        private static method onDamage takes nothing returns nothing
            local real damage = GetEventDamage()

            if damage > 0 and GetUnitAbilityLevel(Damage.target.unit, BUFF) > 0 then
                call BlzSetEventDamage(damage * (1 - GetDamageReduction(GetUnitAbilityLevel(Damage.target.unit, ABILITY))))
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary