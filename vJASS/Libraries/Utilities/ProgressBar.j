library ProgressBar requires Dummy, Utilities, TimerUtils
    /* ------------------------------- ProgressBar v1.0 Chopinski ------------------------------ */
    globals
        // Position update period
        private constant real PERIOD = 0.03

        // Texttag default size
        private constant real TEXTTAG_SIZE = 0.014

        // ProgressBar unit
        private constant integer PROGRESSBAR = 'pbar'
    endglobals

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function CreateProgressBar takes unit u, real x, real y, real z, real scale, real percent, boolean showText returns ProgressBar
        return ProgressBar.create(u, x, y, z, scale, percent, showText)
    endfunction

    function GetProgressBarX takes ProgressBar bar returns real
        return bar.x
    endfunction

    function GetProgressBarY takes ProgressBar bar returns real
        return bar.y
    endfunction

    function GetProgressBarZ takes ProgressBar bar returns real
        return bar.z
    endfunction

    function SetProgressBarX takes ProgressBar bar, real newX returns ProgressBar
        set bar.x = newX
        return bar
    endfunction

    function SetProgressBarY takes ProgressBar bar, real newY returns ProgressBar
        set bar.y = newY
        return bar
    endfunction

    function SetProgressBarZ takes ProgressBar bar, real newZ returns ProgressBar
        set bar.z = newZ
        return bar
    endfunction

    function GetProgressBarPercentage takes ProgressBar bar returns real
        return bar.percentage
    endfunction

    function SetProgressBarPercentage takes ProgressBar bar, real newValue, real duration returns ProgressBar
        call bar.setPercentage(newValue, duration)
        return bar
    endfunction

    function SetProgressBarColor takes ProgressBar bar, integer red, integer green, integer blue, integer alpha returns ProgressBar
        call bar.setColor(red, green, blue, alpha)
        return bar
    endfunction

    function SetProgressBarPlayerColor takes ProgressBar bar, integer color returns ProgressBar
        set bar.playercolor = color
        return bar
    endfunction

    function SetProgressBarScale takes ProgressBar bar, real newScale returns ProgressBar
        set bar.scale = newScale
        return bar
    endfunction

    function GetProgressBarText takes ProgressBar bar returns string
        return bar.text
    endfunction

    function SetProgressBarText takes ProgressBar bar, string newText returns ProgressBar
        set bar.text = newText
        return bar
    endfunction

    function GetProgressBarTextSize takes ProgressBar bar returns real
        return bar.textsize
    endfunction

    function SetProgressBarTextSize takes ProgressBar bar, real newSize returns ProgressBar
        set bar.textsize = newSize
        return bar
    endfunction

    function SetProgressBarTextColor takes ProgressBar bar, integer red, integer green, integer blue, integer alpha returns ProgressBar
        call bar.setTextColor(red, green, blue, alpha)
        return bar
    endfunction

    function ShowProgressBar takes ProgressBar bar, boolean flag returns ProgressBar
        set bar.show = flag
        return bar
    endfunction

    function DestroyProgressBar takes ProgressBar bar returns nothing
        call bar.destroy()
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    struct ProgressBar
        private static integer key = -1
        private static thistype array array
        private static timer location = CreateTimer()

        private real dx
        private real dy
        private real dz
        private real size
        private unit unit
        private unit effect
        private real speed
        private real value
        private real target
        private timer timer
        private string string
        private integer index
        private texttag texttag
        private boolean visible

        method operator x takes nothing returns real
            if unit != null then
                return dx
            else
                return GetUnitX(effect)
            endif
        endmethod

        method operator x= takes real value returns nothing
            if unit != null then
                set dx = value
            else
                call SetUnitX(effect, value)
            endif
        endmethod

        method operator y takes nothing returns real
            if unit != null then
                return dy
            else
                return GetUnitY(effect)
            endif
        endmethod

        method operator y= takes real value returns nothing
            if unit != null then
                set dy = value
            else
                call SetUnitY(effect, value)
            endif
        endmethod

        method operator z takes nothing returns real
            if unit != null then
                return dz
            else
                return GetUnitZ(effect)
            endif
        endmethod

        method operator z= takes real value returns nothing
            if unit != null then
                set dz = value
            else
                call SetUnitZ(effect, value)
            endif
        endmethod

        method operator text takes nothing returns string
            return string
        endmethod

        method operator text= takes string value returns nothing
            set string = value

            if texttag != null then
                call SetTextTagText(texttag, string, size)
            endif
        endmethod

        method operator percentage takes nothing returns real
            return value
        endmethod

        method operator percentage= takes real value returns nothing
            call setPercentage(value, 0)
        endmethod

        method operator textsize takes nothing returns real
            return size
        endmethod

        method operator textsize= takes real value returns nothing
            set size = value

            if texttag != null then
                call SetTextTagText(texttag, string, size)
            endif
        endmethod

        method operator playercolor= takes integer color returns nothing
            call SetUnitColor(effect, GetPlayerColor(Player(color)))
        endmethod

        method operator show= takes boolean flag returns nothing
            set visible = flag

            call ShowUnit(effect, flag)

            if texttag != null then
                call SetTextTagVisibility(texttag, flag)
            endif
        endmethod

        method operator scale= takes real newScale returns nothing
            call SetUnitScale(effect, newScale, newScale, newScale)
        endmethod

        method destroy takes nothing returns nothing
            call ReleaseTimer(timer)
            call BlzSetUnitSkin(effect, Dummy.type)
            call DummyRecycle(effect)
            call deallocate()

            if texttag != null then
                call DestroyTextTag(texttag)
            endif

            if index >= 0 then
                if index < key then
                    set array[index] = array[key]
                    set ProgressBar(array[index]).index = index
                endif

                set array[key] = 0
                set key = key - 1

                if key == -1 then
                    call PauseTimer(location)
                endif
            endif

            set unit = null
            set timer = null
            set effect = null
            set texttag = null
        endmethod

        method setColor takes integer red, integer green, integer blue, integer alpha returns thistype
            call SetUnitVertexColor(effect, red, green, blue, alpha)

            return this
        endmethod

        method setTextColor takes integer red, integer green, integer blue, integer alpha returns thistype
            call SetTextTagColor(texttag, red, green, blue, alpha)

            return this
        endmethod

        method setPercentage takes real percent, real duration returns thistype
            set target = R2I(percent)
            set speed = ((target - value) * 0.1) / RMaxBJ(duration, 0.1)

            if value == target then
                return this
            endif

            call TimerStart(timer, 0.1, true, function thistype.onPeriod)

            return this
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            set value = value + speed

            if (speed > 0 and value >= target) or (speed < 0 and value <= target) then
                set value = target

                call PauseTimer(timer)
            endif

            call SetUnitAnimationByIndex(effect, R2I(value + 0.5))
        endmethod

        private static method onMove takes nothing returns nothing
            local thistype this
            local integer i = 0

            loop
                exitwhen i > key
                    set this = array[i]

                    call SetUnitX(effect, GetUnitX(unit) + dx)
                    call SetUnitY(effect, GetUnitY(unit) + dy)
                    call SetUnitZ(effect, GetUnitZ(unit) + dz)

                    if texttag != null then
                        call SetTextTagText(texttag, string, size)
                        call SetTextTagPos(texttag, GetUnitX(effect) - 20, GetUnitY(effect) - 30, GetUnitFlyHeight(effect))
                    endif
                set i = i + 1
            endloop
        endmethod

        static method create takes unit u, real x, real y, real z, real scale, real percent, boolean showText returns thistype
            local thistype this = thistype.allocate()

            set dx = x
            set dy = y
            set dz = z
            set unit = u
            set index = -1
            set string = "0"
            set visible = true
            set size = TEXTTAG_SIZE
            set value = R2I(percent)
            set timer = NewTimerEx(this)
            set effect = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), x, y, z, 0)

            call BlzSetUnitSkin(effect, PROGRESSBAR)
            call SetUnitScale(effect, scale, scale, scale)
            call SetUnitAnimationByIndex(effect, R2I(value))

            if showText then
                set texttag = CreateTextTag()
                
                call SetTextTagText(texttag, string, size)
                call SetTextTagPos(texttag, x, y, z)
                call SetTextTagColor(texttag, 255, 255, 255, 255)
                call SetTextTagPermanent(texttag, true)
            endif

            if unit != null then
                set key = key + 1
                set index = key
                set array[key] = this

                call SetTextTagPos(texttag, GetUnitX(effect) - 20, GetUnitY(effect) - 30, GetUnitFlyHeight(effect))

                if key == 0 then
                    call TimerStart(location, PERIOD, true, function thistype.onMove)
                endif
            endif

            return this
        endmethod
    endstruct
endlibrary