library MissileUtils requires Missiles, Modules
    /* ------------------------------------- Missile Utils v3.0 ------------------------------------- */
    // This is a simple Utils library for the Relativistic Missiles system.
    /* ---------------------------------------- By Chopinski ---------------------------------------- */
    
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
    
    function GroupMissileAt takes MissileGroup missiles, integer position returns Missiles
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
    
    function IsMissileInGroup takes Missiles missile, MissileGroup missiles returns boolean
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
    
    function GroupRemoveMissile takes MissileGroup missiles, Missiles missile returns nothing
        if missiles != 0 and missile != 0 then
            if missiles.size > 0 then
                call missiles.remove(missile)
            endif
        endif
    endfunction
    
    function GroupAddMissile takes MissileGroup missiles, Missiles missile returns nothing
        if missiles != 0 and missile != 0 then
            if not missiles.contains(missile) then
                call missiles.insert(missile)
            endif
        endif
    endfunction
    
    function GroupPickRandomMissile takes MissileGroup missiles returns Missiles
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
    
    function FirstOfMissileGroup takes MissileGroup missiles returns Missiles
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
        local Missiles missile
        
        if missiles != 0 then
            if Missiles.count > -1 then
                set i = 0
                
                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missiles.count
                        set missile = Missiles.collection[i]
                        
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
        local Missiles missile
        
        if missiles != 0 then
            if Missiles.count > -1 then
                set i = 0
                
                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missiles.count or j == 0
                        set missile = Missiles.collection[i]
                        
                        if missile.type == whichType then
                            call missiles.insert(missile)
                        endif
                        set j = j - 1
                    set i = i + 1
                endloop
            endif
        endif
    endfunction
    
    function GroupEnumMissilesOfPlayer takes MissileGroup missiles, player p returns nothing
        local integer i
        local Missiles missile
        
        if missiles != 0 then
            if Missiles.count > -1 then
                set i = 0
                
                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missiles.count
                        set missile = Missiles.collection[i]
                        
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
        local Missiles missile
        
        if missiles != 0 then
            if Missiles.count > -1 then
                set i = 0
                
                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missiles.count or j == 0
                        set missile = Missiles.collection[i]
                        
                        if missile.owner == p then
                            call missiles.insert(missile)
                        endif
                        set j = j - 1
                    set i = i + 1
                endloop
            endif
        endif
    endfunction
    
    function GroupEnumMissilesInRect takes MissileGroup missiles, rect r returns nothing
        local integer i
        local Missiles missile
        
        if missiles != 0 and r != null then
            if Missiles.count > -1 then
                set i = 0
                
                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missiles.count
                        set missile = Missiles.collection[i]
                        
                        if GetRectMinX(r) <= missile.x and missile.x <= GetRectMaxX(r) and GetRectMinY(r) <= missile.y and missile.y <= GetRectMaxY(r) then
                            call missiles.insert(missile)
                        endif
                    set i = i + 1
                endloop
            endif
        endif
    endfunction
    
    function GroupEnumMissilesInRectCounted takes MissileGroup missiles, rect r, integer amount returns nothing
        local integer i
        local integer j = amount
        local Missiles missile
        
        if missiles != 0 and r != null then
            if Missiles.count > -1 then
                set i = 0
                
                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missiles.count or j == 0
                        set missile = Missiles.collection[i]
                        
                        if GetRectMinX(r) <= missile.x and missile.x <= GetRectMaxX(r) and GetRectMinY(r) <= missile.y and missile.y <= GetRectMaxY(r) then
                            call missiles.insert(missile)
                        endif
                        set j = j - 1
                    set i = i + 1
                endloop
            endif
        endif
    endfunction
    
    function GroupEnumMissilesInRangeOfLoc takes MissileGroup missiles, location loc, real radius returns nothing
        local real dx
        local real dy
        local integer i
        local Missiles missile
    
        if missiles != 0 and radius > 0 and loc != null then
            if Missiles.count > -1 then
                set i = 0
                
                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missiles.count
                        set missile = Missiles.collection[i]
                        set dx = missile.x - GetLocationX(loc)
                        set dy = missile.y - GetLocationY(loc)
                        
                        if SquareRoot(dx*dx + dy*dy) <= radius then
                            call missiles.insert(missile)
                        endif
                    set i = i + 1
                endloop
            endif
        endif
    endfunction
    
    function GroupEnumMissilesInRangeOfLocCounted takes MissileGroup missiles, location loc, real radius, integer amount returns nothing
        local real dx
        local real dy
        local integer i
        local integer j = amount
        local Missiles missile
    
        if missiles != 0 and radius > 0 and loc != null then
            if Missiles.count > -1 then
                set i = 0
                
                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missiles.count or j == 0
                        set missile = Missiles.collection[i]
                        set dx = missile.x - GetLocationX(loc)
                        set dy = missile.y - GetLocationY(loc)
                        
                        if SquareRoot(dx*dx + dy*dy) <= radius then
                            call missiles.insert(missile)
                        endif
                        set j = j - 1
                    set i = i + 1
                endloop
            endif
        endif
    endfunction
    
    function GroupEnumMissilesInRange takes MissileGroup missiles, real x, real y, real radius returns nothing
        local real dx
        local real dy
        local integer i
        local Missiles missile
    
        if missiles != 0 and radius > 0 then
            if Missiles.count > -1 then
                set i = 0
                
                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missiles.count
                        set missile = Missiles.collection[i]
                        set dx = missile.x - x
                        set dy = missile.y - y
                        
                        if SquareRoot(dx*dx + dy*dy) <= radius then
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
        local Missiles missile
    
        if missiles != 0 and radius > 0 then
            if Missiles.count > -1 then
                set i = 0
                
                if missiles.size > 0 then
                    call missiles.clear()
                endif
                
                loop
                    exitwhen i > Missiles.count or j == 0
                        set missile = Missiles.collection[i]
                        set dx = missile.x - x
                        set dy = missile.y - y
                        
                        if SquareRoot(dx*dx + dy*dy) <= radius then
                            call missiles.insert(missile)
                        endif
                        set j = j - 1
                    set i = i + 1
                endloop
            endif
        endif
    endfunction

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    struct MissileGroup
        readonly List group
        
        method operator size takes nothing returns integer
            return group.size
        endmethod

        method destroy takes nothing returns nothing
            call group.destroy()
            call deallocate()
        endmethod
        
        method missileAt takes integer i returns Missiles
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
        
        method remove takes Missiles missile returns nothing
            call group.remove(missile)
        endmethod
        
        method insert takes Missiles missile returns nothing
            call group.insert(missile)
        endmethod
        
        method clear takes nothing returns nothing
            call group.clear()
        endmethod
        
        method contains takes Missiles missile returns boolean
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
endlibrary