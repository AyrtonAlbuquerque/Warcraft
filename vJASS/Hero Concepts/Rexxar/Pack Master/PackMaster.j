library PackMaster requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, TimerUtils, NewBonus
    /* ---------------------- Pack Master v1.0 by Chopinski --------------------- */
    // Credits:
    //     Bribe           - SpellEffectEvent
    //     Vexorian        - TimerUtils
    /* ----------------------------------- END ---------------------------------- */

    /* -------------------------------------------------------------------------- */
    /*                                Configuration                               */
    /* -------------------------------------------------------------------------- */
    globals
        // The ability raw code
        private constant integer ABILITY = 'A003'
        // The Wolf unit raw code
        private constant integer WOLF    = 'o001'
    endglobals
    
    // The maximum number of wolfs per level
    private function GetMaxWolfCount takes integer level returns integer
        return level
    endfunction

    // The wolf damage
    private function GetWolfDamage takes unit source, integer level returns integer
        return R2I((BlzGetUnitBaseDamage(source, 0) + GetUnitBonus(source, BONUS_DAMAGE))*(0.25 + 0.*level))
    endfunction
    
    // The wolf cricital chance
    private function GetWolfCriticalChance takes integer level returns real
        return 30. + 0.*level
    endfunction
    
    // The wolf critical damage bonus (1 base)
    private function GetWolfCriticalDamage takes integer level returns real
        return 1. + 0.*level
    endfunction
    
    // The wolf duration
    private function GetDuration takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    endfunction
    
    // The max distance a wolf can be from Rexxar
    private function GetMaxDistance takes unit source, integer level returns real
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    endfunction
    
    // The Unit Filter
    private function UnitFilter takes player owner, unit target returns boolean
        return IsUnitEnemy(target, owner) and not IsUnitType(target, UNIT_TYPE_STRUCTURE)
    endfunction

    /* -------------------------------------------------------------------------- */
    /*                                   System                                   */
    /* -------------------------------------------------------------------------- */
    private struct Wolf
        static thistype array struct
        
        timer timer
        unit unit
        group group
        player player
        boolean shadow
        
        method operator size takes nothing returns integer
            return BlzGroupGetSize(group)
        endmethod
        
        method destroy takes nothing returns nothing
            call ReleaseTimer(timer)
            call DestroyGroup(group)
            call deallocate()
        
            set unit = null
            set timer = null
            set group = null
            set player = null
        endmethod
        
        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            local integer i = 0
            local unit u
            
            loop
                exitwhen i == size
                    set u = BlzGroupUnitAt(group, i)
                    
                    if not IsUnitInRange(u, unit, GetMaxDistance(unit, GetUnitAbilityLevel(unit, ABILITY))) then
                        call IssueTargetOrder(u, "smart", unit)
                    endif
                set i = i + 1
            endloop
        endmethod
        
        method add takes unit target returns nothing
            local unit wolf = CreateUnit(player, WOLF, GetUnitX(target), GetUnitY(target), 0)
            local integer id = GetUnitUserData(wolf)
            local integer level = GetUnitAbilityLevel(unit, ABILITY)
            
            set struct[id] = this
            
            call SetUnitBonus(wolf, BONUS_CRITICAL_CHANCE, GetWolfCriticalChance(level))
            call SetUnitBonus(wolf, BONUS_CRITICAL_DAMAGE, GetWolfCriticalDamage(level))
            call BlzSetUnitBaseDamage(wolf, GetWolfDamage(unit, level), 0)
            call UnitApplyTimedLife(wolf, 'BTLF', GetDuration(unit, level))
            call GroupAddUnit(group, wolf)
            
            if size == 1 then
                call TimerStart(timer, 1, true, function thistype.onPeriod)
            endif
        endmethod
        
        method command takes unit target, real x, real y, string order returns nothing
            local integer i = 0
            
            if target == null then
                if shadow then
                    loop
                        exitwhen i == size
                            call IssuePointOrder(BlzGroupUnitAt(group, i), order, x + 200*Cos(i*2*bj_PI/size), y + 200*Sin(i*2*bj_PI/size))
                        set i = i + 1
                    endloop
                else
                    call GroupPointOrder(group, order, x, y)
                endif
            else
                if target == unit then
                    loop
                        exitwhen i == size
                            call IssuePointOrder(BlzGroupUnitAt(group, i), order, x + 200*Cos(i*2*bj_PI/size), y + 200*Sin(i*2*bj_PI/size))
                        set i = i + 1
                    endloop
                else
                    call GroupTargetOrder(group, order, target)
                endif
            endif
        endmethod
        
        private static method onDeath takes nothing returns nothing
            local unit target = GetTriggerUnit()
            local integer id
            local thistype this
            
            if GetUnitTypeId(target) == WOLF then
                set id = GetUnitUserData(target)
                
                if struct[id] != 0 then
                    set this = struct[id]
                    
                    call GroupRemoveUnit(group, target)
                    if size == 0 then
                        set shadow = true
                        call PauseTimer(timer)
                    endif
                endif
            endif
            
            set target = null
        endmethod
        
        static method create takes unit owner returns thistype
            local thistype this = thistype.allocate()
            
            set unit = owner
            set shadow = true
            set group = CreateGroup()
            set timer = NewTimerEx(this)
            set player = GetOwningPlayer(owner)
            
            return this
        endmethod
        
        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
        endmethod
    endstruct
    
    private struct Master
        static trigger trigger = CreateTrigger()
        static boolean array holding
        static boolean array registered
        static thistype array struct
    
        Wolf pack
    
        method destroy takes nothing returns nothing
            call pack.destroy()
            call deallocate()
        endmethod
    
        private static method instance takes unit source returns thistype
            local integer id = GetUnitUserData(source)
            local thistype this
            
            if struct[id] != 0 then
                set this = struct[id]
            else
                set this = thistype.create(source)
                set struct[id] = this
            endif
            
            return this
        endmethod
    
        private static method onKey takes nothing returns nothing
            if BlzGetTriggerPlayerIsKeyDown() then
                set holding[GetPlayerId(GetTriggerPlayer())] = true
            else
                set holding[GetPlayerId(GetTriggerPlayer())] = false
            endif
        endmethod
        
        private static method register takes player p returns nothing
            local integer id = GetPlayerId(p)
            
            if not registered[id] then
                set registered[id] = true
                call BlzTriggerRegisterPlayerKeyEvent(trigger, p, OSKEY_TAB, 0, true)
                call BlzTriggerRegisterPlayerKeyEvent(trigger, p, OSKEY_TAB, 0, false)
            endif
        endmethod
        
        private static method onLearn takes nothing returns nothing
            call register(GetOwningPlayer(GetTriggerUnit()))
        endmethod
        
        private static method onOrder takes nothing returns nothing
            local unit source = GetOrderedUnit()
            local unit target = GetOrderTargetUnit()
            local string order = OrderId2String(GetIssuedOrderId())
            local player owner
            local thistype this
            
            if GetUnitAbilityLevel(source, ABILITY) > 0 then
                set this = instance(source)
                set owner = GetOwningPlayer(source)
                
                call register(owner)
                
                if pack.size > 0 then
                    if order == "attackground" then
                        if not (source == target) then
                            set pack.shadow = false
                            
                            if holding[GetPlayerId(owner)] then
                                call pack.command(target, GetOrderPointX(), GetOrderPointY(), "attack")
                            else
                                call pack.command(target, GetOrderPointX(), GetOrderPointY(), "smart")
                            endif
                        else
                            set pack.shadow = true
                            call pack.command(target, GetUnitX(source), GetUnitY(source), "smart")
                        endif
                    elseif pack.shadow then
                        if order == "smart" or order == "move" or order == "attack" then
                            if target == null then
                                call pack.command(target, GetOrderPointX(), GetOrderPointY(), "smart")
                            else
                                call GroupTargetOrder(pack.group, order, target)
                            endif
                        elseif order == "stop" or order == "holdposition" then
                            call GroupImmediateOrder(pack.group, order)
                        endif
                    endif
                endif
            endif
            
            set owner = null
            set source = null
            set target = null
        endmethod
        
        private static method onDeath takes nothing returns nothing
            local unit source = GetKillingUnit()
            local integer level = GetUnitAbilityLevel(source, ABILITY)
            local thistype this
            
            if level > 0 then
                set this = instance(source)
                
                if pack.size < GetMaxWolfCount(level) then
                    call pack.add(GetTriggerUnit())
                endif
            endif
            
            set source = null
        endmethod
        
        static method create takes unit source returns thistype
            local thistype this = thistype.allocate()
            
            set pack = Wolf.create(source)
            
            return this
        endmethod
    
        private static method onInit takes nothing returns nothing
            call TriggerAddCondition(trigger, Condition(function thistype.onKey))
            call RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_SKILL, function thistype.onLearn)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function thistype.onDeath)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, function thistype.onOrder)
        endmethod
    endstruct
    
    private struct Unselect
        timer timer
        unit unit
    
        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            call IssueImmediateOrder(unit, "stop")
            call ReleaseTimer(timer)
            
            set timer = null
            set unit = null
        endmethod
        
        private static method onOrder takes nothing returns nothing
            local unit source = GetOrderedUnit()
            local player owner = GetOwningPlayer(source)
            local string order = OrderId2String(GetIssuedOrderId())
            local thistype this
            
            if order == "smart" and IsUnitSelected(source, owner) and GetUnitTypeId(source) == WOLF then
                set this = thistype.allocate()
                
                set timer = NewTimerEx(this)
                set unit = source
                
                call TimerStart(timer, 0, false, function thistype.onExpire)
            endif
            
            set source = null
            set owner = null
        endmethod
        
        private static method onSelect takes nothing returns nothing
            local unit source = GetTriggerUnit()
            
            if GetUnitTypeId(source) == WOLF then
                call SelectUnit(source, false)
            endif
            
            set source = null
        endmethod
    
        private static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, function thistype.onOrder)
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_SELECTED, function thistype.onSelect)
        endmethod
    endstruct
endlibrary