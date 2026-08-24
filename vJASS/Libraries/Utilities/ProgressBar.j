library ProgressBar requires Effect, TimerUtils
    /* ------------------------------- ProgressBar v1.0 Chopinski ------------------------------ */
    globals
        // Constants
        constant string MANABAR = "ManaBar.mdl"
        constant string HEALTHBAR = "HealthBar.mdl"
        constant string PROGRESSBAR = "ProgressBar.mdl"

        // Position update period
        private constant real PERIOD = 0.03
    endglobals

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function CreateProgressBar takes unit u, real x, real y, real z, real scale, real percent, string bartype returns ProgressBar
        return ProgressBar.create(u, x, y, z, scale, percent, bartype)
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

    function SetProgressBarPercentage takes ProgressBar bar, real newValue, real speed returns ProgressBar
        call bar.setPercentage(newValue, speed)
        return bar
    endfunction

    function SetProgressBarColor takes ProgressBar bar, integer red, integer green, integer blue returns ProgressBar
        call bar.setColor(red, green, blue)
        return bar
    endfunction

    function SetProgressBarScale takes ProgressBar bar, real newScale returns ProgressBar
        set bar.scale = newScale
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
        private real dx
        private real dy
        private real dz
        private unit unit
        private real speed
        private real value
        private real target
        private timer timer
        private timer location
        private boolean done
        private boolean visible
        private boolean reverse
        private Effect effect

        method operator x takes nothing returns real
            if unit != null then
                return dx
            else
                return effect.x
            endif
        endmethod

        method operator x= takes real value returns nothing
            if unit != null then
                set dx = value
            else
                set effect.x = value
            endif
        endmethod

        method operator y takes nothing returns real
            if unit != null then
                return dy
            else
                return effect.y
            endif
        endmethod

        method operator y= takes real value returns nothing
            if unit != null then
                set dy = value
            else
                set effect.y = value
            endif
        endmethod

        method operator z takes nothing returns real
            if unit != null then
                return dz
            else
                return effect.z
            endif
        endmethod

        method operator z= takes real value returns nothing
            if unit != null then
                set dz = value
            else
                set effect.z = value
            endif
        endmethod

        method operator percentage takes nothing returns real
            return value
        endmethod

        method operator show= takes boolean flag returns nothing
            set visible = flag

            if flag then
                set effect.alpha = 255
            else
                set effect.alpha = 0
            endif
        endmethod

        method operator scale= takes real newScale returns nothing
            set effect.scale = newScale
        endmethod

        method destroy takes nothing returns nothing
            set effect.z = -10000

            call ReleaseTimer(location)
            call ReleaseTimer(timer)
            call effect.destroy()
            call deallocate()

            set unit = null
            set timer = null
            set location = null
        endmethod

        method setColor takes integer red, integer green, integer blue returns thistype
            call effect.color(red, green, blue)

            return this
        endmethod

        method setPercentage takes real percent, real speed returns thistype
            set target = R2I(percent)
            set .speed = speed
            set reverse = value > target

            if done then
                call TimerStart(timer, 0.01, true, function thistype.onPeriod)
                set done = false
            endif

            return this
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            if reverse then
                if value > target then
                    set effect.timeScale = -speed
                    set value = value - speed
                elseif value <= target then
                    set done = true
                    set value = target
                    set effect.timeScale = 0

                    call PauseTimer(timer)
                endif
            else
                if value < target then
                    set effect.timeScale = speed
                    set value = value + speed
                elseif value >= target then
                    set done = true
                    set value = target
                    set effect.timeScale = 0

                    call PauseTimer(timer)
                endif
            endif
        endmethod

        private static method onMove takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            if UnitAlive(unit) then
                set effect.x = GetUnitX(unit) + dx
                set effect.y = GetUnitY(unit) + dy
                set effect.z = GetUnitZ(unit) + dz

                if not visible then
                    set show = true
                endif
            else
                if visible then
                    set show = false
                endif
            endif
        endmethod

        static method create takes unit u, real x, real y, real z, real scale, real percent, string bartype returns thistype
            local thistype this = thistype.allocate()

            set dx = x
            set dy = y
            set dz = z
            set unit = u
            set value = 0
            set done = true
            set visible = true
            set timer = NewTimerEx(this)
            set effect = Effect.create(bartype, x, y, z, scale)
            set effect.timeScale = 0

            if percent > 0 then
                call setPercentage(percent, 1)
            endif

            if unit != null then
                set location = NewTimerEx(this)
                call TimerStart(location, PERIOD, true, function thistype.onMove)
            endif

            return this
        endmethod
    endstruct
endlibrary