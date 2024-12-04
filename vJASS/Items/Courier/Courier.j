scope Courier
    struct Deliver
        readonly static integer ability = 'A027'
        readonly static boolean array active

        readonly unit unit
        readonly unit hero
        readonly item item
        readonly integer id
        readonly real x
        readonly real y

        method destroy takes nothing returns nothing
            if active[id] then
                call IssuePointOrder(unit, "move", x, y)
            endif

            set unit = null
            set hero = null
            set item = null
            set active[id] = false

            call deallocate()
        endmethod

        private method onPeriod takes nothing returns boolean
            local integer  i = 0

            if active[id] then
                loop
                    exitwhen UnitInventoryCount(hero) == 6 or UnitInventoryCount(unit) == 0 or i == 6 or UnitHasItem(unit, item)
                        set item = UnitItemInSlot(unit, i)
                    set i = i + 1
                endloop

                if item != null and UnitInventoryCount(hero) < 6 and UnitInventoryCount(unit) > 0 then
                    call UnitDropItemTarget(unit, item, hero)
                else
                    return false
                endif
            endif

            return active[id]
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this

            if not HasStartedTimer(Spell.source.id) then
                set this = thistype.allocate()
                set hero = Hero.player[GetPlayerId(Spell.source.player)]
                set unit = Spell.source.unit
                set item = UnitItemInSlot(Spell.source.unit, 0)
                set id = Spell.source.id
                set x = Spell.source.x
                set y = Spell.source.y
                set active[id] = true

                call StartTimer(0.1, true, this, Spell.source.id)
            endif
        endmethod

        private static method onOrder takes nothing returns nothing
            local unit source = GetOrderedUnit()
            local string order
            local integer i

            if GetUnitTypeId(source) == Courier.unittype then
                set order = OrderId2String(GetIssuedOrderId())
                set i = GetUnitUserData(source)

                if Deliver.active[i] and (order == "smart" or order == "stop" or order == "holdposition" or order == "move") then
                    set Deliver.active[i] = false
                endif
            endif

            set source = null
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            call RegisterSpellEffectEvent(ability, function thistype.onCast)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function thistype.onOrder)
        endmethod
    endstruct
    
    struct Courier extends Item
        static constant integer code = 'I01Z'
        readonly static integer unittype = 'n00J'

        private method onPickup takes unit u, item i returns nothing
            local player p = GetOwningPlayer(u)
            local group g = GetUnitsOfPlayerAndTypeId(p, unittype)

            if CountUnitsInGroup(g) == 0 then
                call CreateUnit(p, unittype, GetUnitX(u), GetUnitY(u), 0)
            endif

            call DestroyGroup(g)

            set g = null
            set p = null
        endmethod

        private static method onInit takes nothing returns nothing
            call thistype.allocate(code, 0, 0, 0, 0, 0)
        endmethod
    endstruct
endscope