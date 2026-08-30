library Shield requires Unit, DamageInterface, ProgressBar, Modules, Indexer
    /* -------------------------------- Shield v1.0 by Chopinski ------------------------------- */
    globals
        private constant real BAR_SCALE = 2.
        private constant real BAR_GAP = 50
        private constant real BAR_OFFSET = 100
    endglobals


    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function RegisterShieldEvent takes code c returns nothing
        call Shield.register(c)
    endfunction

    function RegisterShieldBreakEvent takes code c returns nothing
        call Shield.registerBreak(c)
    endfunction

    function GetTriggerShield takes nothing returns Shield
        return Shield.instance
    endfunction

    function CreateShield takes unit source, unit target, real amount, attacktype atktype, damagetype dmgtype, real duration, string sfx, string attachPoint, boolean showBar, integer playerColor, boolean showText returns Shield
        return Shield.create(source, target, amount, atktype, dmgtype, duration, sfx, attachPoint, showBar, playerColor, showText)
    endfunction

    function GetShieldValue takes Shield shield returns real
        return shield.value
    endfunction

    function SetShieldValue takes Shield shield, real value returns Shield
        set shield.value = value
        return shield
    endfunction

    function GetShieldTotal takes Shield shield returns real
        return shield.total
    endfunction

    function GetShieldingSource takes nothing returns unit
        return Shield.source.unit
    endfunction

    function GetShieldingTarget takes nothing returns unit
        return Shield.target.unit
    endfunction

    function GetShieldingAmount takes nothing returns real
        return Shield.amount
    endfunction

    function SetShieldingAmount takes real value returns nothing
        set Shield.amount = value
    endfunction

    function GetShieldingOverdamage takes nothing returns real
        return Shield.overdamage
    endfunction

    function RestoreShield takes Shield shield returns Shield
        return shield.restore()
    endfunction

    function ShieldAddAmount takes Shield shield, real value returns Shield
        return shield.add(value)
    endfunction

    function GetUnitShieldingIncrease takes unit u returns real
        return Shield.getIncrease(u)
    endfunction

    function GetUnitShieldingDecrease takes unit u returns real
        return Shield.getDecrease(u)
    endfunction

    function SetUnitShieldingIncrease takes unit u, real value returns real
        return Shield.setIncrease(u, value)
    endfunction

    function SetUnitShieldingDecrease takes unit u, real value returns real
        return Shield.setDecrease(u, value)
    endfunction

    function DestroyShield takes Shield shield returns nothing
        call shield.destroy()
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    struct Shield
        readonly static Unit source
        readonly static Unit target
        readonly static real array increase
        readonly static real array decrease
        readonly static trigger break = CreateTrigger()
        readonly static trigger trigger = CreateTrigger()

        private static List array shields
        private static integer array slots
        private static integer array counter

        static real amount
        static real overdamage
        static thistype instance
        static attacktype attacktype
        static damagetype damagetype

        private unit src
        private unit tgt
        private integer id
        private integer slot
        private effect effect
        private boolean showText
        private boolean allocated
        private attacktype atktype
        private damagetype dmgtype

        readonly real total
        readonly ProgressBar bar

        real value

        method destroy takes nothing returns nothing
            local List list
            local List node
            local thistype shield

            if allocated then
                if bar != 0 then
                    set list = List(shields[id])

                    if list != 0 then
                        set node = list.next

                        loop
                            exitwhen node == list
                                set shield = Shield(node.data)

                                if shield.bar != 0 and shield.slot > slot then
                                    set shield.slot = shield.slot - 1
                                    set shield.bar.y = -BAR_OFFSET - BAR_GAP * shield.slot
                                endif
                            set node = node.next
                        endloop
                    endif

                    set slots[id] = slots[id] - 1

                    call DestroyProgressBar(bar)
                endif

                if effect != null then
                    call DestroyEffect(effect)
                endif

                call List(shields[id]).remove(this)
                call CancelTimer(this)

                set bar = 0
                set src = null
                set tgt = null
                set effect = null
                set atktype = null
                set dmgtype = null
                set allocated = false
                set counter[id] = counter[id] - 1

                call deallocate()
            endif
        endmethod

        method add takes real amount returns thistype
            if value + amount > 0 then
                set value = value + amount

                if value >= total then
                    set total = value
                endif

                if bar != 0 then
                    call SetProgressBarPercentage(bar, (value / total) * 100, 0)

                    if showText then
                        call SetProgressBarText(bar, I2S(R2I(value)))
                    endif
                endif
            endif

            return this
        endmethod

        method restore takes nothing returns thistype
            set value = total

            if bar != 0 then
                call SetProgressBarPercentage(bar, 100, 0)

                if showText then
                    call SetProgressBarText(bar, I2S(R2I(value)))
                endif
            endif

            return this
        endmethod

        static method getIncrease takes unit u returns real
            return increase[GetUnitUserData(u)]
        endmethod

        static method getDecrease takes unit u returns real
            return decrease[GetUnitUserData(u)]
        endmethod

        static method setIncrease takes unit u, real value returns real
            set increase[GetUnitUserData(u)] = value

            return value
        endmethod

        static method setDecrease takes unit u, real value returns real
            set decrease[GetUnitUserData(u)] = value

            return value
        endmethod

        static method register takes code c returns nothing
            call TriggerAddCondition(trigger, Filter(c))
        endmethod

        static method registerBreak takes code c returns nothing
            call TriggerAddCondition(break, Filter(c))
        endmethod

        static method create takes unit source, unit target, real amount, attacktype atktype, damagetype dmgtype, real duration, string sfx, string attachPoint, boolean showBar, integer playerColor, boolean showText returns Shield
            local integer id = GetUnitUserData(target)
            local thistype this = thistype.allocate()

            set Shield.instance = this
            set Shield.attacktype = atktype 
            set Shield.damagetype = dmgtype
            set Shield.source.unit = source
            set Shield.target.unit = target
            set Shield.amount = (amount * (1 + increase[Shield.target.id])) * (1 - decrease[Shield.target.id])

            call TriggerEvaluate(trigger)

            if shields[id] == 0 then
                set shields[id] = List.create()
            endif

            set .id = id
            set src = source
            set tgt = target
            set allocated = true
            set .atktype = atktype
            set .dmgtype = dmgtype
            set .showText = showText
            set value = Shield.amount
            set total = Shield.amount
            set counter[id] = counter[id] + 1

            if sfx != "" then
                set effect = AddSpecialEffectTarget(sfx, target, attachPoint)
            endif

            if showBar then
                set slot = slots[id]
                set slots[id] = slots[id] + 1

                if Shield.amount > 0 then
                    set bar = CreateProgressBar(target, 0, -BAR_OFFSET - BAR_GAP * slot, 0, BAR_SCALE, 100, showText)
                else
                    set bar = CreateProgressBar(target, 0, -BAR_OFFSET - BAR_GAP * slot, 0, BAR_SCALE, 0, showText)
                endif

                if showText then
                    call SetProgressBarText(bar, I2S(R2I(value)))
                endif

                set bar.playercolor = playerColor
            endif

            if duration > 0 then
                call StartTimer(duration, false, this, 0)
            endif

            call List(shields[id]).insert(this)

            return this
        endmethod

        private static method onDamage takes nothing returns nothing
            local List list
            local List shield
            local thistype this

            if Damage.amount > 0 and counter[Damage.target.id] > 0 then
                set list = List(shields[Damage.target.id])

                if list != 0 then
                    if list.size > 0 then
                        set shield = list.next

                        loop
                            exitwhen shield == list or Damage.amount <= 0
                                set this = Shield(shield.data)
                                set shield = shield.next

                                if Damage.attacktype == atktype or Damage.damagetype == dmgtype or (atktype == null and dmgtype == null) then
                                    if Damage.amount < value then
                                        set value = value - Damage.amount
                                        set Damage.amount = 0

                                        if bar != 0 then
                                            call SetProgressBarPercentage(bar, (value / total) * 100, 0)

                                            if showText then
                                                call SetProgressBarText(bar, I2S(R2I(value)))
                                            endif
                                        endif
                                    else
                                        set Damage.amount = Damage.amount - value
                                        set Shield.amount = 0
                                        set Shield.instance = this
                                        set Shield.source.unit = src
                                        set Shield.target.unit = tgt
                                        set Shield.attacktype = atktype 
                                        set Shield.damagetype = dmgtype
                                        set Shield.overdamage = Damage.amount 

                                        call TriggerEvaluate(break)
                                        call destroy()
                                    endif
                                endif
                        endloop
                    endif
                endif
            endif
        endmethod

        private static method onDeindex takes nothing returns nothing
            local integer id = GetUnitUserData(GetIndexUnit())
            local List list = List(shields[id])
            local thistype this
            local List shield

            if list != 0 then
                set shield = list.next

                loop
                    exitwhen shield == list
                    set this = Shield(shield.data)
                    set shield = shield.next
                    call destroy()
                endloop

                call list.destroy()
            endif

            set slots[id] = 0
            set shields[id] = 0
            set counter[id] = 0
            set increase[id] = 0
            set decrease[id] = 0
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            set source = Unit.create(null)
            set target = Unit.create(null)

            call RegisterAnyDamageEvent(function thistype.onDamage)
            call RegisterUnitDeindexEvent(function thistype.onDeindex)
        endmethod
    endstruct
endlibrary