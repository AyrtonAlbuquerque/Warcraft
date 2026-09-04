library Group requires Modules optional Table optional Item
    /* -------------------------------- Group v1.0 by Chopinski -------------------------------- */
    globals
        // Use table or arrays. table is slower but allows for any number of groups
        private constant boolean USE_TABLE = false

        // If USE_TABLE is false, this is the maximum number of units that can be stored in a group.
        // This also limits the amount of groups that can be created to 8192/MAX_UNITS
        private constant integer MAX_UNITS = 128
    endglobals

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function interface GroupCallback takes integer instance, unit u returns nothing

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private struct Unit
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
            if hp < 0. then
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
                set unit = null
                set allocated = false

                call deallocate()
            endif
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

            return this
        endmethod
    endstruct

    private struct Filter
        readonly integer buff
        readonly integer item
        readonly player player
        readonly boolean negate
        readonly unittype unittype

        method destroy takes nothing returns nothing
            set player = null
            set unittype = null

            call deallocate()
        endmethod

        static method create takes player p, unittype t, integer i, integer b, boolean negate returns Filter
            local thistype this = thistype.allocate()

            set item = i
            set buff = b
            set player = p
            set unittype = t
            set .negate = negate

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

    struct Group
        private real x
        private real y
        private group group
        private integer end
        private List items
        private List buffs
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
        private integer orderings
        private boolean array descends[13]

        static if USE_TABLE and LIBRARY_Table then
            private Table temp
            private Table sorted
            private Table orders
        else
            private OrderBy array orders[13]
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

        method forGroup takes integer instance, GroupCallback callback returns thistype
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

        method isAlive takes nothing returns thistype
            if negate then
                set dead = true
                set negate = false
            else
                set alive = true
            endif

            return this
        endmethod

        method allyOf takes player p returns thistype
            if p != null then
                call allies.insert(Filter.create(p, null, 0, 0, negate))
                set negate = false
            endif

            return this
        endmethod

        method enemyOf takes player p returns thistype
            if p != null then
                call enemies.insert(Filter.create(p, null, 0, 0, negate))
                set negate = false
            endif

            return this
        endmethod

        method ownedBy takes player p returns thistype
            if p != null then
                call owners.insert(Filter.create(p, null, 0, 0, negate))
                set negate = false
            endif

            return this
        endmethod

        method ofType takes unittype t returns thistype
            if t != null then
                call unittype.insert(Filter.create(null, t, 0, 0, negate))
                set negate = false
            endif

            return this
        endmethod

        method hasItem takes integer itemId returns thistype
            if itemId > 0 then
                call items.insert(Filter.create(null, null, itemId, 0, negate))
                set negate = false
            endif

            return this
        endmethod

        method hasBuff takes integer buffId returns thistype
            if buffId > 0 then
                call buffs.insert(Filter.create(null, null, 0, buffId, negate))
                set negate = false
            endif

            return this
        endmethod

        method hasAbility takes integer abilityId returns thistype
            return hasBuff(abilityId)
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
        endmethod

        private method sort takes nothing returns nothing
            local integer cap = size
            local integer i = 0
            local integer j = 0
            local integer k = 0
            local integer newEnd
            local boolean add
            local List node
            local group g
            local unit u

            if size <= 0 or ordered then
                return
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

                    if dead then
                        set add = add and not UnitAlive(u)
                    endif

                    if allies.size > 0 then
                        set node = allies.next

                        loop
                            exitwhen node == allies
                                if Filter(node.data).negate then
                                    set add = add and not IsUnitAlly(u, Filter(node.data).player)
                                else
                                    set add = add and IsUnitAlly(u, Filter(node.data).player)
                                endif
                            set node = node.next
                        endloop
                    endif

                    if enemies.size > 0 then
                        set node = enemies.next

                        loop
                            exitwhen node == enemies
                                if Filter(node.data).negate then
                                    set add = add and not IsUnitEnemy(u, Filter(node.data).player)
                                else
                                    set add = add and IsUnitEnemy(u, Filter(node.data).player)
                                endif
                            set node = node.next
                        endloop
                    endif

                    if owners.size > 0 then
                        set node = owners.next

                        loop
                            exitwhen node == owners
                                if Filter(node.data).negate then
                                    set add = add and GetOwningPlayer(u) != Filter(node.data).player
                                else
                                    set add = add and GetOwningPlayer(u) == Filter(node.data).player
                                endif
                            set node = node.next
                        endloop
                    endif

                    if unittype.size > 0 then
                        set node = unittype.next

                        loop
                            exitwhen node == unittype
                                if Filter(node.data).negate then
                                    set add = add and not IsUnitType(u, Filter(node.data).unittype)
                                else
                                    set add = add and IsUnitType(u, Filter(node.data).unittype)
                                endif
                            set node = node.next
                        endloop
                    endif

                    if items.size > 0 then
                        set node = items.next

                        loop
                            exitwhen node == items
                                if Filter(node.data).negate then
                                    static if LIBRARY_Item then
                                        set add = add and not UnitHasItemOfType(u, Filter(node.data).item)
                                    else
                                        set add = add and not UnitHasItemOfTypeBJ(u, Filter(node.data).item)
                                    endif
                                else
                                    static if LIBRARY_Item then
                                        set add = add and UnitHasItemOfType(u, Filter(node.data).item)
                                    else
                                        set add = add and UnitHasItemOfTypeBJ(u, Filter(node.data).item)
                                    endif
                                endif
                            set node = node.next
                        endloop
                    endif

                    if buffs.size > 0 then
                        set node = buffs.next

                        loop
                            exitwhen node == buffs
                                if Filter(node.data).negate then
                                    set add = add and GetUnitAbilityLevel(u, Filter(node.data).buff) <= 0
                                else
                                    set add = add and GetUnitAbilityLevel(u, Filter(node.data).buff) > 0
                                endif
                            set node = node.next
                        endloop
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
            set negate = false
            set dead = false
            set alive = false
            set ordered = false
            set group = CreateGroup()
            set items = List.create()
            set buffs = List.create()
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