library BulletTime requires RegisterPlayerUnitEvent, DamageInterface, NewBonus, Periodic, Spell
    /* ---------------------- Bullet Time v1.3 by Chopinski --------------------- */
    // Credits:
    //     Blizzard        - Icon
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
    private struct BulletTime extends extends Ability
        private unit unit
        private real bonus

        method destroy takes nothing returns nothing
            call AddUnitBonus(unit, BONUS_ATTACK_SPEED, -bonus)
            call deallocate()

            set unit = null
        endmethod

        private method onTooltip takes unit source, integer level, ability spell returns string
            return "Every attack increases the fire rate of |cffffcc00Tychus|r mini-gun by |cffffcc00" + N2S(GetBonus(level) * 100, 0) + "%|r, stacking up to |cffffcc00" + N2S(GetMaxBonus(level) * 100, 0) + "%|r bonus |cffffcc00Attack Speed|r. The bonus lasts for |cffffcc00" + N2S(GetDuration(level), 1) + "|r seconds after |cffffcc00Tychus|r stops attacking."
        endmethod

        private static method onDamage takes nothing returns nothing
            local real amount
            local thistype this
            local integer level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if level > 0 and Damage.isEnemy then
                set amount = GetBonus(level)
                set this = GetTimerInstance(Damage.source.id)

                if this == 0 then
                    set this = thistype.allocate()
                    set unit = Damage.source.unit
                    set bonus = 0
                endif

                if bonus + amount <= GetMaxBonus(level) then
                    set bonus = bonus + amount
                    call AddUnitBonus(unit, BONUS_ATTACK_SPEED, amount)
                endif

                call StartTimer(GetDuration(level), false, this, Damage.source.id)
            endif
        endmethod

        private static method onLevel takes nothing returns nothing
            local unit source = GetTriggerUnit()

            if GetLevel(GetHeroLevel(source)) then
                call IncUnitAbilityLevel(source, ABILITY)
            endif

            set source = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endlibrary