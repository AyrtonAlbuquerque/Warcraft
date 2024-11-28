scope Courier
    struct Deliver
        readonly static integer ability = 'A027'
        readonly static timer timer = CreateTimer()
        readonly static integer key = -1
        readonly static thistype array array
        readonly static thistype array struct
        readonly static boolean array active

        readonly unit unit
        readonly unit hero
        readonly item item
        readonly integer id
        readonly real x
        readonly real y

        private method remove takes integer i returns integer
            if active[id] then
                call IssuePointOrder(unit, "move", x, y)
            endif

            set unit = null
            set hero = null
            set item = null
            set array[i] = array[key]
            set key = key - 1
            set active[id] = false
            set struct[id] = 0

            if key == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer  i = 0
            local integer  j
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if active[id] then
                        set j = 0
                        loop
                            exitwhen UnitInventoryCount(hero) == 6 or UnitInventoryCount(unit) == 0 or j == 6 or UnitHasItem(unit, item)
                                set item = UnitItemInSlot(unit, j)
                            set j = j + 1
                        endloop

                        if item != null and UnitInventoryCount(hero) < 6 and UnitInventoryCount(unit) > 0 then
                            call UnitDropItemTarget(unit, item, hero)
                        else
                            set i = remove(i)
                        endif
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        private static method onCast takes nothing returns nothing
            local thistype this

            if struct[Spell.source.id] == 0 then
                set this = thistype.allocate()
                set hero = Hero.player[GetPlayerId(Spell.source.player)]
                set unit = Spell.source.unit
                set item = UnitItemInSlot(Spell.source.unit, 0)
                set id = Spell.source.id
                set x = Spell.source.x
                set y = Spell.source.y
                set struct[id] = this
                set key = key + 1
                set array[key] = this
                set active[id] = true

                if key == 0 then
                    call TimerStart(timer, 0.1, true, function thistype.onPeriod)
                endif
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