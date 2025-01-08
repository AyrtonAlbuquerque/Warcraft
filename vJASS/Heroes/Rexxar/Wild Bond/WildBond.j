library WildBond requires RegisterPlayerUnitEvent, Periodic, Indexer, NewBonus, Ability
    /* ----------------------- Wild Bond v1.1 by Chopinski ---------------------- */
    // Credits:
    //     Nyx-Studio      - Icon
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     Vexorian       - TimerUtils
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Wild Bond Ability
        private constant integer ABILITY       = 'A006'
        // The raw code of the Rexxar unit in the editor
        private constant integer REXXAR_ID     = 'O000'
        // The GAIN_AT_LEVEL is greater than 0
        // Rexxar will gain Wild Bond at this level 
        private constant integer GAIN_AT_LEVEL = 20
        // The updating period
        private constant real    PERIOD        = 1.
    endglobals

    // The bonus damage per unit alive
    private function GetBonusDamage takes integer level returns real
        return 20.*level
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct WildBond extends Ability
        private unit unit
        private real bonus
        private group group
        private player player
        
        method destroy takes nothing returns nothing
            call DestroyGroup(group)
            call deallocate()
            
            set unit = null
            set group = null
            set player  = null
        endmethod

        method update takes nothing returns nothing
            local unit u

            set bonus = 0

            call GroupEnumUnitsOfPlayer(group, player, null)

            loop
                set u = FirstOfGroup(group)
                exitwhen u == null
                    if UnitAlive(u) and GetUnitAbilityLevel(u, 'Aloc') == 0 and not IsUnitType(u, UNIT_TYPE_HERO) and not IsUnitType(u, UNIT_TYPE_STRUCTURE) then
                        set bonus = bonus + GetBonusDamage(GetUnitAbilityLevel(unit, ABILITY))
                    endif
                call GroupRemoveUnit(group, u)
            endloop

            call AddUnitBonus(unit, BONUS_DAMAGE, bonus)
        endmethod

        static method create takes unit source returns thistype
            local integer id = GetUnitUserData(source)
            local thistype this

            if not HasStartedTimer(id) then
                set this = thistype.allocate()
                set unit = source
                set group = CreateGroup()
                set player = GetOwningPlayer(source)

                call update()
                call StartTimer(PERIOD, true, this, id)
            endif

            return this
        endmethod

        private method onPeriod takes nothing returns boolean
            if GetUnitAbilityLevel(unit, ABILITY) > 0 then
                call AddUnitBonus(unit, BONUS_DAMAGE, -bonus)
                call update()

                return true
            endif

            return false
        endmethod

        private method onLearn takes unit source, integer skill, integer level returns nothing
            call create(source)
        endmethod

        private static method onLevelUp takes nothing returns nothing
            local unit u = GetTriggerUnit()
        
            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(u) == REXXAR_ID and GetHeroLevel(u) == GAIN_AT_LEVEL then
                    call UnitAddAbility(u, ABILITY)
                    call UnitMakeAbilityPermanent(u, true, ABILITY)
                    call create(u)
                endif
            endif
        
            set u = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpell(thistype.allocate(), ABILITY)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevelUp)
        endmethod
    endstruct
endlibrary