--[[ requires DamageInterface, SpellEffectEvent, Utilities, NewBonusUtils, CrowdControl
    -- ------------------------------------- Metamorphosis v1.3 ------------------------------------- --
    -- Credits:
    --     BLazeKraze      - Icon
    --     Bribe           - SpellEffectEvent
    --     Mythic          - Damnation Black model (edited by me)
    --     Henry           - Dark Illidan model from Warcraft Underground
    -- ---------------------------------------- By Chopinski ---------------------------------------- --
]]--

do
    -- ---------------------------------------------------------------------------------------------- --
    --                                          Configuration                                         --
    -- ---------------------------------------------------------------------------------------------- --
    -- The raw code of the Metamorphosis ability
    local ABILITY      = FourCC('A006')
    -- The raw code of the Metamorphosis buff
    Metamorphosis_BUFF = FourCC('BEme')
    -- The Metamorphosis lift off model
    local  MODEL       = "Damnation Black.mdl"
    -- The fear model
    local FEAR_MODEL   = "Fear.mdl"
    -- The the fear attachment point
    local ATTACH_FEAR  = "overhead"

    -- The Metamorphosis AoE for Fear effect
    local function GetAoE(level)
        return 400. + 0.*level
    end

    -- The Metamorphosis Fear Duration
    local function GetDuration(unit, level)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
            return 2. + 0.*level
        else
            return 5. + 0.*level
        end
    end

    -- The Metamorphosis Armor debuff Duration
    local function GetArmorDuration(unit, level)
        return 5. + 0.*level
    end

    -- The Metamorphosis Health Bonus
    local function GetBonusHealth(unit, level)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
            return 100*level
        else
            return 50*level
        end
    end

    -- The Metamorphosis Damage Bonus
    local function GetBonusDamage(unit, level)
        if IsUnitType(unit, UNIT_TYPE_HERO) then
            return 10*level
        else
            return 5*level
        end
    end

    -- Fear Filter
    local function FearFilter(player, unit)
        return UnitAlive(unit) and IsUnitEnemy(unit, player) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- ---------------------------------------------------------------------------------------------- --
    --                                             System                                             --
    -- ---------------------------------------------------------------------------------------------- --
    Metamorphosis = setmetatable({}, {})
    local mt = getmetatable(Metamorphosis)
    mt.__index = mt
    
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local timer = CreateTimer()
            local group = CreateGroup()
            local unit = Spell.source.unit
            local player = Spell.source.player
            local level = Spell.level

            TimerStart(timer, 0.5, false, function()
                local health = 0
                local damage = 0
            
                DestroyEffect(AddSpecialEffectEx(MODEL, GetUnitX(unit), GetUnitY(unit), GetUnitZ(unit), 2))
                GroupEnumUnitsInRange(group, GetUnitX(unit), GetUnitY(unit), GetAoE(level), nil)
                for i = 0, BlzGroupGetSize(group) - 1 do
                    local u = BlzGroupUnitAt(group, i)
                    if FearFilter(player, u) then
                        health = health + GetBonusHealth(u, level)
                        damage = damage + GetBonusDamage(u, level)
                        FearUnit(u, GetDuration(u, level), FEAR_MODEL, ATTACH_FEAR, false)
                    end
                end
                LinkBonusToBuff(unit, BONUS_HEALTH, health, Metamorphosis_BUFF)
                LinkBonusToBuff(unit, BONUS_DAMAGE, damage, Metamorphosis_BUFF)
                DestroyGroup(group)
                PauseTimer(timer)
                DestroyTimer(timer)
            end)
        end)
        
        RegisterAttackDamageEvent(function()
            if GetUnitAbilityLevel(Damage.source.unit, Metamorphosis_BUFF) > 0 then
                if Damage.isEnemy and not Damage.target.isMagicImmune then
                    AddUnitBonusTimed(Damage.target.unit, BONUS_ARMOR, -1, GetArmorDuration(Damage.target.unit, GetUnitAbilityLevel(Damage.source.unit, ABILITY)))
                end
            end
        end)
    end)
end