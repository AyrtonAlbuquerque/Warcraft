OnInit("RippingClaws", function (requires)
    requires "Class"
    requires "Damage"
    requires "Utilities"
    requires "RegisterPlayerUnitEvent"

    -- ---------------------------- Ripping Claws v1.0 by Chopinski ---------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The raw code of the ability
    local ABILITY = S2A('Rex7')
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

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        RippingClaws = Class()

        local sequence = {}

        function RippingClaws.onDamage()
            local level = GetUnitAbilityLevel(Damage.source.unit, ABILITY)

            if level > 0 then
                UnitDamageCone(Damage.source.unit, Damage.source.x, Damage.source.y, GetUnitFacing(Damage.source.unit), GetArc(level), GetAoE(level), GetEventDamage()*GetDamagePercentage(level), Damage.attacktype, DAMAGE_TYPE_ENHANCED, false, true, false)
            end
        end

        function RippingClaws.onAttack()
            local source = GetAttacker()
            local level = GetUnitAbilityLevel(source, ABILITY)

            if level > 0 then
                if sequence[source] == 13 then
                    SetUnitAnimationByIndex(source, 13)
                    QueueUnitAnimation(source, "Stand Ready")
                    local effect = AddSpecialEffectEx(CLAW, GetUnitX(source), GetUnitY(source), HEIGHT, SCALE)
                    BlzSetSpecialEffectOrientation(effect, Deg2Rad(GetUnitFacing(source)), 0, Deg2Rad(GetAngle(sequence[source])))
                    DestroyEffect(effect)
                    sequence[source] = 14
                else
                    SetUnitAnimationByIndex(source, 14)
                    QueueUnitAnimation(source, "Stand Ready")
                    local effect = AddSpecialEffectEx(CLAW, GetUnitX(source), GetUnitY(source), HEIGHT, SCALE)
                    BlzSetSpecialEffectOrientation(effect, Deg2Rad(GetUnitFacing(source)), 0, Deg2Rad(GetAngle(sequence[source])))
                    DestroyEffect(effect)
                    sequence[source] = 13
                end
            end
        end

        function RippingClaws.onInit()
            RegisterPlayerUnitEvent(EVENT_PLAYER_UNIT_ATTACKED, RippingClaws.onAttack)
            RegisterAttackDamageEvent(RippingClaws.onDamage)
        end
    end
end)