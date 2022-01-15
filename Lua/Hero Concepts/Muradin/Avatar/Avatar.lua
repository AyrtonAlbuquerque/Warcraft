--[[ requires SpellEffectEvent, NewBonusUtils
    /* ------------------------ Avatar v1.2 by Chopinski ------------------------ */
    // Credits:
    //     Blizzard       - Icon
    //     Bribe          - SpellEffectEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Avatar ability
    Avatar_ABILITY = FourCC('A008')
    -- The raw code of the Avatar buff
    Avatar_BUFF    = FourCC('BHav')

    -- The Health Bonus
    local function GetBonusHealth(level)
        return 500 + 500*level
    end

    -- The Damage Bonus
    local function GetBonusDamage(level)
        return 50*level
    end

    -- The Armor Bonus
    local function GetBonusArmor(level)
        return 10*level
    end
    
    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    Avatar = setmetatable({}, {})
    local mt = getmetatable(Avatar)
    mt.__index = mt
    
    onInit(function()
        RegisterSpellEffectEvent(Avatar_ABILITY, function()
            LinkBonusToBuff(Spell.source.unit, BONUS_HEALTH, GetBonusHealth(Spell.level), Avatar_BUFF)
            LinkBonusToBuff(Spell.source.unit, BONUS_DAMAGE, GetBonusDamage(Spell.level), Avatar_BUFF)
            LinkBonusToBuff(Spell.source.unit, BONUS_ARMOR, GetBonusArmor(Spell.level), Avatar_BUFF)
        end)
    end)
end