library CrowdControl requires Utilities, Missiles, Indexer, TimerUtils, RegisterPlayerUnitEvent, optional Tenacity
    /* ------------------------------------- Crowd Control v1.0 ------------------------------------- */
    // How to Import:
    // 1 - Copy the Utilities library over to your map and follow its install instructions
    // 2 - Copy the Missiles libraries over to your map and follow their install instructions
    // 3 - Copy the Indexer library over to your map and follow its install instructions
    // 4 - Copy the TimerUtils library over to your map and follow its install instructions
    // 5 - Copy the RegisterPlayerUnitEvent library over to your map and follow its install instructions
    // 6 - Copy the Tenacity library over to your map and follow its install instructions
    // 7 - Copy this library into your map
    // 8 - Copy the 11 buffs and 11 abilities with the CC prefix and match their raw code below.
    /* ---------------------------------------- By Chopinski ---------------------------------------- */

    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // The raw code of the silence ability
        private constant integer SILENCE            = 'U000'
        // The raw code of the stun ability
        private constant integer STUN               = 'U001'
        // The raw code of the attack slow ability
        private constant integer ATTACK_SLOW        = 'U002'
        // The raw code of the movement slow ability
        private constant integer MOVEMENT_SLOW      = 'U003'
        // The raw code of the banish ability
        private constant integer BANISH             = 'U004'
        // The raw code of the ensnare ability
        private constant integer ENSNARE            = 'U005'
        // The raw code of the purge ability
        private constant integer PURGE              = 'U006'
        // The raw code of the hex ability
        private constant integer HEX                = 'U007'
        // The raw code of the sleep ability
        private constant integer SLEEP              = 'U008'
        // The raw code of the cyclone ability
        private constant integer CYCLONE            = 'U009'
        // The raw code of the entangle ability
        private constant integer ENTANGLE           = 'U010'
        // The raw code of the silence buff
        private constant integer SILENCE_BUFF       = 'BU00'
        // The raw code of the stun buff
        private constant integer STUN_BUFF          = 'BU01'
        // The raw code of the attack slow buff
        private constant integer ATTACK_SLOW_BUFF   = 'BU02'
        // The raw code of the movement slow buff
        private constant integer MOVEMENT_SLOW_BUFF = 'BU03'
        // The raw code of the banish buff
        private constant integer BANISH_BUFF        = 'BU04'
        // The raw code of the ensnare buff
        private constant integer ENSNARE_BUFF       = 'BU05'
        // The raw code of the purge buff
        private constant integer PURGE_BUFF         = 'BU06'
        // The raw code of the hex buff
        private constant integer HEX_BUFF           = 'BU07'
        // The raw code of the sleep buff
        private constant integer SLEEP_BUFF         = 'BU08'
        // The raw code of the cyclone buff
        private constant integer CYCLONE_BUFF       = 'BU09'
        // The raw code of the entangle buff
        private constant integer ENTANGLE_BUFF      = 'BU10'

        // This is the maximum recursion limit allowed by the system.
        // It's value must be greater than or equal to 0. When equal to 0
        // no recursion is allowed. Values too big can cause screen freezes.
        private constant integer RECURSION_LIMIT    = 8

        // The Crowd Control types
        constant integer CROWD_CONTROL_SILENCE      = 0
        constant integer CROWD_CONTROL_STUN         = 1
        constant integer CROWD_CONTROL_SLOW         = 2
        constant integer CROWD_CONTROL_SLOW_ATTACK  = 3
        constant integer CROWD_CONTROL_BANISH       = 4
        constant integer CROWD_CONTROL_ENSNARE      = 5
        constant integer CROWD_CONTROL_PURGE        = 6
        constant integer CROWD_CONTROL_HEX          = 7
        constant integer CROWD_CONTROL_SLEEP        = 8
        constant integer CROWD_CONTROL_CYCLONE      = 9
        constant integer CROWD_CONTROL_ENTANGLE     = 10
        constant integer CROWD_CONTROL_DISARM       = 11
        constant integer CROWD_CONTROL_FEAR         = 12
        constant integer CROWD_CONTROL_KNOCKBACK    = 13
        constant integer CROWD_CONTROL_KNOCKUP      = 14
    endglobals

    /* ---------------------------------------------------------------------------------------------- */
    /*                                            JASS API                                            */
    /* ---------------------------------------------------------------------------------------------- */
    /* ------------------------------------------- Disarm ------------------------------------------- */
    function DisarmUnit takes unit target, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.disarm(target, duration, model, point, stack)
    endfunction

    function IsUnitDisarmed takes unit target returns boolean
        return CrowdControl.disarmed(target)
    endfunction

    /* -------------------------------------------- Fear -------------------------------------------- */
    function FearUnit takes unit target, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.fear(target, duration, model, point, stack)
    endfunction

    function IsUnitFeared takes unit target returns boolean
        return CrowdControl.feared(target)
    endfunction 

    /* ------------------------------------------ Knockback ----------------------------------------- */
    function KnockbackUnit takes unit target, real angle, real distance, real duration, string model, string point, boolean onCliff, boolean onDestructable, boolean onUnit, boolean stack returns nothing
        call CrowdControl.knockback(target, angle, distance, duration, model, point, onCliff, onDestructable, onUnit, stack)
    endfunction
    
    function IsUnitKnockedBack takes unit target returns boolean
        return CrowdControl.knockedback(target)
    endfunction

    /* ------------------------------------------- Knockup ------------------------------------------ */
    function KnockupUnit takes unit target, real maxHeight, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.knockup(target, maxHeight, duration, model, point, stack)
    endfunction

    function IsUnitKnockedUp takes unit target returns boolean
        return CrowdControl.knockedup(target)
    endfunction

    /* ------------------------------------------- Silence ------------------------------------------ */
    function SilenceUnit takes unit target, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.silence(target, duration, model, point, stack)
    endfunction

    function IsUnitSilenced takes unit target returns boolean
        return CrowdControl.silenced(target)
    endfunction

    /* -------------------------------------------- Stun -------------------------------------------- */
    function StunUnit takes unit target, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.stun(target, duration, model, point, stack)
    endfunction

    function IsUnitStunned takes unit target returns boolean
        return CrowdControl.stunned(target)
    endfunction

    /* ---------------------------------------- Movement Slow --------------------------------------- */
    function SlowUnit takes unit target, real amount, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.slow(target, amount, duration, model, point, stack)
    endfunction

    function IsUnitSlowed takes unit target returns boolean
        return CrowdControl.slowed(target)
    endfunction

    /* ----------------------------------------- Attack Slow ---------------------------------------- */
    function SlowUnitAttack takes unit target, real amount, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.slowAttack(target, amount, duration, model, point, stack)
    endfunction

    function IsUnitAttackSlowed takes unit target returns boolean
        return CrowdControl.attackSlowed(target)
    endfunction

    /* ------------------------------------------- Banish ------------------------------------------- */
    function BanishUnit takes unit target, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.banish(target, duration, model, point, stack)
    endfunction

    function IsUnitBanished takes unit target returns boolean
        return CrowdControl.banished(target)
    endfunction

    /* ------------------------------------------- Ensnare ------------------------------------------ */
    function EnsnareUnit takes unit target, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.ensnare(target, duration, model, point, stack)
    endfunction

    function IsUnitEnsnared takes unit target returns boolean
        return CrowdControl.ensnared(target)
    endfunction

    /* -------------------------------------------- Purge ------------------------------------------- */
    function PurgeUnit takes unit target, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.purge(target, duration, model, point, stack)
    endfunction

    function IsUnitPurged takes unit target returns boolean
        return CrowdControl.purged(target)
    endfunction

    /* --------------------------------------------- Hex -------------------------------------------- */
    function HexUnit takes unit target, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.hex(target, duration, model, point, stack)
    endfunction

    function IsUnitHexed takes unit target returns boolean
        return CrowdControl.hexed(target)
    endfunction

    /* -------------------------------------------- Sleep ------------------------------------------- */
    function SleepUnit takes unit target, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.sleep(target, duration, model, point, stack)
    endfunction

    function IsUnitSleeping takes unit target returns boolean
        return CrowdControl.sleeping(target)
    endfunction

    /* ------------------------------------------- Cyclone ------------------------------------------ */
    function CycloneUnit takes unit target, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.cyclone(target, duration, model, point, stack)
    endfunction

    function IsUnitCycloned takes unit target returns boolean
        return CrowdControl.cycloned(target)
    endfunction

    /* ------------------------------------------ Entangle ------------------------------------------ */
    function EntangleUnit takes unit target, real duration, string model, string point, boolean stack returns nothing
        call CrowdControl.entangle(target, duration, model, point, stack)
    endfunction

    function IsUnitEntangled takes unit target returns boolean
        return CrowdControl.entangled(target)
    endfunction

    /* ------------------------------------------- Events ------------------------------------------- */
    function RegisterCrowdControlEvent takes integer id, code c returns nothing
        call CrowdControl.register(id, c)
    endfunction

    function RegisterAnyCrowdControlEvent takes code c returns nothing
        call CrowdControl.register(-1, c)
    endfunction

    function GetCrowdControlUnit takes nothing returns unit
        return CrowdControl.unit[CrowdControl.key]
    endfunction

    function GetCrowdControlType takes nothing returns integer
        return CrowdControl.type[CrowdControl.key]
    endfunction

    function GetCrowdControlDuration takes nothing returns real
        return CrowdControl.real[CrowdControl.key]
    endfunction

    function GetCrowdControlAmount takes nothing returns real
        return CrowdControl.value[CrowdControl.key]
    endfunction

    function GetKnockbackAngle takes nothing returns real
        return CrowdControl.angle[CrowdControl.key]
    endfunction

    function GetKnockbackDistance takes nothing returns real
        return CrowdControl.distance[CrowdControl.key]
    endfunction

    function GetKnockupHeight takes nothing returns real
        return CrowdControl.height[CrowdControl.key]
    endfunction

    function GetCrowdControlModel takes nothing returns string
        return CrowdControl.effect[CrowdControl.key]
    endfunction

    function GetCrowdControlBone takes nothing returns string
        return CrowdControl.bone[CrowdControl.key]
    endfunction

    function GetCrowdControlStack takes nothing returns boolean
        return CrowdControl.stack[CrowdControl.key]
    endfunction

    function GetKnockbackOnCliff takes nothing returns boolean
        return CrowdControl.cliff[CrowdControl.key]
    endfunction

    function GetKnockbackOnDestructable takes nothing returns boolean
        return CrowdControl.destructable[CrowdControl.key]
    endfunction

    function GetKnockbackOnUnit takes nothing returns boolean
        return CrowdControl.agent[CrowdControl.key]
    endfunction

    function GetCrowdControlRemaining takes unit target, integer id returns real
        return CrowdControl.remaining(target, id)
    endfunction

    function SetCrowdControlUnit takes unit u returns nothing
        set CrowdControl.unit[CrowdControl.key] = u
    endfunction

    function SetCrowdControlType takes integer id returns nothing
        if id >= CROWD_CONTROL_SILENCE and id <= CROWD_CONTROL_KNOCKUP then
            set CrowdControl.type[CrowdControl.key] = id
        endif
    endfunction

    function SetCrowdControlDuration takes real duration returns nothing
        set CrowdControl.real[CrowdControl.key] = duration
    endfunction

    function SetCrowdControlAmount takes real amount returns nothing
        set CrowdControl.value[CrowdControl.key] = amount
    endfunction

    function SetKnockbackAngle takes real angle returns nothing
        set CrowdControl.angle[CrowdControl.key] = angle
    endfunction

    function SetKnockbackDistance takes real distance returns nothing
        set CrowdControl.distance[CrowdControl.key] = distance
    endfunction

    function SetKnockupHeight takes real height returns nothing
        set CrowdControl.height[CrowdControl.key] = height
    endfunction

    function SetCrowdControlModel takes string model returns nothing
        set CrowdControl.effect[CrowdControl.key] = model
    endfunction

    function SetCrowdControlBone takes string point returns nothing
        set CrowdControl.bone[CrowdControl.key] = point
    endfunction

    function SetCrowdControlStack takes boolean stack returns nothing
        set CrowdControl.stack[CrowdControl.key] = stack
    endfunction

    function SetKnockbackOnCliff takes boolean onCliff returns nothing
        set CrowdControl.cliff[CrowdControl.key] = onCliff
    endfunction

    function SetKnockbackOnDestructable takes boolean onDestructable returns nothing
        set CrowdControl.destructable[CrowdControl.key] = onDestructable
    endfunction

    function SetKnockbackOnUnit takes boolean onUnit returns nothing
        set CrowdControl.agent[CrowdControl.key] = onUnit
    endfunction

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             Systems                                            */
    /* ---------------------------------------------------------------------------------------------- */
    /* ------------------------------------------ Knockback ----------------------------------------- */
    struct Knockback extends Missiles
        private static integer array knocked
    
        boolean cliff
        boolean destructable
        boolean unit
        boolean isPaused
        integer key
        effect attachment
    
        method onPeriod takes nothing returns boolean
            if UnitAlive(source) then
                call SetUnitX(source, prevX)
                call SetUnitY(source, prevY)
                
                return false
            else
                return true
            endif
        endmethod
        
        method onHit takes unit u returns boolean
            if unit and u != source then
                if UnitAlive(u) then
                    return true
                else
                    return false
                endif
            else
                return false
            endif
        endmethod
        
        method onDestructable takes destructable d returns boolean
            if destructable then
                if GetDestructableLife(d) > 0 then
                    return true
                else
                    return false
                endif
            else
                return false
            endif
        endmethod
        
        method onCliff takes nothing returns boolean
            return cliff
        endmethod
        
        method onPause takes nothing returns boolean
            call pause(false)
            return false
        endmethod
        
        method onRemove takes nothing returns nothing
            call DestroyEffect(attachment)
            set knocked[key] = knocked[key] - 1
            set attachment = null
            
            if knocked[key] == 0 then
                call BlzPauseUnitEx(source, false)
            endif
        endmethod
        
        static method isUnitKnocked takes unit u returns boolean
            return knocked[GetUnitUserData(u)] > 0
        endmethod
        
        static method apply takes unit whichUnit, real angle, real distance, real duration, string model, string point, boolean onCliff, boolean onDestructable, boolean onUnit returns nothing
            local real x = GetUnitX(whichUnit)
            local real y = GetUnitY(whichUnit)
            local thistype this

            if duration > 0 then
                set this = thistype.create(x, y, 0, x + distance*Cos(angle), y + distance*Sin(angle), 0)
                set .source = whichUnit
                set .duration = duration
                set .collision = 2*BlzGetUnitCollisionSize(whichUnit)
                set .cliff = onCliff
                set .destructable = onDestructable
                set .unit = onUnit
                set .isPaused = isPaused
                set .key = GetUnitUserData(whichUnit)
                set knocked[key] = knocked[key] + 1
                
                if model != null and point != null then
                    set .attachment = AddSpecialEffectTarget(model, whichUnit, point)
                endif
                
                if knocked[key] == 1 then
                    call BlzPauseUnitEx(whichUnit, true)
                endif
                
                call launch()
            endif
        endmethod
    endstruct

    /* ------------------------------------------- Knockup ------------------------------------------ */
    struct Knockup
        private static integer array knocked

        timer timer 
        unit unit
        effect effect
        integer key
        boolean up
        real rate
        real airTime

        static method isUnitKnocked takes unit u returns boolean
            return knocked[GetUnitUserData(u)] > 0
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            if up then
                set up = false
                call SetUnitFlyHeight(unit, GetUnitDefaultFlyHeight(unit), rate)
                call TimerStart(timer, airTime/2, false, function thistype.onPeriod)
            else
                call DestroyEffect(effect)
                call ReleaseTimer(timer)
                call deallocate()

                set knocked[key] = knocked[key] - 1

                if knocked[key] == 0 then
                    call BlzPauseUnitEx(unit, false)
                endif

                set timer = null
                set unit = null
                set effect = null
            endif
        endmethod

        static method apply takes unit whichUnit, real airTime, real maxHeight, string model, string point returns nothing
            local thistype this

            if airTime > 0 then
                set this = thistype.allocate()
                set timer = NewTimerEx(this)
                set unit = whichUnit
                set rate = maxHeight/airTime
                set .airTime = airTime
                set up = true
                set key = GetUnitUserData(unit)
                set knocked[key] = knocked[key] + 1

                if model != null and point != null then
                    set effect = AddSpecialEffectTarget(model, unit, point)
                endif

                if knocked[key] == 1 then
                    call BlzPauseUnitEx(whichUnit, true)
                endif

                call UnitAddAbility(unit, 'Amrf')
                call UnitRemoveAbility(unit, 'Amrf')
                call SetUnitFlyHeight(unit, (GetUnitDefaultFlyHeight(unit) + maxHeight), rate)
                call TimerStart(timer, airTime/2, false, function thistype.onPeriod)
            endif
        endmethod
    endstruct

    /* -------------------------------------------- Fear -------------------------------------------- */
    struct Fear
        static constant real PERIOD = 1./5.
        static constant integer DIRECTION_CHANGE = 5 
        static constant real MAX_CHANGE = 200.
        static integer key = -1
        static thistype array array
        static integer array struct
        static boolean array flag
        static real array x
        static real array y
        static timer timer = CreateTimer()

        unit unit
        effect effect
        integer id
        real duration
        integer change
        boolean selected

        static method isUnitFeared takes unit target returns boolean
            return struct[GetUnitUserData(target)] != 0
        endmethod

        method remove takes integer i returns integer
            set flag[id] = true
            call IssueImmediateOrder(unit, "stop")
            call DestroyEffect(effect)
            call UnitRemoveAbility(unit, 'Abun')

            if selected then
                call SelectUnitAddForPlayer(unit, GetOwningPlayer(unit))
            endif

            set struct[id] = 0
            set unit = null
            set effect = null
            set array[i] = array[key]
            set key = key - 1

            call deallocate()

            if key == -1 then
                call PauseTimer(timer)
            endif

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer i = 0
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if duration > 0 and UnitAlive(unit) then
                        set duration = duration - PERIOD
                        set change = change + 1

                        if change >= DIRECTION_CHANGE then
                            set change = 0
                            set flag[id] = true
                            set x[id] = GetRandomReal(GetUnitX(unit) - MAX_CHANGE, GetUnitX(unit) + MAX_CHANGE)
                            set y[id] = GetRandomReal(GetUnitY(unit) - MAX_CHANGE, GetUnitY(unit) + MAX_CHANGE)
                            call IssuePointOrder(unit, "move", x[id], y[id])
                        endif
                    else
                        set i = remove(i)
                    endif
                set i = i + 1
            endloop
        endmethod

        static method apply takes unit whichUnit, real duration, string model, string point returns nothing
            local integer id = GetUnitUserData(whichUnit)
            local thistype this

            if duration > 0 then
                if struct[id] != 0 then
                    set this = struct[id]
                else
                    set this = thistype.allocate()
                    set .id = id
                    set unit = whichUnit
                    set change = 0
                    set selected = IsUnitSelected(whichUnit, GetOwningPlayer(whichUnit))
                    set key = key + 1
                    set array[key] = this
                    set struct[id] = this

                    call UnitAddAbility(whichUnit, 'Abun')

                    if selected then
                        call SelectUnit(whichUnit, false)
                    endif

                    if model != null and point != null then
                        set effect = AddSpecialEffectTarget(model, whichUnit, point)
                    endif

                    if key == 0 then
                        call TimerStart(timer, PERIOD, true, function thistype.onPeriod)
                    endif
                endif

                set .duration = duration
                set flag[id] = true
                set x[id] = GetRandomReal(GetUnitX(whichUnit) - MAX_CHANGE, GetUnitX(whichUnit) + MAX_CHANGE)
                set y[id] = GetRandomReal(GetUnitY(whichUnit) - MAX_CHANGE, GetUnitY(whichUnit) + MAX_CHANGE)
                call IssuePointOrder(whichUnit, "move", x[id], y[id])
            endif
        endmethod

        private static method onOrder takes nothing returns nothing
            local unit source = GetOrderedUnit()
            local integer id

            if isUnitFeared(source) then
                set id = GetUnitUserData(source)

                if not flag[id] then
                    set flag[id] = true
                    call IssuePointOrder(source, "move", x[id], y[id])
                else
                    set flag[id] = false
                endif
            endif

            set source = null
        endmethod

        private static method onSelect takes nothing returns nothing
            local unit source = GetTriggerUnit()
        
            if isUnitFeared(source) then
                if IsUnitSelected(source, GetOwningPlayer(source)) then
                    call SelectUnit(source, false)
                endif
            endif
            
            set source = null
        endmethod

        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_UNIT_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, function thistype.onSelect)
        endmethod
    endstruct

    /* ------------------------------------------- Disarm ------------------------------------------- */
    struct Disarm
        static constant integer ability = 'Abun'
        static constant real period  = 0.03125000
        static timer timer = CreateTimer()
        static integer key = -1
        static thistype array array
        static thistype array struct
        readonly static integer array count

        unit unit
        effect effect
        integer id
        integer ticks

        static method isUnitDisarmed takes unit target returns boolean
            return GetUnitAbilityLevel(target, ability) > 0
        endmethod

        private method remove takes integer i returns integer
            call disarm(unit, false)
            call DestroyEffect(effect)

            set struct[id] = 0
            set unit = null
            set effect = null
            set array[i] = array[key]
            set key = key - 1

            if key == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer  i = 0
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if ticks <= 0 then
                        set i = remove(i)
                    endif
                    set ticks = ticks - 1
                set i = i + 1
            endloop
        endmethod

        static method apply takes unit whichUnit, real duration, string model, string point returns nothing
            local integer  i = GetUnitUserData(whichUnit)
            local thistype this

            if duration > 0 then
                if struct[i] != 0 then
                    set this = struct[i]
                else
                    set this = thistype.allocate()
                    set unit = whichUnit
                    set id = i
                    set key = key + 1
                    set array[key] = this
                    set struct[i] = this

                    if model != null and point != null then
                        set effect = AddSpecialEffectTarget(model, unit, point)
                    endif

                    call disarm(whichUnit, true)

                    if key == 0 then
                        call TimerStart(timer, period, true, function thistype.onPeriod)
                    endif
                endif

                set ticks = R2I(duration/period)
            endif
        endmethod

        static method disarm takes unit whichUnit, boolean flag returns nothing
            local integer i = GetUnitUserData(whichUnit)
            
            if flag then
                set count[i] = count[i] + 1
                if count[i] > 0 then
                    call UnitAddAbility(whichUnit, ability)
                endif
            else
                set count[i] = count[i] - 1
                if count[i] <= 0 then
                    call UnitRemoveAbility(whichUnit, ability)
                endif
            endif
        endmethod
    endstruct

    /* ---------------------------------------- Crowd Control --------------------------------------- */
    struct CrowdControl extends array
        private static trigger trigger = CreateTrigger()
        private static hashtable hashtable = InitHashtable()
        private static trigger array event
        private static integer array ability
        private static integer array buff
        private static string array string
        private static unit dummy

        readonly static integer key = -1
        
        static unit array unit
        static real array value
        static real array real
        static real array angle
        static real array distance
        static real array height
        static string array effect
        static string array bone
        static boolean array stack 
        static boolean array cliff 
        static boolean array destructable 
        static boolean array agent 
        static integer array type

        private static method onInit takes nothing returns nothing
            set dummy = DummyRetrieve(Player(PLAYER_NEUTRAL_PASSIVE), GetRectCenterX(GetWorldBounds()), GetRectCenterY(GetWorldBounds()), 0, 0)
        endmethod

        private static method onExpire takes nothing returns nothing
            local timer t = GetExpiredTimer()

            call RemoveSavedHandle(hashtable, GetHandleId(LoadUnitHandle(hashtable, GetHandleId(t), 0)), LoadInteger(hashtable, GetHandleId(t), 1))
            call FlushChildHashtable(hashtable, GetHandleId(t))
            call DestroyTimer(t)

            set t = null
        endmethod

        private static method onEvent takes integer id, integer i returns nothing
            if key - CROWD_CONTROL_KNOCKUP < RECURSION_LIMIT then
                if event[id] != null then
                    call TriggerEvaluate(event[type[i]])
                endif
                
                call TriggerEvaluate(trigger)
            else
                call BJDebugMsg("[Crowd Control] Recursion limit reached: " + I2S(RECURSION_LIMIT))
            endif
            
            set key = i
        endmethod

        private static method getOrder takes integer id returns string
            if id == CROWD_CONTROL_SILENCE then
                return "drunkenhaze"
            elseif id == CROWD_CONTROL_STUN then
                return "thunderbolt"
            elseif id == CROWD_CONTROL_SLOW then
                return "cripple"
            elseif id == CROWD_CONTROL_SLOW_ATTACK then
                return "cripple"
            elseif id == CROWD_CONTROL_BANISH then
                return "banish"
            elseif id == CROWD_CONTROL_ENSNARE then
                return "ensnare"
            elseif id == CROWD_CONTROL_PURGE then
                return "purge"
            elseif id == CROWD_CONTROL_HEX then
                return "hex"
            elseif id == CROWD_CONTROL_SLEEP then
                return "sleep"
            elseif id == CROWD_CONTROL_CYCLONE then
                return "cyclone"
            elseif id == CROWD_CONTROL_ENTANGLE then
                return "entanglingroots"
            else
                return null
            endif
        endmethod

        private static method setup takes integer id, integer key returns nothing
            if id == CROWD_CONTROL_SILENCE then
                set ability[key] = SILENCE
                set buff[key] = SILENCE_BUFF
            elseif id == CROWD_CONTROL_STUN then
                set ability[key] = STUN
                set buff[key] = STUN_BUFF
            elseif id == CROWD_CONTROL_SLOW then
                set ability[key] = ATTACK_SLOW
                set buff[key] = ATTACK_SLOW_BUFF
            elseif id == CROWD_CONTROL_SLOW_ATTACK then
                set ability[key] = MOVEMENT_SLOW
                set buff[key] = MOVEMENT_SLOW_BUFF
            elseif id == CROWD_CONTROL_BANISH then
                set ability[key] = BANISH
                set buff[key] = BANISH_BUFF
            elseif id == CROWD_CONTROL_ENSNARE then
                set ability[key] = ENSNARE
                set buff[key] = ENSNARE_BUFF
            elseif id == CROWD_CONTROL_PURGE then
                set ability[key] = PURGE
                set buff[key] = PURGE_BUFF
            elseif id == CROWD_CONTROL_HEX then
                set ability[key] = HEX
                set buff[key] = HEX_BUFF
            elseif id == CROWD_CONTROL_SLEEP then
                set ability[key] = SLEEP
                set buff[key] = SLEEP_BUFF
            elseif id == CROWD_CONTROL_CYCLONE then
                set ability[key] = CYCLONE
                set buff[key] = CYCLONE_BUFF
            elseif id == CROWD_CONTROL_ENTANGLE then
                set ability[key] = ENTANGLE
                set buff[key] = ENTANGLE_BUFF
            endif
        endmethod

        private static method cast takes unit target, real amount, real ang, real dist, real maxHeight, real duration, string model, string point, boolean stacks, boolean onCliff, boolean onDestructable, boolean onUnit, integer id, string order returns nothing
            local ability spell
            local timer t
    
            if not IsUnitType(target, UNIT_TYPE_MAGIC_IMMUNE) and UnitAlive(target) and duration > 0 then
                set key = key + 1
                set unit[key] = target
                set value[key] = amount
                set angle[key] = ang
                set distance[key] = dist
                set height[key] = maxHeight
                set real[key] = duration
                set effect[key] = model
                set bone[key] = point
                set stack[key] = stacks
                set cliff[key] = onCliff
                set destructable[key] = onDestructable
                set agent[key] = onUnit
                set type[key] = id
                set string[key] = order

                call onEvent(id, key)
    
                if type[key] != id then
                    call cast(unit[key], value[key], angle[key], distance[key], height[key], real[key], effect[key], bone[key], stack[key], cliff[key], destructable[key], agent[key], type[key], getOrder(type[key]))
                else
                    static if LIBRARY_Tenacity then
                        set real[key] = GetTenacityDuration(unit[key], real[key])
                    endif
    
                    if real[key] > 0 and UnitAlive(unit[key]) then
                        if not HaveSavedHandle(hashtable, GetHandleId(unit[key]), type[key]) then
                            set t = CreateTimer()
                            call SaveTimerHandle(hashtable, GetHandleId(unit[key]), type[key], t)
                            call SaveUnitHandle(hashtable, GetHandleId(t), 0, unit[key])
                            call SaveInteger(hashtable, GetHandleId(t), 1, type[key])
                        endif
    
                        if stack[key] then
                            set real[key] = real[key] + TimerGetRemaining(LoadTimerHandle(hashtable, GetHandleId(unit[key]), type[key]))
                        endif
    
                        if type[key] != CROWD_CONTROL_DISARM and type[key] != CROWD_CONTROL_FEAR and type[key] != CROWD_CONTROL_KNOCKBACK and type[key] != CROWD_CONTROL_KNOCKUP then
                            call setup(type[key], key)
                            call UnitAddAbility(dummy, ability[key])
                            set spell = BlzGetUnitAbility(dummy, ability[key])
                            call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_NORMAL, 0, real[key])
                            call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_DURATION_HERO, 0, real[key])
    
                            if type[key] == CROWD_CONTROL_SLOW then
                                call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_MOVEMENT_SPEED_REDUCTION_PERCENT_CRI1, 0, value[key])
                            elseif type[key] == CROWD_CONTROL_SLOW_ATTACK then
                                call BlzSetAbilityRealLevelField(spell, ABILITY_RLF_ATTACK_SPEED_REDUCTION_PERCENT_CRI2, 0, value[key])
                            endif
    
                            call IncUnitAbilityLevel(dummy, ability[key])
                            call DecUnitAbilityLevel(dummy, ability[key])
    
                            if IssueTargetOrder(dummy, string[key], unit[key]) then
                                call TimerStart(LoadTimerHandle(hashtable, GetHandleId(unit[key]), type[key]), real[key], false, function thistype.onExpire)

                                if effect[key] != null and effect[key] != "" then
                                    if bone[key] != null and bone[key] != "" then
                                        call LinkEffectToBuff(unit[key], buff[key], effect[key], bone[key])
                                    else
                                        call DestroyEffect(AddSpecialEffect(effect[key], GetUnitX(unit[key]), GetUnitY(unit[key])))
                                    endif
                                endif
                            else
                                call RemoveSavedHandle(hashtable, GetHandleId(unit[key]), type[key])
                                call FlushChildHashtable(hashtable, GetHandleId(t))
                                call DestroyTimer(t)
                            endif
    
                            call UnitRemoveAbility(dummy, ability[key])
                        else
                            if type[key] == CROWD_CONTROL_DISARM then
                                call Disarm.apply(unit[key], real[key], effect[key], bone[key])
                            elseif type[key] == CROWD_CONTROL_FEAR then
                                call Fear.apply(unit[key], real[key], effect[key], bone[key])
                            elseif type[key] == CROWD_CONTROL_KNOCKBACK then
                                call Knockback.apply(unit[key], angle[key], distance[key], real[key], effect[key], bone[key], cliff[key], destructable[key], agent[key])
                            elseif type[key] == CROWD_CONTROL_KNOCKUP then
                                call Knockup.apply(unit[key], real[key], height[key], effect[key], bone[key])
                            endif

                            call TimerStart(LoadTimerHandle(hashtable, GetHandleId(unit[key]), type[key]), real[key], false, function thistype.onExpire)
                        endif
                    endif
                endif
    
                if key > -1 then
                    set key = key - 1
                endif
            endif
    
            set t = null
            set spell = null
        endmethod

        static method silence takes unit target, real duration, string model, string point, boolean stack returns nothing
            call cast(target, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_SILENCE, "drunkenhaze")
        endmethod
    
        static method silenced takes unit target returns boolean
            return GetUnitAbilityLevel(target, SILENCE_BUFF) > 0
        endmethod

        static method stun takes unit target, real duration, string model, string point, boolean stack returns nothing
            call cast(target, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_STUN, "thunderbolt")
        endmethod
    
        static method stunned takes unit target returns boolean
            return GetUnitAbilityLevel(target, STUN_BUFF) > 0
        endmethod

        static method slow takes unit target, real amount, real duration, string model, string point, boolean stack returns nothing
            call cast(target, amount, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_SLOW, "cripple")
        endmethod
    
        static method slowed takes unit target returns boolean
            return GetUnitAbilityLevel(target, MOVEMENT_SLOW_BUFF) > 0
        endmethod

        static method slowAttack takes unit target, real amount, real duration, string model, string point, boolean stack returns nothing
            call cast(target, amount, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_SLOW_ATTACK, "cripple")
        endmethod
    
        static method attackSlowed takes unit target returns boolean
            return GetUnitAbilityLevel(target, ATTACK_SLOW_BUFF) > 0
        endmethod

        static method banish takes unit target, real duration, string model, string point, boolean stack returns nothing
            call cast(target, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_BANISH, "banish")
        endmethod
    
        static method banished takes unit target returns boolean
            return GetUnitAbilityLevel(target, BANISH_BUFF) > 0
        endmethod

        static method ensnare takes unit target, real duration, string model, string point, boolean stack returns nothing
            call cast(target, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_ENSNARE, "ensnare")
        endmethod
    
        static method ensnared takes unit target returns boolean
            return GetUnitAbilityLevel(target, ENSNARE_BUFF) > 0
        endmethod

        static method purge takes unit target, real duration, string model, string point, boolean stack returns nothing
            call cast(target, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_PURGE, "purge")
        endmethod
    
        static method purged takes unit target returns boolean
            return GetUnitAbilityLevel(target, PURGE_BUFF) > 0
        endmethod

        static method hex takes unit target, real duration, string model, string point, boolean stack returns nothing
            call cast(target, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_HEX, "hex")
        endmethod
    
        static method hexed takes unit target returns boolean
            return GetUnitAbilityLevel(target, HEX_BUFF) > 0
        endmethod

        static method sleep takes unit target, real duration, string model, string point, boolean stack returns nothing
            call cast(target, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_SLEEP, "sleep")
        endmethod
    
        static method sleeping takes unit target returns boolean
            return GetUnitAbilityLevel(target, SLEEP_BUFF) > 0
        endmethod

        static method cyclone takes unit target, real duration, string model, string point, boolean stack returns nothing
            call cast(target, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_CYCLONE, "cyclone")
        endmethod
    
        static method cycloned takes unit target returns boolean
            return GetUnitAbilityLevel(target, CYCLONE_BUFF) > 0
        endmethod

        static method entangle takes unit target, real duration, string model, string point, boolean stack returns nothing
            call cast(target, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_ENTANGLE, "entanglingroots")
        endmethod
    
        static method entangled takes unit target returns boolean
            return GetUnitAbilityLevel(target, ENTANGLE_BUFF) > 0
        endmethod
        
        static method knockback takes unit target, real angle, real distance, real duration, string model, string point, boolean onCliff, boolean onDestructable, boolean onUnit, boolean stack returns nothing
            call cast(target, 0, angle, distance, 0, duration, model, point, stack, onCliff, onDestructable, onUnit, CROWD_CONTROL_KNOCKBACK, null)
        endmethod
    
        static method knockedback takes unit target returns boolean
            return Knockback.isUnitKnocked(target)
        endmethod

        static method knockup takes unit target, real maxHeight, real duration, string model, string point, boolean stack returns nothing
            call cast(target, 0, 0, 0, maxHeight, duration, model, point, stack, false, false, false, CROWD_CONTROL_KNOCKUP, null)
        endmethod
    
        static method knockedup takes unit target returns boolean
            return Knockup.isUnitKnocked(target)
        endmethod

        static method fear takes unit target, real duration, string model, string point, boolean stack returns nothing
            call cast(target, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_FEAR, null)
        endmethod
    
        static method feared takes unit target returns boolean
            return Fear.isUnitFeared(target)
        endmethod

        static method disarm takes unit target, real duration, string model, string point, boolean stack returns nothing
            call cast(target, 0, 0, 0, 0, duration, model, point, stack, false, false, false, CROWD_CONTROL_DISARM, null)
        endmethod
    
        static method disarmed takes unit target returns boolean
            return Disarm.isUnitDisarmed(target)
        endmethod

        static method remaining takes unit target, integer id returns real
            return TimerGetRemaining(LoadTimerHandle(hashtable, GetHandleId(target), id))
        endmethod

        static method register takes integer id, code c returns nothing
            if id >= CROWD_CONTROL_SILENCE and id <= CROWD_CONTROL_KNOCKUP then
                if event[id] == null then
                    set event[id] = CreateTrigger()
                endif
                call TriggerAddCondition(event[id], Filter(c))
            else
                call TriggerAddCondition(trigger, Filter(c))
            endif
        endmethod
    endstruct
endlibrary
