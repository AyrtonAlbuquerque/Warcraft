library MovementModifier initializer Init //ver 1.07 by ZibiTheWand3r3r, 18-08-2018

    // Allows to change unit's movement speed for given duration (or permanent)
    // All Object Editor abilities [that changing move speed] will work with this system - they stack.
    // System's bonuses also stack.
    
    // ********************************
    // ==> Requires Unit Event
    // https://www.hiveworkshop.com/threads/gui-unit-event-v2-5-2-0.201641/
    // ********************************
    
    // ==> Applying move speed bonus:
    // UnitAddMoveSpeedBonus(unit u, real percentBonus, real flatBonus, real duration)
    // u                        - unit whos move speed will be changed
    // percentBonus             - positive to increase speed, negative to slow a target (use 0.00 to not apply percent bonus)
    //                           bonus will be added as percent (like Endurance Aura for example)
    // flatBonus                - positive to increase speed, negative to slow a target (use 0.00 to not apply flat bonus)
    //                           bonus will be added like item's Boots of Speed for example
    // duration                 - how long bonus will be on unit, [use duration = 0.00 to make bonus permanent]
    // both percentBonus and flatBonus can be used in one function call -- or use one chosen bonus only
    
    // ==> Removing timed movespeed bonuses:
    // UnitRemoveMoveSpeedBonuses(unit u, boolean removePositiveBonuses, boolean removeNegativeBonuses)
    // u                        - unit whos timed bonuses will be removed
    // removePositiveBonuses    - if "true" _all_ positive timed bonuses (bonus>0.00) will be removed
    // removeNegativeBonuses    - if "true" _all_ negative timed bonuses (bonus<0.00) will be removed
    
    // ==> Usage examples:
    // Speed up unit u: +45% move speed for 12sec:              call UnitAddMoveSpeedBonus(u, 0.45, 0.00, 12.00)
    // Speed up unit u: +120 flat move speed for ever:          call UnitAddMoveSpeedBonus(u, 0.00, 120, 0.00)
    // Slow unit u: -15%(percent) and -20(flat) for 7sec:       call UnitAddMoveSpeedBonus(u, -0.15, -20.00, 7.00)
    // Remove *all negative* move speed bonuses:                call UnitRemoveMoveSpeedBonuses(u, false, true)
    // Remove *all positive* move speed bonuses:                call UnitRemoveMoveSpeedBonuses(u, true, false)
    // Remove _all_ (negative and positive) move speed bonuses: call UnitRemoveMoveSpeedBonuses(u, true, true)
    
    // how bonuses are calculated:
    // moveSpeed = (GetUnitDefaultMoveSpeed(u) + flatBonus) * (1 + percentageBonus1 + percentageBonus2 + etc)
    
    globals
        // configuration:
        private constant real       INTERVAL = 0.50 //How precise is timed applied movespeed change, for greater accuracy use lower value like 0.20 or 0.10
        private constant boolean    PERSISTS_THROUGH_DEATH = true // if "true" then unit/hero's death will not end up applied bonus
        // Set to "false" to end bonus-instance upon unit's death. Above boolean will affect only timed bonuses.
        // end of configuration ----------------------------------------------------------------------------
        private real array          totalFlat               // total flat bonus [targetId] => binded to target unit
        private real array          totalPercent            //  total percent bonus [targetId]
     
        private boolean array       instanceIsBonusPositive // [id] => connected to spell instance
        private real array          instanceBonus           // bonus [id]
        private real array          instanceDuration        // duration [id]
        private unit array          instanceTarget          // target [id]
        private boolean array       instanceIsBonusFlat     // [id]
        private integer             instanceId = 0
        private timer               t = CreateTimer()
    endglobals
    //--------------------------------------------------------------------
    //native UnitAlive takes unit id returns boolean
    //--------------------------------------------------------------------
    private function Loop takes nothing returns nothing
        local integer id=1
        local integer targetId
        loop
            exitwhen id>instanceId      
            set instanceDuration[id] = instanceDuration[id] - INTERVAL //when spell expires:
            if instanceDuration[id] <= 0.00 or ((not PERSISTS_THROUGH_DEATH) and (not UnitAlive(instanceTarget[id]))) then
                //revert:
                set targetId = GetUnitUserData(instanceTarget[id])
                if instanceIsBonusFlat[id] then
                    set totalFlat[targetId] = totalFlat[targetId] - instanceBonus[id] //minus specific flat bonus
                else
                    set totalPercent[targetId] = totalPercent[targetId] - instanceBonus[id] //minus specific % bonus
                endif
                call SetUnitMoveSpeed(instanceTarget[id], (GetUnitDefaultMoveSpeed(instanceTarget[id]) + totalFlat[targetId])*(1+totalPercent[targetId]))
    
                //dealloc: /move data from max to current/
                set instanceIsBonusPositive[id] = instanceIsBonusPositive[instanceId]
                set instanceBonus[id] = instanceBonus[instanceId]
                set instanceDuration[id] = instanceDuration[instanceId]
                set instanceTarget[id] = instanceTarget[instanceId]
                set instanceIsBonusFlat[id]  = instanceIsBonusFlat[instanceId]
                set instanceTarget[instanceId] = null
             
                set instanceId=instanceId-1
                set id=id-1
                if instanceId==0 then
                    call PauseTimer(t)
                endif
            endif
     
            set id=id+1
        endloop
    endfunction
    //--------------------------------------------------------------------
    private function UnitAddMoveSpeedBonus_Ex takes unit u, real bonus, boolean isFlatBonus, real duration returns nothing
        local integer targetId = GetUnitUserData(u)
        //common part:
        if isFlatBonus then
            set totalFlat[targetId] = totalFlat[targetId] + bonus //add flat bonus
        else
            set totalPercent[targetId] = totalPercent[targetId] + bonus //add % bonus      
        endif
        call SetUnitMoveSpeed(u, (GetUnitDefaultMoveSpeed(u) + totalFlat[targetId])*(1+totalPercent[targetId]))
        //permanent:
        if duration==0.00 then
            return
        endif
        //timed:
        set instanceId = instanceId + 1
        set instanceTarget[instanceId] = u
        set instanceDuration[instanceId] = duration
        set instanceIsBonusFlat[instanceId] = isFlatBonus
        set instanceIsBonusPositive[instanceId] = bonus>0.00
        set instanceBonus[instanceId] = bonus
        if instanceId==1 then
            call TimerStart(t, INTERVAL, true, function Loop)
        endif
    endfunction
    //--------------------------------------------------------------------
    //--------------------------------------------------------------------
    function UnitAddMoveSpeedBonus takes unit u, real percentBonus, real flatBonus, real duration returns nothing
        if not (u==null or (not UnitAlive(u)) or duration<0.00 or (percentBonus==0.00 and flatBonus==0.00)) then //<=protection
            if percentBonus != 0.00 then
                call UnitAddMoveSpeedBonus_Ex(u, percentBonus, false, duration)
            endif
            if flatBonus != 0.00 then
                call UnitAddMoveSpeedBonus_Ex(u, flatBonus, true, duration)
            endif
        endif
    endfunction
    //-----------------------------------------------------------------------------------
    // ==> Removing timed movespeed bonuses
    function UnitRemoveMoveSpeedBonuses takes unit u, boolean removePositiveBonuses, boolean removeNegativeBonuses returns nothing
        local integer id=1
        loop
            exitwhen id>instanceId
            if u == instanceTarget[id] then
                if removePositiveBonuses and instanceIsBonusPositive[id] then
                    set instanceDuration[id] = 0.00
                endif
                if removeNegativeBonuses and (not instanceIsBonusPositive[id]) then
                    set instanceDuration[id] = 0.00
                endif
            endif
            set id=id+1
        endloop
        call Loop()
    endfunction
    //-----------------------------------------------------------------------------------
    // Units that changing their form (metamorphosis, chamical rage, destroyer form, bear form etc) 
    // will lose their move speed bonuses comes from SetUnitMoveSpeed. 
    // To prevent that: after unit transforms to new unit-type this function must be called:
    function Trig_UnitUpdateMoveSpeedBonusAfterMorph takes nothing returns boolean
        local integer targetId = GetUnitUserData(udg_UDexUnits[udg_UDex])
        call SetUnitMoveSpeed(udg_UDexUnits[udg_UDex], (GetUnitDefaultMoveSpeed(udg_UDexUnits[udg_UDex]) + totalFlat[targetId])*(1+totalPercent[targetId]))
        return false
    endfunction
    
    private function Init takes nothing returns nothing
        local trigger t=CreateTrigger()
        call TriggerRegisterVariableEvent(t, "udg_UnitTypeEvent", EQUAL, 1.00)
        call TriggerAddCondition(t, function Trig_UnitUpdateMoveSpeedBonusAfterMorph)
        set t=null
    endfunction
    endlibrary