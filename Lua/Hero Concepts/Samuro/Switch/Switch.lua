--[[ requires SpellEffectEvent, MirrorImage
    /* ------------------------ Switch v1.3 by Chopinski ------------------------ */
    // Credits:
    //     Bribe          - SpellEffectEvent
    //     Vexorian       - TimerUtils
    //     CheckeredFlag  - Icon
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Switch ability
    Switch_ABILITY      = FourCC('A006')
    -- The raw code of the Samuro unit in the editor
    local SAMURO_ID     = FourCC('O000')
    -- The GAIN_AT_LEVEL is greater than 0
    -- Samuro will gain Switch at this level 
    local GAIN_AT_LEVEL = 20
    -- The switch effect
    local SWITCH_EFFECT = "Abilities\\Spells\\Orc\\MirrorImage\\MirrorImageCaster.mdl"

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    Switch = setmetatable({}, {})
    local mt = getmetatable(Switch)
    mt.__index = mt
    
    function mt:switch(source, target)
        local sFacing = GetUnitFacing(source)
        local tFacing = GetUnitFacing(target)
        local x = GetUnitX(source)
        local y = GetUnitY(source)
        local g1 = CreateGroup()
        local g2 = CreateGroup()

        PauseUnit(source, true)
        ShowUnit(source, false)
        DestroyEffect(AddSpecialEffect(SWITCH_EFFECT, x, y))
        GroupEnumUnitsOfPlayer(g1, GetOwningPlayer(source), nil)
        for i = 0, BlzGroupGetSize(g1) - 1 do
            local unit = BlzGroupUnitAt(g1, i)
            if GetUnitTypeId(unit) == GetUnitTypeId(source) and IsUnitIllusionEx(unit) then
                PauseUnit(unit, true)
                ShowUnit(unit, false)
                DestroyEffect(AddSpecialEffect(SWITCH_EFFECT, GetUnitX(unit), GetUnitY(unit)))
                GroupAddUnit(g2, unit)
            end
        end
        DestroyGroup(g1)
        SetUnitPosition(source, GetUnitX(target), GetUnitY(target))
        SetUnitFacing(source, tFacing)
        SetUnitPosition(target, x, y)
        SetUnitFacing(target, sFacing)

        return g2
    end
    
    onInit(function()
        RegisterSpellEffectEvent(Switch_ABILITY, function()
            if GetUnitTypeId(Spell.source.unit) == GetUnitTypeId(Spell.target.unit) and IsUnitIllusionEx(Spell.target.unit) then
                local timer = CreateTimer()
                local unit = Spell.source.unit
                local group = Switch:switch(Spell.source.unit, Spell.target.unit)

                TimerStart(timer, 0.25, false, function()
                    PauseUnit(unit, false)
                    ShowUnit(unit, true)
                    for i = 0, BlzGroupGetSize(group) - 1 do
                        local v = BlzGroupUnitAt(group, i)
                        PauseUnit(v, false)
                        ShowUnit(v, true)
                    end
                    DestroyGroup(group)
                    SelectUnitAddForPlayer(unit, GetOwningPlayer(unit))
                    PauseTimer(timer)
                    DestroyTimer(timer)
                end)
            end
        end)
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function()
            if GAIN_AT_LEVEL > 0 then
                local unit = GetTriggerUnit()
                if GetUnitTypeId(unit) == SAMURO_ID and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                    UnitAddAbility(unit, Switch_ABILITY)
                    UnitMakeAbilityPermanent(unit, true, Switch_ABILITY)
                end
            end
        end)
    end)
end