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

        private timer timer
        private unit unit

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call SetUnitPathing(unit, true)
            call AddUnitBonus(unit, BONUS_ATTACK_SPEED, -GetBonusAttackSpeed())
            call ReleaseTimer(timer)

            set timer = null
            set unit = null

            call super.destroy()
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this = thistype.new()
            
            set timer = NewTimerEx(this)
            set unit = Spell.source.unit

            call SetUnitPathing(unit, false)
            call UnitAddAbilityTimed(unit, buff, GetDuration(), 1, true)
            call AddUnitBonus(unit, BONUS_ATTACK_SPEED, GetBonusAttackSpeed())
            call UnitAddMoveSpeedBonus(unit, GetBonusMovementSpeed(), 0, GetDuration())
            call TimerStart(timer, GetDuration(), false, function thistype.onPeriod)
        endmethod

        private static method onLevel takes nothing returns nothing
            local unit source = GetTriggerUnit()

            if GetHeroLevel(source) == GetLevel() and UnitHasItemOfType(source, code) then
                call UnitAddStat(source, GetBonusStats(), GetBonusStats(), GetBonusStats())
            endif
            
            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, BootsOfSpeed.code, GlovesOfHaste.code, GlovesOfHaste.code, AssassinsDagger.code, 0)
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endscope