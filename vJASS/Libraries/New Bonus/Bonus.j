library NewBonus requires Table, Periodic
    /* ---------------------------------------- NewBonus v3.0 --------------------------------------- */
    // Since ObjectMerger is broken and we still have no means to edit
    // bonus values (green values) i decided to create a light weight
    // Bonus library that works in the same way that the original Bonus Mod
    // by Earth Fury did. NewBonus requires patch 1.30+.
    // Credits to Earth Fury for the original Bonus idea

    // How to Import?
    // Importing bonus mod is really simple. Just copy the 9 abilities with the
    // prefix "NewBonus" from the Object Editor into your map and match their new raw
    // code to the bonus types in the global block below. Then create a trigger called
    // NewBonus, convert it to custom text and paste this code there. You done!
    /* ---------------------------------------- By Chopinski ---------------------------------------- */
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // This is the maximum recursion limit allowed by the system.
        // It's value must be greater than or equal to 0. When equal to 0
        // no recursion is allowed. Values too big can cause screen freezes.
        private constant integer RECURSION_LIMIT = 8
    endglobals

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             System                                             */
    /* ---------------------------------------------------------------------------------------------- */
    private interface BonusType
        method get takes unit u returns real defaults 0
        method Set takes unit u, real value returns real defaults 0
        method add takes unit u, real value returns real defaults 0
    endinterface

    struct Bonus extends BonusType
        private static Table table
        private static integer key = 0
        private static integer index = -1
        private static integer array array
        private static trigger array event
        private static BonusType array struct
        private static trigger trigger = CreateTrigger()

        private item item
        private real value
        private unit source
        private integer buff
        private integer bonus

        static unit unit
        static real amount
        static integer type

        method destroy takes nothing returns nothing
            call adder(source, bonus, -value)

            set item = null
            set buff = 0
            set value = 0
            set bonus = 0
            set source = null
            
            call deallocate()
        endmethod

        method overflow takes real current, real value returns real
            if value > 0 and current > 2147483647 - value then
                return 2147483647 - current
            elseif value < 0 and current < -2147483648 - value then
                return -2147483648 - current
            else
                return value
            endif
        endmethod

        static method getter takes unit source, integer bonus returns real
            local thistype this = struct[bonus]

            if this != 0 then
                if get.exists then
                    return get(source)
                endif
            else
                call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Invalid Bonus Type")
            endif

            return 0.
        endmethod

        static method setter takes unit source, integer bonus, real value returns real
            local thistype this = struct[bonus]
            
            if this != 0 then
                if Set.exists then
                    set type = bonus
                    set unit = source
                    set amount = value
                    
                    call onEvent()
                    
                    if type != bonus then
                        return setter(unit, type, amount)
                    endif

                    set key = 0

                    return Set(unit, amount)
                endif
            else
                call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Invalid Bonus Type")
            endif

            return 0.
        endmethod

        static method adder takes unit source, integer bonus, real value returns real
            local thistype this = struct[bonus]

            if this != 0 and value != 0 then
                if add.exists then
                    set type = bonus
                    set unit = source
                    set amount = value
                    
                    call onEvent()
                    
                    if type != bonus then
                        return adder(unit, type, amount)
                    endif

                    set key = 0

                    return add(unit, amount)
                endif
            else
                call DisplayTextToPlayer(GetLocalPlayer(), 0, 0, "Invalid Bonus Type")
            endif

            return 0.
        endmethod
        
        static method copy takes unit source, unit target returns nothing
            local integer i = 0

            loop
                exitwhen i > index
                    if getter(source, array[i]) != 0 then
                        call adder(target, array[i], getter(source, array[i]))
                    endif
                set i = i + 1
            endloop
        endmethod

        static method mirror takes unit source, unit target returns nothing
            local integer i = 0
            
            loop
                exitwhen i > index
                    call setter(target, array[i], getter(source, array[i]))
                set i = i + 1
            endloop
        endmethod

        static method linkTimer takes unit source, integer bonus, real amount, real duration returns nothing
            local thistype this
            
            if amount != 0 then
                set this = thistype.allocate()
                set this.value = adder(source, bonus, amount)
                set this.source = source
                set this.bonus = type
            
                call StartTimer(duration, false, this, -1)
            endif
        endmethod

        static method linkBuff takes unit source, integer bonus, real amount, integer id returns nothing
            local thistype this

            if amount != 0 then
                set this = thistype.allocate()
                set this.value = adder(source, bonus, amount)
                set this.source = source
                set this.bonus = type
                set this.buff = id
            
                call StartTimer(0.03125, true, this, -1)
            endif
        endmethod

        static method linkItem takes unit source, integer bonus, real amount, item i returns nothing
            local thistype this
            
            if amount != 0 then
                set this = thistype.allocate()
                set this.value = adder(source, bonus, amount)
                set this.source = source
                set this.bonus = type
                set this.item = i
                set table[GetHandleId(i)] = this
            endif
        endmethod

        static method register takes BonusType bonus returns integer
            set index = index + 1
            set array[index] = bonus.getType()
            set struct[bonus.getType()] = bonus

            return bonus.getType()
        endmethod

        static method registerEvent takes code c, integer bonus returns nothing
            if bonus > 0 then
                if event[bonus] == null then
                    set event[bonus] = CreateTrigger()
                endif

                call TriggerAddCondition(event[bonus], Filter(c))
            else
                call TriggerAddCondition(trigger, Filter(c))
            endif
        endmethod

        private method onPeriod takes nothing returns boolean
            return GetUnitAbilityLevel(source, buff) > 0
        endmethod

        private static method onEvent takes nothing returns nothing
            set key = key + 1
            
            if key <= RECURSION_LIMIT then
                if event[type] != null then
                    call TriggerEvaluate(event[type])
                endif

                call TriggerEvaluate(trigger)
            endif
        endmethod

        private static method onDrop takes nothing returns nothing
            local integer id = GetHandleId(GetManipulatedItem())
            local thistype this = table[id]

            if this != 0 then
                call table.remove(id)
                call destroy()
            endif
        endmethod

        implement Periodic

        private static method onInit takes nothing returns nothing
            set table = Table.create()

            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, function thistype.onDrop)
        endmethod
    endstruct

    /* ---------------------------------------------------------------------------------------------- */
    /*                                            JASS API                                            */
    /* ---------------------------------------------------------------------------------------------- */
    function RegisterBonus takes BonusType bonus returns integer
        return Bonus.register(bonus)
    endfunction

    function RegisterBonusEvent takes code c returns nothing
        call Bonus.registerEvent(c, 0)
    endfunction
    
    function RegisterBonusTypeEvent takes integer bonus, code c returns nothing
        call Bonus.registerEvent(c, bonus)
    endfunction
    
    function GetBonusUnit takes nothing returns unit
        return Bonus.unit
    endfunction
    
    function GetBonusType takes nothing returns integer
        return Bonus.type
    endfunction
    
    function SetBonusType takes integer bonus returns nothing
        set Bonus.type = bonus
    endfunction
    
    function GetBonusAmount takes nothing returns real
        return Bonus.amount
    endfunction
    
    function SetBonusAmount takes real amount returns nothing
        set Bonus.amount = amount
    endfunction

    function GetUnitBonus takes unit source, integer bonus returns real
        return Bonus.getter(source, bonus)
    endfunction

    function SetUnitBonus takes unit source, integer bonus, real amount returns real
        return Bonus.setter(source, bonus, amount)
    endfunction
    
    function RemoveUnitBonus takes unit source, integer bonus returns nothing
        call Bonus.setter(source, bonus, 0)
    endfunction
    
    function AddUnitBonus takes unit source, integer bonus, real amount returns real
        return Bonus.adder(source, bonus, amount)
    endfunction

    function AddUnitBonusTimed takes unit source, integer bonus, real amount, real duration returns nothing
        call Bonus.linkTimer(source, bonus, amount, duration)
    endfunction

    function LinkBonusToBuff takes unit source, integer bonus, real amount, integer id returns nothing
        call Bonus.linkBuff(source, bonus, amount, id)
    endfunction

    function LinkBonusToItem takes unit source, integer bonus, real amount, item i returns nothing
        call Bonus.linkItem(source, bonus, amount, i)
    endfunction

    function UnitCopyBonuses takes unit source, unit target returns nothing
        call Bonus.copy(source, target)
    endfunction

    function UnitMirrorBonuses takes unit source, unit target returns nothing
        call Bonus.mirror(source, target)
    endfunction
endlibrary