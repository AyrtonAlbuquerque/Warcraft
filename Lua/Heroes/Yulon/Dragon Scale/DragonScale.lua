--[[ requires RegisterPlayerUnitEvent, DamageInterface
    /* --------------------- Dragon Scale v1.1 by Chopinski --------------------- */
    // Credits:
    //     Arowanna        - Icon
    //     Magtheridon96   - RegisterPlayerUnitEvent
    //     AZ              - Model
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY        = FourCC('A000')
    -- The model
    local MODEL          = "GreenFlare.mdl"
    -- The attachment point
    local ATTACH_POINT   = "origin"

    -- The maximum bonus damage per level
    local function GetBonus(level)
        return 50.*level
    end

    -- The damage reduction per level
    local function GetDamageReduction(level)
        return 0.2 + 0.*level
    end

    -- The Dragon Scale level up base on hero level
    local function GetLevel(level)
        return level == 5 or level == 10 or level == 15
    end
    
    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    local energy = {}
    
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_HERO_LEVEL, function()
            local unit = GetTriggerUnit()

            if GetLevel(GetHeroLevel(unit)) then
                IncUnitAbilityLevel(unit, ABILITY)
            end
        end)
        
        RegisterAnyDamageEvent(function()
            local damage = GetEventDamage()
            local level = GetUnitAbilityLevel(Damage.target.unit, ABILITY)

            if damage > 0 and level > 0 and Damage.isEnemy then
                local amount = damage*GetDamageReduction(level)
                damage = damage - amount
                energy[Damage.target.unit] = (energy[Damage.target.unit] or 0) + amount 
                
                BlzSetEventDamage(damage)
            end
        end)
        
        RegisterSpellDamageEvent(function()
            local damage = GetEventDamage()
            local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if damage > 0 and level > 0 and Damage.isEnemy and (energy[Damage.source.unit] or 0) > 0 then
                local amount = GetBonus(level)
                
                if amount >= energy[Damage.source.unit] then
                    amount = energy[Damage.source.unit]
                end
                
                damage = damage + amount
                energy[Damage.source.unit] = energy[Damage.source.unit] - amount
                
                DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.target.unit, ATTACH_POINT))
                BlzSetEventDamage(damage)
            end
        end)
    end)
end
