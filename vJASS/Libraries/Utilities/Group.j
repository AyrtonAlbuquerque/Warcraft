library Group requires Modules, Indexer optional Table optional Item
    /* -------------------------------- Group v1.0 by Chopinski -------------------------------- */
    globals
        // Use table or arrays. table is slower but allows for any number of groups
        private constant boolean USE_TABLE = false

        // If USE_TABLE is false, this is the maximum number of units that can be stored in a group.
        // This also limits the amount of groups that can be created to 8192/MAX_UNITS
        private constant integer MAX_UNITS = 128

        // Dont touch
        private constant integer OP_LT = 0
        private constant integer OP_LE = 1
        private constant integer OP_GT = 2
        private constant integer OP_GE = 3
        private constant integer OP_EQ = 4
        private constant integer OP_NE = 5
    endglobals

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function interface GroupCallback takes integer instance, unit u returns nothing

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private struct Unit
        private static thistype array array

        private real x
        private real y
        private real id
        private real mp
        private real hp
        private real lvl
        private real amr
        private real spd
        private real dmg
        private real agi
        private real str
        private real int
        private real dist
        private real owner
        private boolean allocated
        private real hpPercentage
        private real mpPercentage

        readonly unit unit

        method operator type takes nothing returns real
            if id <= 0 then
                set id = I2R(GetUnitTypeId(unit))
            endif

            return id
        endmethod

        method operator hero takes nothing returns real
            if IsUnitType(unit, UNIT_TYPE_HERO) then
                return 0.
            else
                return 1.
            endif
        endmethod

        method operator mana takes nothing returns real
            if mp <= -1. then
                set mp = GetUnitState(unit, UNIT_STATE_MANA)
            endif

            return mp
        endmethod

        method operator health takes nothing returns real
            if hp <= -1. then
                set hp = GetUnitState(unit, UNIT_STATE_LIFE)
            endif

            return hp
        endmethod

        method operator level takes nothing returns real
            if lvl <= -1. then
                if IsUnitType(unit, UNIT_TYPE_HERO) then
                    set lvl = I2R(GetHeroLevel(unit))
                else
                    set lvl = I2R(GetUnitLevel(unit))
                endif
            endif

            return lvl
        endmethod

        method operator armor takes nothing returns real
            if amr <= -1. then
                set amr = BlzGetUnitArmor(unit)
            endif

            return amr
        endmethod

        method operator speed takes nothing returns real
            if spd <= -1. then
                set spd = GetUnitMoveSpeed(unit)
            endif

            return spd
        endmethod

        method operator damage takes nothing returns real
            if dmg <= -1. then
                set dmg = I2R(BlzGetUnitBaseDamage(unit, 0))
            endif

            return dmg
        endmethod

        method operator player takes nothing returns real
            if owner <= -1. then
                set owner = I2R(GetPlayerId(GetOwningPlayer(unit)))
            endif

            return owner
        endmethod

        method operator agility takes nothing returns real
            if agi <= -1. then
                set agi = I2R(GetHeroAgi(unit, true))
            endif

            return agi
        endmethod

        method operator strength takes nothing returns real
            if str <= -1. then
                set str = I2R(GetHeroStr(unit, true))
            endif

            return str
        endmethod

        method operator intelligence takes nothing returns real
            if int <= -1. then
                set int = I2R(GetHeroInt(unit, true))
            endif

            return int
        endmethod

        method operator distance takes nothing returns real
            if dist <= -1. then
                set dist = SquareRoot((GetUnitX(unit) - x) * (GetUnitX(unit) - x) + (GetUnitY(unit) - y) * (GetUnitY(unit) - y))
            endif

            return dist
        endmethod

        method operator healthPercentage takes nothing returns real
            if hpPercentage <= -1. then
                set hpPercentage = GetUnitLifePercent(unit)
            endif

            return hpPercentage
        endmethod

        method operator manaPercentage takes nothing returns real
            if mpPercentage <= -1. then
                set mpPercentage = GetUnitManaPercent(unit)
            endif

            return mpPercentage
        endmethod

        method field takes OrderBy order returns real
            if order == OrderBy.type then
                return type
            elseif order == OrderBy.hero then
                return hero
            elseif order == OrderBy.mana then
                return mana
            elseif order == OrderBy.level then
                return level
            elseif order == OrderBy.armor then
                return armor
            elseif order == OrderBy.speed then
                return speed
            elseif order == OrderBy.damage then
                return damage
            elseif order == OrderBy.health then
                return health
            elseif order == OrderBy.player then
                return player
            elseif order == OrderBy.agility then
                return agility
            elseif order == OrderBy.distance then
                return distance
            elseif order == OrderBy.strength then
                return strength
            elseif order == OrderBy.intelligence then
                return intelligence
            elseif order == OrderBy.healthPercentage then
                return healthPercentage
            elseif order == OrderBy.manaPercentage then
                return manaPercentage
            endif

            return 0.
        endmethod

        method destroy takes nothing returns nothing
            if allocated then
                set array[GetUnitUserData(unit)] = 0
                set unit = null
                set allocated = false

                call deallocate()
            endif
        endmethod

        static method property takes unit u, integer p, real x, real y returns real
            local thistype this = array[GetUnitUserData(u)]

            if this != 0 then
                if p == Property.health then
                    return health
                elseif p == Property.mana then
                    return mana
                elseif p == Property.level then
                    return level
                elseif p == Property.armor then
                    return armor
                elseif p == Property.speed then
                    return speed
                elseif p == Property.damage then
                    return damage
                elseif p == Property.player then
                    return player
                elseif p == Property.agility then
                    return agility
                elseif p == Property.strength then
                    return strength
                elseif p == Property.intelligence then
                    return intelligence
                elseif p == Property.distance then
                    return distance
                elseif p == Property.healthPercentage then
                    return healthPercentage
                elseif p == Property.manaPercentage then
                    return manaPercentage
                elseif p == Property.type then
                    return type
                elseif p == Property.hero then
                    return hero
                endif
            else
                if p == Property.health then
                    return GetWidgetLife(u)
                elseif p == Property.mana then
                    return GetUnitState(u, UNIT_STATE_MANA)
                elseif p == Property.level then
                    if IsUnitType(u, UNIT_TYPE_HERO) then
                        return I2R(GetHeroLevel(u))
                    else
                        return I2R(GetUnitLevel(u))
                    endif
                elseif p == Property.armor then
                    return BlzGetUnitArmor(u)
                elseif p == Property.speed then
                    return GetUnitMoveSpeed(u)
                elseif p == Property.damage then
                    return I2R(BlzGetUnitBaseDamage(u, 0))
                elseif p == Property.player then
                    return I2R(GetPlayerId(GetOwningPlayer(u)))
                elseif p == Property.agility then
                    return I2R(GetHeroAgi(u, true))
                elseif p == Property.strength then
                    return I2R(GetHeroStr(u, true))
                elseif p == Property.intelligence then
                    return I2R(GetHeroInt(u, true))
                elseif p == Property.distance then
                    return SquareRoot((GetUnitX(u) - x) * (GetUnitX(u) - x) + (GetUnitY(u) - y) * (GetUnitY(u) - y))
                elseif p == Property.healthPercentage then
                    return GetUnitLifePercent(u)
                elseif p == Property.manaPercentage then
                    return GetUnitManaPercent(u)
                elseif p == Property.type then
                    return I2R(GetUnitTypeId(u))
                elseif p == Property.hero then
                    if IsUnitType(u, UNIT_TYPE_HERO) then
                        return 0.
                    else
                        return 1.
                    endif
                endif
            endif

            return 0.
        endmethod

        static method create takes unit u, real x, real y returns thistype
            local thistype this = thistype.allocate()

            set .x = x
            set .y = y
            set id = 0
            set mp = -1.
            set hp = -1.
            set lvl = -1.
            set amr = -1.
            set spd = -1.
            set dmg = -1.
            set agi = -1.
            set str = -1.
            set int = -1.
            set dist = -1.
            set hpPercentage = -1.
            set mpPercentage = -1.
            set owner = -1.
            set unit = u
            set allocated = true
            set array[GetUnitUserData(u)] = this

            return this
        endmethod
    endstruct

    private struct Filter
        readonly integer buff
        readonly integer item
        readonly integer type
        readonly player player
        readonly boolean negate
        readonly boolean orLogic
        readonly unittype unittype
        readonly integer property
        readonly integer operation
        readonly real value

        method destroy takes nothing returns nothing
            set player = null
            set unittype = null

            call deallocate()
        endmethod

        static method create takes player p, unittype t, integer i, integer b, integer id, integer prop, real value, integer op, boolean negate, boolean orLogic returns Filter
            local thistype this = thistype.allocate()

            set item = i
            set buff = b
            set type = id
            set player = p
            set unittype = t
            set property = prop
            set operation = op
            set .value = value
            set .negate = negate
            set .orLogic = orLogic

            return this
        endmethod
    endstruct

    struct OrderBy
        readonly static thistype type = 1
        readonly static thistype hero = 2
        readonly static thistype mana = 4
        readonly static thistype level = 8 
        readonly static thistype armor = 16
        readonly static thistype speed = 32
        readonly static thistype damage = 64
        readonly static thistype health = 128
        readonly static thistype player = 256
        readonly static thistype agility = 512
        readonly static thistype distance = 1024
        readonly static thistype strength = 2048
        readonly static thistype intelligence = 4096
        readonly static thistype healthPercentage = 8192
        readonly static thistype manaPercentage = 16384
    endstruct

    struct Property
        readonly static thistype type = 1
        readonly static thistype hero = 2
        readonly static thistype mana = 4
        readonly static thistype level = 8
        readonly static thistype armor = 16
        readonly static thistype speed = 32
        readonly static thistype damage = 64
        readonly static thistype health = 128
        readonly static thistype player = 256
        readonly static thistype agility = 512
        readonly static thistype distance = 1024
        readonly static thistype strength = 2048
        readonly static thistype intelligence = 4096
        readonly static thistype healthPercentage = 8192
        readonly static thistype manaPercentage = 16384
    endstruct

    struct Group
        private real x
        private real y
        private group group
        private integer end
        private List items
        private List buffs
        private List types
        private List ranges
        private List allies
        private List owners
        private List enemies
        private List unittype
        private integer takes
        private integer skips
        private integer count
        private boolean negate
        private boolean dead
        private boolean alive
        private boolean ordered
        private boolean orLogic
        private integer orderings
        private integer pendingProp
        private boolean pendingNegate
        private boolean pendingOrLogic
        private boolean array descends[15]

        static if USE_TABLE and LIBRARY_Table then
            private Table temp
            private Table sorted
            private Table orders
        else
            private OrderBy array orders[15]
            private Unit array temp[MAX_UNITS]
            private Unit array sorted[MAX_UNITS]
        endif

        method operator size takes nothing returns integer
            return BlzGroupGetSize(group)
        endmethod

        method destroy takes nothing returns nothing
            local integer bound = size
            local integer i = 0

            if end > bound then
                set bound = end
            endif

            static if USE_TABLE and LIBRARY_Table then
                if bound > 0 then
                    loop
                        exitwhen i == bound
                            if sorted.has(i) then
                                call Unit(sorted[i]).destroy()
                            endif
                        set i = i + 1
                    endloop
                endif

                call temp.destroy()
                call sorted.destroy()
                call orders.destroy()
            else
                if bound > 0 then
                    loop
                        exitwhen i == bound
                            if sorted[i] != 0 then
                                call sorted[i].destroy()
                                
                                set sorted[i] = 0
                            endif
                        set i = i + 1
                    endloop
                endif
            endif

            call unfilter()
            call items.destroy()
            call buffs.destroy()
            call allies.destroy()
            call owners.destroy()
            call enemies.destroy()
            call unittype.destroy()
            call types.destroy()
            call ranges.destroy()
            call DestroyGroup(group)

            set group = null

            call deallocate()
        endmethod

        method first takes nothing returns unit
            call sort()

            if end > 0 then
                static if USE_TABLE and LIBRARY_Table then
                    return Unit(sorted[0]).unit
                else
                    return sorted[0].unit
                endif
            else
                return null
            endif
        endmethod
        
        method last takes nothing returns unit
            call sort()

            if end > 0 then
                static if USE_TABLE and LIBRARY_Table then
                    return Unit(sorted[end - 1]).unit
                else
                    return sorted[end - 1].unit
                endif
            else
                return null
            endif
        endmethod

        method skip takes integer amount returns thistype
            if size <= 0 then
                call BJDebugMsg("inRange, inRect, ofPlayer or insert must be called before skipping units.")
            else
                if amount > 0 then
                    set skips = amount
                    set ordered = false
                endif
            endif

            return this
        endmethod

        method take takes integer amount returns thistype
            if size <= 0 then
                call BJDebugMsg("inRange, inRect, ofPlayer or insert must be called before taking units.")
            else
                if amount > 0 then
                    set takes = amount
                    set ordered = false
                endif
            endif

            return this
        endmethod

        method clear takes nothing returns thistype
            local integer bound = size
            local integer i = 0

            if end > bound then
                set bound = end
            endif

            static if USE_TABLE and LIBRARY_Table then
                if bound > 0 then
                    loop
                        exitwhen i == bound
                            if sorted.has(i) then
                                call Unit(sorted[i]).destroy()
                            endif
                        set i = i + 1
                    endloop
                endif

                call temp.flush()
                call sorted.flush()
                call orders.flush()
            else
                if bound > 0 then
                    loop
                        exitwhen i == bound
                            if sorted[i] != 0 then
                                call sorted[i].destroy()
                                
                                set sorted[i] = 0
                            endif
                        set i = i + 1
                    endloop
                endif
            endif

            call unfilter()
            call GroupClear(group)

            set end = 0
            set takes = 0
            set skips = 0
            set count = 0
            set orderings = 0
            set negate = false
            set dead = false
            set alive = false
            set ordered = false
            set orLogic = false
            set pendingProp = 0
            set pendingNegate = false
            set pendingOrLogic = false

            return this
        endmethod

        method insert takes unit u returns thistype
            if u != null then
                if not IsUnitInGroup(u, group) then
                    set ordered = false

                    call GroupAddUnit(group, u)
                endif
            endif

            return this
        endmethod

        method remove takes unit u returns thistype
            if u != null then
                if IsUnitInGroup(u, group) then
                    set ordered = false

                    call GroupRemoveUnit(group, u)
                endif
            endif

            return this
        endmethod

        method damage takes unit source, real amount, attacktype atktype, damagetype dmgtype, integer instance, GroupCallback callback returns thistype
            local integer i = 0
            local unit u

            call sort()

            loop
                exitwhen i == end
                    static if USE_TABLE and LIBRARY_Table then
                        set u = Unit(sorted[i]).unit
                    else
                        set u = sorted[i].unit
                    endif

                    if UnitDamageTarget(source, u, amount, false, false, atktype, dmgtype, null) and callback != 0 then
                        call callback.evaluate(instance, u)
                    endif
                set i = i + 1
            endloop

            set u = null

            return this
        endmethod

        method forEach takes integer instance, GroupCallback callback returns thistype
            local integer i = 0

            if callback != 0 then
                call sort()

                loop
                    exitwhen i == end
                        static if USE_TABLE and LIBRARY_Table then
                            call callback.evaluate(instance, Unit(sorted[i]).unit)
                        else
                            call callback.evaluate(instance, sorted[i].unit)
                        endif
                    set i = i + 1
                endloop
            endif

            return this
        endmethod

        method toGroup takes nothing returns group
            call sort()

            return group
        endmethod

        method inRect takes rect r returns thistype
            local group g = CreateGroup()

            set ordered = false

            call GroupEnumUnitsInRect(g, r, null)
            call BlzGroupAddGroupFast(g, group)
            call DestroyGroup(g)

            set g = null

            return this
        endmethod

        method inRange takes real x, real y, real radius returns thistype
            local group g = CreateGroup()

            set .x = x
            set .y = y
            set ordered = false

            call GroupEnumUnitsInRange(g, x, y, radius, null)
            call BlzGroupAddGroupFast(g, group)
            call DestroyGroup(g)

            set g = null

            return this
        endmethod

        method ofPlayer takes player p returns thistype
            local group g = CreateGroup()

            set ordered = false

            call GroupEnumUnitsOfPlayer(g, p, null)
            call BlzGroupAddGroupFast(g, group)
            call DestroyGroup(g)

            set g = null

            return this
        endmethod

        method isNot takes nothing returns thistype
            set negate = true

            return this
        endmethod

        method isOr takes nothing returns thistype
            set orLogic = true

            return this
        endmethod

        method isAlive takes nothing returns thistype
            if negate then
                set dead = true
                set negate = false
            else
                set alive = true
            endif

            set ordered = false

            return this
        endmethod

        method allyOf takes player p returns thistype
            if p != null then
                call allies.insert(Filter.create(p, null, 0, 0, 0, 0, 0, 0, negate, orLogic))
                set negate = false
                set orLogic = false
                set ordered = false
            endif

            return this
        endmethod

        method enemyOf takes player p returns thistype
            if p != null then
                call enemies.insert(Filter.create(p, null, 0, 0, 0, 0, 0, 0, negate, orLogic))
                set negate = false
                set orLogic = false
                set ordered = false
            endif

            return this
        endmethod

        method ownedBy takes player p returns thistype
            if p != null then
                call owners.insert(Filter.create(p, null, 0, 0, 0, 0, 0, 0, negate, orLogic))
                set negate = false
                set orLogic = false
                set ordered = false
            endif

            return this
        endmethod

        method ofType takes unittype t returns thistype
            if t != null then
                call unittype.insert(Filter.create(null, t, 0, 0, 0, 0, 0, 0, negate, orLogic))
                set negate = false
                set orLogic = false
                set ordered = false
            endif

            return this
        endmethod

        method hasItem takes integer itemId returns thistype
            if itemId > 0 then
                call items.insert(Filter.create(null, null, itemId, 0, 0, 0, 0, 0, negate, orLogic))
                set negate = false
                set orLogic = false
                set ordered = false
            endif

            return this
        endmethod

        method hasBuff takes integer buffId returns thistype
            if buffId > 0 then
                call buffs.insert(Filter.create(null, null, 0, buffId, 0, 0, 0, 0, negate, orLogic))
                set negate = false
                set orLogic = false
                set ordered = false
            endif

            return this
        endmethod

        method hasAbility takes integer abilityId returns thistype
            return hasBuff(abilityId)
        endmethod

        method ofTypeId takes integer typeId returns thistype
            if typeId > 0 then
                call types.insert(Filter.create(null, null, 0, 0, typeId, 0, 0, 0, negate, orLogic))
                set negate = false
                set orLogic = false
                set ordered = false
            endif

            return this
        endmethod

        method where takes Property p returns thistype
            set pendingProp = p
            set pendingNegate = negate
            set pendingOrLogic = orLogic
            set negate = false
            set orLogic = false

            return this
        endmethod

        method lessThan takes real value returns thistype
            if pendingProp > 0 then
                call ranges.insert(Filter.create(null, null, 0, 0, 0, pendingProp, value, OP_LT, pendingNegate, pendingOrLogic))
                set pendingProp = 0
                set ordered = false
            endif

            return this
        endmethod

        method lessOrEqual takes real value returns thistype
            if pendingProp > 0 then
                call ranges.insert(Filter.create(null, null, 0, 0, 0, pendingProp, value, OP_LE, pendingNegate, pendingOrLogic))
                set pendingProp = 0
                set ordered = false
            endif

            return this
        endmethod

        method greaterThan takes real value returns thistype
            if pendingProp > 0 then
                call ranges.insert(Filter.create(null, null, 0, 0, 0, pendingProp, value, OP_GT, pendingNegate, pendingOrLogic))
                set pendingProp = 0
                set ordered = false
            endif

            return this
        endmethod

        method greaterOrEqual takes real value returns thistype
            if pendingProp > 0 then
                call ranges.insert(Filter.create(null, null, 0, 0, 0, pendingProp, value, OP_GE, pendingNegate, pendingOrLogic))
                set pendingProp = 0
                set ordered = false
            endif

            return this
        endmethod

        method equal takes real value returns thistype
            if pendingProp > 0 then
                call ranges.insert(Filter.create(null, null, 0, 0, 0, pendingProp, value, OP_EQ, pendingNegate, pendingOrLogic))
                set pendingProp = 0
                set ordered = false
            endif

            return this
        endmethod

        method notEqual takes real value returns thistype
            if pendingProp > 0 then
                call ranges.insert(Filter.create(null, null, 0, 0, 0, pendingProp, value, OP_NE, pendingNegate, pendingOrLogic))
                set pendingProp = 0
                set ordered = false
            endif

            return this
        endmethod

        method orderBy takes OrderBy order returns thistype
            if negate then
                call BJDebugMsg("Only isAlive, allyOf, enemyOf, ownedBy, ofType, hasBuff, hasAbility and hasItem can be called after isNot is callled.")
            else
                if size <= 0 then
                    call BJDebugMsg("inRange, inRect, ofPlayer or insert must be called before setting an order.")
                else
                    set count = 1
                    set orders[0] = order
                    set orderings = order
                    set ordered = false
                    set descends[0] = false
                endif
            endif

            return this
        endmethod

        method thenBy takes OrderBy order returns thistype
            if negate then
                call BJDebugMsg("Only isAlive, allyOf, enemyOf, ownedBy, ofType, hasBuff, hasAbility and hasItem can be called after isNot is callled.")
            else
                if count <= 0 then
                    call BJDebugMsg("An orderBy must be specified before setting a secondary order.")
                elseif BlzBitAnd(orderings, order) != 0 then
                    call BJDebugMsg("Field is already part of the ordering chain.")
                else
                    set orderings = BlzBitOr(orderings, order)
                    set descends[count] = false
                    set orders[count] = order
                    set count = count + 1
                    set ordered = false
                endif
            endif

            return this
        endmethod

        method descending takes nothing returns thistype
            if negate then
                call BJDebugMsg("Only isAlive, allyOf, enemyOf, ownedBy, ofType, hasBuff, hasAbility and hasItem can be called after isNot is callled.")
            else
                if count <= 0 then
                    call BJDebugMsg("An orderBy must be specified before calling descending.")
                else
                    set descends[count - 1] = true
                    set ordered = false
                endif
            endif

            return this
        endmethod

        method sort takes nothing returns thistype
            local integer cap = size
            local integer i = 0
            local integer j = 0
            local integer k = 0
            local real field
            local boolean passes
            local integer newEnd
            local boolean andResult
            local boolean orResult
            local boolean hasOr
            local boolean add
            local List node
            local group g
            local unit u

            if size <= 0 or ordered then
                return this
            endif

            static if not (USE_TABLE and LIBRARY_Table) then
                if cap > MAX_UNITS then
                    set cap = MAX_UNITS

                    call BJDebugMsg("Group: size " + I2S(size) + " exceeds MAX_UNITS (" + I2S(MAX_UNITS) + "), truncating.")
                endif
            endif

            set g = CreateGroup()

            call BlzGroupAddGroupFast(group, g)

            loop
                exitwhen i == cap
                    set add = true
                    set u = BlzGroupUnitAt(g, i)

                    if alive then
                        set add = UnitAlive(u)
                    endif

                    if add and dead then
                        set add = not UnitAlive(u)
                    endif

                    if add and allies.size > 0 then
                        set node = allies.next
                        set andResult = true
                        set orResult = false
                        set hasOr = false

                        loop
                            exitwhen node == allies
                                if Filter(node.data).orLogic then
                                    set hasOr = true

                                    if Filter(node.data).negate then
                                        set orResult = orResult or not IsUnitAlly(u, Filter(node.data).player)
                                    else
                                        set orResult = orResult or IsUnitAlly(u, Filter(node.data).player)
                                    endif
                                else
                                    if Filter(node.data).negate then
                                        set andResult = andResult and not IsUnitAlly(u, Filter(node.data).player)
                                    else
                                        set andResult = andResult and IsUnitAlly(u, Filter(node.data).player)
                                    endif
                                endif
                            set node = node.next
                        endloop

                        set add = add and andResult

                        if hasOr then
                            set add = add and orResult
                        endif
                    endif

                    if add and enemies.size > 0 then
                        set node = enemies.next
                        set andResult = true
                        set orResult = false
                        set hasOr = false

                        loop
                            exitwhen node == enemies
                                if Filter(node.data).orLogic then
                                    set hasOr = true

                                    if Filter(node.data).negate then
                                        set orResult = orResult or not IsUnitEnemy(u, Filter(node.data).player)
                                    else
                                        set orResult = orResult or IsUnitEnemy(u, Filter(node.data).player)
                                    endif
                                else
                                    if Filter(node.data).negate then
                                        set andResult = andResult and not IsUnitEnemy(u, Filter(node.data).player)
                                    else
                                        set andResult = andResult and IsUnitEnemy(u, Filter(node.data).player)
                                    endif
                                endif
                            set node = node.next
                        endloop

                        set add = add and andResult

                        if hasOr then
                            set add = add and orResult
                        endif
                    endif

                    if add and owners.size > 0 then
                        set node = owners.next
                        set andResult = true
                        set orResult = false
                        set hasOr = false

                        loop
                            exitwhen node == owners
                                if Filter(node.data).orLogic then
                                    set hasOr = true

                                    if Filter(node.data).negate then
                                        set orResult = orResult or GetOwningPlayer(u) != Filter(node.data).player
                                    else
                                        set orResult = orResult or GetOwningPlayer(u) == Filter(node.data).player
                                    endif
                                else
                                    if Filter(node.data).negate then
                                        set andResult = andResult and GetOwningPlayer(u) != Filter(node.data).player
                                    else
                                        set andResult = andResult and GetOwningPlayer(u) == Filter(node.data).player
                                    endif
                                endif
                            set node = node.next
                        endloop

                        set add = add and andResult

                        if hasOr then
                            set add = add and orResult
                        endif
                    endif

                    if add and unittype.size > 0 then
                        set node = unittype.next
                        set andResult = true
                        set orResult = false
                        set hasOr = false

                        loop
                            exitwhen node == unittype
                                if Filter(node.data).orLogic then
                                    set hasOr = true

                                    if Filter(node.data).negate then
                                        set orResult = orResult or not IsUnitType(u, Filter(node.data).unittype)
                                    else
                                        set orResult = orResult or IsUnitType(u, Filter(node.data).unittype)
                                    endif
                                else
                                    if Filter(node.data).negate then
                                        set andResult = andResult and not IsUnitType(u, Filter(node.data).unittype)
                                    else
                                        set andResult = andResult and IsUnitType(u, Filter(node.data).unittype)
                                    endif
                                endif
                            set node = node.next
                        endloop

                        set add = add and andResult

                        if hasOr then
                            set add = add and orResult
                        endif
                    endif

                    if add and items.size > 0 then
                        set node = items.next
                        set andResult = true
                        set orResult = false
                        set hasOr = false

                        loop
                            exitwhen node == items
                                if Filter(node.data).orLogic then
                                    set hasOr = true

                                    if Filter(node.data).negate then
                                        static if LIBRARY_Item then
                                            set orResult = orResult or not UnitHasItemOfType(u, Filter(node.data).item)
                                        else
                                            set orResult = orResult or not UnitHasItemOfTypeBJ(u, Filter(node.data).item)
                                        endif
                                    else
                                        static if LIBRARY_Item then
                                            set orResult = orResult or UnitHasItemOfType(u, Filter(node.data).item)
                                        else
                                            set orResult = orResult or UnitHasItemOfTypeBJ(u, Filter(node.data).item)
                                        endif
                                    endif
                                else
                                    if Filter(node.data).negate then
                                        static if LIBRARY_Item then
                                            set andResult = andResult and not UnitHasItemOfType(u, Filter(node.data).item)
                                        else
                                            set andResult = andResult and not UnitHasItemOfTypeBJ(u, Filter(node.data).item)
                                        endif
                                    else
                                        static if LIBRARY_Item then
                                            set andResult = andResult and UnitHasItemOfType(u, Filter(node.data).item)
                                        else
                                            set andResult = andResult and UnitHasItemOfTypeBJ(u, Filter(node.data).item)
                                        endif
                                    endif
                                endif
                            set node = node.next
                        endloop

                        set add = add and andResult

                        if hasOr then
                            set add = add and orResult
                        endif
                    endif

                    if add and buffs.size > 0 then
                        set node = buffs.next
                        set andResult = true
                        set orResult = false
                        set hasOr = false

                        loop
                            exitwhen node == buffs
                                if Filter(node.data).orLogic then
                                    set hasOr = true

                                    if Filter(node.data).negate then
                                        set orResult = orResult or GetUnitAbilityLevel(u, Filter(node.data).buff) <= 0
                                    else
                                        set orResult = orResult or GetUnitAbilityLevel(u, Filter(node.data).buff) > 0
                                    endif
                                else
                                    if Filter(node.data).negate then
                                        set andResult = andResult and GetUnitAbilityLevel(u, Filter(node.data).buff) <= 0
                                    else
                                        set andResult = andResult and GetUnitAbilityLevel(u, Filter(node.data).buff) > 0
                                    endif
                                endif
                            set node = node.next
                        endloop

                        set add = add and andResult

                        if hasOr then
                            set add = add and orResult
                        endif
                    endif

                    if add and types.size > 0 then
                        set node = types.next
                        set andResult = true
                        set orResult = false
                        set hasOr = false

                        loop
                            exitwhen node == types
                                if Filter(node.data).orLogic then
                                    set hasOr = true

                                    if Filter(node.data).negate then
                                        set orResult = orResult or GetUnitTypeId(u) != Filter(node.data).type
                                    else
                                        set orResult = orResult or GetUnitTypeId(u) == Filter(node.data).type
                                    endif
                                else
                                    if Filter(node.data).negate then
                                        set andResult = andResult and GetUnitTypeId(u) != Filter(node.data).type
                                    else
                                        set andResult = andResult and GetUnitTypeId(u) == Filter(node.data).type
                                    endif
                                endif
                            set node = node.next
                        endloop

                        set add = add and andResult

                        if hasOr then
                            set add = add and orResult
                        endif
                    endif

                    if add and ranges.size > 0 then
                        set node = ranges.next
                        set andResult = true
                        set orResult = false
                        set hasOr = false

                        loop
                            exitwhen node == ranges
                                set passes = false
                                set field = Unit.property(u, Filter(node.data).property, x, y)

                                if Filter(node.data).operation == OP_LT then
                                    set passes = field < Filter(node.data).value
                                elseif Filter(node.data).operation == OP_LE then
                                    set passes = field <= Filter(node.data).value
                                elseif Filter(node.data).operation == OP_GT then
                                    set passes = field > Filter(node.data).value
                                elseif Filter(node.data).operation == OP_GE then
                                    set passes = field >= Filter(node.data).value
                                elseif Filter(node.data).operation == OP_EQ then
                                    set passes = field == Filter(node.data).value
                                elseif Filter(node.data).operation == OP_NE then
                                    set passes = field != Filter(node.data).value
                                endif

                                if Filter(node.data).negate then
                                    set passes = not passes
                                endif

                                if Filter(node.data).orLogic then
                                    set hasOr = true
                                    set orResult = orResult or passes
                                else
                                    set andResult = andResult and passes
                                endif
                            set node = node.next
                        endloop

                        set add = add and andResult

                        if hasOr then
                            set add = add and orResult
                        endif
                    endif

                    if add then
                        static if USE_TABLE and LIBRARY_Table then
                            if sorted.has(j) then
                                call Unit(sorted[j]).destroy()
                            endif
                        else
                            if sorted[j] != 0 then
                                call sorted[j].destroy()
                            endif
                        endif
                        
                        set sorted[j] = Unit.create(u, x, y)
                        set j = j + 1
                    endif
                set i = i + 1
            endloop

            set newEnd = j

            loop
                exitwhen j >= end
                    static if USE_TABLE and LIBRARY_Table then
                        if sorted.has(j) then
                            call Unit(sorted[j]).destroy()
                            call sorted.remove(j)
                        endif
                    else
                        if sorted[j] != 0 then
                            call sorted[j].destroy()
                            set sorted[j] = 0
                        endif
                    endif
                set j = j + 1
            endloop

            set end = newEnd

            if count > 0 then
                call mergeSort(0, end - 1)
            endif

            call GroupClear(group)

            set i = 0

            if skips > 0 then
                set i = IMinBJ(skips, end)
            endif

            set j = end

            if takes > 0 then
                set j = IMinBJ(i + takes, end)
            endif

            set k = 0

            loop
                exitwhen k >= i
                    static if USE_TABLE and LIBRARY_Table then
                        if sorted.has(k) then
                            call Unit(sorted[k]).destroy()
                            call sorted.remove(k)
                        endif
                    else
                        if sorted[k] != 0 then
                            call sorted[k].destroy()
                            set sorted[k] = 0
                        endif
                    endif
                set k = k + 1
            endloop

            set k = j

            loop
                exitwhen k >= end
                    static if USE_TABLE and LIBRARY_Table then
                        if sorted.has(k) then
                            call Unit(sorted[k]).destroy()
                            call sorted.remove(k)
                        endif
                    else
                        if sorted[k] != 0 then
                            call sorted[k].destroy()
                            set sorted[k] = 0
                        endif
                    endif
                set k = k + 1
            endloop

            set k = 0

            loop
                exitwhen i >= j
                    set sorted[k] = sorted[i]
                    
                    if k != i then
                        static if USE_TABLE and LIBRARY_Table then
                            call sorted.remove(i)
                        else
                            set sorted[i] = 0
                        endif
                    endif

                    static if USE_TABLE and LIBRARY_Table then
                        call GroupAddUnit(group, Unit(sorted[k]).unit)
                    else
                        call GroupAddUnit(group, sorted[k].unit)
                    endif

                    set k = k + 1
                    set i = i + 1
            endloop

            set end = k

            call DestroyGroup(g)

            set u = null
            set g = null
            set ordered = true

            return this
        endmethod

        private method unfilter takes nothing returns nothing
            local List node

            if items.size > 0 then
                set node = items.next

                loop
                    exitwhen node == items
                        call Filter(node.data).destroy()
                    set node = node.next
                endloop

                call items.clear()
            endif

            if buffs.size > 0 then
                set node = buffs.next

                loop
                    exitwhen node == buffs
                        call Filter(node.data).destroy()
                    set node = node.next
                endloop

                call buffs.clear()
            endif

            if allies.size > 0 then
                set node = allies.next

                loop
                    exitwhen node == allies
                        call Filter(node.data).destroy()
                    set node = node.next
                endloop

                call allies.clear()
            endif

            if owners.size > 0 then
                set node = owners.next

                loop
                    exitwhen node == owners
                        call Filter(node.data).destroy()
                    set node = node.next
                endloop

                call owners.clear()
            endif

            if enemies.size > 0 then
                set node = enemies.next

                loop
                    exitwhen node == enemies
                        call Filter(node.data).destroy()
                    set node = node.next
                endloop

                call enemies.clear()
            endif

            if unittype.size > 0 then
                set node = unittype.next

                loop
                    exitwhen node == unittype
                        call Filter(node.data).destroy()
                    set node = node.next
                endloop

                call unittype.clear()
            endif

            if types.size > 0 then
                set node = types.next
                
                loop
                    exitwhen node == types
                        call Filter(node.data).destroy()
                    set node = node.next
                endloop

                call types.clear()
            endif

            if ranges.size > 0 then
                set node = ranges.next

                loop
                    exitwhen node == ranges
                        call Filter(node.data).destroy()
                    set node = node.next
                endloop

                call ranges.clear()
            endif
        endmethod

        private method compare takes Unit a, Unit b returns integer
            local integer result = 0
            local integer i = 0
            local real va
            local real vb

            loop
                exitwhen i >= count or result != 0
                    set va = a.field(orders[i])
                    set vb = b.field(orders[i])

                    if va < vb then
                        set result = -1
                    elseif va > vb then
                        set result = 1
                    endif

                    if descends[i] then
                        set result = -result
                    endif

                    set i = i + 1
            endloop

            return result
        endmethod

        private method merge takes integer left, integer mid, integer right returns nothing
            local integer i = left
            local integer j = mid + 1
            local integer k = left

            loop
                exitwhen i > mid or j > right
                    if compare(sorted[i], sorted[j]) <= 0 then
                        set temp[k] = sorted[i]
                        set i = i + 1
                    else
                        set temp[k] = sorted[j]
                        set j = j + 1
                    endif
                set k = k + 1
            endloop

            loop
                exitwhen i > mid
                set temp[k] = sorted[i]
                set i = i + 1
                set k = k + 1
            endloop

            loop
                exitwhen j > right
                set temp[k] = sorted[j]
                set j = j + 1
                set k = k + 1
            endloop

            set k = left

            loop
                exitwhen k > right
                set sorted[k] = temp[k]
                set k = k + 1
            endloop
        endmethod

        private method mergeSort takes integer left, integer right returns nothing
            local integer mid

            if left < right then
                set mid = (left + right) / 2

                call mergeSort(left, mid)
                call mergeSort(mid + 1, right)
                call merge(left, mid, right)
            endif
        endmethod

        static method create takes nothing returns Group
            local thistype this = thistype.allocate()

            set x = 0.
            set y = 0.
            set end = 0
            set takes = 0
            set count = 0
            set skips = 0
            set orderings = 0
            set pendingProp = 0
            set dead = false
            set alive = false
            set negate = false
            set orLogic = false
            set ordered = false
            set pendingNegate = false
            set pendingOrLogic = false
            set group = CreateGroup()
            set items = List.create()
            set buffs = List.create()
            set types = List.create()
            set ranges = List.create()
            set allies = List.create()
            set owners = List.create()
            set enemies = List.create()
            set unittype = List.create()

            static if USE_TABLE and LIBRARY_Table then
                set temp = Table.create()
                set sorted = Table.create()
                set orders = Table.create()
            endif

            return this
        endmethod
    endstruct
endlibrary