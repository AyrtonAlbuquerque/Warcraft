OnInit("MagicResistance", function(requires)
    requires "Class"
    requires "Bonus"

    BONUS_MAGIC_RESISTANCE = 0
    BASE_HERO_MAGIC_RESISTANCE = 5

    local MagicResistance = Class(Bonus)
    local USE_DAMAGE = true
    local resistance = {}
    local ability = FourCC('Z00B')
    local field = ABILITY_RLF_DAMAGE_REDUCTION_ISR2

    function MagicResistance:get(unit)
        if USE_DAMAGE then
            if IsUnitType(unit, UNIT_TYPE_HERO) and not resistance[unit] then
                resistance[unit] = (resistance[unit] or 0.) + BASE_HERO_MAGIC_RESISTANCE
            end

            return resistance[unit] or 0.
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, 0)
        end
    end

    function MagicResistance:set(unit, value)
        if USE_DAMAGE then
            resistance[unit] = value

            return value
        else
            if GetUnitAbilityLevel(unit, ability) == 0 then
                UnitAddAbility(unit, ability)
                UnitMakeAbilityPermanent(unit, true, ability)
            end

            if BlzSetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, 0, value) then
                IncUnitAbilityLevel(unit, ability)
                DecUnitAbilityLevel(unit, ability)
            end

            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, 0)
        end
    end

    function MagicResistance:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    function MagicResistance.onInit()
        BONUS_MAGIC_RESISTANCE = RegisterBonus(MagicResistance.allocate())
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function GetUnitMagicResistance(unit)
        return MagicResistance:get(unit)
    end

    function SetUnitMagicResistance(unit, value)
        return MagicResistance:set(unit, value)
    end

    function UnitAddMagicResistance(unit, value)
        return MagicResistance:add(unit, value)
    end
end)