library FortifyingBrew requires DamageInterface, Spell, NewBonus, Utilities
    /* -------------------- Fortifying Brew v1.4 by Chopinski ------------------- */
    // Credits:
    //     Blizzard        - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Fortifying Brew ability
        private constant integer ABILITY    = 'Chn0'
        // The raw code of the Fortifying Brew Reduction ability
        private constant integer REDUCTION  = 'Chn1'
        // The raw code of the Fortifying Brew buff
        private constant integer BUFF       = 'BCh0'
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
    private struct FortifyingBrew extends Spell
        private method onTooltip takes unit source, integer level, ability spell returns string
            return "Whenever |cffffcc00Chen|r uses an ability he drinks from his keg, increasing his |cff00ff00Health Regeneration|r by |cff00ff00" + N2S(GetHealthRegen(level), 1) + "|r, |cff00ffffMana Regeneration|r by |cff00ffff" + N2S(GetManaRegen(level), 1) + "|r and takes |cffffcc00" + N2S(GetDamageReduction(level) * 100, 1) + "%|r reduced damage from auto attacks for |cffffcc00" + N2S(GetDuration(source, level), 1) + "|r seconds. Regeneration stacks with each cast."
        endmethod

        private static method onSpell takes nothing returns nothing
            local unit source = GetTriggerUnit()
            local integer level = GetUnitAbilityLevel(source, ABILITY)
            local real duration

            if level > 0 then
                set duration = GetDuration(source, level)

                call UnitAddAbilityTimed(source, REDUCTION, duration, 1, true)
                call AddUnitBonusTimed(source, BONUS_MANA_REGEN, GetManaRegen(level), duration)
                call AddUnitBonusTimed(source, BONUS_HEALTH_REGEN, GetHealthRegen(level), duration)
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
            if Damage.amount > 0 and GetUnitAbilityLevel(Damage.target.unit, BUFF) > 0 then
                set Damage.amount = Damage.amount * (1 - GetDamageReduction(GetUnitAbilityLevel(Damage.target.unit, ABILITY)))
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SPELL_EFFECT, function thistype.onSpell)
        endmethod
    endstruct
endlibrary