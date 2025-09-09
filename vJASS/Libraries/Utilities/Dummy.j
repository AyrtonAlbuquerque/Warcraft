library Dummy requires TimerUtils, WorldBounds
    globals
        public constant integer DUMMY = 'dumi'
    endglobals
    
    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function DummyRetrieve takes player owner, real x, real y, real z, real face returns unit
        return Dummy.retrieve(owner, x, y, z, face)
    endfunction

    function DummyRecycle takes unit dummy returns nothing
        call Dummy.recycle(dummy)
    endfunction

    function DummyRecycleTimed takes unit dummy, real delay returns nothing
        call Dummy.recycleTimed(dummy, delay)
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    struct Dummy
        private static group group = CreateGroup()
        private static location location = Location(0, 0)
        private static player player = Player(PLAYER_NEUTRAL_PASSIVE)

        readonly static integer type = DUMMY

        unit unit
        timer timer

        static method recycle takes unit dummy returns nothing
            if GetUnitTypeId(dummy) == DUMMY then
                call GroupAddUnit(group, dummy)
                call SetUnitX(dummy, WorldBounds.maxX)
                call SetUnitY(dummy, WorldBounds.maxY)
                call SetUnitOwner(dummy, player, false)
                call SetUnitScale(dummy, 1, 1, 1)
                call SetUnitTimeScale(dummy, 1)
                call PauseUnit(dummy, true)
            endif
        endmethod

        static method retrieve takes player owner, real x, real y, real z, real face returns unit
            if owner == null then
                set owner = player
            endif
            
            if BlzGroupGetSize(group) > 0 then
                set bj_lastCreatedUnit = FirstOfGroup(group)

                call PauseUnit(bj_lastCreatedUnit, false)
                call GroupRemoveUnit(group, bj_lastCreatedUnit)
                call SetUnitX(bj_lastCreatedUnit, x)
                call SetUnitY(bj_lastCreatedUnit, y)
                call MoveLocation(location, x, y)
                call SetUnitFlyHeight(bj_lastCreatedUnit, z - GetLocationZ(location), 0)
                call SetUnitFacing(bj_lastCreatedUnit, face*bj_RADTODEG)
                call SetUnitOwner(bj_lastCreatedUnit, owner, false)
            else
                set bj_lastCreatedUnit = CreateUnit(owner, DUMMY, x, y, face*bj_RADTODEG)

                call MoveLocation(location, x, y)
                call SetUnitFlyHeight(bj_lastCreatedUnit, z - GetLocationZ(location), 0)
                call UnitRemoveAbility(bj_lastCreatedUnit, 'Amrf')
            endif

            return bj_lastCreatedUnit
        endmethod

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call recycle(unit)
            call ReleaseTimer(timer)
            
            set unit = null
            set timer = null

            call deallocate()
        endmethod

        static method recycleTimed takes unit dummy, real delay returns nothing
            local thistype this

            if GetUnitTypeId(dummy) != DUMMY then
                debug call BJDebugMsg("[DummyPool] Error: Trying to recycle a non dummy unit")
            else
                set this = thistype.allocate()

                set unit = dummy
                set timer = NewTimerEx(this)
                
                call TimerStart(timer, delay, false, function thistype.onExpire)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            local integer i = 0
            local unit u

            loop
                exitwhen i == 150
                    set u = CreateUnit(player, DUMMY, WorldBounds.maxX, WorldBounds.maxY, 0)

                    call PauseUnit(u, false)
                    call GroupAddUnit(group, u)
                    call UnitRemoveAbility(u, 'Amrf')
                set i = i + 1
            endloop

            set u = null
        endmethod
    endstruct
endlibrary