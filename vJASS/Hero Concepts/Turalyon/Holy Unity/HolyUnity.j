library HolyUnity requires RegisterPlayerUnitEvent
    /* ---------------------- Holy unity v1.2 by Chopinski ---------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     KelThuzad      - Icon
    /* ----------------------------------- END ---------------------------------- */
    
    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The raw code of the Holy Unity Ability
        private constant integer ABILITY       = 'A008'
        // The raw code of the Turalyon unit in the editor
        private constant integer TURALYON_ID   = 'H000'
        // The GAIN_AT_LEVEL is greater than 0
        // Turalyon will gain Holy Unity at this level 
        private constant integer GAIN_AT_LEVEL = 20
        // The Holy Unity update period
        private constant real    PERIOD        = 0.3
    endglobals

    // The Holy Unity AoE
    private function GetAoE takes unit source, integer level returns real 
        return 500. + 0.*level
    endfunction

    // The Holy Unity bonus per unit type
    private function GetBonus takes unit source, integer level returns integer 
        if IsUnitType(source, UNIT_TYPE_HERO) then
            return 5 + 0*level
        else
            return 2 + 0*level
        endif
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct HolyUnity
        static thistype array data
        static integer 		  didx  = -1
        static timer 		  timer = CreateTimer()

        unit    unit
        group   group
        player  player
        ability ability

        private method remove takes integer i returns integer
            call DestroyGroup(group)

            set unit    = null
            set group   = null
            set player  = null
            set ability = null
            set data[i] = data[didx]
            set didx 	= didx - 1

            if didx == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer  i     = 0
            local integer  bonus = 0
            local integer  level
            local unit     u
            local thistype this
    
            loop
                exitwhen i > didx
                    set this = data[i]
                    set level = GetUnitAbilityLevel(unit, ABILITY)

                    if level > 0 then
                        call GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), GetAoE(unit, level), null)
                        call GroupRemoveUnit(group, unit)
                        loop
                            set u = FirstOfGroup(group)
                            exitwhen u == null
                                if UnitAlive(u) and IsUnitAlly(u, player) then
                                    set bonus = bonus + GetBonus(u, level)
                                endif
                            call GroupRemoveUnit(group, u)
                        endloop
                        call BlzSetAbilityIntegerLevelField(ability, ABILITY_ILF_STRENGTH_BONUS_ISTR, level - 1, bonus)
                        call IncUnitAbilityLevel(unit, ABILITY)
                        call DecUnitAbilityLevel(unit, ABILITY)
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onLevelUp takes nothing returns nothing
            local unit u = GetTriggerUnit()
            local thistype this
        
            if GAIN_AT_LEVEL > 0 then
                if GetUnitTypeId(u) == TURALYON_ID and GetHeroLevel(u) == GAIN_AT_LEVEL then
                    set this   = thistype.allocate()
                    set unit   = u
                    set group  = CreateGroup()
                    set player = GetOwningPlayer(u)
                    set didx   = didx + 1
                    set data[didx] = this

                    call UnitAddAbility(u, ABILITY)
                    call UnitMakeAbilityPermanent(u, true, ABILITY)
                    set ability = BlzGetUnitAbility(u, ABILITY)

                    if didx == 0 then
                        call TimerStart(timer, PERIOD, true, function thistype.onPeriod)
                    endif
                endif
            endif
        
            set u = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function thistype.onLevelUp)
        endmethod
    endstruct
endlibrary