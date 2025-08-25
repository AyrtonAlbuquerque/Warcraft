library ArcingFloatingText requires Table, Modules
    globals
        private constant real BONUS_SIZE = 0.000
        private constant real LIFE_TIME = 1.0
        private constant real Z_OFFSET = 50
        private constant real Z_OFFSET_BONUS = 50
        private constant real VELOCITY = 2
    endglobals
    
    struct ArcingTextTag
        private static Table table
        private static integer key = 0

        private real x
        private real y
        private real sin
        private real cos
        private real size
        private real duration
        private string text
        private texttag texttag
        
        method destroy takes nothing returns nothing
            set key = key + 1
            set table.texttag[key] = texttag 

            call SetTextTagVisibility(texttag, false)

            set texttag = null

            call deallocate()
        endmethod

        private method onPeriod takes nothing returns boolean
            local real height = Sin(duration * bj_PI)

            set duration = duration - 0.03125

            if duration > 0 then
                set x = x + cos
                set y = y + sin

                call SetTextTagPos(texttag, x, y, Z_OFFSET + Z_OFFSET_BONUS * height)
                call SetTextTagText(texttag, text, size + BONUS_SIZE * height)
            endif

            return duration > 0
        endmethod
        
        public static method create takes string value, unit u, real size returns thistype
            local thistype this = thistype.allocate()
            local real angle = GetRandomReal(0, 2 * bj_PI)
            
            set x = GetUnitX(u)
            set y = GetUnitY(u)
            set .size = size
            set sin = Sin(angle) * VELOCITY
            set cos = Cos(angle) * VELOCITY
            set text = value
            set duration = LIFE_TIME

            if key >= 0 then
                set texttag = table.texttag[key]
                set key = key - 1

                call SetTextTagVisibility(texttag, true)
            else
                set texttag = CreateTextTag()
                call SetTextTagPermanent(texttag, true)
            endif

            call SetTextTagText(texttag, text, size)
            call SetTextTagPos(texttag, x, y, Z_OFFSET)
            call StartTimer(0.03125, true, this, -1)
            
            return this
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            set table = Table.create()

            loop
                exitwhen key > 100
                    set table.texttag[key] = CreateTextTag()

                    call SetTextTagPermanent(table.texttag[key], true)
                    call SetTextTagVisibility(table.texttag[key], false)
                set key = key + 1
            endloop
        endmethod
    endstruct
endlibrary
