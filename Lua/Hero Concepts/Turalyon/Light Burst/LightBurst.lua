--[[ requires SpellEffectEvent, NewBonusUtils, Utilities, optional LightInfusion
    /* ---------------------- Light Burst v1.2 by Chopinski --------------------- */
    // Credits:
    //     Redeemer59         - Icon
    //     Bribe              - SpellEffectEvent
    //     AZ                 - Stomp and Misisle effect
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The Light Burst Ability
    local ABILITY      = FourCC('A004')
    -- The Light Burst Missile Model
    local MODEL        = "Light Burst.mdl"
    -- The Light Burst Missile Model scale
    local SCALE        = 1.5
    -- The Light Burst Missile Speed
    local SPEED        = 2000.
    -- The Light Burst Missile Height offset
    local HEIGHT       = 100.
    -- The Light Burst Stomp Model
    local STOMP        = "LightStomp.mdl"
    -- The Light Burst Stomp scale
    local STOMP_SCALE  = 0.55
    -- The Light Burst disarm Model
    local DISARM       = "Abilities\\Spells\\Other\\TalkToMe\\TalkToMe"
    -- The Light Burst disarm attach point
    local ATTACH       = "overhead"

    -- The Light Burst AoE
    local function GetAoE(unit, level)
        return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ABILITY), ABILITY_RLF_AREA_OF_EFFECT, level - 1)
    end

    -- The Light Burst Buff/Debuff duration
    local function GetDuration(level)
        return 5. + 0.*level
    end

    -- The Light Burst Slow amount
    local function GetSlow(level)
        return 0.1 + 0.1*level
    end

    -- The Light Burst Movement Speed bonus
    local function GetBonus(level)
        return 20 + 20*level
    end

    -- The Light Burst Damage
    local function GetDamage(level)
        return 50. + 50.*level
    end

    -- The Light Burst Damage Filter for enemy units
    local function DamageFilter(unit)
        return not IsUnitType(unit, UNIT_TYPE_STRUCTURE) and not IsUnitType(unit, UNIT_TYPE_MAGIC_IMMUNE)
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterSpellEffectEvent(ABILITY, function()
            local this = Missiles:create(Spell.source.x, Spell.source.y, HEIGHT, Spell.x, Spell.y, 0)

            this:model(MODEL)
            this:scale(SCALE)
            this:speed(SPEED)
            this.source = Spell.source.unit 
            this.owner = Spell.source.player
            this.damage = GetDamage(Spell.level)
            this.aoe = GetAoE(Spell.source.unit, Spell.level)
            this.dur = GetDuration(Spell.level)
            this.slow = GetSlow(Spell.level)

            if LightInfusion then
                if (LightInfusion.charges[Spell.source.unit] or 0) > 0 then
                    this.infused = true
                    this.bonus = GetBonus(Spell.level)
                    LightInfusion:consume(Spell.source.unit)
                end
            end

            this.onFinish = function()
                local group = CreateGroup()

                DestroyEffect(AddSpecialEffectEx(STOMP, this.x, this.y, 0, STOMP_SCALE))
                GroupEnumUnitsInRange(group, this.x, this.y, this.aoe, nil)
                for i = 0, BlzGroupGetSize(group) - 1 do
                    local unit = BlzGroupUnitAt(group, i)
                    if UnitAlive(unit) then
                        if IsUnitEnemy(unit, this.owner) then
                            if DamageFilter(unit) then
                                UnitDamageTarget(this.source, unit, this.damage, false, false, ATTACK_TYPE_NORMAL, DAMAGE_TYPE_MAGIC, nil)
                                SlowUnit(unit, this.slow, this.dur)

                                if this.infused then
                                    DisarmUnitTimed(unit, this.dur)
                                    DestroyEffectTimed(AddSpecialEffectTarget(DISARM, unit, ATTACH), this.dur)
                                end
                            end
                        else
                            if this.infused then
                                AddUnitBonusTimed(unit, BONUS_MOVEMENT_SPEED, this.bonus, this.dur)
                            end
                        end
                    end
                end
                DestroyGroup(group)

                return true
            end

            this:launch()
        end)
    end)
end