OnInit("TimedHandles", function(requires)
    requires "Class"

    TimedHandles = Class()

    local array = {}
    local period = 0.05
    local timer = CreateTimer()

    function TimedHandles.handle(object, duration, type)
        local this = {}

        this.object = object
        this.type = type
        this.duration = duration

        table.insert(array, this)

        if #array == 1 then
            TimerStart(timer, period, true, function()
                local this

                for i = #array, 1, -1 do
                    this = array[i]

                    this.duration = this.duration - period

                    if this.duration <= 0 then
                        if this.type == 0 then
                            DestroyEffect(this.object)
                        elseif this.type == 1 then
                            DestroyLightning(this.object)
                        elseif this.type == 2 then
                            RemoveWeatherEffect(this.object)
                        elseif this.type == 3 then
                            RemoveItem(this.object)
                        elseif this.type == 4 then
                            RemoveUnit(this.object)
                        elseif this.type == 5 then
                            DestroyUbersplat(this.object)
                        elseif this.type == 6 then
                            RemoveDestructable(this.object)
                        end

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

    -- -------------------------------------------------------------------------- --
    --                                   LUA API                                  --
    -- -------------------------------------------------------------------------- --
    function DestroyEffectTimed(effect, duration)
        TimedHandles.handle(effect, duration, 0)
    end

    function DestroyLightningTimed(lightning, duration)
        TimedHandles.handle(lightning, duration, 1)
    end

    function RemoveWeatherEffectTimed(weathereffect, duration)
        TimedHandles.handle(weathereffect, duration, 2)
    end

    function RemoveItemTimed(item, duration)
        TimedHandles.handle(item, duration, 3)
    end

    function RemoveUnitTimed(unit, duration)
        TimedHandles.handle(unit, duration, 4)
    end

    function DestroyUbersplatTimed(ubersplat, duration)
        TimedHandles.handle(ubersplat, duration, 5)
    end

    function RemoveDestructableTimed(destructable, duration)
        TimedHandles.handle(destructable, duration, 6)
    end
end)