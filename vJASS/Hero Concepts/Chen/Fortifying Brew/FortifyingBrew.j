library FortifyingBrew requires DamageInterface, SpellEffectEvent, PluginSpellEffect, NewBonusUtils
    /* -------------------- Fortifying Brew v1.2 by Chopinski ------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Fortifying Brew ability
        private constant integer ABILITY = 'A000'
        // The raw code of the Fortifying Brew bUFF
        private constant integer BUFF    = 'B001'
    endglobals

    // The Fortifying Brew health/mana regen bonus duration per cast
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction

    // The Fortifying Brew health regen bonus
    private function GetHealthRegen takes integer level returns real
        return 5.*level
    endfunction

    // The Fortifying Brew mana regen bonus
    private function GetManaRegen takes integer level returns real
        return 2.*level
    endfunction

    // The Fortifying Brew damage reduction
    private function GetDamageReduction takes integer level returns real
        return 0.33 + 0.*level
    endfunction

    // The Fortifying Brew level up base on hero level
    private function GetLevel takes integer level returns boolean
        return level == 5 or level == 10 or level == 15 or level == 20
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct FortifyingBrew
        private static method onCast takes nothing returns nothing
            call AddUnitBonusTimed(Spell.source.unit, BONUS_HEALTH_REGEN, GetHealthRegen(Spell.level), GetDuration(Spell.source.unit, Spell.level))
            call AddUnitBonusTimed(Spell.source.unit, BONUS_MANA_REGEN, GetManaRegen(Spell.level), GetDuration(Spell.source.unit, Spell.level))
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
            call RegisterSpellEffectEvent(ABILITY, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary