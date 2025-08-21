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
            local List node = attachments.next

            set xPos = value

            call BlzSetSpecialEffectX(effect, value)

            loop
                exitwhen node == attachments
                    set Effect(node.data).x = value - Effect(node.data).x
                set node = node.next
            endloop
        endmethod

        method operator y takes nothing returns real
            return yPos
        endmethod

        method operator y= takes real value returns nothing
            local List node = attachments.next

            set yPos = value

            call BlzSetSpecialEffectY(effect, value)

            loop
                exitwhen node == attachments
                    set Effect(node.data).y = value - Effect(node.data).y
                set node = node.next
            endloop
        endmethod

        method operator z takes nothing returns real
            return zPos
        endmethod

        method operator z= takes real value returns nothing
            local List node = attachments.next

            set zPos = value

            call BlzSetSpecialEffectZ(effect, value)

            loop
                exitwhen node == attachments
                    set Effect(node.data).z = value - Effect(node.data).z
                set node = node.next
            endloop
        endmethod

        method operator yaw takes nothing returns real
            return view
        endmethod

        method operator yaw= takes real value returns nothing
            local List node = attachments.next

            set view = value

            call BlzSetSpecialEffectYaw(effect, value)

            loop
                exitwhen node == attachments
                    set Effect(node.data).yaw = value
                set node = node.next
            endloop
        endmethod

        method operator pitch takes nothing returns real
            return angle
        endmethod

        method operator pitch= takes real value returns nothing
            local List node = attachments.next

            set angle = value

            call BlzSetSpecialEffectPitch(effect, value)

            loop
                exitwhen node == attachments
                    set Effect(node.data).pitch = value
                set node = node.next
            endloop
        endmethod

        method operator roll takes nothing returns real
            return rotation
        endmethod

        method operator roll= takes real value returns nothing
            local List node = attachments.next

            set rotation = value

            call BlzSetSpecialEffectRoll(effect, value)

            loop
                exitwhen node == attachments
                    set Effect(node.data).roll = value
                set node = node.next
            endloop
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
            local List node = attachments.next

            set view = yaw
            set angle = pitch
            set rotation = roll

            call BlzSetSpecialEffectOrientation(effect, yaw, pitch, roll)

            loop
                exitwhen node == attachments
                    set Effect(node.data).yaw = yaw
                    set Effect(node.data).roll = roll
                    set Effect(node.data).pitch = pitch
                set node = node.next
            endloop
        endmethod

        method move takes real x, real y, real z returns boolean
            local List node = attachments.next
            local thistype attachment

            if not (x > WorldBounds.maxX or x < WorldBounds.minX or y > WorldBounds.maxY or y < WorldBounds.minY) then
                set xPos = x
                set yPos = y
                set zPos = z
                
                call BlzSetSpecialEffectPosition(effect, x, y, z)

                loop
                    exitwhen node == attachments
                        set attachment = Effect(node.data)
                        call attachment.move(x - attachment.dx, y - attachment.dy, z - attachment.dz)
                    set node = node.next
                endloop

                return true
            endif

            return false
        endmethod

        method attach takes string model, real dx, real dy, real dz, real scale returns thistype
            local thistype attachment = attachments.insert(create(model, x - dx, y - dy, z - dz, scale)).data
            
            set attachment.dx = dx
            set attachment.dy = dy
            set attachment.dz = dz

            return attachment
        endmethod

        method detach takes thistype attachment returns nothing
            call attachments.remove(attachment)
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