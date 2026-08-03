scope BootsOfAssassins
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetBonusPerLevel takes nothing returns integer
        return 2
    endfunction

    private constant function GetBonusDamage takes nothing returns real
        return 0.15
    endfunction
    
    private constant function GetBonusMovementSpeed takes nothing returns real
        return 0.2
    endfunction

    private constant function GetBonusAttackSpeed takes nothing returns real
        return 0.2
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct BootsOfAssassins extends Item
        static constant integer code = 'I00V'
        static constant integer buff = 'B001'
        static constant integer ability = 'A005'

        // Attributes
        real damage = 10
        real evasion = 0.15
        real attackSpeed = 0.1
        real movementSpeed = 35

        private unit unit

        method destroy takes nothing returns nothing
            call SetUnitPathing(unit, true)
            call deallocate()

            set unit = null
        endmethod

        private method onPeriod takes nothing returns boolean
            return GetUnitAbilityLevel(unit, buff) > 0
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.allocate(0)
            
            set unit = Spell.source.unit

            call SetUnitPathing(unit, false)
            call StartTimer(1, true, this, 0)
            call LinkBonusToBuff(unit, BONUS_ATTACK_SPEED, GetBonusAttackSpeed(), buff)
            call LinkBonusToBuff(unit, BONUS_MOVEMENT_SPEED, GetUnitMoveSpeed(unit) * GetBonusMovementSpeed(), buff)
            call LinkBonusToBuff(unit, BONUS_DAMAGE, (BlzGetUnitBaseDamage(unit, 0) + GetUnitBonus(unit, BONUS_DAMAGE)) * GetBonusDamage(), buff)
        endmethod

        private static method onLevel takes nothing returns nothing
            local unit source = GetTriggerUnit()

            if UnitHasItemOfType(source, code) then
                call UnitAddStat(source, GetBonusPerLevel(), GetBonusPerLevel(), GetBonusPerLevel())
            endif
            
            set source = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterItem(allocate(code), BootsOfSpeed.code, GlovesOfHaste.code, RustySword.code, AssassinsDagger.code, 0)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endscope