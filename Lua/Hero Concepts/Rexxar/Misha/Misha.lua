--[[ requires RegisterPlayerUnitEvent, SpellEffectEvent, PluginSpellEffect, NewBonus, TimerUtils
    /* ------------------------- Misha v1.0 by Chopinski ------------------------ */
    // Credits:
    //     Blizzard        - Icon
    //     Bribe           - SpellEffectEvent
    //     Vexorian        - TimerUtils
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY = FourCC('A000')
    -- The raw code of the Misha unit
    Misha_MISHA = FourCC('n000')

    -- The Misha Max Health
    local function GetMishaHealth(unit, level)
        return 1500 + 500 * level + R2I(BlzGetUnitMaxHP(unit) * 0.125 * level)
    end

    -- The Misha Damage
    local function GetMishaDamage(unit, level)
        return 25 + 25 * level + R2I(GetUnitBonus(unit, BONUS_DAMAGE) * 0.5)
    end

    -- The Misha Armor
    local function GetMishaArmor(unit, level)
        return 1. + 1. * level + GetUnitBonus(unit, BONUS_DAMAGE) * 0.1 * level
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    Misha = setmetatable({}, {})
    local mt = getmetatable(Misha)
    mt.__index = mt

    Misha.group = {}
    Misha.owner = {}

    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function()
            local unit = GetTriggerUnit()
            local id = Misha.owner[unit]

            if id ~= nil then
                Misha.owner[unit] = nil
                GroupRemoveUnit(Misha.group[id], unit)
            end
        end)

        RegisterSpellEffectEvent(ABILITY, function()
            local timer = CreateTimer()
            local unit = Spell.source.unit
            local level = Spell.level
            local player = Spell.source.player

            TimerStart(timer, 0, false, function()
                local group = CreateGroup()

                if Misha.group[unit] == nil then
                    Misha.group[unit] = CreateGroup()
                end

                GroupClear(Misha.group[unit])
                GroupEnumUnitsOfPlayer(group, player, nil)
                for i = 0, BlzGroupGetSize(group) - 1 do
                    local u = BlzGroupUnitAt(group, i)
                    if UnitAlive(u) and GetUnitTypeId(u) == Misha_MISHA then
                        Misha.owner[u] = unit
                        GroupAddUnit(Misha.group[unit], u)
                        local real = GetUnitLifePercent(u)
                        BlzSetUnitMaxHP(u, GetMishaHealth(unit, level))
                        SetUnitLifePercentBJ(u, real)
                        BlzSetUnitBaseDamage(u, GetMishaDamage(unit, level), 0)
                        BlzSetUnitArmor(u, GetMishaArmor(unit, level))
                    end
                end
                DestroyGroup(group)
                PauseTimer(timer)
                DestroyTimer(timer)
            end)
        end)
    end)
end