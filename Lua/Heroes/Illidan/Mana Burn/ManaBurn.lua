--[[ requires DamageInterface, RegisterPlayerUnitEvent, Utilities
    /* ----------------------- Mana Burn v1.2 by Chopinski ---------------------- */
    // Credits:
    //     Magtheridon96  - RegisterPlayerUnitEvent
    //     BETABABY       - Icon
    //     Mythic         - Mana Burn Special Effect
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Mana Burn Ability
    ManaBurn_ABILITY      = S2A('A007')
    -- The raw code of the Illidan unit in the editor
    local ILLIDAN_ID      = S2A('E000')
    -- The raw code of the Dark Illidan unit in the editor
    local DARK_ILLIDAN_ID = S2A('E001')
    -- The GAIN_AT_LEVEL is greater than 0
    -- illidan will gain Mana Burn at this level 
    local GAIN_AT_LEVEL   = 20
    -- The Mana Burn model
    local MODEL           = "Abilities\\Spells\\Human\\Feedback\\SpellBreakerAttack.mdl"
    -- The Mana Burn bonus model
    local BONUS_MODEL     = "ManaBurn.mdl"
    -- The Mana Burn attachment point
    local ATTACH_POINT    = "origin"

    -- The amount of mana burned in each attack
    local function GetManaBurned(level)
        return 50. + 0.*level
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    ManaBurn = setmetatable({}, {})
    local mt = getmetatable(ManaBurn)
    mt.__index = mt
    
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function()
            if GAIN_AT_LEVEL > 0 then
                local unit = GetTriggerUnit()
                if (GetUnitTypeId(unit) == ILLIDAN_ID or GetUnitTypeId(unit) == DARK_ILLIDAN_ID) and GetHeroLevel(unit) == GAIN_AT_LEVEL then
                    UnitAddAbility(unit, ManaBurn_ABILITY)
                    UnitMakeAbilityPermanent(unit, true, ManaBurn_ABILITY)
                end
            end
        end)
        
        RegisterAttackDamageEvent(function()
            local level = GetUnitAbilityLevel(Damage.source.unit, ManaBurn_ABILITY)

            if Damage.isEnemy and not Damage.target.isMagicImmune and level > 0 and BlzGetUnitMaxMana(Damage.target.unit) > 0 then
                local mana = GetUnitState(Damage.target.unit, UNIT_STATE_MANA)
                local burn = GetManaBurned(level)

                if burn > mana then
                    burn = mana
                end

                AddUnitMana(Damage.target.unit, -burn)
                if GetUnitManaPercent(Damage.target.unit) < 40 then
                    DestroyEffect(AddSpecialEffectTarget(BONUS_MODEL, Damage.target.unit, ATTACH_POINT))
                    UnitDamageTarget(Damage.source.unit, Damage.target.unit, burn, false, false, ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, nil)
                else
                    DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.target.unit, ATTACH_POINT))
                    UnitDamageTarget(Damage.source.unit, Damage.target.unit, burn, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                end
            end
        end)
    end)
end