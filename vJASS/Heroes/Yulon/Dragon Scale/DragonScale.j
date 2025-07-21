library DragonScale requires RegisterPlayerUnitEvent, DamageInterface, Ability optional NewBonus
    /* --------------------- Dragon Scale v1.2 by Chopinski --------------------- */
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
    private function GetBonus takes unit source, integer level returns real
        static if LIBRARY_NewBonus then
            return 25.*level + (0.05 * level) * GetUnitBonus(source, BONUS_SPELL_POWER)
        else
            return 25.*level
        endif
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
    private struct DragonScale extends Spell
        private static real array energy

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "|cffffcc00Yu'lon|r dragon scales reduced all damage taken by |cffffcc00" + N2S(GetDamageReduction(level) * 100, 0) + "%|r. All damage reduced is stored as |cff00ffffMagic|r energy. Whenever |cffffcc00Yu'lon|r deals |cff00ffffMagic|r damage, a portion of the energy stored is used to increase the damage dealt. Maximum |cff00ffff" + N2S(GetBonus(source, level), 0) + " Magic|r damage bonus per damage instance.\n\nEnergy Stored: |cff00ffff" + N2S(energy[GetUnitUserData(source)], 0) + "|r"
        endmethod

        private static method onSpellDamage takes nothing returns nothing
            local real amount
            local integer level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if Damage.amount > 0 and level > 0 and Damage.isEnemy and energy[Damage.source.id] > 0 then
                set amount = GetBonus(Damage.source.unit, level)
                
                if amount >= energy[Damage.source.id] then
                    set amount = energy[Damage.source.id]
                endif
                
                set Damage.amount = Damage.amount + amount
                set energy[Damage.source.id] = energy[Damage.source.id] - amount
                
                call DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.target.unit, ATTACH_POINT))
            endif
        endmethod

        private static method onDamage takes nothing returns nothing
            local real amount
            local integer level = GetUnitAbilityLevel(Damage.target.unit, ABILITY)

            if Damage.amount > 0 and level > 0 and Damage.isEnemy then
                set amount = Damage.amount * GetDamageReduction(level)
                set Damage.amount = Damage.amount - amount
                set energy[Damage.target.id] = energy[Damage.target.id] + amount
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
            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterSpellDamageEvent(function thistype.onSpellDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endlibrary