--[[
/**************************************************************
*
*   v1.0.5 by TriggerHappy
*   ----------------------
*   
*   Use this to destroy a handle after X amount seconds.
*
*   It's useful for things like effects where you may
*   want it to be temporary, but not have to worry
*   about the cleaning memory leak. By default it supports
*   effects, lightning, weathereffect, items, ubersplats, and units.
*
*   Installation
    ----------------------
*       1. Copy this script and over to your map inside a blank trigger.
*
*   API
*   ----------------------
*       call DestroyEffectTimed(AddSpecialEffect("effect.mdx", 0, 0), 5)
*       call DestroyLightningTimed(AddLightning("CLPB", true, 0, 0, 100, 100), 5)
*
**************************************************************/
]]--
do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    local PERIOD = 0.05
    
    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    Timed = setmetatable({}, {})
    local mt = getmetatable(Timed)
    mt.__index = mt

    local timer = CreateTimer()
    local array = {}
    local key   = 0
    
    function mt:destroy(i)
        if self.flag == 0 then
            DestroyEffect(self.type)
        elseif self.flag == 1 then
            DestroyLightning(self.type)
        elseif self.flag == 2 then
            RemoveWeatherEffect(self.type)
        elseif self.flag == 3 then
            RemoveItem(self.type)
        elseif self.flag == 4 then
            RemoveUnit(self.type)
        elseif self.flag == 5 then
            DestroyUbersplat(self.type)
        elseif self.flag == 6 then
            RemoveDestructable(self.type)
        end

        array[i] = array[key]
        key      = key - 1
        self     = nil

        if key == 0 then
            PauseTimer(timer)
        end

        return i - 1
    end
    
    function mt:handle(type, duration, flag)
        local this = {}
        setmetatable(this, mt)
        
        this.type   = type
        this.flag   = flag
        this.ticks  = duration/PERIOD
        key         = key + 1
        array[key]  = this
        
        if key == 1 then
            TimerStart(timer, PERIOD, true, function()
                local i = 1
                local this
                
                while i <= key do
                    this = array[i]
                    
                    if this.ticks <= 0 then
                        i = this:destroy(i)
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
    function DestroyEffectTimed(effect, duration)
        Timed:handle(effect, duration, 0)
    end

    function DestroyLightningTimed(lightning, duration)
        Timed:handle(lightning, duration, 1)
    end
    
    function RemoveWeatherEffectTimed(weathereffect, duration)
        Timed:handle(weathereffect, duration, 2)
    end
    
    function RemoveItemTimed(item, duration)
        Timed:handle(item, duration, 3)
    end
    
    function RemoveUnitTimed(unit, duration)
        Timed:handle(unit, duration, 4)
    end
    
    function DestroyUbersplatTimed(ubersplat, duration)
        Timed:handle(ubersplat, duration, 5)
    end
    
    function RemoveDestructableTimed(destructable, duration)
        Timed:handle(destructable, duration, 6)
    end
end