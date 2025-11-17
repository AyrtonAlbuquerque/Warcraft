library Utilities requires TimerUtils, Indexer, Dummy, TimedHandles, RegisterPlayerUnitEvent
    /* --------------------------------------- Utilities v2.1 --------------------------------------- */
    // How to Import:
    // 1 - Copy this library into your map
    // 2 - Copy the dummy unit in object editor and match its raw code below
    // 3 - Copy the TimerUtils library into your map and follow its install instructions
    // 4 - Copy the Indexer library over to your map and follow its install instructions
    // 5 - Copy the TimedHandles library over to your map and follow its install instructions
    // 6 - Copy the RegisterPlayerUnitEvent library over to your map and follow its install instructions
    /* ---------------------------------------- By Chopinski ---------------------------------------- */
    
    /* ---------------------------------------------------------------------------------------------- */
    /*                                          Configuration                                         */
    /* ---------------------------------------------------------------------------------------------- */
    globals
        // Update period
        private constant real PERIOD = 0.03125
        // location z
        private location locationZ    = Location(0, 0)
        // One hashtable to rule them all
        private hashtable table      = InitHashtable()
        // Closest Unit
        private unit bj_closestUnitGroup
    endglobals

    /* ---------------------------------------------------------------------------------------------- */
    /*                                            JASS API                                            */
    /* ---------------------------------------------------------------------------------------------- */
    // Only one declaration per map required
    native UnitAlive takes unit id returns boolean

    // Returns the terrain Z value (Desync safe)
    function GetLocZ takes real x, real y returns real
        call MoveLocation(locationZ, x, y)
        return GetLocationZ(locationZ)
    endfunction
    
    // Similar to GetUnitX and GetUnitY but for Z axis
    function GetUnitZ takes unit u returns real
        return GetLocZ(GetUnitX(u), GetUnitY(u)) + GetUnitFlyHeight(u)
    endfunction
    
    // Similar to SetUnitX and SetUnitY but for Z axis
    function SetUnitZ takes unit u, real z returns nothing
        call SetUnitFlyHeight(u, z - GetLocZ(GetUnitX(u), GetUnitY(u)), 0)
    endfunction

    // Anlge between 2D points
    function AngleBetweenCoordinates takes real x, real y, real x2, real y2 returns real
        return Atan2(y2 - y, x2 - x)
    endfunction

    // Similar to AddSpecialEffect but scales the effect and considers z and return it
    function AddSpecialEffectEx takes string model, real x, real y, real z, real scale returns effect
        set bj_lastCreatedEffect = AddSpecialEffect(model, x, y)

        if z != 0 then
            call BlzSetSpecialEffectZ(bj_lastCreatedEffect, z + GetLocZ(x, y))
        endif
        call BlzSetSpecialEffectScale(bj_lastCreatedEffect, scale)
        
        return bj_lastCreatedEffect
    endfunction

    // Returns a group of enemy units of the specified player within the specified AOE of x and y
    function GetEnemyUnitsInRange takes player enemyOf, real x, real y, real aoe, boolean structures, boolean magicImmune returns group
        local group g = CreateGroup()
        local group h = CreateGroup()
        local unit  w
        
        call GroupEnumUnitsInRange(h, x, y, aoe, null)
        loop
            set w = FirstOfGroup(h)
            exitwhen w == null
                if IsUnitEnemy(w, enemyOf) and UnitAlive(w) and (structures or (not IsUnitType(w, UNIT_TYPE_STRUCTURE))) and (magicImmune or (not IsUnitType(w, UNIT_TYPE_MAGIC_IMMUNE))) then
                    call GroupAddUnit(g, w)
                endif
            call GroupRemoveUnit(h, w)
        endloop
        call DestroyGroup(h)
    
        set h = null
        return g
    endfunction

    // Returns the closest unit in a unit group with center at x and y
    function GetClosestUnitGroup takes real x, real y, group g returns unit
        local unit    u
        local real    dx
        local real    dy
        local real    md = 100000
        local integer i  = 0
        local integer size = BlzGroupGetSize(g)
        
        set bj_closestUnitGroup = null
        loop
            exitwhen i == size
                set u = BlzGroupUnitAt(g, i)
                if UnitAlive(u) then
                    set dx = GetUnitX(u) - x
                    set dy = GetUnitY(u) - y
                    
                    if (dx*dx + dy*dy)/100000 < md then
                        set bj_closestUnitGroup = u
                        set md = (dx*dx + dy*dy)/100000
                    endif
                endif
            set i = i + 1
        endloop
        
        return bj_closestUnitGroup
    endfunction
    
    // Removes a destructable after a period of time
    function RemoveDestructableTimed takes destructable dest, real timeout returns nothing
        call TimedDestructable.create(dest, timeout)
    endfunction

    // Link an effect to a unit buff or ability
    function LinkEffectToBuff takes unit target, integer buffId, string model, string attach returns nothing
        call EffectLink.BuffLink(target, buffId, model, attach)
    endfunction

    // Link an effect to an unit item.
    function LinkEffectToItem takes unit target, item i, string model, string attach returns nothing
        call EffectLink.ItemLink(target, i, model, attach)
    endfunction

    // Pretty obvious.
    function R2I2S takes real r returns string
        return I2S(R2I(r))
    endfunction

    // Workaround for patch 2.0 R2S bug
    function N2S takes real value, integer precision returns string
        local integer digit
        local string result
        local string sign = ""
    
        if value < 0 then
            set sign = "-"
            set value = RAbsBJ(value)
        endif
    
        set result = sign + I2S(R2I(value))
    
        if precision <= 0 then
            return result
        endif
    
        set result = result + "."
        set value = value - R2I(value) 

        loop
            exitwhen precision <= 0
                set value = value * 10
                set digit = R2I(value)
                set result = result + I2S(digit)
                set value = value - digit
            set precision = precision - 1
        endloop
    
        return result
    endfunction

    // Ascii to String
    function A2S takes integer id returns string
        local string chars = " !\"#$%&'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\\]^_`abcdefghijklmnopqrstuvwxyz{|}~"
        local string s = ""
        local integer min = ' '
        local integer i

        if id >= min then
            loop
                exitwhen id == 0
                    set i = ModuloInteger(id, 256) - min
                    set s = SubString(chars, i, i + 1) + s
                set id = id / 256
            endloop
        endif

        return s
    endfunction

    // Spams the specified effect model at a location with the given interval for the number of times count
    function SpamEffect takes string model, real x, real y, real z, real scale, real interval, integer count returns nothing
        call EffectSpam.spam(null, model, "", x, y, z, scale, interval, count)
    endfunction

    // Spams the specified effect model attached to a unit for the given interval for the number of times count
    function SpamEffectUnit takes unit target, string model, string attach, real interval, integer count returns nothing
        call EffectSpam.spam(target, model, attach, 0, 0, 0, 0, interval, count)
    endfunction   

    // Add the specified ability to the specified unit for the given duration. Use hide to show or not the ability button.
    function UnitAddAbilityTimed takes unit whichUnit, integer abilityId, real duration, integer level, boolean hide returns nothing
        call TimedAbility.add(whichUnit, abilityId, duration, level, hide)
    endfunction

    // Resets the specified unit ability cooldown
    function ResetUnitAbilityCooldown takes unit whichUnit, integer abilCode returns nothing
        call ResetCooldown.reset(whichUnit, abilCode)
    endfunction 

    // Returns the distance between 2 coordinates in Warcraft III units
    function DistanceBetweenCoordinates takes real x1, real y1, real x2, real y2 returns real
        local real dx = (x2 - x1)
        local real dy = (y2 - y1)
    
        return SquareRoot(dx*dx + dy*dy)
    endfunction

    // Makes the specified source damage an area respecting some basic unit filters
    function UnitDamageArea takes unit source, real x, real y, real aoe, real damage, attacktype atkType, damagetype dmgType, boolean structures, boolean magicImmune, boolean allies returns nothing
        local group h = CreateGroup()
        local player enemyOf = GetOwningPlayer(source)
        local unit w
        
        call GroupEnumUnitsInRange(h, x, y, aoe, null)
        call GroupRemoveUnit(h, source)
        loop
            set w = FirstOfGroup(h)
            exitwhen w == null
                if UnitAlive(w) and (allies or IsUnitEnemy(w, enemyOf)) and (structures or (not IsUnitType(w, UNIT_TYPE_STRUCTURE))) and (magicImmune or (not IsUnitType(w, UNIT_TYPE_MAGIC_IMMUNE))) then
                    call UnitDamageTarget(source, w, damage, true, false, atkType, dmgType, null)
                endif
            call GroupRemoveUnit(h, w)
        endloop
        call DestroyGroup(h)
    
        set h = null
        set enemyOf = null
    endfunction

    // Makes the specified source damage a group. Creates a special effect if specified
    function UnitDamageGroup takes unit u, group g, real damage, attacktype atk_type, damagetype dmg_type, string sfx, string atch_point, boolean destroy returns group
        local unit    v
        local integer i = 0
        local integer t = BlzGroupGetSize(g)

        loop
            exitwhen i == t
                set v = BlzGroupUnitAt(g, i)
                call UnitDamageTarget(u, v, damage, true, false, atk_type, dmg_type, null)

                if sfx != "" and atch_point != "" then
                    call DestroyEffect(AddSpecialEffectTarget(sfx, v, atch_point))
                endif
            set i = i + 1
        endloop

        if destroy then
            call DestroyGroup(g)
        endif

        return g
    endfunction

    // Returns a random range given a max value
    function GetRandomRange takes real radius returns real
        local real r = GetRandomReal(0, 1) + GetRandomReal(0, 1)

        if r > 1 then
            return (2 - r)*radius
        endif

        return r*radius
    endfunction

    // Returns a random value in the x/y coordinates depending on the value of boolean x
    function GetRandomCoordInRange takes real center, real radius, boolean x returns real
        local real theta = 2*bj_PI*GetRandomReal(0, 1)
        local real r

        if x then
            set r = center + radius*Cos(theta)
        else
            set r = center + radius*Sin(theta)
        endif

        return r
    endfunction

    // Clones the items in the source unit inventory to the target unit
    function CloneItems takes unit source, unit target, boolean isIllusion returns nothing
        local integer i = 0
        local integer j
        local item k
        
        loop
            exitwhen i > bj_MAX_INVENTORY
                set k = UnitItemInSlot(source, i)
                set j = GetItemCharges(k)
                set k = CreateItem(GetItemTypeId(k), GetUnitX(target), GetUnitY(target))
                call SetItemCharges(k, j)
                call UnitAddItem(target, k)

                if isIllusion then
                    if GetItemTypeId(k) == 'ankh' then
                        call BlzItemRemoveAbility(k, 'AIrc')
                    endif

                    call BlzSetItemBooleanField(k, ITEM_BF_ACTIVELY_USED, false)
                endif
            set i = i + 1
        endloop
        
        set k = null
    endfunction

    // Add the mount for he unit mana pool
    function AddUnitMana takes unit whichUnit, real amount returns nothing
        call SetUnitState(whichUnit, UNIT_STATE_MANA, (GetUnitState(whichUnit, UNIT_STATE_MANA) + amount))
    endfunction

    // Add the specified amounts to a hero str/agi/int base amount
    function UnitAddStat takes unit whichUnit, integer strength, integer agility, integer intelligence returns nothing
        if strength != 0 then
            call SetHeroStr(whichUnit, GetHeroStr(whichUnit, false) + strength, true)
        endif
    
        if agility != 0 then
            call SetHeroAgi(whichUnit, GetHeroAgi(whichUnit, false) + agility, true)
        endif
    
        if intelligence != 0 then
            call SetHeroInt(whichUnit, GetHeroInt(whichUnit, false) + intelligence, true)
        endif
    endfunction

    // Returns the closest unit from the x and y coordinates in the map
    function GetClosestUnit takes real x, real y, boolexpr e returns unit
        local real  md = 100000
        local group g = CreateGroup()
        local unit  u
        local real  dx
        local real  dy

        set bj_closestUnitGroup = null
        
        call GroupEnumUnitsInRect(g, bj_mapInitialPlayableArea, e)
        loop
            set u = FirstOfGroup(g)
            exitwhen u == null
                if UnitAlive(u) then
                    set dx = GetUnitX(u) - x
                    set dy = GetUnitY(u) - y
                    
                    if (dx*dx + dy*dy)/100000 < md then
                        set bj_closestUnitGroup = u
                        set md = (dx*dx + dy*dy)/100000
                    endif
                endif
            call GroupRemoveUnit(g, u)
        endloop
        call DestroyGroup(g)
        call DestroyBoolExpr(e)
        set g = null

        return bj_closestUnitGroup
    endfunction
    
    // Creates a chain lightning with the specified ligihtning effect with the amount of bounces
    function CreateChainLightning takes unit source, unit target, real damage, real aoe, real duration, real interval, integer bounceCount, attacktype attackType, damagetype damageType, string lightningType, string sfx, string attachPoint, boolean canRebounce returns nothing
        call ChainLightning.create(source, target, damage, aoe, duration, interval, bounceCount, attackType, damageType, lightningType, sfx, attachPoint, canRebounce)
    endfunction

    // Add the specified amount to the specified player gold amount
    function AddPlayerGold takes player whichPlayer, integer amount returns nothing
        call SetPlayerState(whichPlayer, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(whichPlayer, PLAYER_STATE_RESOURCE_GOLD) + amount)
    endfunction

    // Creates a text tag in an unit position for a duration
    function CreateTextOnUnit takes unit whichUnit, string text, real duration, integer red, integer green, integer blue, integer alpha returns nothing
        local texttag tx = CreateTextTag()
        
        call SetTextTagText(tx, text, 0.015)
        call SetTextTagPosUnit(tx, whichUnit, 0)
        call SetTextTagColor(tx, red, green, blue, alpha)
        call SetTextTagLifespan(tx, duration)
        call SetTextTagVelocity(tx, 0.0, 0.0355)
        call SetTextTagPermanent(tx, false)
        
        set tx = null
    endfunction

    // Add health regeneration to the unit base value
    function UnitAddHealthRegen takes unit whichUnit, real regen returns nothing
        call BlzSetUnitRealField(whichUnit, UNIT_RF_HIT_POINTS_REGENERATION_RATE, BlzGetUnitRealField(whichUnit, UNIT_RF_HIT_POINTS_REGENERATION_RATE) + regen)
    endfunction

    // Casts an ability in the target unit. Must have no casting time
    function CastAbilityTarget takes unit target, integer id, string order, integer level returns nothing
        local unit dummy = DummyRetrieve(GetOwningPlayer(target), 0, 0, 0, 0)
        
        call UnitAddAbility(dummy, id)
        call SetUnitAbilityLevel(dummy, id, level)
        call IssueTargetOrder(dummy, order, target)
        call UnitRemoveAbility(dummy, id)
        call DummyRecycle(dummy)

        set dummy = null
    endfunction

    // Returns a random unit within a group
    function GroupPickRandomUnitEx takes group g returns unit
        if BlzGroupGetSize(g) > 0 then
            return BlzGroupUnitAt(g, GetRandomInt(0, BlzGroupGetSize(g) - 1))
        else
            return null
        endif
    endfunction

    // Returns true if a unit is within a cone given a facing and fov angle in degrees (Less precise)
    function IsUnitInConeEx takes unit u, real x, real y, real face, real fov returns boolean
        return Acos(Cos((Atan2(GetUnitY(u) - y, GetUnitX(u) - x)) - face*bj_DEGTORAD)) < fov*bj_DEGTORAD/2
    endfunction

    // Returns true if a unit is within a cone given a facing, fov angle and a range in degrees (takes collision into consideration). Credits to AGD.
    function IsUnitInCone takes unit u, real x, real y, real range, real face, real fov returns boolean
        if IsUnitInRangeXY(u, x, y, range) then
            set x = GetUnitX(u) - x
            set y = GetUnitY(u) - y
            set range = x*x + y*y
    
            if range > 0. then
                set face = face*bj_DEGTORAD - Atan2(y, x)
                set fov = fov*bj_DEGTORAD/2 + Asin(BlzGetUnitCollisionSize(u)/SquareRoot(range))
    
                return RAbsBJ(face) <= fov or RAbsBJ(face - 2.00*bj_PI) <= fov
            endif
    
            return true
        endif
    
        return false
    endfunction

    // Makes the source unit damage enemy unit in a cone given a direction, foy and range
    function UnitDamageCone takes unit source, real x, real y, real face, real fov, real aoe, real damage, attacktype atkType, damagetype dmgType, boolean structures, boolean magicImmune, boolean allies returns nothing
        local group h = CreateGroup()
        local player enemyOf = GetOwningPlayer(source)
        local unit w
        
        call GroupEnumUnitsInRange(h, x, y, aoe, null)
        call GroupRemoveUnit(h, source)
        loop
            set w = FirstOfGroup(h)
            exitwhen w == null
                if (UnitAlive(w) and IsUnitInCone(w, x, y, aoe, face, fov)) then
                    if (allies or IsUnitEnemy(w, enemyOf)) and (structures or (not IsUnitType(w, UNIT_TYPE_STRUCTURE))) and (magicImmune or (not IsUnitType(w, UNIT_TYPE_MAGIC_IMMUNE))) then
                        call UnitDamageTarget(source, w, damage, true, false, atkType, dmgType, null)
                    endif
                endif
            call GroupRemoveUnit(h, w)
        endloop
        call DestroyGroup(h)
    
        set h = null
        set enemyOf = null
    endfunction

    // Heals all allied units of specified player in an area
    function HealArea takes player alliesOf, real x, real y, real aoe, real amount, string fxpath, string attchPoint returns nothing
        local group g = CreateGroup()
        local unit v
        
        call GroupEnumUnitsInRange(g, x, y, aoe, null)
        loop
            set v = FirstOfGroup(g)
            exitwhen v == null
                if IsUnitAlly(v, alliesOf) and UnitAlive(v) and not IsUnitType(v, UNIT_TYPE_STRUCTURE) then
                    call SetWidgetLife(v, GetWidgetLife(v) + amount)
                    if fxpath != "" then
                        if attchPoint != "" then
                            call DestroyEffect(AddSpecialEffectTarget(fxpath, v, attchPoint))
                        else
                            call DestroyEffect(AddSpecialEffect(fxpath, GetUnitX(v), GetUnitY(v)))
                        endif
                    endif
                endif
            call GroupRemoveUnit(g, v)
        endloop
        call DestroyGroup(g)
    
        set g = null
    endfunction

    // Returns an ability real level field as a string. Usefull for toolltip manipulation.
    function AbilityRealField takes unit u, integer abilityId, abilityreallevelfield field, integer level, integer multiplier, boolean asInteger returns string
        if asInteger then
            return R2I2S(BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, abilityId), field, level)*multiplier)
        else
            return R2SW(BlzGetAbilityRealLevelField(BlzGetUnitAbility(u, abilityId), field, level)*multiplier,1,1)
        endif
    endfunction

    // Fix for camera pan desync. credits do Daffa
    function SmartCameraPanBJModified takes player whichPlayer, location loc, real duration returns nothing 
        local real tx = GetLocationX(loc)
        local real ty = GetLocationY(loc)
        local real dx = tx - GetCameraTargetPositionX()
        local real dy = ty - GetCameraTargetPositionY()
        local real dist = SquareRoot(dx * dx + dy * dy)

        if (GetLocalPlayer() == whichPlayer) then
            if (dist >= bj_SMARTPAN_TRESHOLD_SNAP) then
                call PanCameraToTimed(tx, ty, duration)
                // Far away = snap camera immediately to point
            elseif (dist >= bj_SMARTPAN_TRESHOLD_PAN) then
                call PanCameraToTimed(tx, ty, duration)
                // Moderately close = pan camera over duration
            else
                // User is close, don't move camera
            endif
        endif
    endfunction
    
    // Fix for camera pan desync. credits do Daffa
    function SmartCameraPanBJModifiedXY takes player whichPlayer, real x, real y, real duration returns nothing 
        local real dx = x - GetCameraTargetPositionX()
        local real dy = y - GetCameraTargetPositionY()
        local real dist = SquareRoot(dx * dx + dy * dy)

        if (GetLocalPlayer() == whichPlayer) then
            if (dist >= bj_SMARTPAN_TRESHOLD_SNAP) then
                call PanCameraToTimed(x, y, duration)
                // Far away = snap camera immediately to point
            elseif (dist >= bj_SMARTPAN_TRESHOLD_PAN) then
                call PanCameraToTimed(x, y, duration)
                // Moderately close = pan camera over duration
            else
                // User is close, don't move camera
            endif
        endif
    endfunction

    // Start the cooldown for the source unit unit the new value
    function StartUnitAbilityCooldown takes unit source, integer abilCode, real cooldown returns nothing
        call AbilityCooldown.start(source, abilCode, cooldown)
    endfunction
    
    // Pauses or Unpauses a unit after a delay. If flag = true than the unit will be paused and unpaused after the duration. If flag = false than the unit will be unpaused and paused after the duration.
    function PauseUnitTimed takes unit u, real duration, boolean flag returns nothing
        call TimedPause.create(u, duration, flag)
    endfunction

    // Replace Unit respecting Max Health and Mana values
    function ReplaceUnit takes unit whichUnit, integer newUnitId, integer unitStateMethod returns unit
        local unit oldUnit = whichUnit
        local unit newUnit
        local boolean wasHidden
        local integer index
        local item indexItem
        local real oldRatio

        if (oldUnit == null) then
            set bj_lastReplacedUnit = oldUnit
            return oldUnit
        endif

        set wasHidden = IsUnitHidden(oldUnit)
        call ShowUnit(oldUnit, false)

        if (newUnitId == 'ugol') then
            set newUnit = CreateBlightedGoldmine(GetOwningPlayer(oldUnit), GetUnitX(oldUnit), GetUnitY(oldUnit), GetUnitFacing(oldUnit))
        else
            set newUnit = CreateUnit(GetOwningPlayer(oldUnit), newUnitId, GetUnitX(oldUnit), GetUnitY(oldUnit), GetUnitFacing(oldUnit))
        endif

        if (unitStateMethod == bj_UNIT_STATE_METHOD_RELATIVE) then
            if (GetUnitState(oldUnit, UNIT_STATE_MAX_LIFE) > 0) then
                set oldRatio = GetUnitState(oldUnit, UNIT_STATE_LIFE) / GetUnitState(oldUnit, UNIT_STATE_MAX_LIFE)
                call SetUnitState(newUnit, UNIT_STATE_LIFE, oldRatio * GetUnitState(newUnit, UNIT_STATE_MAX_LIFE))
            endif

            if (GetUnitState(oldUnit, UNIT_STATE_MAX_MANA) > 0) and (GetUnitState(newUnit, UNIT_STATE_MAX_MANA) > 0) then
                set oldRatio = GetUnitState(oldUnit, UNIT_STATE_MANA) / GetUnitState(oldUnit, UNIT_STATE_MAX_MANA)
                call SetUnitState(newUnit, UNIT_STATE_MANA, oldRatio * GetUnitState(newUnit, UNIT_STATE_MAX_MANA))
            endif
        elseif (unitStateMethod == bj_UNIT_STATE_METHOD_ABSOLUTE) then
            call BlzSetUnitMaxHP(newUnit, BlzGetUnitMaxHP(oldUnit))
            call SetUnitState(newUnit, UNIT_STATE_LIFE, GetUnitState(oldUnit, UNIT_STATE_LIFE))

            if (GetUnitState(newUnit, UNIT_STATE_MAX_MANA) > 0) then
                call BlzSetUnitMaxMana(newUnit, BlzGetUnitMaxMana(oldUnit))
                call SetUnitState(newUnit, UNIT_STATE_MANA, GetUnitState(oldUnit, UNIT_STATE_MANA))
            endif
        elseif (unitStateMethod == bj_UNIT_STATE_METHOD_DEFAULTS) then
            // The newly created unit should already have default life and mana.
        elseif (unitStateMethod == bj_UNIT_STATE_METHOD_MAXIMUM) then
            call BlzSetUnitMaxHP(newUnit, BlzGetUnitMaxHP(oldUnit))
            call BlzSetUnitMaxMana(newUnit, BlzGetUnitMaxMana(oldUnit))
            call SetUnitState(newUnit, UNIT_STATE_LIFE, GetUnitState(newUnit, UNIT_STATE_MAX_LIFE))
            call SetUnitState(newUnit, UNIT_STATE_MANA, GetUnitState(newUnit, UNIT_STATE_MAX_MANA))
        else
            // Unrecognized unit state method - ignore the request.
        endif

        call SetResourceAmount(newUnit, GetResourceAmount(oldUnit))

        if (IsUnitType(oldUnit, UNIT_TYPE_HERO) and IsUnitType(newUnit, UNIT_TYPE_HERO)) then
            set index = 0

            call SetHeroXP(newUnit, GetHeroXP(oldUnit), false)

            loop
                set indexItem = UnitItemInSlot(oldUnit, index)

                if (indexItem != null) then
                    call UnitRemoveItem(oldUnit, indexItem)
                    call UnitAddItem(newUnit, indexItem)
                endif

                set index = index + 1
                exitwhen index >= bj_MAX_INVENTORY
            endloop
        endif

        if wasHidden then
            call KillUnit(oldUnit)
            call RemoveUnit(oldUnit)
        else
            call RemoveUnit(oldUnit)
        endif

        set bj_lastReplacedUnit = newUnit
        
        return newUnit
    endfunction

    // Creates a lightning effect between 2 units
    function CreateLightningUnit2Unit takes unit source, unit target, real duration, string lightningType returns TimedLightning
        return TimedLightning.unit2unit(source, target, duration, lightningType)
    endfunction

    // Creates a lightning effect between unit and point
    function CreateLightningUnit2Point takes unit source, real x, real y, real z, real duration, string lightningType returns TimedLightning
        return TimedLightning.unit2point(source, x, y, z, duration, lightningType)
    endfunction

    /* ---------------------------------------------------------------------------------------------- */
    /*                                             Systems                                            */
    /* ---------------------------------------------------------------------------------------------- */
    /* ----------------------------------- Reset Ability Cooldown ----------------------------------- */
    struct ResetCooldown
        timer timer
        unit unit
        integer ability

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call BlzEndUnitAbilityCooldown(unit, ability)
            call ReleaseTimer(timer)
            call deallocate()
            
            set unit = null
            set timer  = null
        endmethod

        static method reset takes unit u, integer id returns nothing
            local thistype this = thistype.allocate()

            set timer = NewTimerEx(this)
            set unit = u
            set ability = id

            call TimerStart(timer, 0.01, false, function thistype.onExpire)
        endmethod 
    endstruct

    /* ---------------------------------------- Timed Ability --------------------------------------- */
    struct TimedAbility
        static timer timer = CreateTimer()
        static integer key = -1
        static thistype array array

        unit unit
        integer ability
        real duration

        method remove takes integer i returns integer
            call UnitRemoveAbility(unit, ability)
            call RemoveSavedInteger(table, GetHandleId(unit), ability)

            set array[i] = array[key]
            set key = key - 1
            set unit = null

            if key == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        static method onPeriod takes nothing returns nothing
            local integer i = 0
            local thistype this

            loop
                exitwhen i > key
                    set this = array[i]

                    if duration <= 0 then
                        set i = remove(i)
                    endif
                    set duration = duration - 0.1
                set i = i + 1
            endloop
        endmethod


        static method add takes unit u, integer id, real duration, integer level, boolean hide returns nothing
            local thistype this = LoadInteger(table, GetHandleId(u), id)
            
            if this == 0 then
                set this = thistype.allocate()
                set unit = u
                set ability = id
                set key = key + 1
                set array[key] = this

                call SaveInteger(table, GetHandleId(unit), ability, this)

                if key == 0 then
                    call TimerStart(timer, 0.1, true, function thistype.onPeriod)
                endif
            endif

            if GetUnitAbilityLevel(unit, ability) != level then
                call UnitAddAbility(unit, ability)
                call SetUnitAbilityLevel(unit, ability, level)
                call UnitMakeAbilityPermanent(unit, true, ability)
                call BlzUnitHideAbility(unit, ability, hide)
            endif

            set .duration = duration
        endmethod
    endstruct

    /* ----------------------------------------- Effect Spam ---------------------------------------- */
    struct EffectSpam
        timer timer
        unit unit 
        integer i 
        string effect
        string point
        real scale
        real x
        real y
        real z

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            if i > 0 then
                if unit == null then
                    call DestroyEffect(AddSpecialEffectEx(effect, x, y, z, scale))
                else
                    call DestroyEffect(AddSpecialEffectTarget(effect, unit, point))
                endif
            else
                call ReleaseTimer(timer)
                call deallocate()
                set timer = null
                set unit = null
            endif
            set i = i - 1
        endmethod

        static method spam takes unit target, string model, string attach, real x, real y, real z, real scale, real interval, integer count returns nothing
            local thistype this = thistype.allocate()

            set timer = NewTimerEx(this)
            set unit = target
            set i = count
            set effect = model
            set .x = x
            set .y = y
            set .z = z
            set .scale = scale
            set point = attach

            call TimerStart(timer, interval, true, function thistype.onPeriod)
        endmethod
    endstruct

    /* --------------------------------------- Chain Lightning -------------------------------------- */
    struct ChainLightning
        timer timer
        unit unit
        unit prev
        unit self
        unit next
        group group
        group damaged
        player player
        real damage
        real range
        real duration
        integer bounces
        attacktype attacktype
        damagetype damagetype
        string lightning
        string effect
        string attach
        boolean rebounce

        private method destroy takes nothing returns nothing
            call DestroyGroup(group)
            call ReleaseTimer(timer)
            call DestroyGroup(damaged)

            set prev       = null
            set self       = null
            set next       = null 
            set unit       = null
            set group      = null
            set timer      = null
            set player     = null
            set damaged    = null
            set attacktype = null
            set damagetype = null

            call deallocate()
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
            
            call DestroyGroup(group)
            if bounces > 0 then
                set group = GetEnemyUnitsInRange(player, GetUnitX(self), GetUnitY(self), range, false, false)
                call GroupRemoveUnit(group, self)
                
                if not rebounce then
                    call BlzGroupRemoveGroupFast(damaged, group)
                endif
                
                if BlzGroupGetSize(group) == 0 then
                    call destroy()
                else
                    set next = GetClosestUnitGroup(GetUnitX(self), GetUnitY(self), group)
                    
                    if next == prev and BlzGroupGetSize(group) > 1 then
                        call GroupRemoveUnit(group, prev)
                        set next = GetClosestUnitGroup(GetUnitX(self), GetUnitY(self), group)
                    endif
                    
                    if next != null then
                        call DestroyLightningTimed(AddLightningEx(lightning, true, GetUnitX(self), GetUnitY(self), GetUnitZ(self) + 60.0, GetUnitX(next), GetUnitY(next), GetUnitZ(next) + 60.0), duration)
                        call DestroyEffect(AddSpecialEffectTarget(effect, next, attach))
                        call GroupAddUnit(damaged, next)
                        call UnitDamageTarget(unit, next, damage, false, false, attacktype, damagetype, null)
                        call DestroyGroup(group)
                        set prev = self
                        set self = next
                        set next = null
                    else
                        call destroy()
                    endif
                endif
            else
                call destroy()
            endif
            set bounces = bounces - 1
        endmethod

        static method create takes unit source, unit target, real dmg, real aoe, real dur, real interval, integer bounceCount, attacktype attackType, damagetype damageType, string lightningType, string sfx, string attachPoint, boolean canRebounce returns thistype
            local group    g
            local thistype this

            set g = GetEnemyUnitsInRange(GetOwningPlayer(source), GetUnitX(target), GetUnitY(target), aoe, false, false)

            if BlzGroupGetSize(g) == 1 then
                call DestroyLightningTimed(AddLightningEx(lightningType, true, GetUnitX(source), GetUnitY(source), BlzGetUnitZ(source) + 60.0, GetUnitX(target), GetUnitY(target), BlzGetUnitZ(target) + 60.0), dur)
                call DestroyEffect(AddSpecialEffectTarget(sfx, target, attachPoint))
                call UnitDamageTarget(source, target, dmg, false, false, attackType, damageType, null)
            else
                set this       = thistype.allocate()
                set timer      = NewTimerEx(this)
                set prev       = null
                set self       = target
                set next       = null
                set unit       = source
                set player     = GetOwningPlayer(source)
                set damage     = dmg
                set range      = aoe
                set duration   = dur
                set bounces    = bounceCount
                set attacktype = attackType
                set damagetype = damageType
                set lightning  = lightningType
                set effect     = sfx
                set attach     = attachPoint
                set rebounce   = canRebounce
                set damaged    = CreateGroup()

                call GroupRemoveUnit(g, target)
                call GroupAddUnit(damaged, target)
                call DestroyEffect(AddSpecialEffectTarget(sfx, target, attachPoint))
                call UnitDamageTarget(source, target, damage, false, false, attacktype, damagetype, null)
                call TimerStart(timer, interval, true, function thistype.onPeriod)
            endif
            call DestroyGroup(g)
            set g = null

            return this
        endmethod
    endstruct

    /* ----------------------------------------- Effect Link ---------------------------------------- */
    struct EffectLink
        static timer timer = CreateTimer()
        //Dynamic Indexing for buff and timed
        static integer didx = -1
        static thistype array data
        //Dynamic Indexing for items
        static integer ditem = -1
        static thistype array items

        unit    unit
        effect  effect
        item    item
        integer buff

        method remove takes integer i, boolean isItem returns integer
            call DestroyEffect(effect)

            if isItem then
                set  items[i] = items[ditem]
                set  ditem    = ditem - 1
            else
                set  data[i] = data[didx]
                set  didx    = didx - 1

                if didx == -1 then
                    call PauseTimer(timer)
                endif
            endif

            set unit   = null
            set item   = null
            set effect = null

            call deallocate()

            return i - 1
        endmethod

        static method onDrop takes nothing returns nothing
            local item     j = GetManipulatedItem()
            local integer  i = 0
            local thistype this

            loop
                exitwhen i > ditem
                    set this = items[i]

                    if item == j then
                        set i = remove(i, true)
                    endif
                set i = i + 1
            endloop

            set j = null
        endmethod

        static method onPeriod takes nothing returns nothing
            local integer i = 0
            local thistype this

            loop
                exitwhen i > didx
                    set this = data[i]

                    if GetUnitAbilityLevel(unit, buff) == 0 then
                        set i = remove(i, false)
                    endif
                set i = i + 1
            endloop
        endmethod

        static method BuffLink takes unit target, integer id, string model, string attach returns nothing
            local thistype this = thistype.allocate()

            set unit       = target
            set buff       = id
            set effect     = AddSpecialEffectTarget(model, target, attach)
            set didx       = didx + 1
            set data[didx] = this
            
            if didx == 0 then
                call TimerStart(timer, 0.03125000, true, function thistype.onPeriod)
            endif
        endmethod

        static method ItemLink takes unit target, item i, string model, string attach returns nothing
            local thistype this = thistype.allocate()

            set item         = i
            set effect       = AddSpecialEffectTarget(model, target, attach)
            set ditem        = ditem + 1
            set items[ditem] = this
        endmethod

        static method onInit takes nothing returns nothing
            call RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, function thistype.onDrop)
        endmethod
    endstruct

    /* ----------------------------------- Start Ability Cooldown ----------------------------------- */
    struct AbilityCooldown
        timer   timer
        unit    unit
        integer ability
        real    newCd

        private static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            call BlzStartUnitAbilityCooldown(unit, ability, newCd)
            call ReleaseTimer(timer)
            call deallocate()

            set timer = null
            set unit  = null
        endmethod

        static method start takes unit source, integer abilCode, real cooldown returns nothing
            local thistype this = thistype.allocate()

            set timer   = NewTimerEx(this)
            set unit    = source
            set ability = abilCode
            set newCd   = cooldown

            call TimerStart(timer, 0.01, false, function thistype.onExpire)
        endmethod
    endstruct

    /* ------------------------------------- Destructable Timed ------------------------------------- */
    struct TimedDestructable
        private static constant real    period = 0.03125000
        private static timer            timer  = CreateTimer()
        private static integer          id    = -1
        private static thistype array   array

        destructable destructable
        real duration

        private method remove takes integer i returns integer
            call RemoveDestructable(destructable)

            set destructable = null
            set array[i] = array[id]
            set id = id - 1

            if id == -1 then
                call PauseTimer(timer)
            endif

            call deallocate()

            return i - 1
        endmethod

        private static method onPeriod takes nothing returns nothing
            local integer  i = 0
            local thistype this

            loop
                exitwhen i > id
                    set this = array[i]

                    if duration <= 0 then
                        set i = remove(i)
                    endif
                    set duration = duration - period
                set i = i + 1
            endloop
        endmethod

        static method create takes destructable dest, real timeout returns thistype
            local thistype this = thistype.allocate()

            set destructable = dest
            set duration     = timeout
            set id           = id + 1
            set array[id]    = this

            if id == 0 then
                call TimerStart(timer, period, true, function thistype.onPeriod)
            endif

            return this
        endmethod
    endstruct

    /* ----------------------------------------- Timed Pause ---------------------------------------- */
    struct TimedPause
        static integer array array

        timer timer
        unit unit
        integer key
        boolean flag

        static method onExpire takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())

            set array[key] = array[key] - 1
            if array[key] == 0 then
                call BlzPauseUnitEx(unit, not flag)
            endif
            call ReleaseTimer(timer)
            call deallocate()
            
            set timer = null
            set unit = null
        endmethod


        static method create takes unit u, real duration, boolean pause returns thistype
            local thistype this = thistype.allocate()

            set timer = NewTimerEx(this)
            set unit = u
            set flag = pause
            set key = GetUnitUserData(u)
            
            if array[key] == 0 then
                call BlzPauseUnitEx(u, pause)
            endif
            set array[key] = array[key] + 1
            
            call TimerStart(timer, duration, false, function thistype.onExpire)
            
            return this
        endmethod
    endstruct

    /* ------------------------------------- TimedLightning ------------------------------------ */
    struct TimedLightning
        private real x
        private real y
        private real z
        private timer timer
        private unit source
        private unit target
        private real duration
        private boolean permanent
        private lightning lightning

        method destroy takes nothing returns nothing
            call DestroyLightning(lightning)
            call ReleaseTimer(timer)
            call deallocate()

            set timer = null
            set source = null
            set target = null
            set lightning = null
        endmethod

        private static method onPeriod takes nothing returns nothing
            local thistype this = GetTimerData(GetExpiredTimer())
  
            if not permanent then
                set duration = duration - PERIOD

                if duration <= 0 then
                    call destroy()
                endif
            endif

            if source != null and target != null then
                call MoveLightningEx(lightning, true, GetUnitX(source), GetUnitY(source), GetUnitZ(source) + 50.0, GetUnitX(target), GetUnitY(target), GetUnitZ(target) + 50.0)
            elseif source != null then
                call MoveLightningEx(lightning, true, GetUnitX(source), GetUnitY(source), GetUnitZ(source) + 50.0, x, y, z)
            endif
        endmethod

        static method unit2point takes unit source, real x, real y, real z, real duration, string lightningType returns thistype
            local thistype this = thistype.allocate()

            set this.x = x
            set this.y = y
            set this.z = z
            set this.source = source
            set this.duration = duration
            set this.permanent = duration <= 0
            set this.timer = NewTimerEx(this)
            set this.lightning = AddLightningEx(lightningType, true, GetUnitX(source), GetUnitY(source), GetUnitZ(source) + 50.0, x, y, z)

            call TimerStart(timer, PERIOD, true, function thistype.onPeriod)

            return this
        endmethod

        static method unit2unit takes unit source, unit target, real duration, string lightningType returns thistype
            local thistype this = thistype.allocate()

            set this.source = source
            set this.target = target
            set this.duration = duration
            set this.permanent = duration <= 0
            set this.timer = NewTimerEx(this)
            set this.lightning = AddLightningEx(lightningType, true, GetUnitX(source), GetUnitY(source), GetUnitZ(source) + 50.0, GetUnitX(target), GetUnitY(target), GetUnitZ(target) + 50.0)

            call TimerStart(timer, PERIOD, true, function thistype.onPeriod)

            return this
        endmethod
    endstruct
endlibrary