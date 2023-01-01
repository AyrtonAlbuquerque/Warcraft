--[[
    /* ------------------------ LifeSteal v2.4 by Chopinski ----------------------- */
     LifeSteal intends to simulate the Life Steal system in warcraft, and allow you
     to easily change the life steal amount of any unit.

     Whenever a unit deals Physical damage, and it has a value of life steal given by
     this system, it will heal based of this value and the damage amount.

     The formula for life steal is:
     heal = damage * life steal
     fror life steal: 0.1 = 10%

     *LifeSteal requires DamageInterface. Do not use TriggerSleepAction() within triggers.

     The API:
         function SetUnitLifeSteal takes unit u, real amount returns nothing
             -> Set the Life Steal amount for a unit

         function GetUnitLifeSteal takes unit u returns real
             -> Returns the Life Steal amount of a unit

         function UnitAddLifeSteal takes unit u, real amount returns nothing
             -> Add to the Life Steal amount of a unit the given amount
]]--
do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    local effect = "Abilities\\Spells\\Undead\\VampiricAura\\VampiricAuraTarget.mdl"

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    LifeSteal = {}
    
    onInit(function()
        RegisterAttackDamageEvent(function()
            local damage = GetEventDamage()
            
            if damage > 0 and (LifeSteal[Damage.source.unit] or 0) > 0 and not Damage.target.isStructure then
                SetWidgetLife(Damage.source.unit, (GetWidgetLife(Damage.source.unit) + (damage * (LifeSteal[Damage.source.unit] or 0))))
                DestroyEffect(AddSpecialEffectTarget(effect, Damage.source.unit, "origin"))
            end
        end)
    end)
    
    -- -------------------------------------------------------------------------- --
    --                                   LUA API                                  --
    -- -------------------------------------------------------------------------- --
    function SetUnitLifeSteal(unit, real)
        LifeSteal[unit] = real
    end

    function GetUnitLifeSteal(unit)
        return LifeSteal[unit] or 0
    end

    function UnitAddLifeSteal(unit, real)
        if not LifeSteal[unit] then LifeSteal[unit] = 0 end
        LifeSteal[unit] = LifeSteal[unit] + real
    end
end