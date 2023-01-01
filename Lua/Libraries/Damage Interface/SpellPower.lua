--[[
    /* ------------------------ SpellPower 2.4 by Chopinski ----------------------- */
     SpellPower intends to simulate a system similiar to Ability Power from LoL or
     Spell Amplification from Dota 2.

     Whenever a units deals Spell damage, that dealt damage will be amplified by a flat
     and percentile amount that represents a unit spell power bonus.

     The formula for amplification is: 
     final damage = (initial damage + flat bonus) * (1 + percent bonus)
     for percent bonus: 0.1 = 10% bonus

     *SpellPower requires DamageInterface. Do not use TriggerSleepAction() within triggers.

     The API:
         function GetUnitSpellPowerFlat takes unit u returns real
             -> Returns the Flat bonus of spell power of a unit

         function GetUnitSpellPowerPercent takes unit u returns real
             -> Returns the Percent bonus of spell power of a unit

         function SetUnitSpellPowerFlat takes unit u, real value returns nothing
             -> Set the Flat amount of Spell Power of a unit

         function SetUnitSpellPowerPercent takes unit u, real value returns nothing
             -> Set the Flat amount of Spell Power of a unit

         function UnitAddSpellPowerFlat takes unit u, real amount returns nothing
             -> Add to the Flat amount of Spell Power of a unit

         function UnitAddSpellPowerPercent takes unit u, real amount returns nothing
             -> Add to the Percent amount of Spell Power of a unit

         function GetSpellDamage takes real amount, unit u returns real
             -> Returns the amount of spell damage that would be dealt given an initial damage
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    SpellPower = {
        flat = {},
        percent = {}
    }
    
    onInit(function()
        RegisterSpellDamageEvent(function()
            local damage = GetEventDamage()
            
            if damage > 0 then
                BlzSetEventDamage((damage + (SpellPower.flat[Damage.source.unit] or 0))*(1 + (SpellPower.percent[Damage.source.unit] or 0)))
            end
        end)
    end)
    
    -- -------------------------------------------------------------------------- --
    --                                   LUA API                                  --
    -- -------------------------------------------------------------------------- --
    function GetUnitSpellPowerFlat(unit)
        return SpellPower.flat[unit] or 0
    end

    function GetUnitSpellPowerPercent(unit)
        return SpellPower.percent[unit] or 0
    end

    function SetUnitSpellPowerFlat(unit, real)
        SpellPower.flat[unit] = real
    end

    function SetUnitSpellPowerPercent(unit, real)
        SpellPower.percent[unit] = real
    end

    function UnitAddSpellPowerFlat(unit, real)
        if not SpellPower.flat[unit] then SpellPower.flat[unit] = 0 end
        SpellPower.flat[unit] = SpellPower.flat[unit] + real
    end

    function UnitAddSpellPowerPercent(unit, real)
        if not SpellPower.percent[unit] then SpellPower.percent[unit] = 0 end
        SpellPower.percent[unit] = SpellPower.percent[unit] + real
    end

    function GetSpellDamage(unit, real)
        return (real + (SpellPower.flat[unit] or 0))*(1 + (SpellPower.percent[unit] or 0))
    end
end