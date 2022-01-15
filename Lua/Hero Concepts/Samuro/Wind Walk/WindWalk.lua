--[[ requires RegisterPlayerUnitEvent, SpellEffectEvent, NewBonusUtils, CriticalStrike
    /* ----------------------- Wind Walk v1.2 by Chopinski ---------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     Bribe          - SpellEffectEvent
    //     Anachron       - Icon
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Wind Walk ability
    WindWalk_ABILITY = FourCC('A001')
    -- The raw code of the Wind Walk buff
    local BUFF       = FourCC('BOwk')

    -- The health regeneration bonus
    local function GetRegenBonus(level)
        return 15. + 5.*level
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    WindWalk = setmetatable({}, {})
    local mt = getmetatable(WindWalk)
    mt.__index = mt
    
    local check = {}
    
    onInit(function()
        RegisterSpellEffectEvent(WindWalk_ABILITY, function()
            LinkBonusToBuff(Spell.source.unit, BONUS_HEALTH_REGEN, GetRegenBonus(Spell.level), BUFF)
        end)
        
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function()
            local unit = GetAttacker()
            local level = GetUnitAbilityLevel(unit, BUFF)

            if check[unit] and level == 0 then
                check[unit] = nil
                UnitAddCriticalStrike(unit, -100, -1)
            elseif not check[unit] and level > 0 then
                check[unit] = true
                UnitAddCriticalStrike(unit, 100, 1)
            end
        end)
        
        RegisterCriticalStrikeEvent(function()
            local unit = GetCriticalSource()

            if check[unit] then
                check[unit] = nil
                UnitAddCriticalStrike(unit, -100, -1)
            end
        end)
        
    end)
end