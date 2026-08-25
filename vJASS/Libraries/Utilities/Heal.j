library Heal requires Unit, Indexer, ArcingFloatingText
    /* --------------------------------- Heal 1.0 by Chopinski --------------------------------- */
    globals
        // The text size
        private constant real TEXT_SIZE = 0.02
        // The healing types
        constant integer HEALTH = 0
        constant integer MANA = 1
    endglobals

    /* ----------------------------------------------------------------------------------------- */
    /*                                          JASS API                                         */
    /* ----------------------------------------------------------------------------------------- */
    function RegisterHealingEvent takes code c returns nothing
        call Heal.register(c)
    endfunction

    function HealUnit takes unit source, unit target, real amount, integer healtype, boolean showText returns boolean
        return Heal.heal(source, target, amount, healtype, showText)
    endfunction

    function GetHealingSource takes nothing returns unit
        return Heal.source.unit
    endfunction

    function GetHealingTarget takes nothing returns unit
        return Heal.target.unit
    endfunction

    function GetHealingAmount takes nothing returns real
        return Heal.amount
    endfunction

    function SetHealingAmount takes real value returns nothing
        set Heal.amount = value
    endfunction

    function GetHealingType takes nothing returns integer
        return Heal.type
    endfunction

    function SetHealingType takes integer value returns nothing
        set Heal.type = value
    endfunction

    function GetUnitHealingIncrease takes unit u returns real
        return Heal.getIncrease(u)
    endfunction

    function GetUnitHealingDecrease takes unit u returns real
        return Heal.getDecrease(u)
    endfunction

    function SetUnitHealingIncrease takes unit u, real value returns real
        return Heal.setIncrease(u, value)
    endfunction

    function SetUnitHealingDecrease takes unit u, real value returns real
        return Heal.setDecrease(u, value)
    endfunction

    /* ----------------------------------------------------------------------------------------- */
    /*                                           System                                          */
    /* ----------------------------------------------------------------------------------------- */
    struct Heal
        readonly static Unit source
        readonly static Unit target
        readonly static real array increase
        readonly static real array decrease
        readonly static trigger trigger = CreateTrigger()

        static real amount
        static integer type

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

        static method heal takes unit source, unit target, real amount, integer healtype, boolean showText returns boolean
            if amount > 0 and (healtype == HEALTH or healtype == MANA) then
                set Heal.type = healtype
                set Heal.source.unit = source
                set Heal.target.unit = target
                set Heal.amount = (amount * (1 + increase[Heal.target.id])) * (1 - decrease[Heal.target.id])

                call TriggerEvaluate(trigger)

                if UnitAlive(Heal.target.unit) and Heal.amount > 0 then
                    if Heal.type == HEALTH then
                        call SetWidgetLife(Heal.target.unit, Heal.target.health + Heal.amount)
                    else
                        call SetUnitState(Heal.target.unit, UNIT_STATE_MANA, Heal.target.mana + Heal.amount)
                    endif

                    if showText then
                        if Heal.type == HEALTH then
                            call ArcingTextTag.create("|cff00ff00+" + (I2S(R2I(Heal.amount))) + "|r", Heal.target.unit, TEXT_SIZE)
                        else
                            call ArcingTextTag.create("|cff00ffff+" + (I2S(R2I(Heal.amount))) + "|r", Heal.target.unit, TEXT_SIZE)
                        endif
                    endif

                    return true
                endif
            endif

            return false
        endmethod

        static method register takes code c returns nothing
            call TriggerAddCondition(trigger, Filter(c))
        endmethod

        private static method onDeindex takes nothing returns nothing
            local integer id = GetUnitUserData(GetIndexUnit())

            set increase[id] = 0
            set decrease[id] = 0
        endmethod

        private static method onInit takes nothing returns nothing
            set source = Unit.create(null)
            set target = Unit.create(null)

            call RegisterUnitDeindexEvent(function thistype.onDeindex)
        endmethod
    endstruct
endlibrary