library ManaBurn requires DamageInterface, RegisterPlayerUnitEvent, Utilities
    /* ----------------------- Mana Burn v1.2 by Chopinski ---------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     BETABABY       - Icon
    //     Mythic         - Mana Burn Special Effect
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Mana Burn Ability
        public  constant integer ABILITY         = 'A007'
        // The raw code of the Illidan unit in the editor
        private constant integer ILLIDAN_ID      = 'E000'
        // The raw code of the Dark Illidan unit in the editor
        private constant integer DARK_ILLIDAN_ID = 'E001'
        // The GAIN_AT_LEVEL is greater than 0
        // illidan will gain Mana Burn at this level 
        private constant integer GAIN_AT_LEVEL   = 20
        // The Mana Burn model
        private constant string  MODEL           = "Abilities\\Spells\\Human\\Feedback\\SpellBreakerAttack.mdl"
        // The Mana Burn bonus model
        private constant string  BONUS_MODEL     = "ManaBurn.mdl"
        // The Mana Burn attachment point
        private constant string  ATTACH_POINT    = "origin"
    endglobals

    // The amount of mana burned in each attack
    private function GetManaBurned takes integer level returns real
        return 50. + 0.*level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct ManaBurn extends array
        static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)
            local real    mana
            local real    burn

            if Damage.isEnemy and not Damage.target.isMagicImmune and level > 0 and BlzGetUnitMaxMana(Damage.target.unit) > 0 then
                set mana = GetUnitState(Damage.target.unit, UNIT_STATE_MANA)
                set burn = GetManaBurned(level)

                if burn > mana then
                    set burn = mana
                endif

                call AddUnitMana(Damage.target.unit, -burn)
                if GetUnitManaPercent(Damage.target.unit) < 40 then
                    call DestroyEffect(AddSpecialEffectTarget(BONUS_MODEL, Damage.target.unit, ATTACH_POINT))
                    call UnitDamageTarget(Damage.source.unit, Damage.target.unit, burn, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, null)
                else
                    call DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.target.unit, ATTACH_POINT))
                    call UnitDamageTarget(Damage.source.unit, Damage.target.unit, burn, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, null)
                endif
            endif
        endmethod

        static method onLevelUp takes nothing returns nothing
            local unit u = GetTriggerUnit()
        
            if GAIN_AT_LEVEL > 0 then
                if (GetUnitTypeId(u) == ILLIDAN_ID or GetUnitTypeId(u) == DARK_ILLIDAN_ID) and GetHeroLevel(u) == GAIN_AT_LEVEL then
                    call UnitAddAbility(u, ABILITY)
                    call UnitMakeAbilityPermanent(u, true, ABILITY)
                endif
            endif
        
            set u = null
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevelUp)
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary