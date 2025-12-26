OnInit("Utilities", function(requires)
    requires "Class"
    requires "Dummy"
    requires "Indexer"
    requires "TimedHandles"
    requires "RegisterPlayerUnitEvent"

    -- Update period
    local PERIOD = 0.03125
    -- location z
    local location = Location(0,0)
    -- Closest Unit
    local bj_closestUnitGroup

    -- ---------------------------------------------------------------------------------------------- --
    --                                             Lua API                                            --
    -- ---------------------------------------------------------------------------------------------- --
    -- String to Ascii
    S2A = FourCC

    -- Ascii to String
    function A2S(id)
        local a = (id >> 24) & 0xFF
        local b = (id >> 16) & 0xFF
        local c = (id >>  8) & 0xFF
        local d =  id        & 0xFF

        return string.char(a, b, c, d)
    end

    -- Workaround for patch 2.0 R2S bug
    function N2S(value,  precision)
        local digit
        local result
        local sign = ""

        if value < 0 then
            sign = "-"
            value = RAbsBJ(value)
        end

        result = sign .. I2S(R2I(value))

        if precision <= 0 then
            return result
        end

        result = result .. "."
        value = value - R2I(value)

        while precision > 0 do
            value = value * 10
            digit = R2I(value)
            result = result .. I2S(digit)
            value = value - digit
            precision = precision - 1
        end

        return result
    end

    -- Real to Integer to String
    function R2I2S(real)
        return I2S(R2I(real))
    end

    -- Returns the terrain Z value
    function GetLocZ(x, y)
        MoveLocation(location, x, y)
        return GetLocationZ(location)
    end

    -- Similar to GetUnitX and GetUnitY but for Z axis
    function GetUnitZ(unit)
        return GetLocZ(GetUnitX(unit), GetUnitY(unit)) + GetUnitFlyHeight(unit)
    end

    -- Similar to SetUnitX and SetUnitY but for Z axis
    function SetUnitZ(unit, z)
        SetUnitFlyHeight(unit, z - GetLocZ(GetUnitX(unit), GetUnitY(unit)), 0)
    end

    -- Anlge between 2D points
    function AngleBetweenCoordinates(x, y, x2, y2)
        return Atan2(y2 - y, x2 - x)
    end

    -- Similar to AddSpecialEffect but scales the effect and considers z and return it
    function AddSpecialEffectEx(effect, x, y, z, scale)
        bj_lastCreatedEffect = AddSpecialEffect(effect, x, y)

        if z ~= 0 then
            BlzSetSpecialEffectZ(bj_lastCreatedEffect, z + GetLocZ(x, y))
        end
        BlzSetSpecialEffectScale(bj_lastCreatedEffect, scale)

        return bj_lastCreatedEffect
    end

    -- Returns a group of enemy units of the specified player within the specified AOE of x and y
    function GetEnemyUnitsInRange(player, x, y, aoe, structures, magicImmune)
        local group = CreateGroup()
        local g = CreateGroup()
        local unit

        GroupEnumUnitsInRange(g, x, y, aoe, nil)

        for i = 0, BlzGroupGetSize(g) - 1 do
            unit = BlzGroupUnitAt(g, i)

            if IsUnitEnemy(unit, player) and UnitAlive(unit) and (structures or (not IsUnitType(unit, UNIT_TYPE_STRUCTURE))) and (magicImmune or (not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE))) then
                GroupAddUnit(group, unit)
            end
        end

        DestroyGroup(g)

        return group
    end

    -- Returns the closest unit in a unit group with center at x and y
    function GetClosestUnitGroup(x, y, group)
        local md = 100000
        local unit
        local dx
        local dy

        bj_closestUnitGroup = nil
        for i = 0, BlzGroupGetSize(group) - 1 do
            unit = BlzGroupUnitAt(group, i)

            if UnitAlive(unit) then
                dx = GetUnitX(unit) - x
                dy = GetUnitY(unit) - y

                if (dx*dx + dy*dy)/100000 < md then
                    bj_closestUnitGroup = unit
                    md = (dx*dx + dy*dy)/100000
                end
            end
        end

        return bj_closestUnitGroup
    end

    -- Link an effect to a unit buff or ability
    function LinkEffectToBuff(unit, buffId, model, attach)
        EffectLink.buff(unit, buffId, model, attach)
    end

    -- Link an effect to an unit item.
    function LinkEffectToItem(unit, i, model, attach)
        EffectLink.item(unit, i, model, attach)
    end

    -- Spams the specified effect model at a location with the given interval for the number of times count
    function SpamEffect(model, x, y, z, scale, interval, count)
        local timer = CreateTimer()

        TimerStart(timer, interval, true, function()
            if count > 0 then
                DestroyEffect(AddSpecialEffectEx(model, x, y, z, scale))
            else
                PauseTimer(timer)
                DestroyTimer(timer)
            end

            count = count - 1
        end)
    end

    -- Spams the specified effect model attached to a unit for the given interval for the number of times count
    function SpamEffectUnit(unit, model, attach, interval, count)
        local timer = CreateTimer()

        TimerStart(timer, interval, true, function()
            if count > 0 then
                DestroyEffect(AddSpecialEffectTarget(model, unit, attach))
            else
                PauseTimer(timer)
                DestroyTimer(timer)
            end

            count = count - 1
        end)
    end

    -- Add the specified ability to the specified unit for the given duration. Use hide to show or not the ability button.
    function UnitAddAbilityTimed(unit, ability, duration, level, hide)
        TimedAbility.add(unit, ability, duration, level, hide)
    end

    -- Resets the specified unit ability cooldown
    function ResetUnitAbilityCooldown(unit, ability)
        local timer = CreateTimer()

        TimerStart(timer, 0.01, false, function()
            BlzEndUnitAbilityCooldown(unit, ability)
            PauseTimer(timer)
            DestroyTimer(timer)
        end)
    end

    -- Returns the distance between 2 coordinates in Warcraft III units
    function DistanceBetweenCoordinates(x1, y1, x2, y2)
        local dx = (x2 - x1)
        local dy = (y2 - y1)

        return SquareRoot(dx*dx + dy*dy)
    end

    -- Makes the specified source damage an area respecting some basic unit filters
    function UnitDamageArea(unit, x, y, aoe, damage, attacktype, damagetype, structures, magicImmune, allies)
        local group = CreateGroup()
        local player = GetOwningPlayer(unit)

        GroupEnumUnitsInRange(group, x, y, aoe, nil)
        GroupRemoveUnit(group, unit)

        for i = 0, BlzGroupGetSize(group) - 1 do
            local u = BlzGroupUnitAt(group, i)

            if UnitAlive(u) and (allies or IsUnitEnemy(u, player)) and (structures or (not IsUnitType(u, UNIT_TYPE_STRUCTURE))) and (magicImmune or (not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE))) then
                UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, nil)
            end
        end

        DestroyGroup(group)
    end

    -- Makes the specified source damage a group. Creates a special effect if specified
    function UnitDamageGroup(unit, group, damage, attacktype, damagetype, effect, attach, destroy)
        for i = 0, BlzGroupGetSize(group) - 1 do
            local u = BlzGroupUnitAt(group, i)

            UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, nil)

            if effect and attach then
                DestroyEffect(AddSpecialEffectTarget(effect, u, attach))
            end
        end

        if destroy then
            DestroyGroup(group)
        end

        return group
    end

    -- Returns a random range given a max value
    function GetRandomRange(radius)
        local r = GetRandomReal(0, 1) + GetRandomReal(0, 1)

        if r > 1 then
            return (2 - r)*radius
        end

        return r*radius
    end

    -- Returns a random value in the x/y coordinates depending on the value of boolean x
    function GetRandomCoordInRange(center, radius, x)
        local theta = 2*bj_PI*GetRandomReal(0, 1)
        local r

        if x then
            r = center + radius*Cos(theta)
        else
            r = center + radius*Sin(theta)
        end

        return r
    end

    -- Clones the items in the source unit inventory to the target unit
    function CloneItems(source, target, isIllusion)
        for i = 0, bj_MAX_INVENTORY do
            local item = UnitItemInSlot(source, i)
            local j = GetItemCharges(item)

            item = CreateItem(GetItemTypeId(item), GetUnitX(target), GetUnitY(target))

            SetItemCharges(item, j)
            UnitAddItem(target, item)

            if isIllusion then
                if GetItemTypeId(item) == S2A('ankh') then
                    BlzItemRemoveAbility(item, S2A('AIrc'))
                end

                BlzSetItemBooleanField(item, ITEM_BF_ACTIVELY_USED, false)
            end
        end
    end

    -- Add the mount for he unit mana pool
    function AddUnitMana(unit, real)
        SetUnitState(unit, UNIT_STATE_MANA, (GetUnitState(unit, UNIT_STATE_MANA) + real))
    end

    -- Add the specified amounts to a hero str/agi/int base amount
    function UnitAddStat(unit, strength, agility, intelligence)
        if strength ~= 0 then
            SetHeroStr(unit, GetHeroStr(unit, false) + strength, true)
        end

        if agility ~= 0 then
            SetHeroAgi(unit, GetHeroAgi(unit, false) + agility, true)
        end

        if intelligence ~= 0 then
            SetHeroInt(unit, GetHeroInt(unit, false) + intelligence, true)
        end
    end

    -- Returns the closest unit from the x and y coordinates in the map
    function GetClosestUnit(x, y, boolexpr)
        local group = CreateGroup()
        local md = 100000

        bj_closestUnitGroup = nil

        GroupEnumUnitsInRect(group, bj_mapInitialPlayableArea, boolexpr)
        for i = 0, BlzGroupGetSize(group) - 1 do
            local unit = BlzGroupUnitAt(group, i)

            if UnitAlive(unit) then
                local dx = GetUnitX(unit) - x
                local dy = GetUnitY(unit) - y

                if (dx*dx + dy*dy)/100000 < md then
                    bj_closestUnitGroup = unit
                    md = (dx*dx + dy*dy)/100000
                end
            end
        end

        DestroyGroup(group)
        DestroyBoolExpr(boolexpr)

        return bj_closestUnitGroup
    end

    -- Creates a chain lightning with the specified ligihtning effect with the amount of bounces
    function CreateChainLightning(source, target, damage, aoe, duration, interval, bounces, attacktype, damagetype, lightning, effect, attach, rebounce)
        local player = GetOwningPlayer(source)
        local group = GetEnemyUnitsInRange(player, GetUnitX(target), GetUnitY(target), aoe, false, false)

        if BlzGroupGetSize(group) == 1 then
            DestroyLightningTimed(AddLightningEx(lightning, true, GetUnitX(source), GetUnitY(source), GetUnitZ(source) + 60.0, GetUnitX(target), GetUnitY(target), GetUnitZ(target) + 60.0), duration)
            DestroyEffect(AddSpecialEffectTarget(effect, target, attach))
            UnitDamageTarget(source, target, damage, false, false, attacktype, damagetype, nil)
            DestroyGroup(group)
        else
            local timer = CreateTimer()
            local damaged = CreateGroup()
            local prev = nil
            local this = target
            local next = nil

            GroupRemoveUnit(group, this)
            GroupAddUnit(damaged, this)
            UnitDamageTarget(source, this, damage, false, false, attacktype, damagetype, nil)
            DestroyEffect(AddSpecialEffectTarget(effect, this, attach))
            TimerStart(timer, interval, true, function()
                DestroyGroup(group)
                if bounces > 0 then
                    group = GetEnemyUnitsInRange(player, GetUnitX(this), GetUnitY(this), aoe, false, false)

                    GroupRemoveUnit(group, this)

                    if not rebounce then
                        BlzGroupRemoveGroupFast(damaged, group)
                    end

                    if BlzGroupGetSize(group) == 0 then
                        PauseTimer(timer)
                        DestroyTimer(timer)
                        DestroyGroup(group)
                        DestroyGroup(damaged)
                    else
                        next = GetClosestUnitGroup(GetUnitX(this), GetUnitY(this), group)

                        if next == prev and BlzGroupGetSize(group) > 1 then
                            GroupRemoveUnit(group, prev)
                            next = GetClosestUnitGroup(GetUnitX(this), GetUnitY(this), group)
                        end

                        if next then
                            DestroyLightningTimed(AddLightningEx(lightning, true, GetUnitX(this), GetUnitY(this), GetUnitZ(this) + 60.0, GetUnitX(next), GetUnitY(next), GetUnitZ(next) + 60.0), duration)
                            DestroyEffect(AddSpecialEffectTarget(effect, next, attach))
                            GroupAddUnit(damaged, next)
                            UnitDamageTarget(source, next, damage, false, false, attacktype, damagetype, nil)
                            DestroyGroup(group)

                            prev = this
                            this = next
                            next = nil
                        else
                            PauseTimer(timer)
                            DestroyTimer(timer)
                            DestroyGroup(group)
                            DestroyGroup(damaged)
                        end
                    end
                else
                    PauseTimer(timer)
                    DestroyTimer(timer)
                    DestroyGroup(group)
                    DestroyGroup(damaged)
                end

                bounces = bounces - 1
            end)
        end

        DestroyGroup(group)
    end

    -- Add the specified amount to the specified player gold amount
    function AddPlayerGold(player, amount)
        SetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD, GetPlayerState(player, PLAYER_STATE_RESOURCE_GOLD) + amount)
    end

    -- Creates a text tag in an unit position for a duration
    function CreateTextOnUnit(unit, string, duration, red, green, blue, alpha)
        local texttag = CreateTextTag()

        SetTextTagText(texttag, string, 0.015)
        SetTextTagPosUnit(texttag, unit, 0)
        SetTextTagColor(texttag, red, green, blue, alpha)
        SetTextTagLifespan(texttag, duration)
        SetTextTagVelocity(texttag, 0.0, 0.0355)
        SetTextTagPermanent(texttag, false)
    end

    -- Add health regeneration to the unit base value
    function UnitAddHealthRegen(unit, regen)
        BlzSetUnitRealField(unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE, BlzGetUnitRealField(unit, UNIT_RF_HIT_POINTS_REGENERATION_RATE) + regen)
    end

    -- Casts an ability in the target unit. Must have no casting time
    function CastAbilityTarget(unit, ability, order, level)
        local dummy = DummyRetrieve(GetOwningPlayer(unit), 0, 0, 0, 0)

        UnitAddAbility(dummy, ability)
        SetUnitAbilityLevel(dummy, ability, level)
        IssueTargetOrder(dummy, order, unit)
        UnitRemoveAbility(dummy, ability)
        DummyRecycle(dummy)
    end

    -- Returns a random unit within a group
    function GroupPickRandomUnitEx(group)
        if BlzGroupGetSize(group) > 0 then
            return BlzGroupUnitAt(group, GetRandomInt(0, BlzGroupGetSize(group) - 1))
        else
            return nil
        end
    end

    -- Returns true if a unit is within a cone given a facing and fov angle in degrees (Less precise)
    function IsUnitInConeEx(unit, x, y, face, fov)
        return Acos(Cos((Atan2(GetUnitY(unit) - y, GetUnitX(unit) - x)) - face*bj_DEGTORAD)) < fov*bj_DEGTORAD/2
    end

    -- Returns true if a unit is within a cone given a facing, fov angle and a range in degrees (takes collision into consideration). Credits to AGD.
    function IsUnitInCone(unit, x, y, range, face, fov)
        if IsUnitInRangeXY(unit, x, y, range) then
            x = GetUnitX(unit) - x
            y = GetUnitY(unit) - y
            range = x*x + y*y

            if range > 0 then
                face = face*bj_DEGTORAD - Atan2(y, x)
                fov = fov*bj_DEGTORAD/2 + Asin(BlzGetUnitCollisionSize(unit)/SquareRoot(range))

                return RAbsBJ(face) <= fov or RAbsBJ(face - 2.00*bj_PI) <= fov
            end

            return true
        end

        return false
    end

    -- Makes the source unit damage enemy unit in a cone given a direction, foy and range
    function UnitDamageCone(unit, x, y, face, fov, aoe, damage, attacktype, damagetype, structures, magicImmune, allies)
        local group = CreateGroup()
        local player = GetOwningPlayer(unit)

        GroupEnumUnitsInRange(group, x, y, aoe, nil)
        GroupRemoveUnit(group, unit)

        for i = 0, BlzGroupGetSize(group) - 1 do
            local u = BlzGroupUnitAt(group, i)

            if UnitAlive(u) and IsUnitInCone(u, x, y, aoe, face, fov) then
                if (allies or IsUnitEnemy(u, player)) and (structures or (not IsUnitType(u, UNIT_TYPE_STRUCTURE))) and (magicImmune or (not IsUnitType(u, UNIT_TYPE_MAGIC_IMMUNE))) then
                    UnitDamageTarget(unit, u, damage, true, false, attacktype, damagetype, nil)
                end
            end
        end

        DestroyGroup(group)
    end

    -- Heals all allied units of specified player in an area
    function HealArea(player, x, y, aoe, amount, effect, attach)
        local group = CreateGroup()
        local unit

        GroupEnumUnitsInRange(group, x, y, aoe, nil)
        for i = 0, BlzGroupGetSize(group) - 1 do
            unit = BlzGroupUnitAt(group, i)

            if IsUnitAlly(unit, player) and UnitAlive(unit) and not IsUnitType(unit, UNIT_TYPE_STRUCTURE) then
                SetWidgetLife(unit, GetWidgetLife(unit) + amount)

                if effect ~= "" then
                    if attach ~= "" then
                        DestroyEffect(AddSpecialEffectTarget(effect, unit, attach))
                    else
                        DestroyEffect(AddSpecialEffect(effect, GetUnitX(unit), GetUnitY(unit)))
                    end
                end
            end
        end

        DestroyGroup(group)
    end

    -- Returns an ability real level field as a string. Usefull for toolltip manipulation.
    function AbilityRealField(unit, ability, field, level, multiplier, integer)
        if integer then
            return R2I2S(BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, level)*multiplier)
        else
            return R2SW(BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, level)*multiplier, 1, 1)
        end
    end

    -- Fix for camera pan desync. credits do Daffa
    function SmartCameraPanBJModified(player, loc, duration)
        local x = GetLocationX(loc)
        local y = GetLocationY(loc)
        local dx = x - GetCameraTargetPositionX()
        local dy = y - GetCameraTargetPositionY()
        local dist = SquareRoot(dx*dx + dy*dy)

        if GetLocalPlayer() == player then
            if dist >= bj_SMARTPAN_TRESHOLD_SNAP then
                PanCameraToTimed(x, y, duration)
            elseif dist >= bj_SMARTPAN_TRESHOLD_PAN then
                PanCameraToTimed(x, y, duration)
            else
                -- User is close, dont move camera
            end
        end
    end

    -- Fix for camera pan desync. credits do Daffa
    function SmartCameraPanBJModifiedXY(player, x, y, duration)
        local dx = x - GetCameraTargetPositionX()
        local dy = y - GetCameraTargetPositionY()
        local dist = SquareRoot(dx*dx + dy*dy)

        if GetLocalPlayer() == player then
            if dist >= bj_SMARTPAN_TRESHOLD_SNAP then
                PanCameraToTimed(x, y, duration)
            elseif dist >= bj_SMARTPAN_TRESHOLD_PAN then
                PanCameraToTimed(x, y, duration)
            else
                -- User is close, dont move camera
            end
        end
    end

    -- Start the cooldown for the source unit unit the new value
    function StartUnitAbilityCooldown(unit, ability, cooldown)
        local timer = CreateTimer()

        TimerStart(timer, 0.01, false, function()
            BlzStartUnitAbilityCooldown(unit, ability, cooldown)
            PauseTimer(timer)
            DestroyTimer(timer)
        end)
    end

    -- Replace Unit respecting Max Health, Mana, Damage and Armor values
    function ReplaceUnit(whichUnit, newUnitId, unitStateMethod)
        local oldUnit = whichUnit
        local newUnit
        local wasHidden
        local index
        local indexItem
        local oldRatio

        if oldUnit == null then
            bj_lastReplacedUnit = oldUnit
            return oldUnit
        end

        wasHidden = IsUnitHidden(oldUnit)
        ShowUnit(oldUnit, false)

        if (newUnitId == S2A('ugol')) then
            newUnit = CreateBlightedGoldmine(GetOwningPlayer(oldUnit), GetUnitX(oldUnit), GetUnitY(oldUnit), GetUnitFacing(oldUnit))
        else
            newUnit = CreateUnit(GetOwningPlayer(oldUnit), newUnitId, GetUnitX(oldUnit), GetUnitY(oldUnit), GetUnitFacing(oldUnit))
        end

        if unitStateMethod == bj_UNIT_STATE_METHOD_RELATIVE then
            if (GetUnitState(oldUnit, UNIT_STATE_MAX_LIFE) > 0) then
                oldRatio = GetUnitState(oldUnit, UNIT_STATE_LIFE) / GetUnitState(oldUnit, UNIT_STATE_MAX_LIFE)
                SetUnitState(newUnit, UNIT_STATE_LIFE, oldRatio * GetUnitState(newUnit, UNIT_STATE_MAX_LIFE))
            end

            if (GetUnitState(oldUnit, UNIT_STATE_MAX_MANA) > 0) and (GetUnitState(newUnit, UNIT_STATE_MAX_MANA) > 0) then
                oldRatio = GetUnitState(oldUnit, UNIT_STATE_MANA) / GetUnitState(oldUnit, UNIT_STATE_MAX_MANA)
                SetUnitState(newUnit, UNIT_STATE_MANA, oldRatio * GetUnitState(newUnit, UNIT_STATE_MAX_MANA))
            end
        elseif unitStateMethod == bj_UNIT_STATE_METHOD_ABSOLUTE then
            BlzSetUnitMaxHP(newUnit, BlzGetUnitMaxHP(oldUnit))
            SetUnitState(newUnit, UNIT_STATE_LIFE, GetUnitState(oldUnit, UNIT_STATE_LIFE))
            BlzSetUnitBaseDamage(newUnit, BlzGetUnitBaseDamage(oldUnit, 0), 0)
            BlzSetUnitArmor(newUnit, BlzGetUnitArmor(oldUnit))

            if GetUnitState(newUnit, UNIT_STATE_MAX_MANA) > 0 then
                BlzSetUnitMaxMana(newUnit, BlzGetUnitMaxMana(oldUnit))
                SetUnitState(newUnit, UNIT_STATE_MANA, GetUnitState(oldUnit, UNIT_STATE_MANA))
            end
        elseif unitStateMethod == bj_UNIT_STATE_METHOD_DEFAULTS then
            -- The newly created unit should already have default life and mana.
        elseif unitStateMethod == bj_UNIT_STATE_METHOD_MAXIMUM then
            BlzSetUnitMaxHP(newUnit, BlzGetUnitMaxHP(oldUnit))
            BlzSetUnitMaxMana(newUnit, BlzGetUnitMaxMana(oldUnit))
            BlzSetUnitBaseDamage(newUnit, BlzGetUnitBaseDamage(oldUnit, 0), 0)
            BlzSetUnitArmor(newUnit, BlzGetUnitArmor(oldUnit))
            SetUnitState(newUnit, UNIT_STATE_LIFE, GetUnitState(newUnit, UNIT_STATE_MAX_LIFE))
            SetUnitState(newUnit, UNIT_STATE_MANA, GetUnitState(newUnit, UNIT_STATE_MAX_MANA))
        else
            -- Unrecognized unit state method - ignore the request.
        end

        SetResourceAmount(newUnit, GetResourceAmount(oldUnit))

        if (IsUnitType(oldUnit, UNIT_TYPE_HERO) and IsUnitType(newUnit, UNIT_TYPE_HERO)) then
            index = 0

            SetHeroXP(newUnit, GetHeroXP(oldUnit), false)

            while index < bj_MAX_INVENTORY do
                indexItem = UnitItemInSlot(oldUnit, index)

                if indexItem  then
                    UnitRemoveItem(oldUnit, indexItem)
                    UnitAddItem(newUnit, indexItem)
                end

                index = index + 1
            end
        end

        if wasHidden then
            KillUnit(oldUnit)
            RemoveUnit(oldUnit)
        else
            RemoveUnit(oldUnit)
        end

        bj_lastReplacedUnit = newUnit

        return newUnit
    end

    -- Creates a lightning effect between 2 units
    function CreateLightningUnit2Unit(source, target, duration, lightningType)
        return TimedLightning.unit2unit(source, target, duration, lightningType)
    end

    -- Creates a lightning effect between unit and point
    function CreateLightningUnit2Point(source, x, y, z, duration, lightningType)
        return TimedLightning.unit2point(source, x, y, z, duration, lightningType)
    end

    -- Get a unit or hero level
    function GetWidgetLevel(unit)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
            return GetHeroLevel(unit)
        else
            return GetUnitLevel(unit)
        end
    end
    -- -- ---------------------------------------------------------------------------------------------- --
    -- --                                             Systems                                            --
    -- -- ---------------------------------------------------------------------------------------------- --
    -- -- ---------------------------------------- Timed Ability --------------------------------------- --
    do
        TimedAbility = Class()

        local array = {}
        local ability = {}
        local timer = CreateTimer()

        function TimedAbility.add(unit, id, duration, level, hide)
            if not ability[unit] then ability[unit] = {} end

            local this = ability[unit][id]

            if not this then
                this = {}

                this.id = id
                this.unit = unit
                ability[unit][id] = this

                table.insert(array, this)

                if #array == 1 then
                    TimerStart(timer, PERIOD, true, function()
                        local this

                        for i = #array, 1, -1 do
                            this = array[i]

                            this.duration = this.duration - PERIOD

                            if this.duration <= 0 then
                                i = this:destroy(i)

                                UnitRemoveAbility(this.unit, this.id)

                                ability[this.unit][this.id] = nil
                                this = nil
                                table.remove(array, i)

                                if #array == 0 then
                                    PauseTimer(timer)
                                end
                            end
                        end
                    end)
                end
            end

            if GetUnitAbilityLevel(unit, id) ~= level then
                UnitAddAbility(unit, id)
                SetUnitAbilityLevel(unit, id, level)
                UnitMakeAbilityPermanent(unit, true, id)
                BlzUnitHideAbility(unit, id, hide)
            end

            this.duration = duration
        end
    end

    -- -- ----------------------------------------- Effect Link ---------------------------------------- --
    do
        EffectLink = Class()

        local array = {}
        local items = {}
        local timer = CreateTimer()

        function EffectLink.buff(unit, id, model, attach)
            local this = {}

            this.buff = id
            this.unit = unit
            this.effect = AddSpecialEffectTarget(model, unit, attach)

            table.insert(array, this)

            if #array == 1 then
                TimerStart(timer, PERIOD, true, function()
                    local this

                    for i = #array, 1, -1 do
                        this = array[i]

                        if GetUnitAbilityLevel(this.unit, this.buff) == 0 then
                            DestroyEffect(this.effect)

                            this = nil
                            table.remove(array, i)

                            if #array == 0 then
                                PauseTimer(timer)
                            end
                        end
                    end
                end)
            end
        end

        function EffectLink.item(unit, i, model, attach)
            local this = {}

            this.item = i
            this.effect = AddSpecialEffectTarget(model, unit, attach)

            table.insert(items, this)
        end

        function EffectLink.onDrop()
            local this
            local item = GetManipulatedItem()

            for i = #items, 1, -1 do
                this = items[i]

                if this.item == item then
                    DestroyEffect(this.effect)

                    this = nil
                    table.remove(items, i)
                end
            end
        end

        function EffectLink.onInit()
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, EffectLink.onDrop)
        end
    end

    -- ------------------------------------ Timed Lightning ------------------------------------ --
    do
        TimedLightning = Class()

        local array = {}

        function TimedLightning:destroy()
            array[self.timer] = nil

            DestroyLightning(self.lightning)
            PauseTimer(self.timer)
            DestroyTimer(self.timer)

            self.timer = nil
            self.source = nil
            self.target = nil
            self.lightning = nil
        end

        function TimedLightning.onPeriod()
            local this = array[GetExpiredTimer()]

            if this then
                if not this.permanent then
                    this.duration = this.duration - PERIOD

                    if this.duration <= 0 then
                        this:destroy()
                    end
                end

                if this.source and this.target then
                    MoveLightningEx(this.lightning, true, GetUnitX(this.source), GetUnitY(this.source), GetUnitZ(this.source) + 50.0, GetUnitX(this.target), GetUnitY(this.target), GetUnitZ(this.target) + 50.0)
                elseif this.source then
                    MoveLightningEx(this.lightning, true, GetUnitX(this.source), GetUnitY(this.source), GetUnitZ(this.source) + 50.0, this.x, this.y, this.z)
                end
            end
        end

        function TimedLightning.unit2point(source, x, y, z, duration, lightningType)
            local this = TimedLightning.allocate()

            this.x = x
            this.y = y
            this.z = z
            this.source = source
            this.duration = duration
            this.permanent = duration <= 0
            this.timer = CreateTimer()
            this.lightning = AddLightningEx(lightningType, true, GetUnitX(source), GetUnitY(source), GetUnitZ(source) + 50.0, x, y, z)

            array[this.timer] = this

            TimerStart(this.timer, PERIOD, true, TimedLightning.onPeriod)

            return this
        end

        function TimedLightning.unit2unit(source, target, duration, lightningType)
            local this = TimedLightning.allocate()

            this.source = source
            this.target = target
            this.duration = duration
            this.permanent = duration <= 0
            this.timer = CreateTimer()
            this.lightning = AddLightningEx(lightningType, true, GetUnitX(source), GetUnitY(source), GetUnitZ(source) + 50.0, GetUnitX(target), GetUnitY(target), GetUnitZ(target) + 50.0)

            array[this.timer] = this

            TimerStart(this.timer, PERIOD, true, TimedLightning.onPeriod)

            return this
        end
    end
end)