library OrbWalking requires RegisterPlayerUnitEvent, Utilities, WorldBounds optional Missiles optional Indexer
    /* ----------------------------------------------------------------------------------------- */
    /*                                       Configuration                                       */
    /* ----------------------------------------------------------------------------------------- */
    private function UnitFilter takes unit u returns boolean
        return IsUnitType(u, UNIT_TYPE_HERO)
    endfunction
    
    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private struct OrbWalking
        private static method onOrder takes nothing returns nothing
            local unit source = GetOrderedUnit()
            local string order = OrderId2String(GetIssuedOrderId())
            local unit target
            local player owner
            local real range
            local group g
            local unit u

            if order == "smart" or order == "attack" and UnitFilter(source) then
                set target = GetOrderTargetUnit()
                set owner = GetOwningPlayer(source)
                set range = BlzGetUnitWeaponRealField(source, UNIT_WEAPON_RF_ATTACK_RANGE, 0)

                if (order == "smart" or order == "attack") and IsUnitEnemy(target, owner) and IsUnitInRange(source, target, range) then
                    call BlzSetUnitWeaponRealField(source, UNIT_WEAPON_RF_ATTACK_DAMAGE_POINT, 0, 0)
                    call BlzSetUnitFacingEx(source, AngleBetweenCoordinates(GetUnitX(source), GetUnitY(source), GetUnitX(target), GetUnitY(target))*bj_RADTODEG)
                elseif order == "attack" and target == null then
                    set g = CreateGroup()
                    
                    call GroupEnumUnitsInRange(g, GetUnitX(source), GetUnitY(source), range + 50, null)

                    loop
                        set u = FirstOfGroup(g)
                        exitwhen u == null
                            if UnitAlive(u) and IsUnitEnemy(u, owner) and IsUnitInRange(source, u, range) and not BlzIsUnitInvulnerable(u) then
                                call BlzSetUnitWeaponRealField(source, UNIT_WEAPON_RF_ATTACK_DAMAGE_POINT, 0, 0)
                                call BlzSetUnitFacingEx(source, AngleBetweenCoordinates(GetUnitX(source), GetUnitY(source), GetUnitX(u), GetUnitY(u))*bj_RADTODEG)
                                exitwhen true
                            endif
                        call GroupRemoveUnit(g, u)
                    endloop

                    call DestroyGroup(g)
                endif
            endif

            set u = null
            set g = null
            set owner = null
            set source = null
            set target = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, function thistype.onOrder)
        endmethod
    endstruct
endlibrary
