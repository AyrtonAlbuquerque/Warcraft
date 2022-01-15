--[[ requires DamageInterface, RegisterPlayerUnitEvent, Utilities
    /* ---------------------- Afterburner v1.5 by Chopinski --------------------- */
    // Credits:
    //     PrinceYaser      - icon.
    //     Magtheridon96    - RegisterPlayerUnitEvent
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Afternurner Ability
    local ABILITY         = FourCC('A003')
    -- The raw code of the Afternurner Prox Ability
    local AFTERBURN_PROXY = FourCC('A007')
    -- The Attack type of the damage dealt (Spell)
    local ATTACK_TYPE     = ATTACK_TYPE_NORMAL
    -- The Damage type of the damage dealt
    local DAMAGE_TYPE     = DAMAGE_TYPE_MAGIC

    -- function responsible to determine the duration of the Afterburn
    -- By default, it uses the Cooldown value in the Object Editor
    local function GetDuration(unit)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_DURATION_NORMAL, GetUnitAbilityLevel(unit, ABILITY) - 1)
    end

    -- function responsible to determine the AoE of the Afterburn
    -- By default, it uses the AoE value in the Object Editor
    local function GetAoE(unit)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, GetUnitAbilityLevel(unit, ABILITY) - 1)
    end

    -- The damage per interval of the Afterburn
    local function GetDamage(unit)
        return 25.*GetUnitAbilityLevel(unit, ABILITY)
    end

    -- The damage interval of the Afterburn
    local function GetDamageInterval(unit)
        return 1.
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    Afterburner = setmetatable({}, {})
    local mt = getmetatable(Afterburner)
    mt.__index = mt
    
    local proxy = {}
    
    function mt:create(x, y, damage, duration, aoe, interval, source)
        local this = {}
        local timer = CreateTimer()
        local unit = DummyRetrieve(GetOwningPlayer(source), x, y, 0, 0)
        local ability

        this.unit = source
        this.damage = damage
        proxy[unit] = this

        UnitAddAbility(unit, AFTERBURN_PROXY)
        ability = BlzGetUnitAbility(unit, AFTERBURN_PROXY)
        BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_NORMAL, 0, duration)
        BlzSetAbilityRealLevelField(ability, ABILITY_RLF_FULL_DAMAGE_INTERVAL, 0, duration)
        BlzSetAbilityRealLevelField(ability, ABILITY_RLF_HALF_DAMAGE_INTERVAL, 0, interval)
        BlzSetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, 0, aoe)
        BlzSetAbilityRealLevelField(ability, ABILITY_RLF_HALF_DAMAGE_DEALT, 0, damage)
        IncUnitAbilityLevel(unit, AFTERBURN_PROXY)
        DecUnitAbilityLevel(unit, AFTERBURN_PROXY)
        IssuePointOrder(unit, "flamestrike", x, y)
        TimerStart(timer, duration + 0.05, false, function()
            this = nil
            proxy[unit] = nil
            DummyRecycle(unit)
            PauseTimer(timer)
            DestroyTimer(timer)
        end)
    end
    
    onInit(function()
        RegisterSpellDamageEvent(function()
            local this
        
            if proxy[Damage.source.unit] and GetEventDamage() > 0 then
                this = proxy[Damage.source.unit]
                BlzSetEventDamage(0)
                UnitDamageTarget(this.unit, Damage.target.unit, this.damage, false, false, ATTACK_TYPE, DAMAGE_TYPE, nil)
            end
            
        end)
    end)
    
    function Afterburn(x, y, unit)
        if GetUnitAbilityLevel(unit, ABILITY) > 0 then
            Afterburner:create(x, y, GetDamage(unit), GetDuration(unit), GetAoE(unit), GetDamageInterval(unit), unit)
        end
    end
end