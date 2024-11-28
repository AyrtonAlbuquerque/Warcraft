--[[ requires SpellEffectEvent, Missiles
    /* -------------------- Odin Annihilate v1.2 by Chopinski ------------------- */
    // Credits:
    //     a-ravlik        - Icon
    //     Bribe           - SpellEffectEvent
    //     Mythic          - Interceptor Shell model
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Odin Annihilate ability
    OdinAnnihilate_ABILITY = FourCC('A008')
    -- The Missile model
    local MODEL   = "Interceptor Shell.mdl"
    -- The Missile scale
    local SCALE   = 0.6
    -- The Missile speed
    local SPEED   = 1000.
    -- The Missile height offset
    local HEIGHT  = 200.

    -- The Explosion AoE
    local function GetAoE(level)
        return 200. + 0.*level
    end

    -- The max aoe at which rockets can strike, by default the ability aoe field
    local function GetMaxAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, OdinAnnihilate_ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The explosion damage
    local function GetDamage(level)
        return 50.*level
    end

    -- The numebr of rockets.
    local function GetRocketCount(level)
        return 10 + 5*level
    end

    -- The interval at which rockets are spawnned.
    local function GetInterval(level)
        return 0.2 + 0.*level
    end

    -- The rocket missile arc.
    local function GetArc(level)
        return GetRandomReal(30, 60)
    end

    -- The rocket missile curve.
    local function GetCurve(level)
        return GetRandomReal(-20, 20)
    end

    -- The Damage Filter.
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    OdinAnnihilate = setmetatable({}, {})
    local mt = getmetatable(OdinAnnihilate)
    mt.__index = mt
    
    onInit(function()
        RegisterSpellEffectEvent(OdinAnnihilate_ABILITY, function()
            local timer = CreateTimer()
            local unit = Spell.source.unit
            local level = Spell.level
            local player = Spell.source.player
            local x = Spell.x
            local y = Spell.y
            local aoe = GetMaxAoE(Spell.source.unit, Spell.level)
            local count = GetRocketCount(Spell.level)

            TimerStart(timer, GetInterval(Spell.level), true, function()
                if count > 0 then
                    local range = GetRandomRange(aoe)
                    local this = Missiles:create(GetUnitX(unit), GetUnitY(unit), HEIGHT, GetRandomCoordInRange(x, range, true), GetRandomCoordInRange(y, range, false), 50)
                    
                    this:model(MODEL)
                    this:scale(SCALE)
                    this:speed(SPEED)
                    this:arc(GetArc(level))
                    this:curve(GetCurve(level))
                    this.source = unit
                    this.owner = player
                    this.damage = GetDamage(level)
                    this.aoe = GetAoE(level)
                    this.group = CreateGroup()

                    this.onFinish = function()
                        DestroyEffect(AddSpecialEffect(MODEL, this.x, this.y))
                        GroupEnumUnitsInRange(this.group, this.x, this.y, this.aoe, nil)
                        for i = 0, BlzGroupGetSize(this.group) - 1 do
                            local unit = BlzGroupUnitAt(this.group, i)
                            if DamageFilter(this.owner, unit) then
                                UnitDamageTarget(this.source, unit, this.damage, true, true, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
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
                count = count - 1
            end)
        end)
    end)
end