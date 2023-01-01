--[[
    /* ------------------------ CriticalStrike v2.4 by Chopinski ----------------------- */
     CriticalStrike implements an easy way to register and detect a custom critical event.
     allows the manipulation of a unit critical strike chance and multiplier, as well as
     manipulating the critical damage dealt.

     It works by monitoring custom critical strike chance and multiplier values given to units.

     It will only detect custom critical strikes, so all critical chance given to a
     unit must be done so using the public API provided by this system.

     *CriticalStrike requires DamageInterface. Do not use TriggerSleepAction() with Evasion.
     It also requires optional Evasion so that this library is written after the Evasion
     library, so both custom events will not fire at the same time.

     The API:
         function RegisterCriticalStrikeEvent(function YourFunction)
             -> YourFunction will run when a unit hits a critical strike.

         function GetCriticalSource takes nothing returns unit
             -> Returns the unit hitting a critical strike.
    
         function GetCriticalTarget takes nothing returns unit
             -> Returns the unit being hit by a critical strike.
    
         function GetCriticalDamage takes nothing returns real
             -> Returns the critical strike damage amount.
    
         function GetUnitCriticalChance takes unit u returns real
             -> Returns the chance to hit a critical strike to specified unit.
    
         function GetUnitCriticalMultiplier takes unit u returns real
             -> Returns the chance to hit a critical strike to specified unit.
    
         function SetUnitCriticalChance takes unit u, real value returns nothing
             -> Set's the unit chance to hit a critical strike to specified value.
             -> 15.0 = 15%
    
         function SetUnitCriticalMultiplier takes unit u, real value returns nothing
             -> Set's the unit multiplier of damage when hitting a critical to value
             -> 1.0 = increases the multiplier by 1. all units have a multiplier of 1.0
                 by default, so by adding 1.0, for example, the critical damage will be 
                 2x the normal damage

         function SetCriticalEventDamage takes real newValue returns nothing
             -> Modify the critical damage dealt to the specified value.
    
         function UnitAddCriticalStrike takes unit u, real chance, real multiplier returns nothing
             -> Adds the specified values of chance and multiplier to a unit
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    local TEXT_SIZE = 0.016
    
    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    Critical = {
        source,
        target,
        damage,
        chance = {},
        multiplier = {}
    }
    local event = {}
    
    local function Text(unit, text, duration, red, green, blue, alpha)
        local texttag = CreateTextTag()
        
        SetTextTagText(texttag, text, TEXT_SIZE)
        SetTextTagPosUnit(texttag, unit, 0)
        SetTextTagColor(texttag, red, green, blue, alpha)
        SetTextTagLifespan(texttag, duration)
        SetTextTagVelocity(texttag, 0.0, 0.0355)
        SetTextTagPermanent(texttag, false)
    end
    
    onInit(function()
        RegisterAttackDamageEvent(function()
            local damage = GetEventDamage()
        
            if damage > 0 and GetRandomReal(0, 100) <= (Critical.chance[Damage.source.unit] or 0) and Damage.isEnemy and not Damage.target.isStructure and (Critical.multiplier[Damage.source.unit] or 0) > 0 then
                Critical.source = Damage.source
                Critical.target = Damage.target
                Critical.damage = damage*(1 + (Critical.multiplier[Damage.source.unit] or 0))

                for i = 1, #event do
                    event[i]()
                end
                BlzSetEventDamage(Critical.damage)

                if Critical.damage > 0 then
                    Text(Critical.target.unit, (I2S(R2I(Critical.damage)) .. "!"), 1.5, 255, 0, 0, 255)
                end

                Critical.source = nil
                Critical.target = nil
                Critical.damage = 0
            end
        end)
    end)
    
    -- -------------------------------------------------------------------------- --
    --                                   LUA API                                  --
    -- -------------------------------------------------------------------------- --
    function RegisterCriticalStrikeEvent(code)
        if type(code) == "function" then
            table.insert(event, code)
        end
    end

    function GetCriticalSource()
        return Critical.source.unit
    end

    function GetCriticalTarget()
        return Critical.target.unit
    end

    function GetCriticalDamage()
        return Critical.damage or 0
    end

    function GetUnitCriticalChance(unit)
        return Critical.chance[unit] or 0
    end

    function GetUnitCriticalMultiplier(unit)
        return Critical.multiplier[unit] or 0
    end

    function SetUnitCriticalChance(unit, real)
        Critical.chance[unit] = real
    end

    function SetUnitCriticalMultiplier(unit, real)
        Critical.multiplier[unit] = real
    end

    function SetCriticalEventDamage(real)
        Critical.damage = real
    end

    function UnitAddCriticalStrike(unit, chance, multiplier)
        if not Critical.chance[unit] then Critical.chance[unit] = 0 end
        if not Critical.multiplier[unit] then Critical.multiplier[unit] = 0 end
        
        Critical.chance[unit] = Critical.chance[unit] + chance
        Critical.multiplier[unit] = Critical.multiplier[unit] + multiplier
    end
end