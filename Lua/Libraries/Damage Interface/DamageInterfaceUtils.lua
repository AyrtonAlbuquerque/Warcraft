--[[
    /* ------- Utility Library for all the Damage Interface Custom Events ------- */
    /* ---------------------------- v2.4 by Chopinski --------------------------- */
     The API:
         Evasion System:
             function UnitAddEvasionChanceTimed takes unit u, real amount, real duration returns nothing
                 -> Add to a unit Evasion chance the specified amount for a given period
    
             function UnitAddMissChanceTimed takes unit u, real amount, real duration returns nothing
                 -> Add to a unit Miss chance the specified amount for a given period

         Critical Strike System:
             function UnitAddCriticalStrikeTimed takes unit u, real chance, real multiplier, real duration returns nothing
                 -> Adds the specified values of chance and multiplier to a unit for a given period
        
             function UnitAddCriticalChanceTimed takes unit u, real chance, real duration returns nothing
                 -> Adds the specified values of critical chance to a unit for a given period
        
             function UnitAddCriticalMultiplierTimed takes unit u, real multiplier, real duration returns nothing
                 -> Adds the specified values of critical multiplier to a unit for a given period

         Spell Power System:
             function UnitAddSpellPowerFlatTimed takes unit u, real amount, real duration returns nothing
                 -> Add to the Flat amount of Spell Power of a unit for a given period

             function UnitAddSpellPowerPercentTimed takes unit u, real amount, real duration returns nothing
                 -> Add to the Percent amount of Spell Power of a unit for a given period

             function AbilitySpellDamage takes unit u, integer abilityId, abilityreallevelfield field returns string
                 -> Given an ability field, will return a string that represents the damage that would be dealt
                 taking into consideration the spell power bonusses of a unit.

             function AbilitySpellDamageEx takes real amount, unit u returns string
                 -> Similar to GetSpellDamage will return the damage that would be dealt but as a string

         Life Steal System:
             function UnitAddLifeStealTimed takes unit u, real amount, real duration returns nothing
                 -> Add to the Life Steal amount of a unit the given amount for a given period

         Spell Vamp System:
             function UnitAddSpellVampTimed takes unit u, real amount, real duration returns nothing
                 -> Add to the Spell Vamp amount of a unit the given amount for a given period
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    local PERIOD = 0.03125000

    -- -------------------------------------------------------------------------- --
    --                                Evasion Utils                               --
    -- -------------------------------------------------------------------------- --
    do
        EvasionUtils = setmetatable({}, {})
        local mt = getmetatable(EvasionUtils)
        mt.__index = mt
        
        local array = {}
        local key   = 0
        local timer = CreateTimer()
        
        function mt:remove(i)
            if self.type then
                UnitAddEvasionChance(self.unit, -self.amount)
            else
                UnitAddMissChance(self.unit, -self.amount)
            end

            array[i] = array[key]
            key      = key - 1
            self     = nil

            if key == 0 then
                PauseTimer(timer)
            end

            return i - 1
        end
        
        function mt:addTimed(unit, amount, duration, type)
            local this = {}
            setmetatable(this, mt)
            
            this.unit   = unit
            this.amount = amount
            this.ticks  = duration/PERIOD
            this.type   = type
            key         = key + 1
            array[key]  = this
            
            if type then
                UnitAddEvasionChance(unit, amount)
            else
                UnitAddMissChance(unit, amount)
            end
            
            if key == 1 then
                TimerStart(timer, PERIOD, true, function()
                    local i = 1
                    local this
                    
                    while i <= key do
                        this = array[i]
                        
                        if this.ticks <= 0 then
                            i = this:remove(i)
                        end
                        this.ticks = this.ticks - 1
                        i = i + 1
                    end
                end)
            end
        end
    end
    
    -- -------------------------------------------------------------------------- --
    --                            Critical Strike Utils                           --
    -- -------------------------------------------------------------------------- --
    do
        CriticalUtils = setmetatable({}, {})
        local mt = getmetatable(CriticalUtils)
        mt.__index = mt
        
        local array = {}
        local key   = 0
        local timer = CreateTimer()
        
        function mt:remove(i)
            UnitAddCriticalStrike(self.unit, -self.chance, -self.multiplier)
        
            array[i] = array[key]
            key      = key - 1
            self     = nil

            if key == 0 then
                PauseTimer(timer)
            end

            return i - 1
        end
        
        function mt:addTimed(unit, chance, multiplier, duration, type)
            local this = {}
            setmetatable(this, mt)
            
            this.unit       = unit
            this.chance     = chance
            this.multiplier = multiplier
            this.ticks      = duration/PERIOD
            key             = key + 1
            array[key]      = this

            UnitAddCriticalStrike(unit, chance, multiplier)
            
            if key == 1 then
                TimerStart(timer, PERIOD, true, function()
                    local i = 1
                    local this

                    while i <= key do
                        this = array[i]
                        
                        if this.ticks <= 0 then
                            i = this:remove(i)
                        end
                        this.ticks = this.ticks - 1
                        i = i + 1
                    end
                end)
            end
        end
    end
    
    -- -------------------------------------------------------------------------- --
    --                              Spell Power Utils                             --
    -- -------------------------------------------------------------------------- --
    do
        SpellPowerUtils = setmetatable({}, {})
        local mt = getmetatable(SpellPowerUtils)
        mt.__index = mt
        
        local array = {}
        local key   = 0
        local timer = CreateTimer()
        
        function mt:remove(i)
            if self.type then
                UnitAddSpellPowerFlat(self.unit, -self.amount)
            else
                UnitAddSpellPowerPercent(self.unit, -self.amount)
            end
        
            array[i] = array[key]
            key      = key - 1
            self     = nil

            if key == 0 then
                PauseTimer(timer)
            end

            return i - 1
        end
        
        function mt:addTimed(unit, amount, duration, type)
            local this = {}
            setmetatable(this, mt)
            
            this.unit   = unit
            this.amount = amount
            this.ticks  = duration/PERIOD
            this.type   = type
            key         = key + 1
            array[key]  = this
            
            if type then
                UnitAddSpellPowerFlat(unit, amount)
            else
                UnitAddSpellPowerPercent(unit, amount)
            end
            
            
            if key == 1 then
                TimerStart(timer, PERIOD, true, function()
                    local i = 1
                    local this
                    
                    while i <= key do
                        this = array[i]
                        
                        if this.ticks <= 0 then
                            i = this:remove(i)
                        end
                        this.ticks = this.ticks - 1
                        i = i + 1
                    end
                end)
            end
        end
    end
    
    -- -------------------------------------------------------------------------- --
    --                              Life Steal Utils                              --
    -- -------------------------------------------------------------------------- --
    do
        LifeStealUtils = setmetatable({}, {})
        local mt = getmetatable(LifeStealUtils)
        mt.__index = mt
        
        local array = {}
        local key   = 0
        local timer = CreateTimer()
        
        function mt:remove(i)
            UnitAddLifeSteal(self.unit, -self.amount)
        
            array[i] = array[key]
            key      = key - 1
            self     = nil

            if key == 0 then
                PauseTimer(timer)
            end

            return i - 1
        end
        
        function mt:addTimed(unit, amount, duration)
            local this = {}
            setmetatable(this, mt)
            
            this.unit       = unit
            this.amount     = amount
            this.ticks      = duration/PERIOD
            key             = key + 1
            array[key]      = this

            UnitAddLifeSteal(unit, amount)
            
            if key == 1 then
                TimerStart(timer, PERIOD, true, function()
                    local i = 1
                    local this

                    while i <= key do
                        this = array[i]
                        
                        if this.ticks <= 0 then
                            i = this:remove(i)
                        end
                        this.ticks = this.ticks - 1
                        i = i + 1
                    end
                end)
            end
        end
    end

    -- -------------------------------------------------------------------------- --
    --                              Spell Vamp Utils                              --
    -- -------------------------------------------------------------------------- --
    SpellVampUtils = setmetatable({}, {})
        local mt = getmetatable(SpellVampUtils)
        mt.__index = mt
        
        local array = {}
        local key   = 0
        local timer = CreateTimer()
        
        function mt:remove(i)
            UnitAddSpellVamp(self.unit, -self.amount)
        
            array[i] = array[key]
            key      = key - 1
            self     = nil

            if key == 0 then
                PauseTimer(timer)
            end

            return i - 1
        end
        
        function mt:addTimed(unit, amount, duration)
            local this = {}
            setmetatable(this, mt)
            
            this.unit       = unit
            this.amount     = amount
            this.ticks      = duration/PERIOD
            key             = key + 1
            array[key]      = this

            UnitAddSpellVamp(unit, amount)
            
            if key == 1 then
                TimerStart(timer, PERIOD, true, function()
                    local i = 1
                    local this

                    while i <= key do
                        this = array[i]
                        
                        if this.ticks <= 0 then
                            i = this:remove(i)
                        end
                        this.ticks = this.ticks - 1
                        i = i + 1
                    end
                end)
            end
        end
    
    -- -------------------------------------------------------------------------- --
    --                                   LUA API                                  --
    -- -------------------------------------------------------------------------- --
    function UnitAddEvasionChanceTimed(unit, amount, duration)
        EvasionUtils:addTimed(unit, amount, duration, true)
    end

    function UnitAddMissChanceTimed(unit, amount, duration)
        EvasionUtils:addTimed(unit, amount, duration, false)
    end
    
    function UnitAddCriticalStrikeTimed(unit, chance, multiplier, duration)
        CriticalUtils:addTimed(unit, chance, multiplier, duration, 0)
    end

    function UnitAddCriticalChanceTimed(unit, chance, duration)
        CriticalUtils:addTimed(unit, chance, 0, duration, 1)
    end

    function UnitAddCriticalMultiplierTimed(unit, multiplier, duration)
        CriticalUtils:addTimed(unit, 0, multiplier, duration, 2)
    end
    
    function UnitAddSpellPowerFlatTimed(unit, amount, duration)
        SpellPowerUtils:addTimed(unit, amount, duration, true)
    end

    function UnitAddSpellPowerPercentTimed(unit, amount, duration)
        SpellPowerUtils:addTimed(unit, amount, duration, false)
    end

    function AbilitySpellDamage(unit, ability, field)
        return I2S(R2I((BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, GetUnitAbilityLevel(unit, ability) - 1) + (SpellPower.flat[unit] or 0)) * (1 + (SpellPower.percent[unit] or 0))))
    end

    function AbilitySpellDamageEx(real, unit)
        return I2S(R2I((real + (SpellPower.flat[unit] or 0)) * (1 + (SpellPower.percent[unit] or 0))))
    end
    
    function UnitAddLifeStealTimed(unit, amount, duration)
        LifeStealUtils:addTimed(unit, amount, duration)
    end

    function UnitAddSpellVampTimed(unit, amount, duration)
        SpellVampUtils:addTimed(unit, amount, duration)
    end
end