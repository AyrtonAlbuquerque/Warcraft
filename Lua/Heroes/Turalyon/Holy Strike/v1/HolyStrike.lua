OnInit("HolyStrike", function (requires)
    requires "Class"
    requires "Spell"
    requires "Damage"
    requires "Utilities"

    -- ----------------------------- Holy Strike v1.3 by Chopinski ----------------------------- --

    -- ----------------------------------------------------------------------------------------- --
    --                                       Configuration                                       --
    -- ----------------------------------------------------------------------------------------- --
    -- The Holy Strike ablity
    local ABILITY      = S2A('Trl4')
    -- The Holy Strike level 1 buff
    local BUFF_1       = S2A('BTr0')
    -- The Holy Strike level 2 buff
    local BUFF_2       = S2A('BTr1')
    -- The Holy Strike level 3 buff
    local BUFF_3       = S2A('BTr2')
    -- The Holy Strike level 4 buff
    local BUFF_4       = S2A('BTr3')
    -- The Holy Strike heal model
    local MODEL        = "HolyStrike.mdl"
    -- The Holy Strike heal attchment point
    local ATTACH_POINT = "origin"

    -- The Holy Strike Heal
    local function GetHeal(level, isRanged)
        local heal = 20.*level

        if isRanged then
            heal = heal/2
        end

        return heal
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                           System                                          --
    -- ----------------------------------------------------------------------------------------- --
    do
        HolyStrike = Class(Spell)

        function HolyStrike.onDamage()
            if Damage.isEnemy then
                if GetUnitAbilityLevel(Damage.source.unit, BUFF_4) > 0 then
                    SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + GetHeal(4, Damage.source.isRanged))
                    DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.source.unit, ATTACH_POINT))
                elseif GetUnitAbilityLevel(Damage.source.unit, BUFF_3) > 0 then
                    SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + GetHeal(3, Damage.source.isRanged))
                    DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.source.unit, ATTACH_POINT))
                elseif GetUnitAbilityLevel(Damage.source.unit, BUFF_2) > 0 then
                    SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + GetHeal(2, Damage.source.isRanged))
                    DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.source.unit, ATTACH_POINT))
                elseif GetUnitAbilityLevel(Damage.source.unit, BUFF_1) > 0 then
                    SetWidgetLife(Damage.source.unit, GetWidgetLife(Damage.source.unit) + GetHeal(1, Damage.source.isRanged))
                    DestroyEffect(AddSpecialEffectTarget(MODEL, Damage.source.unit, ATTACH_POINT))
                end
            end
        end

        function HolyStrike.onInit()
            RegisterSpell(HolyStrike.allocate(), ABILITY)
            RegisterAttackDamageEvent(HolyStrike.onDamage)
        end
    end
end)