library CrowdControl requires optional Tenacity
    /* ------------------------------------- Crowd Control v2.0 ------------------------------------- */
    globals
        // This is the maximum recursion limit allowed by the system.
        // Its value must be greater than or equal to 0. When equal to 0
        // no recursion is allowed. Values too big can cause screen freezes.
        private constant integer RECURSION_LIMIT    = 8
        // The raw code of the true sight ability.
        // Add this to dummy cast based disables
        // so that the dummy can see invisible units
        public constant integer TRUE_SIGHT         = 'U014'
    endglobals

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             Systems                                            */
    /* ---------------------------------------------------------------------------------------------- */
    private interface ICrowdControl
        method start takes unit source, unit target, real value, real angle, real duration, string model, string point, boolean stack returns boolean defaults false
        method finish takes unit target returns boolean defaults false
        method isApplied takes unit target returns boolean defaults false
        method getRemaining takes unit target returns real defaults 0.
    endinterface

    struct CrowdControl extends ICrowdControl
        private static HashTable table
        readonly static integer key = 0
        private static integer index = -1
        private static integer array array
        private static trigger array event
        private static ICrowdControl array struct
        private static trigger trigger = CreateTrigger()

        static unit array source
        static unit array target
        static real array value
        static real array angle
        static string array model
        static string array point
        static integer array type
        static real array duration
        static boolean array stack

        static method apply takes integer control, unit source, unit target, real value, real angle, real duration, string model, string point, boolean stack returns boolean
            local thistype this = struct[control]
            
            if this != 0 then
                if start.exists and not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE) and UnitAlive(target) and duration > 0 then
                    set key = key + 1
                    set .value[key] = value
                    set .angle[key] = angle
                    set .model[key] = model
                    set .point[key] = point
                    set .stack[key] = stack
                    set .type[key] = control
                    set .target[key] = target
                    set .source[key] = source
                    set .duration[key] = duration

                    call onEvent(key)
            
                    static if LIBRARY_Tenacity then
                        set .duration[key] = GetTenacityDuration(.target[key], .duration[key])
                    endif

                    if type[key] != control then
                        return start(.source[key], .target[key], .value[key], .angle[key], .duration[key], .model[key], .point[key], .stack[key])
                    endif
                    
                    return start(.source[key], .target[key], .value[key], .angle[key], .duration[key], .model[key], .point[key], .stack[key])
                endif
            else
                call BJDebugMsg("Invalid CrowdControl Type")
            endif

            return false
        endmethod

        static method dispel takes unit target, integer control returns boolean
            local thistype this = struct[control]

            if this != 0 then
                if finish.exists and UnitAlive(target) then
                    return finish(target)
                endif
            endif

            return false
        endmethod

        static method dispelAll takes unit target returns nothing
            local integer i = 0
            local thistype this

            if UnitAlive(target) then
                loop
                    exitwhen i > index
                        set this = struct[array[i]]

                        if this != 0 then
                            if finish.exists then
                                call finish(target)
                            endif
                        endif
                    set i = i + 1
                endloop
            endif
        endmethod

        static method remaining takes unit target, integer control returns real
            local thistype this = struct[control]

            if this != 0 then
                if getRemaining.exists and UnitAlive(target) then
                    return getRemaining(target)
                endif
            endif

            return 0.
        endmethod

        static method applied takes unit target, integer control returns boolean
            local thistype this = struct[control]

            if this != 0 then
                if isApplied.exists and UnitAlive(target) then
                    return isApplied(target)
                endif
            endif

            return false
        endmethod

        static method register takes ICrowdControl control returns integer
            set index = index + 1
            set array[index] = control.getType()
            set struct[control.getType()] = control

            return control.getType()
        endmethod

        static method registerEvent takes integer control, code c returns nothing
            if control > 0 then
                if event[control] == null then
                    set event[control] = CreateTrigger()
                endif

                call TriggerAddCondition(event[control], Filter(c))
            else
                call TriggerAddCondition(trigger, Filter(c))
            endif
        endmethod

        private static method onEvent takes integer key returns nothing
            set .key = .key + 1

            if key <= RECURSION_LIMIT then
                if event[type[key]] != null then
                    call TriggerEvaluate(event[type[key]])
                endif

                call TriggerEvaluate(trigger)
            endif

            set .key = .key - 1
        endmethod
    endstruct

    /* ---------------------------------------------------------------------------------------------- */
    /*                                            JASS API                                            */
    /* ---------------------------------------------------------------------------------------------- */
    function RegisterCrowdControl takes ICrowdControl control returns integer
        return CrowdControl.register(control)
    endfunction

    function RegisterCrowdControlEvent takes integer id, code c returns nothing
        call CrowdControl.registerEvent(id, c)
    endfunction

    function RegisterAnyCrowdControlEvent takes code c returns nothing
        call CrowdControl.registerEvent(0, c)
    endfunction

    function UnitApplyCrowdControl takes integer control, unit source, unit target, real value, real angle, real duration, string model, string point, boolean stack returns boolean
        return CrowdControl.apply(control, source, target, value, angle, duration, model, point, stack)
    endfunction

    function GetCrowdControlSource takes nothing returns unit
        return CrowdControl.source[CrowdControl.key - 1]
    endfunction

    function GetCrowdControlTarget takes nothing returns unit
        return CrowdControl.target[CrowdControl.key - 1]
    endfunction

    function GetCrowdControlType takes nothing returns integer
        return CrowdControl.type[CrowdControl.key - 1]
    endfunction

    function GetCrowdControlDuration takes nothing returns real
        return CrowdControl.duration[CrowdControl.key - 1]
    endfunction

    function GetCrowdControlValue takes nothing returns real
        return CrowdControl.value[CrowdControl.key - 1]
    endfunction

    function GetCrowdControlAngle takes nothing returns real
        return CrowdControl.angle[CrowdControl.key - 1]
    endfunction

    function GetCrowdControlModel takes nothing returns string
        return CrowdControl.model[CrowdControl.key - 1]
    endfunction

    function GetCrowdControlBone takes nothing returns string
        return CrowdControl.point[CrowdControl.key - 1]
    endfunction

    function GetCrowdControlStack takes nothing returns boolean
        return CrowdControl.stack[CrowdControl.key - 1]
    endfunction

    function GetCrowdControlRemaining takes unit target, integer id returns real
        return CrowdControl.remaining(target, id)
    endfunction

    function SetCrowdControlSource takes unit u returns nothing
        set CrowdControl.source[CrowdControl.key - 1] = u
    endfunction

    function SetCrowdControlTarget takes unit u returns nothing
        set CrowdControl.target[CrowdControl.key - 1] = u
    endfunction

    function SetCrowdControlType takes integer id returns nothing
        set CrowdControl.type[CrowdControl.key - 1] = id
    endfunction

    function SetCrowdControlDuration takes real duration returns nothing
        set CrowdControl.duration[CrowdControl.key - 1] = duration
    endfunction

    function SetCrowdControlValue takes real amount returns nothing
        set CrowdControl.value[CrowdControl.key - 1] = amount
    endfunction

    function SetCrowdControlAngle takes real amount returns nothing
        set CrowdControl.angle[CrowdControl.key - 1] = amount
    endfunction

    function SetCrowdControlModel takes string model returns nothing
        set CrowdControl.model[CrowdControl.key - 1] = model
    endfunction

    function SetCrowdControlBone takes string point returns nothing
        set CrowdControl.point[CrowdControl.key - 1] = point
    endfunction

    function SetCrowdControlStack takes boolean stack returns nothing
        set CrowdControl.stack[CrowdControl.key - 1] = stack
    endfunction

    function UnitDispelCrowdControl takes unit target, integer id returns nothing
        call CrowdControl.dispel(target, id)
    endfunction

    function UnitDispelAllCrowdControl takes unit target returns nothing
        call CrowdControl.dispelAll(target)
    endfunction
endlibrary
