--[[ requires RegisterPlayerUnitEvent, NewBonus
    /* -------------------- Adaptive Strike v1.2 by Chopinski ------------------- */
    // Credits:
    //     Blizzard        - Icon
    //     Magtheridon96   - RegisterPlayerUnitEvent
    //     Mythic          - Culling Slash and Cleave Effects
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Adaptive Strike ability
    local ABILITY = FourCC('A003')
    -- The Adaptive Strike Slash model
    local SLASH   = "Culling Slash.mdl"
    -- The Adaptive Strike Cleave model
    local CLEAVE  = "Culling Cleave.mdl"

    -- The Adaptive Strike proc chance
    local function GetChance(level)
        return GetRandomInt(level, 4) <= level
    end

    -- The Adaptive Strike damage
    local function GetDamage(unit, level)
        return 50*level + GetUnitBonus(unit, BONUS_DAMAGE)*0.5
    end

    -- The Adaptive Strike AoE
    local function GetAoE(slash, level)
        if slash then
            return 250. + 0.*level
        else
            return 250. + 0.*level
        end
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    local state = {}
    
    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function()
            local unit = GetAttacker()
            local level = GetUnitAbilityLevel(unit, ABILITY)
        
            if level > 0 and IsUnitType(unit, UNIT_TYPE_MELEE_ATTACKER) and GetChance(level) then
                state[unit] = GetRandomInt(1, 2)
                if state[unit] == 1 then
                    SetUnitAnimationByIndex(unit, 4)
                    QueueUnitAnimation(unit, "Stand Ready")
                    DestroyEffect(AddSpecialEffectTarget(CLEAVE, unit, "origin"))
                else
                    SetUnitAnimationByIndex(unit, 5)
                    QueueUnitAnimation(unit, "Stand Ready")
                    DestroyEffect(AddSpecialEffectTarget(SLASH, unit, "origin"))
                end
            end
        end)
        
        RegisterAttackDamageEvent(function()
            if state[Damage.source.unit] then
                local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)
                if state[Damage.source.unit] == 1 then
                    UnitDamageCone(Damage.source.unit, Damage.source.x, Damage.source.y, GetUnitFacing(Damage.source.unit), 150, GetAoE(false, level), GetDamage(Damage.source.unit, level), ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, false, true, false)
                else
                    UnitDamageArea(Damage.source.unit, Damage.source.x, Damage.source.y, GetAoE(true, level), GetDamage(Damage.source.unit, level), ATTACK_TYPE_HERO, DAMAGE_TYPE_UNIVERSAL, false, true, false)
                end
                state[Damage.source.unit] = nil
            end
        end)
    end)
end