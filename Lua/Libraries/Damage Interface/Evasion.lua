--[[
    /* ------------------------ Evasion v2.3 by Chopinski ----------------------- */
    Evasion implements an easy way to register and detect a custom evasion event.

     It works by monitoring custom evasion and missing values given to units,
     and nulling damage when the odds given occurs.

     It will only detect custom evasion, so all evasion or miss values given to a
     unit must be done so using the public API provided by this system.

     *Evasion requires DamageInterface. Do not use TriggerSleepAction() with Evasion.

     The API:
         function RegisterEvasionEvent(function YourFunction)
             -> YourFunction will run when a unit evades an attack.

         function GetMissingUnit takes nothing returns unit
             -> Returns the unit missing the attack

         function GetEvadingUnit takes nothing returns unit
             -> Returns the unit evading the attack

         function GetEvadedDamage takes nothing returns real
             -> Returns the amount of evaded damage

         function GetUnitEvasionChance takes unit u returns real
             -> Returns this system amount of evasion chance given to a unit

         function GetUnitMissChance takes unit u returns real
             -> Returns this system amount of miss chance given to a unit

         function SetUnitEvasionChance takes unit u, real chance returns nothing
             -> Sets unit evasion chance to specified amount

         function SetUnitMissChance takes unit u, real chance returns nothing
             -> Sets unit miss chance to specified amount

         function UnitAddEvasionChance takes unit u, real chance returns nothing
             -> Add to a unit Evasion chance the specified amount

         function UnitAddMissChance takes unit u, real chance returns nothing
             -> Add to a unit Miss chance the specified amount

         function MakeUnitNeverMiss takes unit u, boolean flag returns nothing
             -> Will make a unit never miss attacks no matter the evasion chance of the attacked unit

         function DoUnitNeverMiss takes unit u returns boolean
             -> Returns true if the unit will never miss an attack
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    local TEXT_SIZE = 0.016

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    Evasion = {
        evasion = {},
        miss = {},
        neverMiss = {},
        source,
        target,
        damage,
        evade
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
        RegisterAttackDamagingEvent(function()
            local damage = GetEventDamage()
        
            Evasion.evade = false
            if damage > 0 and not ((Evasion.neverMiss[Damage.source.id] or 0) > 0) then
                Evasion.evade = GetRandomReal(0, 100) <= (Evasion.evasion[Damage.target.id] or 0) or GetRandomReal(0, 100) <= (Evasion.miss[Damage.source.id] or 0)
                if Evasion.evade then
                    Evasion.source = Damage.source
                    Evasion.target = Damage.target
                    Evasion.damage = damage

                    for i = 1, #event do
                        event[i]()
                    end
                    
                    BlzSetEventDamage(0)
                    BlzSetEventWeaponType(WEAPON_TYPE_WHOKNOWS)
                    Text(Evasion.source.unit, "miss", 1.5, 255, 0, 0, 255)
                    
                    Evasion.damage = 0
                    Evasion.source = nil
                    Evasion.target = nil
                end
            end
        end)
    end)
    
    -- -------------------------------------------------------------------------- --
    --                                   LUA API                                  --
    -- -------------------------------------------------------------------------- --
    function RegisterEvasionEvent(code)
        if type(code) == "function" then
            table.insert(event, code)
        end
    end

    function GetMissingUnit()
        return Evasion.source.unit
    end

    function GetEvadingUnit()
        return Evasion.target.unit
    end

    function GetEvadedDamage()
        return Evasion.damage or 0
    end

    function GetUnitEvasionChance(unit)
        return Evasion.evasion[GetUnitUserData(unit)] or 0
    end

    function GetUnitMissChance(unit)
        return Evasion.miss[GetUnitUserData(unit)] or 0
    end

    function SetUnitEvasionChance(unit, real)
        Evasion.evasion[GetUnitUserData(unit)] = real
    end

    function SetUnitMissChance(unit, real)
        Evasion.miss[GetUnitUserData(unit)] = real
    end

    function UnitAddEvasionChance(unit, real)
        local i = GetUnitUserData(unit)
        
        if not Evasion.evasion[i] then Evasion.evasion[i] = 0 end
        Evasion.evasion[i] = Evasion.evasion[i] + real
    end

    function UnitAddMissChance(unit, real)
        local i = GetUnitUserData(unit)
        
        if not Evasion.miss[i] then Evasion.miss[i] = 0 end
        Evasion.miss[i] = Evasion.miss[i] + real
    end

    function MakeUnitNeverMiss(unit, flag)
        local i = GetUnitUserData(unit)
        
        if not Evasion.neverMiss[i] then Evasion.neverMiss[i] = 0 end
        if flag then
            Evasion.neverMiss[i] = Evasion.neverMiss[i] + 1
        else
            Evasion.neverMiss[i] = Evasion.neverMiss[i] - 1
        end
    end

    function DoUnitNeverMiss(unit)
        return Evasion.neverMiss[GetUnitUserData(unit)] > 0
    end
end