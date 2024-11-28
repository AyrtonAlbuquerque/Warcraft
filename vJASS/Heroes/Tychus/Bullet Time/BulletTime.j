library BulletTime requires RegisterPlayerUnitEvent, DamageInterface, NewBonusUtils, TimerUtils
    /* ---------------------- Bullet Time v1.2 by Chopinski --------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Vexorian        - TimerUtils
    //     Magtheridon96   - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Bullet Time ability
        private constant integer ABILITY = 'A000'
    endglobals

    // The Bullet Time duration after no attacks.
    private function GetDuration takes integer level returns real
        return 5. + 0.*level
    endfunction

    // The Bullet Time Attack Speed bonus per attack per level
    private function GetBonus takes integer level returns real
        return 0.1 + 0.*level
    endfunction

    // The Bullet Time Max bonus per level. Real(1. => 100%)
    private function GetMaxBonus takes integer level returns real
        return 1.*level
    endfunction

    // The Bullet Time level up base on hero level
    private function GetLevel takes integer level returns boolean
        return level == 5 or level == 10 or level == 15
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct BulletTime
        static thistype array array

        timer   timer
        unit    unit
        real    bonus
        integer i

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call AddUnitBonus(unit, BONUS_ATTACK_SPEED, -bonus)
            call ReleaseTimer(timer)
            call deallocate()

            set array[i] = 0
            set timer    = null
            set unit     = null
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer  level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)
            local real     amount
            local thistype this

            if level > 0 and Damage.isEnemy then
                set amount = GetBonus(level)

                if array[Damage.source.id] != 0 then
                    set this = array[Damage.source.id]
                else
                    set this     = thistype.allocate()
                    set timer    = NewTimerEx(this)
                    set unit     = Damage.source.unit
                    set bonus    = 0.
                    set i        = Damage.source.id
                    set array[i] = this
                endif

                if bonus + amount <= GetMaxBonus(level) then
                    set bonus = bonus + amount
                    call AddUnitBonus(unit, BONUS_ATTACK_SPEED, amount)
                endif

                call TimerStart(timer, GetDuration(level), false, function thistype.onExpire)
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
            call RegisterAttackDamageEvent(function thistype.onDamage)
        endmethod
    endstruct
endlibrary