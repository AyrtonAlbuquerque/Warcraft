library Missiles requires Effect, Dummy, Modules, Utilities, TimerUtils, WorldBounds
    /* ---------------------------------------- Missiles v3.0 --------------------------------------- */
    // Thanks and Credits to BPower, Dirac and Vexorian for their Missile Libraries from which i based
    // this Missiles library. Credits and thanks to AGD for the effect orientation ideas.
    // This version of Missiles requires patch 1.31+
    /* ---------------------------------------- By Chopinski ---------------------------------------- */
    
    globals
        // The update period of the system
        public  constant real    PERIOD             = 1./30.
        // The max amount of Missiles processed in a PERIOD
        // You can play around with both these values to find
        // your sweet spot. If equal to 0, the system will
        // process all missiles at once every period.
        public  constant real    SWEET_SPOT         = 150
        // the avarage collision size compensation when detecting collisions
        private constant real    COLLISION_SIZE     = 128.
        // item size used in z collision
        private constant real    ITEM_SIZE          = 16.
    endglobals
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                            JASS API                                            */
    /* ---------------------------------------------------------------------------------------------- */
    function CreateMissileGroup takes nothing returns MissileGroup
        return MissileGroup.create()
    endfunction
    
    function DestroyMissileGroup takes MissileGroup missiles returns nothing
        if missiles != 0 then
            call missiles.destroy()
        endif
    endfunction
    
    function MissileGroupGetSize takes MissileGroup missiles returns integer
        if missiles != 0 then
            return missiles.size
        else
            return 0
        endif
    endfunction
    
    function GroupMissileAt takes MissileGroup missiles, integer position returns Missile
        if missiles != 0 then
            return missiles.missileAt(position)
        else
            return 0
        endif
    endfunction
    
    function ClearMissileGroup takes MissileGroup missiles returns nothing
        if missiles != 0 then
            call missiles.clear()
        endif
    endfunction
    
    function IsMissileInGroup takes Missile missile, MissileGroup missiles returns boolean
        if missiles != 0 and missile != 0 then
            if missiles.size > 0 then
                return missiles.contains(missile)
            else
                return false
            endif
        else
            return false
        endif
    endfunction
    
    function GroupRemoveMissile takes MissileGroup missiles, Missile missile returns nothing
        if missiles != 0 and missile != 0 then
            if missiles.size > 0 then
                call missiles.remove(missile)
            endif
        endif
    endfunction
    
    function GroupAddMissile takes MissileGroup missiles, Missile missile returns nothing
        if missiles != 0 and missile != 0 then
            if not missiles.contains(missile) then
                call missiles.insert(missile)
            endif
        endif
    endfunction
    
    function GroupPickRandomMissile takes MissileGroup missiles returns Missile
        if missiles != 0 then
            if missiles.size > 0 then
                return missiles.missileAt(GetRandomInt(0, missiles.size - 1))
            else
                return 0
            endif
        else
            return 0
        endif
    endfunction
    
    function FirstOfMissileGroup takes MissileGroup missiles returns Missile
        if missiles != 0 then
            if missiles.size > 0 then
                return missiles.group.next.data
            else
                return 0
            endif
        else
            return 0
        endif
    endfunction
    
    function GroupAddMissileGroup takes MissileGroup source, MissileGroup target returns nothing
        if source != 0 and target != 0 then
            if source.size > 0 and source != target then
                call target.addGroup(source)
            endif
        endif
    endfunction
    
    function GroupRemoveMissileGroup takes MissileGroup source, MissileGroup target returns nothing
        if source != 0 and target != 0 then
            if source == target then
                call source.clear()
            elseif source.size > 0 then
                call target.removeGroup(source)
            endif
        endif
    endfunction
    
    function GroupEnumMissilesOfType takes MissileGroup missiles, integer whichType returns nothing
        local integer i
        local Missile missile
        
        if missiles != 0 then
            if Missile.count > -1 then
                set i = 0
                
                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missile.count
                        set missile = Missile.collection[i]
                        
                        if missile.type == whichType then
                            call missiles.insert(missile)
                        endif
                    set i = i + 1
                endloop
            endif
        endif
    endfunction
    
    function GroupEnumMissilesOfTypeCounted takes MissileGroup missiles, integer whichType, integer amount returns nothing
        local integer i
        local integer j = amount
        local Missile missile
        
        if missiles != 0 then
            if Missile.count > -1 then
                set i = 0
                
                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missile.count or j == 0
                        set missile = Missile.collection[i]
                        
                        if missile.type == whichType then
                            set j = j - 1
                            call missiles.insert(missile)
                        endif
                    set i = i + 1
                endloop
            endif
        endif
    endfunction
    
    function GroupEnumMissilesOfPlayer takes MissileGroup missiles, player p returns nothing
        local integer i
        local Missile missile
        
        if missiles != 0 then
            if Missile.count > -1 then
                set i = 0
                
                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missile.count
                        set missile = Missile.collection[i]
                        
                        if missile.owner == p then
                            call missiles.insert(missile)
                        endif
                    set i = i + 1
                endloop
            endif
        endif
    endfunction
    
    function GroupEnumMissilesOfPlayerCounted takes MissileGroup missiles, player p, integer amount returns nothing
        local integer i
        local integer j = amount
        local Missile missile
        
        if missiles != 0 then
            if Missile.count > -1 then
                set i = 0
                
                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missile.count or j == 0
                        set missile = Missile.collection[i]
                        
                        if missile.owner == p then
                            set j = j - 1
                            call missiles.insert(missile)
                        endif
                    set i = i + 1
                endloop
            endif
        endif
    endfunction
    
    function GroupEnumMissilesInRect takes MissileGroup missiles, rect r returns nothing
        local integer i
        local real minx
        local real miny
        local real maxx
        local real maxy
        local Missile missile
        
        if missiles != 0 and r != null then
            if Missile.count > -1 then
                set i = 0
                set minx = GetRectMinX(r)
                set miny = GetRectMinY(r)
                set maxx = GetRectMaxX(r)
                set maxy = GetRectMaxY(r)

                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missile.count
                        set missile = Missile.collection[i]

                        if minx <= missile.x and missile.x <= maxx and miny <= missile.y and missile.y <= maxy then
                            call missiles.insert(missile)
                        endif
                    set i = i + 1
                endloop
            endif
        endif
    endfunction
    
    function GroupEnumMissilesInRectCounted takes MissileGroup missiles, rect r, integer amount returns nothing
        local integer i
        local real minx
        local real miny
        local real maxx
        local real maxy
        local integer j = amount
        local Missile missile
        
        if missiles != 0 and r != null then
            if Missile.count > -1 then
                set i = 0
                set minx = GetRectMinX(r)
                set miny = GetRectMinY(r)
                set maxx = GetRectMaxX(r)
                set maxy = GetRectMaxY(r)

                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missile.count or j == 0
                        set missile = Missile.collection[i]

                        if minx <= missile.x and missile.x <= maxx and miny <= missile.y and missile.y <= maxy then
                            set j = j - 1
                            call missiles.insert(missile)
                        endif
                    set i = i + 1
                endloop
            endif
        endif
    endfunction
    
    function GroupEnumMissilesInRangeOfLoc takes MissileGroup missiles, location loc, real radius returns nothing
        local real x
        local real y
        local real dx
        local real dy
        local integer i
        local Missile missile
        local real range = radius * radius

        if missiles != 0 and range > 0 and loc != null then
            if Missile.count > -1 then
                set i = 0
                set x = GetLocationX(loc)
                set y = GetLocationY(loc)

                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missile.count
                        set missile = Missile.collection[i]
                        set dx = missile.x - x
                        set dy = missile.y - y

                        if dx*dx + dy*dy <= range then
                            call missiles.insert(missile)
                        endif
                    set i = i + 1
                endloop
            endif
        endif
    endfunction
    
    function GroupEnumMissilesInRangeOfLocCounted takes MissileGroup missiles, location loc, real radius, integer amount returns nothing
        local real x
        local real y
        local real dx
        local real dy
        local integer i
        local integer j = amount
        local Missile missile
        local real range = radius * radius
    
        if missiles != 0 and range > 0 and loc != null then
            if Missile.count > -1 then
                set i = 0
                set x = GetLocationX(loc)
                set y = GetLocationY(loc)

                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missile.count or j == 0
                        set missile = Missile.collection[i]
                        set dx = missile.x - x
                        set dy = missile.y - y
                        
                        if dx*dx + dy*dy <= range then
                            set j = j - 1
                            call missiles.insert(missile)
                        endif
                    set i = i + 1
                endloop
            endif
        endif
    endfunction
    
    function GroupEnumMissilesInRange takes MissileGroup missiles, real x, real y, real radius returns nothing
        local real dx
        local real dy
        local integer i
        local Missile missile
        local real range = radius * radius
    
        if missiles != 0 and range > 0 then
            if Missile.count > -1 then
                set i = 0
                
                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missile.count
                        set missile = Missile.collection[i]
                        set dx = missile.x - x
                        set dy = missile.y - y
                        
                        if dx*dx + dy*dy <= range then
                            call missiles.insert(missile)
                        endif
                    set i = i + 1
                endloop
            endif
        endif
    endfunction
    
    function GroupEnumMissilesInRangeCounted takes MissileGroup missiles, real x, real y, real radius, integer amount returns nothing
        local real dx
        local real dy
        local integer i
        local integer j = amount
        local Missile missile
        local real range = radius * radius
    
        if missiles != 0 and range > 0 then
            if Missile.count > -1 then
                set i = 0
                
                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missile.count or j == 0
                        set missile = Missile.collection[i]
                        set dx = missile.x - x
                        set dy = missile.y - y
                        
                        if dx*dx + dy*dy <= range then
                            set j = j - 1
                            call missiles.insert(missile)
                        endif
                    set i = i + 1
                endloop
            endif
        endif
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    private module OnMove
        if target != null and GetUnitTypeId(target) != 0 and UnitAlive(target) then
            call impact.move(GetUnitX(target), GetUnitY(target), GetUnitFlyHeight(target) + toZ)

            set dx = impact.x - x
            set dy = impact.y - y
            set angle = Atan2(dy, dx)
            set traveled = origin.distance - SquareRoot(dx*dx + dy*dy)
        else
            set angle = origin.angle
            set target = null
        endif

        set ds = speed * PERIOD * dilation
        set speed = speed + acceleration
        set traveled = traveled + ds

        if not .onMove.exists then
            if turn != 0 and not (Cos(curvature - angle) >= Cos(turn)) then
                if Sin(angle - curvature) >= 0 then
                    set curvature = curvature + turn
                else
                    set curvature = curvature - turn
                endif
            else
                set curvature = angle
            endif

            set yaw = curvature
            set pitch = origin.alpha
            set x = x + ds * Cos(yaw)
            set y = y + ds * Sin(yaw)
            set px = x
            set py = y

            if height != 0 or origin.slope != 0 then
                set z = 4 * height * traveled * (origin.distance - traveled)/(origin.square) + origin.slope * traveled + origin.z
                set pitch = pitch - Atan(((4 * height) * (2 * traveled - origin.distance))/(origin.square))
            endif
            
            if bend != 0 then
                set dx = 4 * bend * traveled * (origin.distance - traveled)/(origin.square)
                set angle = yaw + bj_PI/2
                set x = x + dx * Cos(angle)
                set y = y + dx * Sin(angle)
                set yaw = yaw + Atan(-((4 * bend) * (2 * traveled - origin.distance))/(origin.square))
            endif
        else
            call .onMove()
        endif
    endmodule

    private module OnUnit    
        if .onUnit.exists then
            if allocated and collision > 0 then
                call GroupEnumUnitsInRange(group, x, y, collision + COLLISION_SIZE, null)

                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if not HaveSavedBoolean(table, this, GetHandleId(u)) then
                            if IsUnitInRangeXY(u, x, y, collision) then
                                if collideZ then
                                    set dx = GetUnitZ(u)
                                    set dy = BlzGetUnitCollisionSize(u)

                                    if dx + dy >= z - collision and dx <= z + collision then
                                        call SaveBoolean(table, this, GetHandleId(u), true)

                                        if allocated and .onUnit(u) then
                                            call terminate()
                                            exitwhen true
                                        endif
                                    endif
                                else
                                    call SaveBoolean(table, this, GetHandleId(u), true)

                                    if allocated and .onUnit(u) then
                                        call terminate()
                                        exitwhen true
                                    endif
                                endif
                            endif
                        endif
                    call GroupRemoveUnit(group, u)
                endloop
            endif
        endif
    endmodule
    
    private module OnItem
        if .onItem.exists then
            if allocated and collision > 0 then
                set dx = collision

                call SetRect(rect, x - dx, y - dx, x + dx, y + dx)
                call EnumItemsInRect(rect, null, function thistype.onItems)
            endif
        endif
    endmodule

    private module OnMissile
        if .onMissile.exists then
            if allocated and collision > 0 then
                set k = 0

                loop
                    exitwhen k > count
                        set missile = collection[k]

                        if missile != this then
                            if not HaveSavedBoolean(table, this, missile) then
                                set dx = missile.x - x
                                set dy = missile.y - y

                                if dx*dx + dy*dy <= collision*collision then
                                    call SaveBoolean(table, this, missile, true)

                                    if allocated and .onMissile(missile) then
                                        call terminate()
                                        exitwhen true
                                    endif
                                endif
                            endif
                        endif
                    set k = k + 1
                endloop
            endif
        endif
    endmodule

    private module OnDestructable
        if .onDestructable.exists then
            if allocated and collision > 0 then
                set dx = collision

                call SetRect(rect, x - dx, y - dx, x + dx, y + dx)
                call EnumDestructablesInRect(rect, null, function thistype.onDestructables)
            endif
        endif
    endmodule

    private module OnCliff
        if .onCliff.exists then
            set k = GetTerrainCliffLevel(x, y)

            if cliff < k and z < (k - GetTerrainCliffLevel(WorldBounds.maxX, WorldBounds.maxY))*bj_CLIFFHEIGHT then
                if allocated and .onCliff() then
                    call terminate()
                endif
            endif

            set cliff = k
        endif
    endmodule
       
    private module OnTerrain
        if .onTerrain.exists then
            if GetLocZ(x, y) > z then
                if allocated and .onTerrain() then
                    call terminate()
                endif
            endif
        endif
    endmodule
    
    private module OnTileset
        if .onTileset.exists then
            set k = GetTerrainType(x, y)

            if k != tileset then
                if allocated and .onTileset(k) then
                    call terminate()
                endif
            endif

            set tileset = k
        endif
    endmodule
    
    private module OnPeriod
        if .onPeriod.exists then
            if allocated and .onPeriod() then
                call terminate()
            endif
        endif
    endmodule
    
    private module OnFinish
        if traveled >= origin.distance - 0.0001 then
            set finished = true

            if .onFinish.exists then
                if allocated and .onFinish() then
                    call terminate()
                else
                    if traveled > 0 and not paused then
                        call terminate()
                    endif
                endif
            else
                call terminate()
            endif
        else
            if not autoroll then
                call effect.orient(yaw, -pitch, roll)
            else
                call effect.orient(yaw, -pitch, Atan2(bend, height))
            endif
        endif
    endmodule

    private module OnBoundaries
        if not effect.move(x, y, z) then
            if .onBoundaries.exists then
                if allocated and .onBoundaries() then
                    call terminate()
                endif
            endif
        else
            if dummy != null then
                call SetUnitX(dummy, x)
                call SetUnitY(dummy, y)
            endif

            if unit != null then
                call SetUnitX(unit, x)
                call SetUnitY(unit, y)
                call SetUnitZ(unit, z)
            endif
        endif
    endmodule

    interface IMissile
        method onMove takes nothing returns nothing defaults nothing
        method onUnit takes unit u returns boolean defaults false
        method onItem takes item i returns boolean defaults false
        method onMissile takes Missile missile returns boolean defaults false
        method onDestructable takes destructable d returns boolean defaults false
        method onCliff takes nothing returns boolean defaults false
        method onTerrain takes nothing returns boolean defaults false
        method onTileset takes integer tileset returns boolean defaults false
        method onPeriod takes nothing returns boolean defaults false
        method onFinish takes nothing returns boolean defaults false
        method onBoundaries takes nothing returns boolean defaults false
        method onPause takes nothing returns boolean defaults false
        method onResume takes nothing returns boolean defaults false
        method onRemove takes nothing returns nothing defaults nothing
    endinterface

    private struct Coordinates
        readonly real x
        readonly real y
        readonly real z
        readonly real slope
        readonly real alpha
        readonly real angle
        readonly real square
        readonly real distance

        private thistype linked

        method operator link= takes thistype that returns nothing
            set linked = that
            set that.linked = this

            call math(this, that)
        endmethod

        method destroy takes nothing returns nothing
            call deallocate()
        endmethod

        method move takes real toX, real toY, real toZ returns nothing
            set x = toX
            set y = toY
            set z = toZ + GetLocZ(toX, toY)

            if linked != this then
                call math(this, linked)
            endif
        endmethod

        private static method math takes thistype a, thistype b returns nothing
            local real dx
            local real dy

            loop
                set dx = b.x - a.x
                set dy = b.y - a.y
                set dx = dx*dx + dy*dy
                set dy = SquareRoot(dx)
                exitwhen dx != 0. and dy != 0.
                set b.x = b.x + .01
                set b.z = b.z - GetLocZ(b.x -.01, b.y) + GetLocZ(b.x, b.y)
            endloop

            set a.square = dx
            set a.distance = dy
            set a.angle = Atan2(b.y - a.y, b.x - a.x)
            set a.slope = (b.z - a.z) / dy
            set a.alpha = Atan(a.slope)
            
            if b.linked == a then
                set b.angle = a.angle + bj_PI
                set b.distance = dy
                set b.slope = -a.slope
                set b.alpha = -a.alpha
                set b.square = dx
            endif
        endmethod

        static method create takes real x, real y, real z returns Coordinates
            local thistype this = thistype.allocate()

            set linked = this

            call move(x, y, z)

            return this
        endmethod
    endstruct

    struct MissileGroup
        readonly List group
        
        method operator size takes nothing returns integer
            return group.size
        endmethod

        method destroy takes nothing returns nothing
            call group.destroy()
            call deallocate()
        endmethod
        
        method missileAt takes integer i returns Missile
            local List node = group.next
            local integer j = 0
        
            if size > 0 and i <= size - 1 then
                loop
                    exitwhen j == i
                        set node = node.next
                    set j = j + 1
                endloop
                
                return node.data
            else
                return 0
            endif
        endmethod
        
        method remove takes Missile missile returns nothing
            call group.remove(missile)
        endmethod
        
        method insert takes Missile missile returns nothing
            call group.insert(missile)
        endmethod
        
        method clear takes nothing returns nothing
            call group.clear()
        endmethod
        
        method contains takes Missile missile returns boolean
            return group.has(missile)
        endmethod
        
        method addGroup takes thistype source returns nothing
            local List node = source.group.next
        
            loop
                exitwhen node == source.group
                    if not contains(node.data) then
                        call insert(node.data)
                    endif
                set node = node.next
            endloop
        endmethod
        
        method removeGroup takes thistype source returns nothing
            local List node = source.group.next
        
            loop
                exitwhen node == source.group
                    if contains(node.data) then
                        call remove(node.data)
                    endif
                set node = node.next
            endloop
        endmethod
        
        static method create takes nothing returns thistype
            local thistype this = thistype.allocate()
            
            set group = List.create()
            
            return this
        endmethod
    endstruct

    struct Missile extends IMissile
        private static integer id = -1
        private static integer last = 0
        private static integer pid = -1
        private static thistype temp = 0
        private static thistype array frozen
        private static thistype array missiles
        private static timer timer = CreateTimer()
        private static group group = CreateGroup()
        private static rect rect = Rect(0, 0, 0, 0)
        private static hashtable table = InitHashtable()
        
        readonly static real dilation = 1
        readonly static real period = PERIOD
        readonly static integer count = -1
        readonly static thistype array collection
        
        private real toZ
        private real time
        private real bend
        private real sight
        private real height
        private real curvature
        private unit dummy
        private integer pkey
        private integer cliff
        private integer index
        
        readonly real traveled
        readonly Effect effect
        readonly integer tileset
        readonly boolean paused
        readonly boolean launched
        readonly boolean finished
        readonly boolean allocated
        readonly Coordinates impact
        readonly Coordinates origin

        real x
        real y
        real z
        real yaw
        real roll
        real turn
        unit unit
        real pitch
        real speed
        unit source
        unit target
        real damage
        integer data
        integer type
        player owner
        real collision
        boolean autoroll
        boolean collideZ
        real acceleration

        method operator arc= takes real value returns nothing
            set height = Tan(value) * origin.distance / 4
        endmethod
        
        method operator arc takes nothing returns real
            return Atan(4 * height / origin.distance)
        endmethod

        method operator curve= takes real value returns nothing
            set bend = Tan(value) * origin.distance
        endmethod
        
        method operator curve takes nothing returns real
            return Atan(bend / origin.distance)
        endmethod

        method operator model= takes string fx returns nothing
            set effect.model = fx
        endmethod

        method operator model takes nothing returns string
            return effect.model
        endmethod
        
        method operator scale= takes real value returns nothing
            set effect.scale = value
        endmethod

        method operator scale takes nothing returns real
            return effect.scale
        endmethod

        method operator alpha= takes integer newAlpha returns nothing
            set effect.alpha = newAlpha
        endmethod

        method operator alpha takes nothing returns integer
            return effect.alpha
        endmethod

        method operator vision= takes real sightRange returns nothing
            set sight = sightRange
            
            if dummy == null then
                if owner == null then
                    if source != null then
                        set dummy = DummyRetrieve(GetOwningPlayer(source), x, y, z, 0)
                        call BlzSetUnitRealField(dummy, UNIT_RF_SIGHT_RADIUS, sightRange)
                    endif
                else
                    set dummy = DummyRetrieve(owner, x, y, z, 0)
                    call BlzSetUnitRealField(dummy, UNIT_RF_SIGHT_RADIUS, sightRange)
                endif
            else
                call SetUnitOwner(dummy, owner, false)
                call BlzSetUnitRealField(dummy, UNIT_RF_SIGHT_RADIUS, sightRange)
            endif
        endmethod
        
        method operator vision takes nothing returns real
            return sight
        endmethod

        method operator duration= takes real flightTime returns nothing
            set speed = RMaxBJ(0.00000001, (origin.distance - traveled)/RMaxBJ(0.00000001, flightTime))
            set time = flightTime
        endmethod
        
        method operator duration takes nothing returns real
            return time
        endmethod

        method operator animation= takes integer animType returns nothing
            set effect.animation = animType
        endmethod

        method operator animation takes nothing returns integer
            return effect.animation
        endmethod

        method operator timeScale= takes real newTimeScale returns nothing
            set effect.timeScale = newTimeScale
        endmethod
        
        method operator timeScale takes nothing returns real
            return effect.timeScale
        endmethod

        method operator playercolor= takes integer playerId returns nothing
            set effect.playercolor = playerId
        endmethod

        method operator playercolor takes nothing returns integer
            return effect.playercolor
        endmethod

        method bounce takes nothing returns nothing
            set traveled = 0
            set finished = false

            call origin.move(x, y, z - GetLocZ(x, y))
        endmethod

        method deflect takes real tx, real ty, real tz returns nothing
            set toZ = tz
            set traveled = 0
            set target = null
            set finished = false
            
            call impact.move(tx, ty, tz)
            call origin.move(x, y, z - GetLocZ(x, y))
        endmethod
        
        method deflectTarget takes unit u returns nothing
            call deflect(GetUnitX(u), GetUnitY(u), toZ)
            set target = u
        endmethod

        method flushAll takes nothing returns nothing
            call FlushChildHashtable(table, this)
        endmethod

        method flush takes agent a returns nothing
            if a != null then
                call RemoveSavedBoolean(table, this, GetHandleId(a))
            endif
        endmethod

        method hitted takes agent a returns boolean
            return HaveSavedBoolean(table, this, GetHandleId(a))
        endmethod

        method attach takes string model, real dx, real dy, real dz, real scale returns Effect
            return effect.attach(model, dx, dy, dz, scale)
        endmethod

        method detach takes Effect attachment returns nothing
            if attachment != 0 then
                call effect.detach(attachment)
                call attachment.destroy()
            endif
        endmethod

        method pause takes boolean flag returns nothing
            local thistype aux
        
            set paused = flag
            
            if not paused and pkey != -1 then
                set id = id + 1
                set missiles[id] = this
                set aux = frozen[pid]
                set aux.pkey = pkey
                set frozen[pkey] = frozen[pid]
                set pid = pid - 1
                set pkey = -1

                if id + 1 > SWEET_SPOT and SWEET_SPOT > 0 then
                    set dilation = (id + 1) / SWEET_SPOT
                else
                    set dilation = 1
                endif

                if id == 0 then
                    call TimerStart(timer, PERIOD, true, function thistype.move)
                endif

                if .onResume.exists then
                    if allocated and .onResume() then
                        call terminate()
                    else
                        if finished then
                            call terminate()
                        endif
                    endif
                else
                    if finished then
                        call terminate()
                    endif
                endif
            endif
        endmethod

        method color takes integer red, integer green, integer blue returns nothing
            call effect.color(red, green, blue)
        endmethod

        method terminate takes nothing returns nothing
            local thistype aux
    
            if allocated and launched then
                set allocated = false
                
                if pkey != -1 then
                    set aux = frozen[pid]
                    set aux.pkey = pkey
                    set frozen[pkey] = frozen[pid]
                    set pid = pid - 1
                    set pkey = -1
                endif

                if .onRemove.exists then
                    call .onRemove()
                endif
                
                if dummy != null then
                    call DummyRecycle(dummy)
                endif
                
                set aux = collection[count]
                set aux.index = index
                set collection[index] = collection[count]
                set count = count - 1
                set index = -1

                call origin.destroy()
                call impact.destroy()
                call effect.destroy()
                call reset()
                call FlushChildHashtable(table, this)
            endif
        endmethod

        method launch takes nothing returns nothing
            if not launched and allocated then
                set launched = true
                set id = id + 1
                set missiles[id] = this
                set count = count + 1
                set index = count
                set collection[count] = this
                
                if id + 1 > SWEET_SPOT and SWEET_SPOT > 0 then
                    set dilation = (id + 1)/SWEET_SPOT
                else
                    set dilation = 1
                endif

                if id == 0 then
                    call TimerStart(timer, PERIOD, true, function thistype.move)
                endif
            endif
        endmethod

        private method reset takes nothing returns nothing
            set yaw = 0
            set roll = 0
            set turn = 0
            set time = 0
            set data = 0
            set type = 0
            set bend = 0
            set pitch = 0
            set sight = 0
            set speed = 0
            set pkey = -1
            set index = -1
            set height = 0
            set damage = 0
            set unit = null
            set tileset = 0
            set traveled = 0
            set owner = null
            set dummy = null
            set collision = 0
            set source = null
            set target = null
            set paused = false
            set acceleration = 0
            set autoroll = false
            set launched = false
            set finished = false
            set collideZ = false
        endmethod

        private method remove takes integer i returns integer
            if paused then
                set pid = pid + 1
                set pkey = pid
                set frozen[pid] = this
                
                if .onPause.exists then
                    if allocated and .onPause() then
                        call terminate()
                    endif
                endif
            else
                call terminate()
            endif
            
            set missiles[i] = missiles[id]
            set id = id - 1

            if id + 1 > SWEET_SPOT and SWEET_SPOT > 0 then
                set dilation = (id + 1)/SWEET_SPOT
            else
                set dilation = 1
            endif

            if id == -1 then
                call PauseTimer(timer)
            endif
            
            if not allocated then
                call deallocate()
            endif

            return i - 1
        endmethod
        
        private static method move takes nothing returns nothing
            local unit u
            local real dx
            local real dy
            local real ds
            local real px
            local real py
            local real angle
            local integer i = 0
            local integer j = 0
            local integer k = 0
            local thistype this
            local thistype missile

            if SWEET_SPOT > 0 then
                set i = last
            endif
            
            loop
                exitwhen ((j >= SWEET_SPOT and SWEET_SPOT > 0) or j > id)
                    set this = missiles[i]
                    set temp = this

                    if allocated and not paused then
                        implement OnMove
                        implement OnUnit
                        implement OnItem
                        implement OnMissile
                        implement OnDestructable
                        implement OnCliff
                        implement OnTerrain
                        implement OnTileset
                        implement OnPeriod
                        implement OnFinish
                        implement OnBoundaries

                        if not .onMove.exists then
                            set x = px
                            set y = py
                        endif
                    else
                        set i = remove(i)
                        set j = j - 1
                    endif
                set i = i + 1
                set j = j + 1

                if i > id and SWEET_SPOT > 0 then
                    set i = 0
                endif
            endloop

            set last = i
            set u = null
        endmethod

        private static method onItems takes nothing returns nothing
            local item i = GetEnumItem()
            local thistype this = temp
            local real dz

            if not HaveSavedBoolean(table, this, GetHandleId(i)) then
                if collideZ then
                    set dz = GetLocZ(GetItemX(i), GetItemY(i))

                    if dz + ITEM_SIZE >= z - collision and dz <= z + collision then
                        call SaveBoolean(table, this, GetHandleId(i), true)

                        if allocated and .onItem(i) then
                            set i = null
                            call terminate()
                            return
                        endif
                    endif
                else
                    call SaveBoolean(table, this, GetHandleId(i), true)

                    if allocated and .onItem(i) then
                        set i = null
                        call terminate()
                        return
                    endif
                endif
            endif

            set i = null
        endmethod

        private static method onDestructables takes nothing returns nothing
            local destructable d = GetEnumDestructable()
            local thistype this = temp
            local real dz
            local real tz

            if not HaveSavedBoolean(table, this, GetHandleId(d)) then
                if collideZ then
                    set dz = GetLocZ(GetWidgetX(d), GetWidgetY(d))
                    set tz = GetDestructableOccluderHeight(d)

                    if dz + tz >= z - collision and dz <= z + collision then
                        call SaveBoolean(table, this, GetHandleId(d), true)

                        if allocated and .onDestructable(d) then
                            set d = null
                            call terminate()
                            return
                        endif
                    endif
                else
                    call SaveBoolean(table, this, GetHandleId(d), true)
                    
                    if allocated and .onDestructable(d) then
                        set d = null
                        call terminate()
                        return
                    endif
                endif
            endif

            set d = null
        endmethod

        static method create takes real x, real y, real z, real toX, real toY, real toZ returns thistype
            local thistype this = thistype.allocate()

            call reset()

            set allocated = true
            set origin = Coordinates.create(x, y, z)
            set impact = Coordinates.create(toX, toY, toZ)
            set effect = Effect.create("", x, y, origin.z, 1)
            set origin.link = impact
            set curvature = origin.angle
            set this.x = x
            set this.y = y
            set this.z = impact.z
            set this.toZ = toZ
            set cliff = GetTerrainCliffLevel(x, y)
            
            return this
        endmethod
    endstruct
endlibrary