--[[ requires SpellEffectEvent, Missiles, MouseUtils, DamageInterface, Utilities
    /* -------------------- Odin Annihilate v1.2 by Chopinski ------------------- */
    // Credits:
    //     a-ravlik        - Icon
    //     Bribe           - SpellEffectEvent
    //     MyPad           - MouseUtils
    //     Mythic          - Interceptor Shell model
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Odin Incinerate ability
    OdinIncinerate_ABILITY = FourCC('A009')
    -- The raw code of the Incinerate ability
    local FLAMES  = FourCC('A00A')
    -- The Missile model
    local MODEL   = "Interceptor Shell.mdl"
    -- The Missile scale
    local SCALE   = 0.6
    -- The Missile speed
    local SPEED   = 1000.
    -- The Missile arc
    local ARC     = 45.
    -- The Missile height offset
    local HEIGHT  = 200.
    -- The time the player has to move the mouse before the spell starts
    local DRAG_AND_DROP_TIME  = 0.05

    -- The distance between rocket explosions that create the flames. Recommended about 50% of the size of the flame strike aoe.
    local function GetOffset(level)
        return 100. +0*level
    end

    -- The explosion damage
    local function GetDamage(level)
        return 50.*level
    end

    -- The explosion aoe
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, OdinIncinerate_ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The incineration damage per interval
    local function GetIncinerationDamage(level)
        return 12.5*level
    end

    -- The incineration AoE
    local function GetIncinerationAoE(unit, level)
        return GetAoE(unit, level)
    end

    -- The incineration damage interval
    local function GetIncinerationInterval(level)
        return 1. + 0.*level
    end

    -- The the incineration duration
    local function GetIncinerationDuration(level)
        return 5. + 0.*level
    end

    -- The numebr of rockets.
    local function GetRocketCount(level)
        return 3 + 2*level
    end

    -- The interval at which rockets are spawnned.
    local function GetInterval(level)
        return 0.2 + 0.*level
    end

    -- The Damage Filter.
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    do
        Incineration = setmetatable({}, {})
        local mt = getmetatable(Incineration)
        mt.__index = mt
        
        local proxy = {}
        
        function mt:create(x, y, damage, duration, aoe, interval, source)
            local timer = CreateTimer()
            local unit = DummyRetrieve(GetOwningPlayer(source), x, y, 0, 0)
            local this = {}
            
            this.unit = source
            this.damage = damage
            proxy[unit] = this

            UnitAddAbility(unit, FLAMES)
            local ability = BlzGetUnitAbility(unit, FLAMES)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_DURATION_NORMAL, 0, duration)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_FULL_DAMAGE_INTERVAL, 0, duration)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_HALF_DAMAGE_INTERVAL, 0, interval)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_AREA_OF_EFFECT, 0, aoe)
            BlzSetAbilityRealLevelField(ability, ABILITY_RLF_HALF_DAMAGE_DEALT, 0, damage)
            IncUnitAbilityLevel(unit, FLAMES)
            DecUnitAbilityLevel(unit, FLAMES)
            IssuePointOrder(unit, "flamestrike", x, y)
            TimerStart(timer, duration + 0.05, false, function()
                this = nil
                proxy[unit] = nil
                UnitRemoveAbility(unit, FLAMES)
                DummyRecycle(unit)
                PauseTimer(timer)
                DestroyTimer(timer)
            end)
        end
        
        onInit(function()
            RegisterSpellDamageEvent(function()
                if proxy[Damage.source.unit] and GetEventDamage() > 0 then
                    local this = proxy[Damage.source.unit]
                    BlzSetEventDamage(0)
                    UnitDamageTarget(this.unit, Damage.target.unit, this.damage, false, false, Damage.attacktype, Damage.damagetype, nil)
                end
            end)
        end)
    end
    
    OdinIncinerate = setmetatable({}, {})
    local mt = getmetatable(OdinIncinerate)
    mt.__index = mt
    
    onInit(function()
        RegisterSpellEffectEvent(OdinIncinerate_ABILITY, function()
            local timer = CreateTimer()
            local unit = Spell.source.unit
            local level = Spell.level
            local player = Spell.source.player
            local x = Spell.x
            local y = Spell.y
            local i = 0
            local count = GetRocketCount(Spell.level)
            local offset = GetOffset(Spell.level)
            local damage = GetDamage(Spell.level)
            local aoe = GetAoE(Spell.source.unit, Spell.level)
            local iAoE = GetIncinerationAoE(Spell.source.unit, Spell.level)
            local iDamage = GetIncinerationDamage(Spell.level)
            local iInterval = GetIncinerationInterval(Spell.level)
            local iDuration = GetIncinerationDuration(Spell.level)

            TimerStart(timer, DRAG_AND_DROP_TIME, false, function()
                local angle = AngleBetweenCoordinates(x, y, GetPlayerMouseX(player), GetPlayerMouseY(player))
                TimerStart(timer, GetInterval(level), true, function()
                    if i < count then
                        local this = Missiles:create(GetUnitX(unit), GetUnitY(unit), HEIGHT, x + offset*i*Cos(angle), y + offset*i*Sin(angle), 50)
                        
                        this:model(MODEL)
                        this:scale(SCALE)
                        this:speed(SPEED)
                        this:arc(ARC)
                        this.source = unit
                        this.owner = player
                        this.damage = damage
                        this.aoe = aoe
                        this.group = CreateGroup()

                        this.onFinish = function()
                            Incineration:create(this.x, this.y, iDamage, iDuration, iAoE, iInterval, this.source)
                            DestroyEffect(AddSpecialEffect(MODEL, this.x, this.y))
                            GroupEnumUnitsInRange(this.group, this.x, this.y, this.aoe, nil)
                            for j = 0, BlzGroupGetSize(this.group) - 1 do
                                local u = BlzGroupUnitAt(this.group, j)
                                if DamageFilter(this.owner, u) then
                                    UnitDamageTarget(this.source, u, this.damage, true, true, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                                end
                            end
                            DestroyGroup(this.group)

                            return true
                        end

                        this:launch()
                    else
                        PauseTimer(timer)
                        DestroyTimer(timer)
                    end
                    i = i + 1
                end)
            end)
        end)
    end)
end