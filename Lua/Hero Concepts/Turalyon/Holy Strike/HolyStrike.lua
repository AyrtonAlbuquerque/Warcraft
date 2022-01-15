--[[ requires DamageInterface
    /* ---------------------- Holy Strike v1.2 by Chopinski --------------------- */
    // Credits:
    //     AbstractCreativity - Icon
    //     Bribe              - SpellEffectEvent
    //     Blizzard           - Healing Effect
    /* ----------------------------------- END ---------------------------------- */
]]--

do
    -- -------------------------------------------------------------------------- --
    --                                Configuration                               --
    -- -------------------------------------------------------------------------- --
    -- The Holy Strike level 1 buff
    local BUFF_1       = FourCC('B001')
    -- The Holy Strike level 2 buff
    local BUFF_2       = FourCC('B002')
    -- The Holy Strike level 3 buff
    local BUFF_3       = FourCC('B003')
    -- The Holy Strike level 4 buff
    local BUFF_4       = FourCC('B004')
    -- The Holy Strike heal model
    local MODEL        = "HolyStrike.mdl"
    -- The Holy Strike heal attchment point
    local ATTACH_POINT = "origin"

    -- The Holy Strike Heal
    local function GetHeal(level, isRanged)
        local real heal = 10.*level

        if isRanged then
            heal = heal/2
        end

        return heal
    end

    -- -------------------------------------------------------------------------- --
    --                                   System                                   --
    -- -------------------------------------------------------------------------- --
    onInit(function()
        RegisterAttackDamageEvent(function()
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
        end)
    end)
end