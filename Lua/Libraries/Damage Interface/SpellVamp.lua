--[[
    /* ------------------------ SpellVamp v2.3 by Chopinski ----------------------- */
     SpellVamp intends to introduce to warcraft a healing based on Spell damage, like
     in LoL or Dota 2.

     Whenever a unit deals Spell damage, and it has a value of spell vamp given by
     this system, it will heal based of this value and the damage amount.

     The formula for spell vamp is:
     heal = damage * lspell vamp
     fror spell vamp: 0.1 = 10%

     *SpellVamp requires DamageInterface. Do not use TriggerSleepAction() within triggers.

     The API:
         function SetUnitSpellVamp takes unit u, real amount returns nothing
             -> Set the Spell Vamp amount for a unit
    
         function GetUnitSpellVamp takes unit u returns real
             -> Returns the Spell Vamp amount of a unit
    
         function UnitAddSpellVamp takes unit u, real amount returns nothing
             -> Add to the Spell Vamp amount of a unit the given amount
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    SpellVamp = {}
    
    onInit(function()
        RegisterSpellDamageEvent(function()
            local damage = GetEventDamage()
        
            if damage > 0 and (SpellVamp[Damage.source.id] or 0) > 0 and not Damage.target.isStructure then
                SetWidgetLife(Damage.source.unit, (GetWidgetLife(Damage.source.unit) + (damage * (SpellVamp[Damage.source.id] or 0))))
            end
        end)
    end)
    
    -- -------------------------------------------------------------------------- --
    --                                   LUA API                                  --
    -- -------------------------------------------------------------------------- --
    function SetUnitSpellVamp(unit, real)
        SpellVamp[GetUnitUserData(unit)] = real
    end

    function GetUnitSpellVamp(unit)
        return SpellVamp[GetUnitUserData(unit)] or 0
    end

    function UnitAddSpellVamp(unit, real)
        local i = GetUnitUserData(unit)
        
        if not SpellVamp[i] then SpellVamp[i] = 0 end
        SpellVamp[i] = SpellVamp[i] + real
    end
end