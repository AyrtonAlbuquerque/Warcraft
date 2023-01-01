--[[ requires SpellEffectEvent, DamageInterface, Missiles, Utilities, optional ArsenalUpgrade
    /* ------------------- Automated Turrent v1.2 by Chipinski ------------------ */
    // Credits:
    //     NFWar        - Gun Fire Icon
    //     4eNNightmare - Rocket Flare Icon
    //     Bribe        - SpellEffectEvent
    //     Mythic       - Missile model
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the Automated Turrent ability
    AutomatedTurrent_ABILITY = FourCC('A002')
    -- The raw code of the Automated Turrent Missile ability
    local MISSILE = FourCC('A003')
    -- The raw code of the Automated Turrent unit
    local UNIT    = FourCC('o000')
    -- The Missile model
    local MODEL   = "Airstrike Rocket.mdl"
    -- The Missile scale
    local SCALE   = 0.5
    -- The Missile speed
    local SPEED   = 1000.

    -- The Automated Turrent duration
    local function GetDuration(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, AutomatedTurrent_ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
    end

    -- The Automated Turrent max hp
    local function GetMaxHealth(level, source)
        return R2I(100 + 100*level + BlzGetUnitMaxHP(source)*0.2)
    end

    -- The Automated Turrent base damage.
    local function GetUnitDamage(level, source)
        return R2I(5*level + GetUnitBonus(source, BONUS_DAMAGE)*0.2)
    end

    -- The number of Automated Turrents created
    local function GetAmount(level)
        return 1 + 0*level
    end

    -- The number of attacks necessary for a missile to be released
    local function GetAttackCount(unit, level)
        if ArsenalUpgrade then
            if GetUnitAbilityLevel(unit, ArsenalUpgrade_ABILITY) > 0 then
                return 18 - 2*level
            else
                return 22 - 2*level
            end
        else
            return 22 - 2*level
        end
    end

    -- The Missile max aoe for random location
    local function GetMaxAoE(level)
        return 150. + 0.*level
    end

    -- The Missile damage aoe
    local function GetAoE(level)
        return 150. + 0.*level
    end

    -- The Automated Turrent missile damage.
    local function GetDamage(level)
        return 25.*level
    end

    -- The Automated Turrent missile arc.
    local function GetArc(level)
        return GetRandomReal(0, 20)
    end

    -- The Automated Turrent missile curve.
    local function GetCurve(level)
        return GetRandomReal(-15, 15)
    end

    -- The Damage Filter.
    local function DamageFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    AutomatedTurrent = setmetatable({}, {})
    local mt = getmetatable(AutomatedTurrent)
    mt.__index = mt
    
    local array = {}
    
    onInit(function()
        RegisterSpellEffectEvent(AutomatedTurrent_ABILITY, function()
            for i = 0, GetAmount(Spell.level) - 1 do
                local unit = CreateUnit(Spell.source.player, UNIT, Spell.x, Spell.y, 0)
                
                array[unit] = 0
                SetUnitAbilityLevel(unit, MISSILE, Spell.level)
                BlzSetUnitBaseDamage(unit, GetUnitDamage(Spell.level, Spell.source.unit), 0)
                BlzSetUnitMaxHP(unit, GetMaxHealth(Spell.level, Spell.source.unit))
                SetUnitLifePercentBJ(unit, 100)
                UnitApplyTimedLife(unit, FourCC('BTLF'), GetDuration(Spell.source.unit, Spell.level))
            end
        end)

        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_DEATH, function()
            local unit = GetTriggerUnit()

            if GetUnitTypeId(unit) == UNIT then
                array[unit] = nil
            end
        end)

        RegisterAttackDamageEvent(function()
            local level = GetUnitAbilityLevel(Damage.source.unit, MISSILE)

            if level > 0 and Damage.isEnemy then
                array[Damage.source.unit] = (array[Damage.source.unit] or 0) + 1
                if array[Damage.source.unit] >= GetAttackCount(Damage.source.unit, level) then
                    local range = GetRandomRange(GetMaxAoE(level))
                    local this = Missiles:create(Damage.source.x, Damage.source.y, Damage.source.z + 80, GetRandomCoordInRange(Damage.target.x, range, true), GetRandomCoordInRange(Damage.target.y, range, false), 0)
                    
                    array[Damage.source.unit] = 0
                    
                    this:model(MODEL)
                    this:scale(SCALE)
                    this:speed(SPEED)
                    this:arc(GetArc(level))
                    this:curve(GetCurve(level))
                    this.source = Damage.source.unit
                    this.owner = Damage.source.player
                    this.damage = GetDamage(level)
                    this.group = CreateGroup()
                    this.aoe = GetAoE(level)

                    this.onFinish = function()
                        GroupEnumUnitsInRange(this.group, this.x, this.y, this.aoe, nil)
                        for i = 0, BlzGroupGetSize(this.group) - 1 do
                            local unit = BlzGroupUnitAt(this.group, i)
                            if DamageFilter(this.owner, unit) then
                                UnitDamageTarget(this.source, unit, this.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                            end
                        end
                        DestroyGroup(this.group)

                        return true
                    end

                    this:launch()
                end
            end
        end)
    end)
end