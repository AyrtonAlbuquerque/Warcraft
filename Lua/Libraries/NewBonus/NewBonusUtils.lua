--[[
    /* ----------------------- NewBonusUtils v2.3 by Chopinski ----------------------- */
   Required Library: RegisterPlayerUnitEvent -> www.hiveworkshop.com/threads/snippet-registerplayerunitevent.203338/

        API:
        function AddUnitBonusTimed takes unit u, integer bonus_type, real amount, real duration returns nothing
            -> Add the specified amount for the specified bonus type for unit for a duration
            -> Example: call AddUnitBonusTimed(GetTriggerUnit(), BONUS_ARMOR, 13, 10.5)

        function LinkBonusToBuff takes unit u, integer bonus_type, real amount, integer buffId returns nothing
            -> Links the bonus amount specified to a buff or ability. As long as the unit has the buff or
            -> the ability represented by the parameter buffId the bonus is not removed.
            -> Example: call LinkBonusToBuff(GetTriggerUnit(), BONUS_ARMOR, 10, 'B000')
 
        function LinkBonusToItem takes unit u, integer bonus_type, real amount, item i returns nothing
            -> Links the bonus amount specified to an item. As long as the unit has that item the bonus is not removed.
            -> Note that it will work for items with the same id, because it takes as parameter the item object.
            -> Example: call LinkBonusToItem(GetManipulatingUnit(), BONUS_ARMOR, 10, GetManipulatedItem())

        function UnitCopyBonuses takes unit source, unit target returns nothing
            -> Copy the source unit bonuses using the Add functionality to the target unit
            -> Example: call UnitCopyBonuses(GetTriggerUnit(), GetSummonedUnit())

        function UnitMirrorBonuses takes unit source, unit target returns nothing
            -> Copy the source unit bonuses using the Set functionality to the target unit
            -> Example: call UnitMirrorBonuses(GetTriggerUnit(), GetSummonedUnit())
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    local PERIOD = 0.03125000

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    NewBonusUtils = setmetatable({}, {})
    local mt = getmetatable(NewBonusUtils)
    mt.__index = mt
    
    local array = {}
    local key = 0
    local items = {}
    local k = 0
    local timer = CreateTimer()
    
    function mt:destroy(i, item)
        if NewBonus_EXTENDED and Damage and Evasion and Critical and SpellPower and LifeSteal and SpellVamp then
            if self.type == BONUS_COOLDOWN_REDUCTION then
                UnitRemoveCooldownReduction(self.unit, self.amount)
            else
                AddUnitBonus(self.unit, self.type, -self.amount)
            end
        else
            AddUnitBonus(self.unit, self.type, -self.amount)
        end
        
        if item then
            items[i] = items[k]
            k = k - 1
        else
            array[i] = array[key]
            key = key - 1

            if key == 0 then
                PauseTimer(timer)
            end
        end
        self = nil

        return i - 1
    end
    
    function mt:onPeriod()
        local i = 1
        local this
        
        while i <= key do
            this = array[i]
            
            if this.timed then
                if this.duration <= 0 then
                    i = this:destroy(i, false)
                end
                this.duration = this.duration - PERIOD
            else
                if GetUnitAbilityLevel(this.unit, this.buff) == 0 then
                    i = this:destroy(i, false)
                end
            end
            i = i + 1
        end
    end
    
    function mt:linkItem(unit, type, amount, item)
        local this = {}
        setmetatable(this, mt)
        
        this.unit = unit
        this.item = item
        this.amount = AddUnitBonus(unit, type, amount)
        this.type = NewBonus.linkType
        k = k + 1
        items[k] = this
    end
    
    function mt:linkTimed(unit, type, amount, duration, timed)
        local this = {}
        setmetatable(this, mt)
        
        this.unit = unit
        this.timed = timed
        this.duration = duration
        this.amount = AddUnitBonus(unit, type, amount)
        this.type = NewBonus.linkType
        key = key + 1
        array[key] = this
        
        if key == 1 then
            TimerStart(timer, PERIOD, true, function() self:onPeriod() end)
        end
    end
    
    function mt:linkBuff(unit, type, amount, buff, timed)
        local this = {}
        setmetatable(this, mt)
        
        this.unit = unit
        this.timed = timed
        this.buff = buff
        this.amount = AddUnitBonus(unit, type, amount)
        this.type = NewBonus.linkType
        key = key + 1
        array[key] = this
        
        if key == 1 then
            TimerStart(timer, PERIOD, true, function() self:onPeriod() end)
        end
    end
    
    function mt:copy(source, target)
        for i = 1, NewBonus.last do
            if GetUnitBonus(source, i) ~= 0 then
                AddUnitBonus(target, i, GetUnitBonus(source, i))
            end
        end
    end

    function mt:mirror(source, target)
        for i = 1, NewBonus.last do
            SetUnitBonus(target, i, GetUnitBonus(source, i))
        end
    end
    
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DROP_ITEM, function()
            local item = GetManipulatedItem()
            local i = 1
            local this
            
            while i <= k do
                this = items[i]
                
                if this.item == item then
                    i = this:destroy(i, true)
                end
                i = i + 1
            end
        end)
    end)
    
    -- -------------------------------------------------------------------------- --
    --                                   LUA API                                  --
    -- -------------------------------------------------------------------------- --
    function AddUnitBonusTimed(unit, type, amount, duration)
        NewBonusUtils:linkTimed(unit, type, amount, duration, true)
    end

    function LinkBonusToBuff(unit, type, amount, buff)
        NewBonusUtils:linkBuff(unit, type, amount, buff, false)
    end

    function LinkBonusToItem(unit, type, amount, item)
        NewBonusUtils:linkItem(unit, type, amount, item)
    end

    function UnitCopyBonuses(source, target)
        NewBonusUtils:copy(source, target)
    end

    function UnitMirrorBonuses(source, target)
        NewBonusUtils:mirror(source, target)
    end
end