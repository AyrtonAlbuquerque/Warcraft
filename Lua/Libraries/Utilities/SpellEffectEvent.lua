--[[
    /* ------------------- SpellEffectEvent v1.1 by Chopinski ------------------ */
    -- Full credits to Bribe for the original library. I just modified it to store
    -- some usefull information in a table to be used later instead of calling
    -- these functions all the time for every ability.
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    local funcs = {}
    local trigger = nil
    local location = Location(0, 0)
    
    Spell = {
        source = {
            unit,
            player,
            handle,
            isHero,
            isStructure,
            id,
            x,
            y,
            z
        },
        target = {
            unit,
            player,
            handle,
            isHero,
            isStructure,
            id,
            x,
            y,
            z
        },
        ability,
        level,
        id,
        x,
        y,
        z
    }
   
    local function GetUnitZ(unit)
        MoveLocation(location, GetUnitX(unit), GetUnitY(unit))
        return GetUnitFlyHeight(unit) + GetLocationZ(location)
    end
    
    local function GetSpellTargetZ()
        MoveLocation(location, Spell.x, Spell.y)
        if Spell.target.unit then
            return GetUnitZ(Spell.target.unit)
        else
            return GetLocationZ(location)
        end
    end
   
    function RegisterSpellEffectEvent(ability, code)
        if type(code) == "function" then
            if not trigger then
                trigger = CreateTrigger()
                TriggerRegisterAnyUnitEventBJ(trigger, EVENT_PLAYER_UNIT_SPELL_EFFECT)
                TriggerAddCondition(trigger, Condition(function()
                    local f = funcs[GetSpellAbilityId()]
                    
                    if f then
                        if GetUnitAbilityLevel(GetTriggerUnit(), FourCC('Aloc')) == 0 then
                            Spell.source.unit   = GetTriggerUnit()
                            Spell.source.player = GetOwningPlayer(Spell.source.unit)
                            Spell.source.handle = GetHandleId(Spell.source.unit)
                            Spell.source.id     = GetUnitUserData(Spell.source.unit)
                            Spell.source.x      = GetUnitX(Spell.source.unit)
                            Spell.source.y      = GetUnitY(Spell.source.unit)
                            Spell.source.z      = GetUnitZ(Spell.source.unit)
                            Spell.source.isHero = IsUnitType(Spell.source.unit, UNIT_TYPE_HERO)
                            Spell.source.isStructure = IsUnitType(Spell.source.unit, UNIT_TYPE_STRUCTURE)

                            Spell.target.unit   = GetSpellTargetUnit()
                            Spell.target.player = GetOwningPlayer(Spell.target.unit)
                            Spell.target.handle = GetHandleId(Spell.target.unit)
                            Spell.target.id     = GetUnitUserData(Spell.target.unit)
                            Spell.target.x      = GetUnitX(Spell.target.unit)
                            Spell.target.y      = GetUnitY(Spell.target.unit)
                            Spell.target.z      = GetUnitZ(Spell.target.unit)
                            Spell.target.isHero = IsUnitType(Spell.target.unit, UNIT_TYPE_HERO)
                            Spell.target.isStructure = IsUnitType(Spell.target.unit, UNIT_TYPE_STRUCTURE)

                            Spell.x             = GetSpellTargetX()
                            Spell.y             = GetSpellTargetY()
                            Spell.z             = GetSpellTargetZ()
                            Spell.id            = GetSpellAbilityId()
                            Spell.level         = GetUnitAbilityLevel(Spell.source.unit, Spell.id)
                            Spell.ability       = BlzGetUnitAbility(Spell.source.unit, Spell.id)
                        end
                        
                        f() 
                    end
                end))
            end
            funcs[ability] = code
        end
    end
end