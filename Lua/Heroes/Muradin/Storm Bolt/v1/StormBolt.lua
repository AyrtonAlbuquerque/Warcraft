--[[ requires SpellEffectEvent, Missiles, Utilities, TimedHandles, CrowdControl optional Avatar
    -- --------------------------------------- Storm Bolt v1.4 -------------------------------------- --
    -- Credits:
    --     Blizzard       - Icon
    --     Bribe          - SpellEffectEvent
    --     TriggerHappy   - TimedHandles
    -- ---------------------------------------- By Chipinski ---------------------------------------- --
]]--

do
    -- ---------------------------------------------------------------------------------------------- --
    --                                          Configuration                                         --
    -- ---------------------------------------------------------------------------------------------- --
    -- The raw code of the Storm Bolt ability
    StormBolt_ABILITY            = FourCC('A001')
    -- The raw code of the Storm Bolt Double Thunder ability
    StormBolt_STORM_BOLT_RECAST  = FourCC('A002')
    -- The missile model
    local MISSILE_MODEL          = "Abilities\\Spells\\Human\\StormBolt\\StormBoltMissile.mdl"
    -- The missile size
    local MISSILE_SCALE          = 1.
    -- The missile speed
    local MISSILE_SPEED          = 1250.
    -- The model used when storm bolt deal bonus damage
    local BONUS_DAMAGE_MODEL     = "ShockHD.mdl"
    -- The model used when storm bolt refunds mana on kill
    local REFUND_MANA            = "Abilities\\Spells\\Items\\AIma\\AImaTarget.mdl"
    -- The attachment point of the bonus dmaage model
    local ATTACH_POINT           = "origin"
    -- The model used when storm bolt stuns a unit
    local STUN_MODEL             = "Abilities\\Spells\\Human\\Thunderclap\\ThunderclapTarget.mdl"
    -- The attachment point of the stun model
    local STUN_POINT             = "overhead"

    -- The storm bolt damage
    function StormBolt_GetDamage(level)
        return 150. + 50.*level
    end

    -- The storm bolt damage when the target is already stunned
    function StormBolt_GetBonusDamage(damage, level)
        return damage * (1. + 0.25*level)
    end

    -- The storm bolt stun duration
    local function GetDuration(source, target, level)
        if IsUnitType(target, UNIT_TYPE_HERO) then
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, StormBolt_ABILITY), ABILITY_RLF_DURATION_HERO, level - 1)
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(source, StormBolt_ABILITY), ABILITY_RLF_DURATION_NORMAL, level - 1)
        end
    end

    -- The storm bolt mana refunded
    function StormBolt_GetMana(unit, level)
        return BlzGetAbilityIntegerLevelField(BlzGetUnitAbility(unit, StormBolt_ABILITY), ABILITY_ILF_MANA_COST, level - 1)*0.5
    end

    -- ---------------------------------------------------------------------------------------------- --
    --                                             System                                             --
    -- ---------------------------------------------------------------------------------------------- --
    StormBolt = setmetatable({}, {})
    local mt = getmetatable(StormBolt)
    mt.__index = mt
    
    function mt:onCast(source, target, level)
        local this = Missiles:create(GetUnitX(source), GetUnitY(source), 60, GetUnitX(target), GetUnitY(target), 60)

        this.source = source
        this.target = target
        this:model(MISSILE_MODEL)
        this:speed(MISSILE_SPEED)
        this:scale(MISSILE_SCALE)
        this.damage = StormBolt_GetDamage(level)
        this.dur = GetDuration(source, target, level)
        this.mana = StormBolt_GetMana(source, level)
        this.level = level

        this.onFinish = function()
            if UnitAlive(this.target) then
                if IsUnitStunned(this.target) then
                    this.damage = StormBolt_GetBonusDamage(this.damage, this.level)
                    this.bonus  = true
                end

                if UnitDamageTarget(this.source, this.target, this.damage, true, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil) then
                    if this.bonus then
                        DestroyEffect(AddSpecialEffectTarget(BONUS_DAMAGE_MODEL, this.target, ATTACH_POINT))
                    end

                    if not UnitAlive(this.target) then
                        AddUnitMana(this.source, this.mana)
                        DestroyEffectTimed(AddSpecialEffectTarget(REFUND_MANA, this.source, ATTACH_POINT), 1.0)
                        if Avatar then
                            if GetUnitAbilityLevel(this.source, Avatar_BUFF) > 0 then
                                ResetUnitAbilityCooldown(this.source, StormBolt_ABILITY)
                            end
                        end
                    else
                        StunUnit(this.target, this.dur, STUN_MODEL, STUN_POINT, false)
                    end
                end
            end

            return true
        end
        
        this:launch()
    end
    
    onInit(function()
        RegisterSpellEffectEvent(StormBolt_ABILITY, function()
            StormBolt:onCast(Spell.source.unit, Spell.target.unit, Spell.level)
        end)
        RegisterSpellEffectEvent(StormBolt_STORM_BOLT_RECAST, function()
            StormBolt:onCast(Spell.source.unit, Spell.target.unit, GetUnitAbilityLevel(Spell.source.unit, StormBolt_ABILITY))
        end)
    end)
end