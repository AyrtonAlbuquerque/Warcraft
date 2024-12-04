scope BerserkerBoots
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private constant function GetLevel takes nothing returns integer
        return 15
    endfunction

    private constant function GetBonusStats takes nothing returns integer
        return 25
    endfunction

    private constant function GetBonusMovementSpeed takes nothing returns real
        return 0.2
    endfunction

    private constant function GetBonusAttackSpeed takes nothing returns real
        return 0.2
    endfunction

    private constant function GetDuration takes nothing returns real
        return 5.
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                            Item                                           */
    /* ----------------------------------------------------------------------------------------- */
    struct BerserkerBoots extends Item
        static constant integer code = 'I020'
        static constant integer ability = 'A028'
        static constant integer buff = 'A04M'

        // Attributes
        real damage = 10
        real attackSpeed = 0.1
        real evasionChance = 15
        real movementSpeed = 35

        private unit unit

        method destroy takes nothing returns nothing
            call SetUnitPathing(unit, true)
            call super.destroy()

            set unit = null
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.new()
            
            set unit = Spell.source.unit

            call SetUnitPathing(unit, false)
            call StartTimer(GetDuration(), false, this, -1)
            call UnitAddAbilityTimed(unit, buff, GetDuration(), 1, true)
            call AddUnitBonusTimed(unit, BONUS_ATTACK_SPEED, GetBonusAttackSpeed(), GetDuration())
            call UnitAddMoveSpeedBonus(unit, GetBonusMovementSpeed(), 0, GetDuration())
        endmethod

        private static method onLevel takes nothing returns nothing
            local unit source = GetTriggerUnit()

            if GetHeroLevel(source) == GetLevel() and UnitHasItemOfType(source, code) then
                call UnitAddStat(source, GetBonusStats(), GetBonusStats(), GetBonusStats())
            endif
            
            set source = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, BootsOfSpeed.code, GlovesOfHaste.code, GlovesOfHaste.code, AssassinsDagger.code, 0)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endscope