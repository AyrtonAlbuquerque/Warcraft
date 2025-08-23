library Effect requires Modules, WorldBounds
    struct Effect
        private real dx
        private real dy
        private real dz
        private real xPos
        private real yPos
        private real zPos
        private real size
        private real time
        private real view
        private real angle
        private real rotation
        private string path
        private integer animtype
        private integer playerColor
        private integer transparency

        readonly effect effect
        readonly List attachments

        method operator x takes nothing returns real
            return xPos
        endmethod

        method operator x= takes real value returns nothing
            set xPos = value

            call BlzSetSpecialEffectX(effect, value)
            call update()
        endmethod

        method operator y takes nothing returns real
            return yPos
        endmethod

        method operator y= takes real value returns nothing
            set yPos = value

            call BlzSetSpecialEffectY(effect, value)
            call update()
        endmethod

        method operator z takes nothing returns real
            return zPos
        endmethod

        method operator z= takes real value returns nothing
            set zPos = value

            call BlzSetSpecialEffectZ(effect, value)
            call update()
        endmethod

        method operator yaw takes nothing returns real
            return view
        endmethod

        method operator yaw= takes real value returns nothing
            set view = value

            call BlzSetSpecialEffectYaw(effect, value)
            call update()
        endmethod

        method operator pitch takes nothing returns real
            return angle
        endmethod

        method operator pitch= takes real value returns nothing
            set angle = value

            call BlzSetSpecialEffectPitch(effect, value)
            call update()
        endmethod

        method operator roll takes nothing returns real
            return rotation
        endmethod

        method operator roll= takes real value returns nothing
            set rotation = value

            call BlzSetSpecialEffectRoll(effect, value)
            call update()
        endmethod

        method operator model takes nothing returns string
            return path
        endmethod

        method operator model= takes string sfx returns nothing
            if sfx != path then
                call DestroyEffect(effect)

                set path = sfx
                set effect = AddSpecialEffect(sfx, x, y)

                call BlzSetSpecialEffectPosition(effect, x, y, z)
                call BlzSetSpecialEffectOrientation(effect, yaw, pitch, roll)
                call BlzSetSpecialEffectScale(effect, size)
            endif
        endmethod

        method operator scale takes nothing returns real
            return size
        endmethod

        method operator scale= takes real value returns nothing
            local List node = attachments.next

            set size = value

            call BlzSetSpecialEffectScale(effect, value)

            loop
                exitwhen node == attachments
                    set Effect(node.data).scale = value
                set node = node.next
            endloop
        endmethod

        method operator alpha takes nothing returns integer
            return transparency
        endmethod

        method operator alpha= takes integer newAlpha returns nothing
            local List node = attachments.next

            set transparency = newAlpha

            call BlzSetSpecialEffectAlpha(effect, transparency)

            loop
                exitwhen node == attachments
                    set Effect(node.data).alpha = transparency
                set node = node.next
            endloop
        endmethod
        
        method operator animation takes nothing returns integer
            return animtype
        endmethod

        method operator animation= takes integer animType returns nothing
            local List node = attachments.next

            set animtype = animType

            call BlzPlaySpecialEffect(effect, ConvertAnimType(animtype))

            loop
                exitwhen node == attachments
                    set Effect(node.data).animation = animtype
                set node = node.next
            endloop
        endmethod

        method operator timeScale takes nothing returns real
            return time
        endmethod

        method operator timeScale= takes real newTimeScale returns nothing
            local List node = attachments.next

            set time = newTimeScale

            call BlzSetSpecialEffectTimeScale(effect, time)

            loop
                exitwhen node == attachments
                    set Effect(node.data).timeScale = newTimeScale
                set node = node.next
            endloop
        endmethod  

        method operator playercolor takes nothing returns integer
            return playercolor
        endmethod

        method operator playercolor= takes integer id returns nothing
            local List node = attachments.next

            set playercolor = id

            call BlzSetSpecialEffectColorByPlayer(effect, Player(id))

            loop
                exitwhen node == attachments
                    set Effect(node.data).playercolor = id
                set node = node.next
            endloop
        endmethod

        method destroy takes nothing returns nothing
            local List node = attachments.next

            loop
                exitwhen node == attachments
                    call Effect(node.data).destroy()
                set node = node.next
            endloop

            call DestroyEffect(effect)
            call attachments.destroy()
            call deallocate()

            set effect = null
        endmethod

        method orient takes real yaw, real pitch, real roll returns nothing
            set view = yaw
            set angle = pitch
            set rotation = roll

            call BlzSetSpecialEffectOrientation(effect, yaw, pitch, roll)
            call update()
        endmethod

        method move takes real x, real y, real z returns boolean
            if not (x > WorldBounds.maxX or x < WorldBounds.minX or y > WorldBounds.maxY or y < WorldBounds.minY) then
                set xPos = x
                set yPos = y
                set zPos = z
                
                call BlzSetSpecialEffectPosition(effect, x, y, z)
                call update()

                return true
            endif

            return false
        endmethod

        method attach takes string model, real dx, real dy, real dz, real scale returns thistype
            local thistype attachment = attachments.insert(create(model, x + dx, y + dy, z + dz, scale)).data
            
            set attachment.dx = dx
            set attachment.dy = dy
            set attachment.dz = dz

            call update()

            return attachment
        endmethod

        method detach takes thistype attachment returns nothing
            call attachments.remove(attachment)
        endmethod

        method update takes nothing returns nothing
            local real dx
            local real dy
            local real dz
            local real x1
            local real y1
            local real z1
            local real x2
            local real y2
            local real z2
            local thistype attachment
            local List node = attachments.next

            loop
                exitwhen node == attachments
                    set attachment = Effect(node.data)
                    set dx = attachment.dx
                    set dy = attachment.dy
                    set dz = attachment.dz
                    set x1 = dx * Cos(view) - dy * Sin(view)
                    set y1 = dx * Sin(view) + dy * Cos(view)
                    set z1 = dz
                    set x2 = x1 * Cos(angle) + z1 * Sin(angle)
                    set y2 = y1
                    set z2 = -x1 * Sin(angle) + z1 * Cos(angle)
                    set dx = x2
                    set dy = y2 * Cos(rotation) - z2 * Sin(rotation)
                    set dz = y2 * Sin(rotation) + z2 * Cos(rotation)
                    set attachment.yaw = view
                    set attachment.pitch = angle
                    set attachment.roll = rotation

                    call attachment.move(xPos + dx, yPos + dy, zPos + dz)
                set node = node.next
            endloop
        endmethod

        method color takes integer red, integer green, integer blue returns nothing
            call BlzSetSpecialEffectColor(effect, red, green, blue)
        endmethod

        static method create takes string model, real x, real y, real z, real scale returns thistype
            local thistype this = thistype.allocate()

            set effect = AddSpecialEffect(model, x, y)
            set xPos = x
            set yPos = y
            set zPos = z
            set time = 1
            set size = scale
            set path = model
            set animtype = 0
            set playerColor = 0
            set transparency = 0
            set attachments = List.create()

            call BlzSetSpecialEffectZ(effect, z)
            call BlzSetSpecialEffectScale(effect, scale)

            return this
        endmethod
    endstruct
endlibrary