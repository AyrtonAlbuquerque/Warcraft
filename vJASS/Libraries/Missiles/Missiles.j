library Missiles requires Effect, Dummy, Modules, Utilities, TimerUtils, WorldBounds, optional Enumerable
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
        // If you want Missiles the Enumerable library
        private constant boolean USE_ENUMERABLE     = true
    endglobals
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                            JASS API                                            */
    /* ---------------------------------------------------------------------------------------------- */
    // For those who are not so well versed in JASS structs, you can use the missile API together with
    // these function interfaces to set up your missiles. Simply create functions that have the same 
    // arguments as one of these and then call the corresponding SetMissileOn...Callback functions,
    // passing the function name you created as an argument. 
    function interface OnMoveEvent takes Missile missile returns nothing
    function interface OnUnitEvent takes Missile missile, unit u returns boolean
    function interface OnItemEvent takes Missile missile, item i returns boolean
    function interface OnMissileEvent takes Missile missile, Missile m returns boolean
    function interface OnDestructableEvent takes Missile missile, destructable d returns boolean
    function interface OnCliffEvent takes Missile missile returns boolean
    function interface OnTerrainEvent takes Missile missile returns boolean
    function interface OnTilesetEvent takes Missile missile, integer tileset returns boolean
    function interface OnPeriodEvent takes Missile missile returns boolean
    function interface OnFinishEvent takes Missile missile returns boolean
    function interface OnBoundariesEvent takes Missile missile returns boolean
    function interface OnPauseEvent takes Missile missile returns boolean
    function interface OnResumeEvent takes Missile missile returns boolean
    function interface OnRemoveEvent takes Missile missile returns nothing
    
    /* ---------------------------------------- Missiles --------------------------------------- */
    function CreateMissile takes real x, real y, real z, real toX, real toY, real toZ returns Missile
        return Missile.create(x, y, z, toX, toY, toZ)
    endfunction

    function DestroyMissile takes Missile missile returns nothing
        if missile != 0 then
            call missile.terminate()
        endif
    endfunction

    function LaunchMissile takes Missile missile returns nothing
        if missile != 0 then
            call missile.launch()
        endif
    endfunction

    function SetMissileOnMoveCallback takes Missile missile, OnMoveEvent callback returns nothing
        if missile != 0 then
            set missile.OnMove = callback
        endif
    endfunction

    function SetMissileOnUnitCallback takes Missile missile, OnUnitEvent callback returns nothing
        if missile != 0 then
            set missile.OnUnit = callback
        endif
    endfunction

    function SetMissileOnItemCallback takes Missile missile, OnItemEvent callback returns nothing
        if missile != 0 then
            set missile.OnItem = callback
        endif
    endfunction

    function SetMissileOnMissileCallback takes Missile missile, OnMissileEvent callback returns nothing
        if missile != 0 then
            set missile.OnMissile = callback
        endif
    endfunction

    function SetMissileOnDestructableCallback takes Missile missile, OnDestructableEvent callback returns nothing
        if missile != 0 then
            set missile.OnDestructable = callback
        endif
    endfunction

    function SetMissileOnCliffCallback takes Missile missile, OnCliffEvent callback returns nothing
        if missile != 0 then
            set missile.OnCliff = callback
        endif
    endfunction

    function SetMissileOnTerrainCallback takes Missile missile, OnTerrainEvent callback returns nothing
        if missile != 0 then
            set missile.OnTerrain = callback
        endif
    endfunction

    function SetMissileOnTilesetCallback takes Missile missile, OnTilesetEvent callback returns nothing
        if missile != 0 then
            set missile.OnTileset = callback
        endif
    endfunction

    function SetMissileOnPeriodCallback takes Missile missile, OnPeriodEvent callback returns nothing
        if missile != 0 then
            set missile.OnPeriod = callback
        endif
    endfunction

    function SetMissileOnFinishCallback takes Missile missile, OnFinishEvent callback returns nothing
        if missile != 0 then
            set missile.OnFinish = callback
        endif
    endfunction

    function SetMissileOnBoundariesCallback takes Missile missile, OnBoundariesEvent callback returns nothing
        if missile != 0 then
            set missile.OnBoundaries = callback
        endif
    endfunction

    function SetMissileOnPauseCallback takes Missile missile, OnPauseEvent callback returns nothing
        if missile != 0 then
            set missile.OnPause = callback
        endif
    endfunction

    function SetMissileOnResumeCallback takes Missile missile, OnResumeEvent callback returns nothing
        if missile != 0 then
            set missile.OnResume = callback
        endif
    endfunction

    function SetMissileOnRemoveCallback takes Missile missile, OnRemoveEvent callback returns nothing
        if missile != 0 then
            set missile.OnRemove = callback
        endif
    endfunction

    function SetMissileX takes Missile missile, real x returns nothing
        if missile != 0 then
            set missile.x = x
        endif
    endfunction

    function GetMissileX takes Missile missile returns real
        if missile != 0 then
            return missile.x
        endif

        return 0.
    endfunction

    function SetMissileY takes Missile missile, real y returns nothing
        if missile != 0 then
            set missile.y = y
        endif
    endfunction

    function GetMissileY takes Missile missile returns real
        if missile != 0 then
            return missile.y
        endif

        return 0.
    endfunction

    function SetMissileZ takes Missile missile, real z returns nothing
        if missile != 0 then
            set missile.z = z
        endif
    endfunction

    function GetMissileZ takes Missile missile returns real
        if missile != 0 then
            return missile.z
        endif

        return 0.
    endfunction

    function SetMissileYaw takes Missile missile, real yaw returns nothing
        if missile != 0 then
            set missile.yaw = yaw
        endif
    endfunction

    function GetMissileYaw takes Missile missile returns real
        if missile != 0 then
            return missile.yaw
        endif

        return 0.
    endfunction

    function SetMissileRoll takes Missile missile, real roll returns nothing
        if missile != 0 then
            set missile.roll = roll
        endif
    endfunction

    function GetMissileRoll takes Missile missile returns real
        if missile != 0 then
            return missile.roll
        endif

        return 0.
    endfunction

    function SetMissilePitch takes Missile missile, real pitch returns nothing
        if missile != 0 then
            set missile.pitch = pitch
        endif
    endfunction

    function GetMissilePitch takes Missile missile returns real
        if missile != 0 then
            return missile.pitch
        endif

        return 0.
    endfunction

    function SetMissileUnit takes Missile missile, unit u returns nothing
        if missile != 0 then
            set missile.unit = u
        endif
    endfunction

    function GetMissileUnit takes Missile missile returns unit
        if missile != 0 then
            return missile.unit
        endif

        return null
    endfunction

    function GetMissileTileset takes Missile missile returns integer
        if missile != 0 then
            return missile.tileset
        endif

        return 0
    endfunction

    function GetMissileTraveledDistance takes Missile missile returns real
        if missile != 0 then
            return missile.traveled
        endif

        return 0.
    endfunction

    function PauseMissile takes Missile missile, boolean flag returns nothing
        if missile != 0 then
            call missile.pause(flag)
        endif
    endfunction

    function IsMissilePaused takes Missile missile returns boolean
        if missile != 0 then
            return missile.paused
        endif

        return false
    endfunction

    function BounceMissile takes Missile missile returns nothing
        if missile != 0 then
            call missile.bounce()
        endif
    endfunction

    function DeflectMissile takes Missile missile, real tx, real ty, real tz returns nothing
        if missile != 0 then
            call missile.deflect(tx, ty, tz)
        endif
    endfunction

    function DeflectMissileTarget takes Missile missile, unit target returns nothing
        if missile != 0 then
            call missile.deflectTarget(target)
        endif
    endfunction

    function SetMissileColor takes Missile missile, integer red, integer green, integer blue returns nothing
        if missile != 0 then
            call missile.color(red, green, blue)
        endif
    endfunction

    function MissileCollided takes Missile missile, agent a returns boolean
        if missile != 0 and a != null then
            return missile.hitted(a)
        endif

        return false
    endfunction

    function MissileResetCollision takes Missile missile, agent a returns nothing
        if missile != 0 and a != null then
            call missile.flush(a)
        endif
    endfunction

    function MissileClearCollisions takes Missile missile returns nothing
        if missile != 0 then
            call missile.flushAll()
        endif
    endfunction

    function MissileAttachEffect takes Missile missile, string model, real dx, real dy, real dz, real scale returns Effect
        if missile != 0 then
            return missile.attach(model, dx, dy, dz, scale)
        endif

        return 0
    endfunction

    function MissileDetachEffect takes Missile missile, Effect e returns nothing
        if missile != 0 and e != 0 then
            call missile.detach(e)
        endif
    endfunction

    function SetMissileSource takes Missile missile, unit source returns nothing
        if missile != 0 then
            set missile.source = source
        endif
    endfunction

    function GetMissileSource takes Missile missile returns unit
        if missile != 0 then
            return missile.source
        endif

        return null
    endfunction

    function SetMissileTarget takes Missile missile, unit target returns nothing
        if missile != 0 then
            set missile.target = target
        endif
    endfunction

    function GetMissileTarget takes Missile missile returns unit
        if missile != 0 then
            return missile.target
        endif

        return null
    endfunction

    function SetMissileDamage takes Missile missile, real damage returns nothing
        if missile != 0 then
            set missile.damage = damage
        endif
    endfunction

    function GetMissileDamage takes Missile missile returns real
        if missile != 0 then
            return missile.damage
        endif

        return 0.
    endfunction

    function SetMissilePlayer takes Missile missile, player p returns nothing
        if missile != 0 then
            set missile.owner = p
        endif
    endfunction

    function GetMissilePlayer takes Missile missile returns player
        if missile != 0 then
            return missile.owner
        endif

        return null
    endfunction

    function SetMissileCollision takes Missile missile, real collision returns nothing
        if missile != 0 then
            set missile.collision = collision
        endif
    endfunction

    function GetMissileCollision takes Missile missile returns real
        if missile != 0 then
            return missile.collision
        endif

        return 0.
    endfunction

    function SetMissileType takes Missile missile, integer t returns nothing
        if missile != 0 then
            set missile.type = t
        endif
    endfunction

    function GetMissileType takes Missile missile returns integer
        if missile != 0 then
            return missile.type
        endif

        return 0
    endfunction

    function SetMissileTurnRate takes Missile missile, real turn returns nothing
        if missile != 0 then
            set missile.turn = turn
        endif
    endfunction

    function GetMissileTurnRate takes Missile missile returns real
        if missile != 0 then
            return missile.turn
        endif

        return 0.
    endfunction

    function SetMissileAcceleration takes Missile missile, real acceleration returns nothing
        if missile != 0 then
            set missile.acceleration = acceleration
        endif
    endfunction

    function GetMissileAcceleration takes Missile missile returns real
        if missile != 0 then
            return missile.acceleration
        endif

        return 0.
    endfunction

    function SetMissileCollideZ takes Missile missile, boolean flag returns nothing
        if missile != 0 then
            set missile.collideZ = flag
        endif
    endfunction

    function DoMissileCollideZ takes Missile missile returns boolean
        if missile != 0 then
            return missile.collideZ
        endif

        return false
    endfunction

    function SetMissileAutoRoll takes Missile missile, boolean flag returns nothing
        if missile != 0 then
            set missile.autoroll = flag
        endif
    endfunction

    function DoMissileAutoRoll takes Missile missile returns boolean
        if missile != 0 then
            return missile.autoroll
        endif

        return false
    endfunction

    function SetMissileData takes Missile missile, integer data returns nothing
        if missile != 0 then
            set missile.data = data
        endif
    endfunction

    function GetMissileData takes Missile missile returns integer
        if missile != 0 then
            return missile.data
        endif

        return 0
    endfunction

    function SetMissileArc takes Missile missile, real arc returns nothing
        if missile != 0 then
            set missile.arc = arc
        endif
    endfunction

    function GetMissileArc takes Missile missile returns real
        if missile != 0 then
            return missile.arc
        endif

        return 0.
    endfunction

    function SetMissileCurve takes Missile missile, real curve returns nothing
        if missile != 0 then
            set missile.curve = curve
        endif
    endfunction

    function GetMissileCurve takes Missile missile returns real
        if missile != 0 then
            return missile.curve
        endif

        return 0.
    endfunction

    function SetMissileModel takes Missile missile, string model returns nothing
        if missile != 0 then
            set missile.model = model
        endif
    endfunction

    function GetMissileModel takes Missile missile returns string
        if missile != 0 then
            return missile.model
        endif

        return null
    endfunction

    function SetMissileScale takes Missile missile, real scale returns nothing
        if missile != 0 then
            set missile.scale = scale
        endif
    endfunction

    function GetMissileScale takes Missile missile returns real
        if missile != 0 then
            return missile.scale
        endif

        return 0.
    endfunction

    function SetMissileSpeed takes Missile missile, real speed returns nothing
        if missile != 0 then
            set missile.speed = speed
        endif
    endfunction

    function GetMissileSpeed takes Missile missile returns real
        if missile != 0 then
            return missile.speed
        endif

        return 0.
    endfunction

    function SetMissileDuration takes Missile missile, real duration returns nothing
        if missile != 0 then
            set missile.duration = duration
        endif
    endfunction

    function GetMissileDuration takes Missile missile returns real
        if missile != 0 then
            return missile.duration
        endif

        return 0.
    endfunction

    function SetMissileAlpha takes Missile missile, integer alpha returns nothing
        if missile != 0 then
            set missile.alpha = alpha
        endif
    endfunction

    function GetMissileAlpha takes Missile missile returns integer
        if missile != 0 then
            return missile.alpha
        endif

        return 0
    endfunction

    function SetMissileSightRange takes Missile missile, real sightRange returns nothing
        if missile != 0 then
            set missile.vision = sightRange
        endif
    endfunction

    function GetMissileSightRange takes Missile missile returns real
        if missile != 0 then
            return missile.vision
        endif

        return 0.
    endfunction

    function SetMissileAnimation takes Missile missile, integer animation returns nothing
        if missile != 0 then
            set missile.animation = animation
        endif
    endfunction

    function GetMissileAnimation takes Missile missile returns integer
        if missile != 0 then
            return missile.animation
        endif

        return 0
    endfunction

    function SetMissileTimeScale takes Missile missile, real timeScale returns nothing
        if missile != 0 then
            set missile.timeScale = timeScale
        endif
    endfunction

    function GetMissileTimeScale takes Missile missile returns real
        if missile != 0 then
            return missile.timeScale
        endif

        return 0.
    endfunction

    function SetMissilePlayerColor takes Missile missile, integer playerId returns nothing
        if missile != 0 then
            set missile.playercolor = playerId
        endif
    endfunction

    function GetMissilePlayerColor takes Missile missile returns integer
        if missile != 0 then
            return missile.playercolor
        endif

        return 0
    endfunction

    /* ------------------------------------- Missile Groups ------------------------------------ */
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
    private module MOnMove
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

        if not .onMove.exists and OnMove == 0 then
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
        elseif .onMove.exists then
            call .onMove()
        elseif OnMove != 0 then
            call OnMove.evaluate(this)
        endif
    endmodule

    private module MOnUnit    
        if .onUnit.exists or OnUnit != 0 then
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

                                        if .onUnit.exists then
                                            if allocated and .onUnit(u) then
                                                call terminate()
                                                exitwhen true
                                            endif
                                        else
                                            if allocated and OnUnit.evaluate(this, u) then
                                                call terminate()
                                                exitwhen true
                                            endif
                                        endif
                                    endif
                                else
                                    call SaveBoolean(table, this, GetHandleId(u), true)

                                    if .onUnit.exists then
                                        if allocated and .onUnit(u) then
                                            call terminate()
                                            exitwhen true
                                        endif
                                    else
                                        if allocated and OnUnit.evaluate(this, u) then
                                            call terminate()
                                            exitwhen true
                                        endif
                                    endif
                                endif
                            endif
                        endif
                    call GroupRemoveUnit(group, u)
                endloop
            endif
        endif
    endmodule
    
    private module MOnItem
        if .onItem.exists or OnItem != 0 then
            if allocated and collision > 0 then
                set dx = collision

                call SetRect(rect, x - dx, y - dx, x + dx, y + dx)
                call EnumItemsInRect(rect, null, function thistype.onItems)
            endif
        endif
    endmodule

    private module MOnMissile
        if .onMissile.exists or OnMissile != 0 then
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

                                    if .onMissile.exists then
                                        if allocated and .onMissile(missile) then
                                            call terminate()
                                            exitwhen true
                                        endif
                                    else
                                        if allocated and OnMissile.evaluate(this, missile) then
                                            call terminate()
                                            exitwhen true
                                        endif
                                    endif
                                endif
                            endif
                        endif
                    set k = k + 1
                endloop
            endif
        endif
    endmodule

    private module MOnDestructable
        if .onDestructable.exists or OnDestructable != 0 then
            if allocated and collision > 0 then
                set dx = collision

                call SetRect(rect, x - dx, y - dx, x + dx, y + dx)
                call EnumDestructablesInRect(rect, null, function thistype.onDestructables)
            endif
        endif
    endmodule
       
    private module MOnCliff
        if .onCliff.exists or OnCliff != 0 then
            set k = GetTerrainCliffLevel(x, y)

            if cliff < k and z < (k - GetTerrainCliffLevel(WorldBounds.maxX, WorldBounds.maxY))*bj_CLIFFHEIGHT then
                if .onCliff.exists then
                    if allocated and .onCliff() then
                        call terminate()
                    endif
                else
                    if allocated and OnCliff.evaluate(this) then
                        call terminate()
                    endif
                endif
            endif

            set cliff = k
        endif
    endmodule
       
    private module MOnTerrain
        if .onTerrain.exists or OnTerrain != 0 then
            if GetLocZ(x, y) > z then
                if .onTerrain.exists then
                    if allocated and .onTerrain() then
                        call terminate()
                    endif
                else
                    if allocated and OnTerrain.evaluate(this) then
                        call terminate()
                    endif
                endif
            endif
        endif
    endmodule
    
    private module MOnTileset
        if .onTileset.exists or OnTileset != 0 then
            set k = GetTerrainType(x, y)

            if k != tileset then
                if .onTileset.exists then
                    if allocated and .onTileset(k) then
                        call terminate()
                    endif
                else
                    if allocated and OnTileset.evaluate(this, k) then
                        call terminate()
                    endif
                endif
            endif

            set tileset = k
        endif
    endmodule
    
    private module MOnPeriod
        if .onPeriod.exists or OnPeriod != 0 then
            if .onPeriod.exists then
                if allocated and .onPeriod() then
                    call terminate()
                endif
            else
                if allocated and OnPeriod.evaluate(this) then
                    call terminate()
                endif
            endif
        endif
    endmodule
    
    private module MOnFinish
        if traveled >= origin.distance - 0.0001 then
            set finished = true

            if .onFinish.exists or OnFinish != 0 then
                if .onFinish.exists then
                    if allocated and .onFinish() then
                        call terminate()
                    else
                        if traveled > 0 and not paused then
                            call terminate()
                        endif
                    endif
                else
                    if allocated and OnFinish.evaluate(this) then
                        call terminate()
                    else
                        if traveled > 0 and not paused then
                            call terminate()
                        endif
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

    private module MOnBoundaries
        if not effect.move(x, y, z) then
            if .onBoundaries.exists or OnBoundaries != 0 then
                if .onBoundaries.exists then
                    if allocated and .onBoundaries() then
                        call terminate()
                    endif
                else
                    if allocated and OnBoundaries.evaluate(this) then
                        call terminate()
                    endif
                endif
            endif
        else
            static if LIBRARY_Enumerable and USE_ENUMERABLE then
                set object.x = x
                set object.y = y
                set object.z = z
            endif

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
        private real size
        private real time
        private real bend
        private real sight
        private real height
        private real curvature
        private unit dummy
        private integer pkey
        private integer cliff
        private integer index

        static if LIBRARY_Enumerable and USE_ENUMERABLE then
            private Object object
        endif
        
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
        boolean autoroll
        boolean collideZ
        real acceleration
        OnMoveEvent OnMove
        OnUnitEvent OnUnit
        OnItemEvent OnItem
        OnPauseEvent OnPause
        OnCliffEvent OnCliff
        OnResumeEvent OnResume
        OnPeriodEvent OnPeriod
        OnFinishEvent OnFinish
        OnRemoveEvent OnRemove
        OnTerrainEvent OnTerrain
        OnTilesetEvent OnTileset
        OnMissileEvent OnMissile
        OnBoundariesEvent OnBoundaries
        OnDestructableEvent OnDestructable

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

            static if LIBRARY_Enumerable and USE_ENUMERABLE then
                call Enumerable.remove(object)

                set object = Object[effect.effect]
                set object.x = x
                set object.y = y
                set object.z = z
                set object.data = this
                set object.onCollide = thistype.onCollide

                call Enumerable.track(object)
            endif
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

        method operator collision= takes real value returns nothing
            set size = value

            static if LIBRARY_Enumerable and USE_ENUMERABLE then
                set object.collision = value
            endif
        endmethod

        method operator collision takes nothing returns real
            return size
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

                if .onResume.exists or OnResume != 0 then
                    if .onResume.exists then
                        if allocated and .onResume() then
                            call terminate()
                        else
                            if finished then
                                call terminate()
                            endif
                        endif
                    else
                        if allocated and OnResume.evaluate(this) then
                            call terminate()
                        else
                            if finished then
                                call terminate()
                            endif
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

                if .onRemove.exists or OnRemove != 0 then
                    if .onRemove.exists then
                        call .onRemove()
                    else
                        call OnRemove.evaluate(this)
                    endif
                endif
                
                if dummy != null then
                    call DummyRecycle(dummy)
                endif
                
                set aux = collection[count]
                set aux.index = index
                set collection[index] = collection[count]
                set count = count - 1
                set index = -1
                
                static if LIBRARY_Enumerable and USE_ENUMERABLE then
                    call Enumerable.remove(object)
                endif

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
            set size = 0
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
            set source = null
            set target = null
            set paused = false
            set acceleration = 0
            set autoroll = false
            set launched = false
            set finished = false
            set collideZ = false
            set OnMove = 0
            set OnUnit = 0
            set OnItem = 0
            set OnMissile = 0
            set OnDestructable = 0
            set OnCliff = 0
            set OnTerrain = 0
            set OnTileset = 0
            set OnPeriod = 0
            set OnFinish = 0
            set OnBoundaries = 0
            set OnPause = 0
            set OnResume = 0
            set OnRemove = 0
        endmethod

        private method remove takes integer i returns integer
            if paused then
                set pid = pid + 1
                set pkey = pid
                set frozen[pid] = this
                
                if .onPause.exists or OnPause != 0 then
                    if .onPause.exists then
                        if allocated and .onPause() then
                            call terminate()
                        endif
                    else
                        if allocated and OnPause.evaluate(this) then
                            call terminate()
                        endif
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
                        implement MOnMove

                        static if LIBRARY_Enumerable and USE_ENUMERABLE then
                        else
                            implement MOnUnit
                            implement MOnItem
                            implement MOnMissile
                            implement MOnDestructable
                        endif

                        implement MOnCliff
                        implement MOnTerrain
                        implement MOnTileset
                        implement MOnPeriod
                        implement MOnFinish
                        implement MOnBoundaries

                        if not .onMove.exists and OnMove == 0 then
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

        static if LIBRARY_Enumerable and USE_ENUMERABLE then
            private static method onCollide takes Object colisor, Object collided returns nothing
                local real dx
                local real dy
                local real dz
                local real tz
                local thistype this = colisor.data
                local thistype missile = collided.data

                if this != 0 and launched and allocated then
                    if collided.isUnit and (.onUnit.exists or OnUnit != 0) then
                        if not HaveSavedBoolean(table, this, GetHandleId(collided.unit)) then
                            if collideZ then
                                set dx = GetUnitZ(collided.unit)
                                set dy = collided.collision

                                if dx + dy >= z - collision and dx <= z + collision then
                                    call SaveBoolean(table, this, GetHandleId(collided.unit), true)

                                    if .onUnit.exists then
                                        if allocated and .onUnit(collided.unit) then
                                            call terminate()
                                        endif
                                    else
                                        if allocated and OnUnit.evaluate(this, collided.unit) then
                                            call terminate()
                                        endif
                                    endif
                                endif
                            else
                                call SaveBoolean(table, this, GetHandleId(collided.unit), true)

                                if .onUnit.exists then
                                    if allocated and .onUnit(collided.unit) then
                                        call terminate()
                                    endif
                                else
                                    if allocated and OnUnit.evaluate(this, collided.unit) then
                                        call terminate()
                                    endif
                                endif
                            endif
                        endif
                    elseif collided.isItem and (.onItem.exists or OnItem != 0) then
                        if not HaveSavedBoolean(table, this, GetHandleId(collided.item)) then
                            if collideZ then
                                set dz = GetLocZ(collided.x, collided.y)

                                if dz + ITEM_SIZE >= z - collision and dz <= z + collision then
                                    call SaveBoolean(table, this, GetHandleId(collided.item), true)

                                    if .onItem.exists then
                                        if allocated and .onItem(collided.item) then
                                            call terminate()
                                            return
                                        endif
                                    else
                                        if allocated and OnItem.evaluate(this, collided.item) then
                                            call terminate()
                                            return
                                        endif
                                    endif
                                endif
                            else
                                call SaveBoolean(table, this, GetHandleId(collided.item), true)

                                if .onItem.exists then
                                    if allocated and .onItem(collided.item) then
                                        call terminate()
                                        return
                                    endif
                                else
                                    if allocated and OnItem.evaluate(this, collided.item) then
                                        call terminate()
                                        return
                                    endif
                                endif
                            endif
                        endif
                    elseif collided.isDestructable and (.onDestructable.exists or OnDestructable != 0) then
                        if not HaveSavedBoolean(table, this, GetHandleId(collided.destructable)) then
                            if collideZ then
                                set dz = GetLocZ(collided.x, collided.y)
                                set tz = GetDestructableOccluderHeight(collided.destructable)

                                if dz + tz >= z - collision and dz <= z + collision then
                                    call SaveBoolean(table, this, GetHandleId(collided.destructable), true)

                                    if .onDestructable.exists then
                                        if allocated and .onDestructable(collided.destructable) then
                                            call terminate()
                                            return
                                        endif
                                    else
                                        if allocated and OnDestructable.evaluate(this, collided.destructable) then
                                            call terminate()
                                            return
                                        endif
                                    endif
                                endif
                            else
                                call SaveBoolean(table, this, GetHandleId(collided.destructable), true)
                                
                                if .onDestructable.exists then
                                    if allocated and .onDestructable(collided.destructable) then
                                        call terminate()
                                        return
                                    endif
                                else
                                    if allocated and OnDestructable.evaluate(this, collided.destructable) then
                                        call terminate()
                                        return
                                    endif
                                endif
                            endif
                        endif
                    elseif missile != 0 and (.onMissile.exists or OnMissile != 0) then
                        if not HaveSavedBoolean(table, this, missile) then
                            call SaveBoolean(table, this, missile, true)

                            if .onMissile.exists then
                                if allocated and .onMissile(missile) then
                                    call terminate()
                                endif
                            else
                                if allocated and OnMissile.evaluate(this, missile) then
                                    call terminate()
                                endif
                            endif
                        endif
                    endif
                endif
            endmethod
        endif

        private static method onItems takes nothing returns nothing
            local item i = GetEnumItem()
            local thistype this = temp
            local real dz

            if not HaveSavedBoolean(table, this, GetHandleId(i)) then
                if collideZ then
                    set dz = GetLocZ(GetItemX(i), GetItemY(i))

                    if dz + ITEM_SIZE >= z - collision and dz <= z + collision then
                        call SaveBoolean(table, this, GetHandleId(i), true)

                        if .onItem.exists then
                            if allocated and .onItem(i) then
                                set i = null
                                call terminate()
                                return
                            endif
                        else
                            if allocated and OnItem.evaluate(this, i) then
                                set i = null
                                call terminate()
                                return
                            endif
                        endif
                    endif
                else
                    call SaveBoolean(table, this, GetHandleId(i), true)

                    if .onItem.exists then
                        if allocated and .onItem(i) then
                            set i = null
                            call terminate()
                            return
                        endif
                    else
                        if allocated and OnItem.evaluate(this, i) then
                            set i = null
                            call terminate()
                            return
                        endif
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

                        if .onDestructable.exists then
                            if allocated and .onDestructable(d) then
                                set d = null
                                call terminate()
                                return
                            endif
                        else
                            if allocated and OnDestructable.evaluate(this, d) then
                                set d = null
                                call terminate()
                                return
                            endif
                        endif
                    endif
                else
                    call SaveBoolean(table, this, GetHandleId(d), true)
                    
                    if .onDestructable.exists then
                        if allocated and .onDestructable(d) then
                            set d = null
                            call terminate()
                            return
                        endif
                    else
                        if allocated and OnDestructable.evaluate(this, d) then
                            set d = null
                            call terminate()
                            return
                        endif
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

            static if LIBRARY_Enumerable and USE_ENUMERABLE then
                set object = Object[effect.effect]
                set object.x = x
                set object.y = y
                set object.z = z
                set object.data = this
                set object.onCollide = thistype.onCollide

                call Enumerable.track(object)
            endif
            
            return this
        endmethod
    endstruct
endlibrary