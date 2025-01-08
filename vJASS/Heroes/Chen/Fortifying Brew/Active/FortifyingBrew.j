library FortifyingBrew requires DamageInterface, Ability, NewBonus, Utilities
    /* -------------------- Fortifying Brew v1.4 by Chopinski ------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Fortifying Brew ability
        private constant integer ABILITY    = 'A000'
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
    private struct FortifyingBrew extends Ability
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Chen|r drinks from his keg, increasing his |cff00ff00Health Regeneration|r by |cff00ff00" + N2S(GetHealthRegen(level), 1) + "|r, |cff00ffffMana Regeneration|r by |cff00ffff" + N2S(GetManaRegen(level), 1) + "|r and takes |cffffcc00" + N2S(GetDamageReduction(level) * 100, 1) + "%|r reduced damage from auto attacks for |cffffcc00" + N2S(GetDuration(source, level), 1) + "|r seconds. Regeneration stacks with each cast."
        endmethod

        private method onCast takes nothing returns nothing
            local real duration = GetDuration(Spell.source.unit, Spell.level)

            call AddUnitBonusTimed(Spell.source.unit, BONUS_MANA_REGEN, GetManaRegen(Spell.level), duration)
            call AddUnitBonusTimed(Spell.source.unit, BONUS_HEALTH_REGEN, GetHealthRegen(Spell.level), duration)
        endmethod

        private static method onLevel takes nothing returns nothing
            local unit source = GetTriggerUnit()

            if GetLevel(GetHeroLevel(source)) then
                call IncUnitAbilityLevel(source, ABILITY)
            endif

            set source = null
        endmethod

        private static method onDamage takes nothing returns nothing
            if Damage.amount > 0 and GetUnitAbilityLevel(Damage.target.unit, BUFF) > 0 then
                set Damage.amount = Damage.amount * (1 - GetDamageReduction(GetUnitAbilityLevel(Damage.target.unit, ABILITY)))
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endlibrary