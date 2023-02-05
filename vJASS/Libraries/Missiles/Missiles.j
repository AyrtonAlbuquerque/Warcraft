library Missiles requires MissileEffect, TimerUtils, WorldBounds
    /* ---------------------------------------- Missiles v2.8 --------------------------------------- */
    // Thanks and Credits to BPower, Dirac and Vexorian for the Missile Library's at which i based
    // this Missiles library. Credits and thanks to AGD and for the effect orientation ideas.
    // This version of Missiles requires patch 1.31+
    
    // How to Import:
    //     1 - Copy this, MissileEffect and optionaly the MissileUtils libraries to your map
    /* ---------------------------------------- By Chopinski ---------------------------------------- */
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // The update period of the system
        public  constant real    PERIOD             = 1./40.
        // The max amount of Missiles processed in a PERIOD
        // You can play around with both these values to find
        // your sweet spot. If equal to 0, the system will
        // process all missiles at once every period.
        public  constant real    SWEET_SPOT         = 150
        // the avarage collision size compensation when detecting collisions
        private constant real    COLLISION_SIZE     = 128.
        // item size used in z collision
        private constant real    ITEM_SIZE          = 16.
        // Raw code of the dummy unit used for vision
        private constant integer DUMMY              = 'dumi'
        // Needed, don't touch.
        private location         LOC                = Location(0., 0.)
    endglobals

    private interface MissileEvents
        method onHit takes unit hit returns boolean defaults false
        method onMissile takes Missiles missile returns boolean defaults false
        method onDestructable takes destructable dest returns boolean defaults false
        method onItem takes item i returns boolean defaults false
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
    
    private function GetLocZ takes real x, real y returns real
        call MoveLocation(LOC, x, y)
        return GetLocationZ(LOC)
    endfunction
    
    private function GetUnitZ takes unit u returns real
        return GetLocZ(GetUnitX(u), GetUnitY(u)) + GetUnitFlyHeight(u)
    endfunction
    
    private function SetUnitZ takes unit u, real z returns nothing
        call SetUnitFlyHeight(u, z - GetLocZ(GetUnitX(u), GetUnitY(u)), 0)
    endfunction
    
    private function GetMapCliffLevel takes nothing returns integer
        return GetTerrainCliffLevel(WorldBounds.maxX, WorldBounds.maxY)
    endfunction

    private struct Pool
        private static player player = Player(PLAYER_NEUTRAL_PASSIVE)
        private static group  group  = CreateGroup()

        timer timer
        unit  unit

        static method recycle takes unit dummy returns nothing
            if GetUnitTypeId(dummy) == DUMMY then
                call GroupAddUnit(group, dummy)
                call SetUnitX(dummy, WorldBounds.maxX)
                call SetUnitY(dummy, WorldBounds.maxY)
                call SetUnitOwner(dummy, player, false)
                call PauseUnit(dummy, true)
            endif
        endmethod

        static method retrieve takes real x, real y, real z, real face returns unit
            if BlzGroupGetSize(group) > 0 then
                set bj_lastCreatedUnit = FirstOfGroup(group)
                call PauseUnit(bj_lastCreatedUnit, false)
                call GroupRemoveUnit(group, bj_lastCreatedUnit)
                call SetUnitX(bj_lastCreatedUnit, x)
                call SetUnitY(bj_lastCreatedUnit, y)
                call SetUnitZ(bj_lastCreatedUnit, z)
                call BlzSetUnitFacingEx(bj_lastCreatedUnit, face)
            else
                set bj_lastCreatedUnit = CreateUnit(player, DUMMY, x, y, face)
                call SetUnitZ(bj_lastCreatedUnit, z)
                call UnitRemoveAbility(bj_lastCreatedUnit, 'Amrf')
            endif

            return bj_lastCreatedUnit
        endmethod

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call recycle(unit)
            call ReleaseTimer(timer)
            
            set timer = null
            set unit  = null

            call deallocate()
        endmethod

        static method recycleTimed takes unit dummy, real delay returns nothing
            local thistype this

            if GetUnitTypeId(dummy) != DUMMY then
                debug call BJDebugMsg("[DummyPool] Error: Trying to recycle a non dummy unit")
            else
                set this = thistype.allocate()

                set timer = NewTimerEx(this)
                set unit  = dummy
                
                call TimerStart(timer, delay, false, function thistype.onExpire)
            endif
        endmethod

        private static method onInit takes nothing returns nothing
            local integer i = 0
            local unit u

            loop
                exitwhen i == SWEET_SPOT
                    set u = CreateUnit(player, DUMMY, WorldBounds.maxX, WorldBounds.maxY, 0)
                    call PauseUnit(u, false)
                    call GroupAddUnit(group, u)
                    call UnitRemoveAbility(u, 'Amrf')
                set i = i + 1
            endloop

            set u = null
        endmethod
    endstruct

    private struct Coordinates
        readonly real x
        readonly real y
        readonly real z
        readonly real angle
        readonly real distance
        readonly real square
        readonly real slope
        readonly real alpha

        // Creates an origin - impact link.
        private thistype ref

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

            set a.square   = dx
            set a.distance = dy
            set a.angle    = Atan2(b.y - a.y, b.x - a.x)
            set a.slope    = (b.z - a.z)/dy
            set a.alpha    = Atan(a.slope)
            // Set b.
            if b.ref == a then
                set b.angle     = a.angle + bj_PI
                set b.distance  = dy
                set b.slope     = -a.slope
                set b.alpha     = -a.alpha
                set b.square    = dx
            endif
        endmethod

        static method link takes thistype a, thistype b returns nothing
            set a.ref = b
            set b.ref = a
            call math(a, b)
        endmethod

        method move takes real toX, real toY, real toZ returns nothing
            set x = toX
            set y = toY
            set z = toZ + GetLocZ(toX, toY)
            if ref != this then
                call math(this, ref)
            endif
        endmethod

        method destroy takes nothing returns nothing
            call .deallocate()
        endmethod

        static method create takes real x, real y, real z returns Coordinates
            local thistype this = thistype.allocate()
            set ref = this
            call move(x, y, z)
            return this
        endmethod
    endstruct
        
    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private module OnHit
        set o = origin
        set h = height
        set c = open
        set d = o.distance
    
        if .onHit.exists then
            if allocated and collision > 0 then
                call GroupEnumUnitsInRange(group, x, y, collision + COLLISION_SIZE, null)
                loop
                    set u = FirstOfGroup(group)
                    exitwhen u == null
                        if not HaveSavedBoolean(table, this, GetHandleId(u)) then
                            if IsUnitInRangeXY(u, x, y, collision) then
                                if collideZ then
                                    set dx = GetLocZ(GetUnitX(u), GetUnitY(u)) + GetUnitFlyHeight(u)
                                    set dy = BlzGetUnitCollisionSize(u)
                                    if dx + dy >= z - collision and dx <= z + collision then
                                        call SaveBoolean(table, this, GetHandleId(u), true)
                                        if allocated and .onHit(u) then
                                            call terminate()
                                            exitwhen true
                                        endif
                                    endif
                                else
                                    call SaveBoolean(table, this, GetHandleId(u), true)
                                    if allocated and .onHit(u) then
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
                                if SquareRoot(dx*dx + dy*dy) <= collision then
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
                call EnumDestructablesInRect(rect, null, function thistype.onDest)
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
       
    private module OnCliff
        if .onCliff.exists then
            set dx = GetTerrainCliffLevel(nextX, nextY)
            set dy = GetTerrainCliffLevel(x, y) 
            if dy < dx and z  < (dx - GetMapCliffLevel())*bj_CLIFFHEIGHT then
                if allocated and .onCliff() then
                    call terminate()
                endif
            endif
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
    
    private module OnOrient
        // Homing or not
        set u = target
        if u != null and GetUnitTypeId(u) != 0 then
            call impact.move(GetUnitX(u), GetUnitY(u), GetUnitFlyHeight(u) + toZ)
            set dx = impact.x - nextX
            set dy = impact.y - nextY
            set a = Atan2(dy, dx)
            set travel = o.distance - SquareRoot(dx*dx + dy*dy)
        else
            set a = o.angle
            set target = null
        endif
        
        // turn rate
        if turn != 0 and not (Cos(cA-a) >= Cos(turn)) then
            if Sin(a-cA) >= 0 then
                set cA = cA + turn
            else
                set cA = cA - turn
            endif
        else
            set cA = a
        endif

        set vel = veloc*dilation
        set yaw = cA
        set s = travel + vel
        set veloc = veloc + acceleration
        set travel = s
        set pitch = o.alpha
        set prevX = x
        set prevY = y
        set prevZ = z
        set x = nextX
        set y = nextY
        set z = nextZ
        set nextX = x + vel*Cos(yaw)
        set nextY = y + vel*Sin(yaw)

        // arc calculation
        if h != 0 or o.slope != 0 then
            set nextZ = 4*h*s*(d-s)/(d*d) + o.slope*s + o.z
            set pitch = pitch - Atan(((4*h)*(2*s - d))/(d*d))
        endif
        
        // curve calculation
        if c != 0 then
            set dx = 4*c*s*(d-s)/(d*d)
            set a = yaw + bj_PI/2
            set x = x + dx*Cos(a)
            set y = y + dx*Sin(a)
            set yaw = yaw + Atan(-((4*c)*(2*s - d))/(d*d))
        endif
    endmodule
    
    private module OnFinish
        if s >= d - 0.0001 then
            set finished = true
            if .onFinish.exists then
                if allocated and .onFinish() then
                    call terminate()
                else
                    if travel > 0 and not paused then
                        call terminate()
                    endif
                endif
            else
                call terminate()
            endif
        else
            if not roll then
                call effect.orient(yaw, -pitch, 0)
            else
                call effect.orient(yaw, -pitch, Atan2(c, h))
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
        endif
    endmodule
    
    private module OnPause
        set pid = pid + 1
        set pkey = pid
        set frozen[pid] = this
        
        if .onPause.exists then
            if allocated and .onPause() then
                call terminate()
            endif
        endif
    endmodule
    
    private module OnResume
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
                set dilation = (id + 1)/SWEET_SPOT
            else
                set dilation = 1.
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
    endmodule
    
    private module OnRemove
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
                call Pool.recycle(dummy)
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
    endmodule
    
    private module Operators
        /* -------------------------- Model of the missile -------------------------- */
        method operator model= takes string fx returns nothing
            call DestroyEffect(effect.effect)
            set effect.path = fx
            set effect.effect = AddSpecialEffect(fx, origin.x, origin.y)
            call BlzSetSpecialEffectZ(effect.effect, origin.z)
            call BlzSetSpecialEffectYaw(effect.effect, cA)
        endmethod

        method operator model takes nothing returns string
            return effect.path
        endmethod
        
        /* ----------------------------- Curved movement ---------------------------- */
        method operator curve= takes real value returns nothing
            set open = Tan(value*bj_DEGTORAD)*origin.distance
        endmethod
        
        method operator curve takes nothing returns real
            return Atan(open/origin.distance)*bj_RADTODEG
        endmethod
        
        /* ----------------------------- Arced Movement ----------------------------- */
        method operator arc= takes real value returns nothing
            set height = Tan(value*bj_DEGTORAD)*origin.distance/4
        endmethod
        
        method operator arc takes nothing returns real
            return Atan(4*height/origin.distance)*bj_RADTODEG
        endmethod
        
        /* ------------------------------ Effect scale ------------------------------ */
        method operator scale= takes real value returns nothing
            set effect.size = value
            call effect.scale(effect.effect, value)
        endmethod

        method operator scale takes nothing returns real
            return effect.size
        endmethod

        /* ------------------------------ Missile Speed ----------------------------- */
        method operator speed= takes real newspeed returns nothing
            local real d = origin.distance
            local real s
            local real vel
        
            set veloc = newspeed*PERIOD
            set vel = veloc*dilation
            set s = travel + vel
            set nextX = x + vel*Cos(cA)
            set nextY = y + vel*Sin(cA)

            if height != 0 or origin.slope != 0 then
                set nextZ = 4*height*s*(d-s)/(d*d) + origin.slope*s + origin.z
                set z = nextZ
            endif
        endmethod

        method operator speed takes nothing returns real
            return veloc/PERIOD
        endmethod

        /* ------------------------------- Flight Time ------------------------------ */
        method operator duration= takes real flightTime returns nothing
            local real d = origin.distance
            local real s
            local real vel
        
            set veloc = RMaxBJ(0.00000001, (origin.distance - travel)*PERIOD/RMaxBJ(0.00000001, flightTime))
            set time = flightTime
            set vel = veloc*dilation
            set s = travel + vel
            set nextX = x + vel*Cos(cA)
            set nextY = y + vel*Sin(cA)

            if height != 0 or origin.slope != 0 then
                set nextZ = 4*height*s*(d-s)/(d*d) + origin.slope*s + origin.z
                set z = nextZ
            endif
        endmethod
        
        method operator duration takes nothing returns real
            return time
        endmethod
        
        /* ------------------------------- Sight Range ------------------------------ */
        method operator vision= takes real sightRange returns nothing
            set sight = sightRange
            
            if dummy == null then
                if owner == null then
                    if source != null then
                        set dummy = Pool.retrieve(x, y, z, 0)
                        call SetUnitOwner(dummy, GetOwningPlayer(source), false)
                        call BlzSetUnitRealField(dummy, UNIT_RF_SIGHT_RADIUS, sightRange)
                    endif
                else
                    set dummy = Pool.retrieve(x, y, z, 0)
                    call SetUnitOwner(dummy, owner, false)
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

        /* ------------------------------- Time Scale ------------------------------- */
        method operator timeScale= takes real newTimeScale returns nothing
            set effect.timeScale = newTimeScale
        endmethod
        
        method operator timeScale takes nothing returns real
            return effect.timeScale
        endmethod

        /* ---------------------------------- Alpha --------------------------------- */
        method operator alpha= takes integer newAlpha returns nothing
            set effect.alpha = newAlpha
        endmethod

        method operator alpha takes nothing returns integer
            return effect.alpha
        endmethod

        /* ------------------------------ Player Color ------------------------------ */
        method operator playerColor= takes integer playerId returns nothing
            set effect.playerColor = playerId
        endmethod

        method operator playerColor takes nothing returns integer
            return effect.playerColor
        endmethod

        /* -------------------------------- Animation ------------------------------- */
        method operator animation= takes integer animType returns nothing
            set effect.animation = animType
        endmethod

        method operator animation takes nothing returns integer
            return effect.animation
        endmethod
    endmodule
    
    private module Methods
        /* --------------------------- Bounce and Deflect --------------------------- */
        method bounce takes nothing returns nothing
            call origin.move(x, y, z - GetLocZ(x, y))
            
            set travel = 0
            set finished = false
        endmethod

        method deflect takes real tx, real ty, real tz returns nothing
            local real locZ = GetLocZ(x, y)
            
            set target = null
            set toZ = tz
            
            if z < locZ and .onTerrain.exists then
                set nextX = prevX
                set nextY = prevY
                set nextZ = prevZ
            endif
            
            call impact.move(tx, ty, tz)
            call origin.move(x, y, z - locZ)
            
            set travel = 0
            set finished = false
        endmethod
        
        method deflectTarget takes unit u returns nothing
            call deflect(GetUnitX(u), GetUnitY(u), toZ)
            set target = u
        endmethod

        /* ---------------------------- Flush hit targets --------------------------- */
        method flushAll takes nothing returns nothing
            call FlushChildHashtable(table, this)
        endmethod

        method flush takes widget w returns nothing
            if w != null then
                call RemoveSavedBoolean(table, this, GetHandleId(w))
            endif
        endmethod

        method hitted takes widget w returns boolean
            return HaveSavedBoolean(table, this, GetHandleId(w))
        endmethod

        /* ----------------------- Missile attachment methods ----------------------- */
        method attach takes string model, real dx, real dy, real dz, real scale returns effect
            return effect.attach(model, dx, dy, dz, scale)
        endmethod

        method detach takes effect attachment returns nothing
            if attachment != null then
                call effect.detach(attachment)
            endif
        endmethod

        /* ------------------------------ Missile Pause ----------------------------- */
        method pause takes boolean flag returns nothing
            implement OnResume
        endmethod

        /* ---------------------------------- Color --------------------------------- */
        method color takes integer red, integer green, integer blue returns nothing
            call effect.setColor(red, green, blue)
        endmethod
        
        /* ---------------------- Destructable collision method --------------------- */
        static method onDest takes nothing returns nothing
            local thistype this  = temp
            local destructable d = GetEnumDestructable()
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

        /* -------------------------- Item collision method ------------------------- */
        static method onItems takes nothing returns nothing
            local thistype this  = temp
            local item i = GetEnumItem()
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

        /* -------------------------------- Terminate ------------------------------- */
        method terminate takes nothing returns nothing
            implement OnRemove
        endmethod
    endmodule

    struct Missiles extends MissileEvents
        private static timer timer = CreateTimer()
        private static group group = CreateGroup()
        private static rect rect = Rect(0., 0., 0., 0.)
        private static hashtable table = InitHashtable()
        private static integer last = 0 
        private static thistype temp = 0
        private static integer id = -1
        private static integer pid = -1
        private static thistype array missiles
        private static thistype array frozen
        private static real dilation = 1
        
        readonly static thistype array collection
        readonly static integer count = -1
        
        private real     cA
        private real     height
        private real     open
        private real     toZ
        private real     time
        private real     sight
        private unit     dummy
        private integer  pkey
        private integer  index
        
        Coordinates      impact
        Coordinates      origin
        MissileEffect    effect
        
        readonly real    x
        readonly real    y
        readonly real    z
        readonly real    prevX
        readonly real    prevY
        readonly real    prevZ
        readonly real    nextX
        readonly real    nextY
        readonly real    nextZ
        readonly real    turn
        readonly real    veloc
        readonly real    travel
        readonly boolean launched
        readonly boolean allocated
        readonly boolean finished
        readonly boolean paused
        readonly integer tileset
        
        unit             source
        unit             target
        player           owner
        boolean          collideZ
        real             collision
        real             damage
        real             acceleration
        integer          data
        integer          type
        boolean          roll
        
        implement Operators
        implement Methods

        /* ------------------------------ Reset members ----------------------------- */
        private method reset takes nothing returns nothing
            set launched     = false
            set finished     = false
            set collideZ     = false
            set paused       = false
            set roll         = false
            set source       = null
            set target       = null
            set owner        = null
            set dummy        = null
            set open         = 0.
            set height       = 0.
            set veloc        = 0.
            set acceleration = 0.
            set collision    = 0.
            set damage       = 0.
            set travel       = 0.
            set turn         = 0.
            set time         = 0.
            set sight        = 0.
            set data         = 0
            set type         = 0
            set tileset      = 0
            set pkey         = -1
            set index        = -1
        endmethod

        /* -------------------------- Destroys the missile -------------------------- */
        private method remove takes integer i returns integer
            if paused then
                implement OnPause
            else
                implement OnRemove
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
        
        /* ---------------------------- Missiles movement --------------------------- */
        private static method move takes nothing returns nothing
            local integer     j = 0
            local integer     i
            local integer     k
            local unit        u
            local real        a
            local real        d
            local real        s
            local real        h
            local real        c
            local real        dx
            local real        dy
            local real        vel
            local real        yaw
            local real        pitch
            local Missiles    missile
            local Coordinates o
            local thistype    this

            if SWEET_SPOT > 0 then
                set i = last
            else
                set i = 0
            endif
            
            loop
                exitwhen ((j >= SWEET_SPOT and SWEET_SPOT > 0) or j > id)
                    set this = missiles[i]
                    set temp = this
                    if allocated and not paused then
                        implement OnHit
                        implement OnMissile
                        implement OnDestructable
                        implement OnItem
                        implement OnCliff
                        implement OnTerrain
                        implement OnTileset
                        implement OnPeriod
                        implement OnOrient
                        implement OnFinish
                        implement OnBoundaries
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
        
        /* --------------------------- Launch the Missile --------------------------- */
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
                    set dilation = 1.
                endif

                if id == 0 then
                    call TimerStart(timer, PERIOD, true, function thistype.move)
                endif
            endif
        endmethod

        /* --------------------------- Main Creator method -------------------------- */
        static method create takes real x, real y, real z, real toX, real toY, real toZ returns thistype
            local thistype this  = thistype.allocate()

            call .reset()
            set .origin = Coordinates.create(x, y, z)
            set .impact = Coordinates.create(toX, toY, toZ)
            set .effect = MissileEffect.create(x, y, origin.z)
            call Coordinates.link(origin, impact)
            set .allocated = true
            set .cA = origin.angle
            set .x = x
            set .y = y
            set .z = impact.z
            set .prevX = x
            set .prevY = y
            set .prevZ = impact.z
            set .nextX = x
            set .nextY = y
            set .nextZ = impact.z
            set .toZ = toZ
            
            return this
        endmethod
    endstruct
endlibrary