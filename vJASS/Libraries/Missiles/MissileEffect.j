library MissileEffect requires WorldBounds, Alloc
    /* ------------------------------------- Missile Effect v2.7 ------------------------------------ */
    // This is a simple helper library for the Relativistic Missiles system.
    // Credits:
    //     Sevion for the Alloc module
    //         - www.hiveworkshop.com/threads/snippet-alloc.192348/
    //     Nestharus for World Bounds Library
    /* ---------------------------------------- By Chopinski ---------------------------------------- */
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    private module LinkedList
        readonly thistype next
        readonly thistype prev

        method init takes nothing returns thistype
            set next = this
            set prev = this

            return this
        endmethod

        method pushBack takes thistype node returns thistype
            set node.prev = prev
            set node.next = this
            set prev.next = node
            set prev = node

            return node
        endmethod

        method pushFront takes thistype node returns thistype
            set node.prev = this
            set node.next = next
            set next.prev = node
            set next = node

            return node
        endmethod

        method pop takes nothing returns nothing
            set prev.next = next
            set next.prev = prev
        endmethod
    endmodule

    private struct Effect extends array
        implement LinkedList
        implement Alloc

        real    x
        real    y
        real    z
        real    size
        real    yaw
        real    pitch
        real    roll
        string  path
        effect  effect

        method remove takes nothing returns nothing
            call DestroyEffect(effect)
            call pop()
            call deallocate()
            set effect = null
        endmethod

        method insert takes string fxpath, real x, real y, real z, real scale returns thistype
            local thistype node = pushBack(allocate())

            set node.x      = x
            set node.y      = y
            set node.z      = z
            set node.yaw    = 0.
            set node.pitch  = 0.
            set node.roll   = 0.
            set node.path   = fxpath
            set node.size   = scale
            set node.effect = AddSpecialEffect(fxpath, x, y)
            call BlzSetSpecialEffectZ(node.effect, z)
            call BlzSetSpecialEffectScale(node.effect, scale)

            return node
        endmethod

        static method create takes nothing returns thistype
            return thistype(allocate()).init()
        endmethod
    endstruct

    struct MissileEffect
        real    size
        real    yaw
        real    pitch
        real    roll
        real    time
        integer transparency
        integer animtype
        integer playercolor
        string  path
        effect  effect
        Effect  attachments

        /* -------------------------------- Operators ------------------------------- */
        method operator timeScale= takes real newTimeScale returns nothing
            set time = newTimeScale
            call BlzSetSpecialEffectTimeScale(effect, time)
        endmethod
        
        method operator timeScale takes nothing returns real
            return time
        endmethod

        method operator alpha= takes integer newAlpha returns nothing
            set transparency = newAlpha
            call BlzSetSpecialEffectAlpha(effect, transparency)
        endmethod

        method operator alpha takes nothing returns integer
            return transparency
        endmethod

        method operator playerColor= takes integer playerId returns nothing
            set playercolor = playerId
            call BlzSetSpecialEffectColorByPlayer(effect, Player(playerId))
        endmethod

        method operator playerColor takes nothing returns integer
            return playercolor
        endmethod

        method operator animation= takes integer animType returns nothing
            set animtype = animType
            call BlzPlaySpecialEffect(effect, ConvertAnimType(animtype))
        endmethod

        method operator animation takes nothing returns integer
            return animtype
        endmethod

        /* --------------------------------- Methods -------------------------------- */
        method scale takes effect sfx, real scale returns nothing
            set size = scale
            call BlzSetSpecialEffectScale(sfx, scale)
        endmethod   

        method orient takes real yaw, real pitch, real roll returns nothing
            local Effect node = attachments.next

            set .yaw   = yaw
            set .pitch = pitch
            set .roll  = roll
            call BlzSetSpecialEffectOrientation(effect, yaw, pitch, roll)

            loop
                exitwhen node == attachments
                    set node.yaw   = yaw
                    set node.pitch = pitch
                    set node.roll  = roll
                    call BlzSetSpecialEffectOrientation(node.effect, yaw, pitch, roll)
                set node = node.next
            endloop
        endmethod

        method move takes real x, real y, real z returns boolean
            local Effect node = attachments.next

            if not (x > WorldBounds.maxX or x < WorldBounds.minX or y > WorldBounds.maxY or y < WorldBounds.minY) then
                call BlzSetSpecialEffectPosition(effect, x, y, z)
                loop
                    exitwhen node == attachments
                        call BlzSetSpecialEffectPosition(node.effect, x - node.x, y - node.y, z - node.z)
                    set node = node.next
                endloop
                return true
            endif
            return false
        endmethod

        method attach takes string fxpath, real dx, real dy, real dz, real scale returns effect
            local Effect node = attachments.insert(fxpath, dx, dy, dz, scale)

            call BlzSetSpecialEffectPosition(node.effect, BlzGetLocalSpecialEffectX(effect) - dx, BlzGetLocalSpecialEffectY(effect) - dy, BlzGetLocalSpecialEffectZ(effect) - dz)

            return node.effect
        endmethod

        method detach takes effect sfx returns nothing
            local Effect node = attachments.next

            loop
                exitwhen node == attachments
                    if GetHandleId(node.effect) == GetHandleId(sfx) then
                        call node.remove()
                        exitwhen true
                    endif
                set node = node.next
            endloop
        endmethod

        method setColor takes integer red, integer green, integer blue returns nothing
            call BlzSetSpecialEffectColor(effect, red, green, blue)
        endmethod

        /* -------------------------- Contructor/Destructor ------------------------- */
        method destroy takes nothing returns nothing
            local Effect node = attachments.next

            loop
                exitwhen node == attachments
                    call node.remove()
                set node = node.next
            endloop
            call DestroyEffect(effect)
            call attachments.deallocate()
            
            set effect = null
            set path   = null
            set size   = 1.
            call deallocate()
        endmethod

        static method create takes real x, real y, real z returns thistype
            local thistype this = thistype.allocate()

            set effect = AddSpecialEffect("", x, y)
            set path = ""
            set size = 1
            set time = 0
            set transparency = 0
            set animtype = 0
            set playercolor = 0
            set attachments = Effect.create()
            call BlzSetSpecialEffectZ(effect, z)

            return this
        endmethod
    endstruct
endlibrary