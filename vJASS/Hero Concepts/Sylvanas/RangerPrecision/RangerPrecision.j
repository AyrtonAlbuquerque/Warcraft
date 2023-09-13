library RangerPrecision requires DamageInterface, RegisterPlayerUnitEvent, NewBonusUtils
    /* ------------------- Ranger Precision v1.2 by Chopinski ------------------- */
    // Credits:
    //     Magtheridon96 - RegisterPlayerUnitEvent
    //     The Panda     - Dark Bow icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Ranger Precision ability
        public  constant integer ABILITY                = 'A00M'
        // The raw code of the Withering Fire Normal Ability
        private constant integer WITHERING_FIRE_NORMAL  = 'A00S'
        // The raw code of the Withering Fire Cursed Ability
        private constant integer WITHERING_FIRE_CURSED  = 'A00R'
        // The bonus type gained
        private constant integer BONUS_TYPE             = BONUS_AGILITY
    endglobals

    // The bonus duration
    private function GetBonusDuration takes integer level returns real
        return 10. + 0*level
    endfunction

    // The amount of agility gained
    private function GetBonusAmount takes integer level returns integer
        return 2 + 0*level
    endfunction

    // The attack count
    private function GetAttackCount takes integer level returns integer
        return 5 - level
    endfunction

    // The auto level up levels
    private function GetLevel takes integer level returns boolean
        return level == 5 or level == 10 or level == 15 or level == 20
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    struct RangerPrecision extends array
        private static integer array count
        readonly static boolean array enabled

        static method enable takes unit u, boolean flag returns nothing
            set enabled[GetUnitUserData(u)] = flag           
        endmethod

        private static method onDamage takes nothing returns nothing
            local integer level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if level > 0 and Damage.target.isHero then
                call AddUnitBonusTimed(Damage.source.unit, BONUS_TYPE, GetBonusAmount(level), GetBonusDuration(level))
            endif
        endmethod

        private static method onDeath takes nothing returns nothing
            local unit killer = GetKillingUnit()
            local integer level = GetUnitAbilityLevel(killer, ABILITY)

            if level > 0 then
                call AddUnitBonusTimed(killer, BONUS_TYPE, GetBonusAmount(level), GetBonusDuration(level))
            endif

            set killer = null
        endmethod   

        private static method onAttack takes nothing returns nothing
            local unit source = GetAttacker()
            local integer level = GetUnitAbilityLevel(source, ABILITY)
            local integer attacks
            local integer id

            if level > 0 then
                set id = GetUnitUserData(source)
                set attacks = GetAttackCount(level)

                if attacks >= 1 then
                    set count[id] = count[id] + 1

                    if count[id] == attacks then
                        if enabled[id] then
                            call UnitRemoveAbility(source, WITHERING_FIRE_NORMAL)
                            call UnitAddAbility(source, WITHERING_FIRE_CURSED)
                        else
                            call UnitRemoveAbility(source, WITHERING_FIRE_CURSED)
                            call UnitAddAbility(source, WITHERING_FIRE_NORMAL)
                        endif
                    elseif count[id] > attacks then
                        set count[id] = 0
                        call UnitRemoveAbility(source, WITHERING_FIRE_NORMAL)
                        call UnitRemoveAbility(source, WITHERING_FIRE_CURSED)
                    endif
                else
                    if enabled[id] then
                        call UnitRemoveAbility(source, WITHERING_FIRE_NORMAL)
                        call UnitAddAbility(source, WITHERING_FIRE_CURSED)
                    else
                        call UnitRemoveAbility(source, WITHERING_FIRE_CURSED)
                        call UnitAddAbility(source, WITHERING_FIRE_NORMAL)
                    endif
                endif
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

        private static method onInit takes nothing returns nothing
            call RegisterAttackDamageEvent(function thistype.onDamage)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function thistype.onAttack)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevel)
        endmethod
    endstruct
endlibrary