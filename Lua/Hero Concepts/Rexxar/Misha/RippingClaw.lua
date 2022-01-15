--[[ requires RegisterPlayerUnitEvent, DamageInterface, Utilities
    /* --------------------- Ripping Claws v1.0 by Chopinski -------------------- */
    // Credits:
    //     Nyx-Studio      - Icon
    //     Magtheridon96   - RegisterPlayerUnitEvent
    //     Vinz            - Reaper's claw effect
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY = FourCC('A008')
    -- The Claw effect
    local CLAW    = "Reaper's Claws Gold.mdl"
    -- The model scale
    local SCALE   = 1
    -- The effect height offset
    local HEIGHT  = 90

    -- The arc at which units are damaged
    local function GetArc(level)
        return 180. + 0.*level
    end

    -- The damage percentage transfered to nearby units (1 = 100%)
    local function GetDamagePercentage(level)
        return 1. + 0.*level
    end

    -- The AoE
    local function GetAoE(level)
        return 300. + 0.*level
    end

    -- The claw effect tilt for each attack sequence
    local function GetAngle(sequence)
        if sequence == 13 then
            return -45.
        else
            return -135.
        end
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    local sequence = {}

    onInit(function()
        RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, function()
            local unit = GetAttacker()
            local level = GetUnitAbilityLevel(unit, ABILITY)

            if level > 0 then
                if sequence[unit] == 13 then
                    SetUnitAnimationByIndex(unit, 13)
                    QueueUnitAnimation(unit, "Stand Ready")
                    local effect = AddSpecialEffectEx(CLAW, GetUnitX(unit), GetUnitY(unit), HEIGHT, SCALE)
                    BlzSetSpecialEffectOrientation(effect, Deg2Rad(GetUnitFacing(unit)), 0, Deg2Rad(GetAngle(sequence[unit])))
                    DestroyEffect(effect)
                    sequence[unit] = 14
                else
                    SetUnitAnimationByIndex(unit, 14)
                    QueueUnitAnimation(unit, "Stand Ready")
                    local effect = AddSpecialEffectEx(CLAW, GetUnitX(unit), GetUnitY(unit), HEIGHT, SCALE)
                    BlzSetSpecialEffectOrientation(effect, Deg2Rad(GetUnitFacing(unit)), 0, Deg2Rad(GetAngle(sequence[unit])))
                    DestroyEffect(effect)
                    sequence[unit] = 13
                end
            end
        end)

        RegisterAttackDamageEvent(function()
            local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if level > 0 then
                UnitDamageCone(Damage.source.unit, Damage.source.x, Damage.source.y, GetUnitFacing(Damage.source.unit), GetArc(level), GetAoE(level), GetEventDamage()*GetDamagePercentage(level), Damage.attacktype, DAMAGE_TYPE_ENHANCED, false, true, false)
            end
        end)
    end)
end