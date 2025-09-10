OnInit("CriticalStrike", function(requires)
    requires "Unit"
    requires "Class"
    requires "Bonus"
    requires.optional "Damage"
    requires.optional "ArcingFloatingText"

    local TEXT_SIZE = 0.02
    local USE_DAMAGE = true
    local ability = FourCC('Z00C')

    local CriticalChance = Class(Bonus)

    CriticalChance.field = ABILITY_RLF_CHANCE_TO_CRITICAL_STRIKE

    function CriticalChance:get(unit)
        if Damage and USE_DAMAGE then
            return GetUnitCriticalChance(unit)
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), CriticalChance.field, 0)
        end
    end

    function CriticalChance:set(unit, value)
        if Damage and USE_DAMAGE then
            return SetUnitCriticalChance(unit, value)
        else
            if GetUnitAbilityLevel(unit, ability) == 0 then
                UnitAddAbility(unit, ability)
                UnitMakeAbilityPermanent(unit, true, ability)
            end

            if BlzSetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), CriticalChance.field, 0, value) then
                IncUnitAbilityLevel(unit, ability)
                DecUnitAbilityLevel(unit, ability)
            end

            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), CriticalChance.field, 0)
        end
    end

    function CriticalChance:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    BONUS_CRITICAL_CHANCE = RegisterBonus(CriticalChance.allocate())

    local CriticalDamage = Class(Bonus)

    CriticalDamage.field = ABILITY_RLF_DAMAGE_MULTIPLIER_OCR2

    function CriticalDamage:get(unit)
        if Damage and USE_DAMAGE then
            return GetUnitCriticalMultiplier(unit)
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), CriticalDamage.field, 0)
        end
    end

    function CriticalDamage:set(unit, value)
        if Damage and USE_DAMAGE then
            return SetUnitCriticalMultiplier(unit, value)
        else
            if value == 0 then
                value = 1
            end

            if GetUnitAbilityLevel(unit, ability) == 0 then
                UnitAddAbility(unit, ability)
                UnitMakeAbilityPermanent(unit, true, ability)
            end

            if BlzSetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), CriticalDamage.field, 0, value) then
                IncUnitAbilityLevel(unit, ability)
                DecUnitAbilityLevel(unit, ability)
            end

            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), CriticalDamage.field, 0)
        end
    end

    function CriticalDamage:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    BONUS_CRITICAL_DAMAGE = RegisterBonus(CriticalDamage.allocate())

    Critical = Class()

    Critical.damage = 0
    Critical.source = Unit.create(nil)
    Critical.target = Unit.create(nil)

    local event = {}
    local chance = {}
    local multiplier = {}

    function Critical.getChance(unit)
        return chance[unit] or 0
    end

    function Critical.getMultiplier(unit)
        return multiplier[unit] or 0
    end

    function Critical.setChance(unit, value)
        chance[unit] = value

        return value
    end

    function Critical.setMultiplier(unit, value)
        multiplier[unit] = value

        return value
    end

    function Critical.add(unit, chance, multiplier)
        Critical.setChance(unit, Critical.getChance(unit) + chance)
        Critical.setMultiplier(unit, Critical.getMultiplier(unit) + multiplier)
    end

    function Critical.register(code)
        if type(code) == "function" then
            table.insert(event, code)
        end
    end

    function Critical.onDamage()
        if Damage and USE_DAMAGE then
            if Damage.amount > 0 and GetRandomReal(0, 1) <= (chance[Damage.source.unit] or 0) and Damage.isEnemy and not Damage.target.isStructure and (multiplier[Damage.source.unit] or 0) > 0 then
                Critical.source.unit = Damage.source.unit
                Critical.target.unit = Damage.target.unit
                Critical.damage = Damage.amount * (1 + (multiplier[Damage.source.unit] or 0))
                Damage.amount = Critical.damage

                for i = 1, #event do
                    event[i]()
                end

                if Critical.damage > 0 then
                    ArcingTextTag.create("|cffff0000" .. N2S(Critical.damage, 0) .. "!|r", Critical.target.unit, TEXT_SIZE)
                end

                Critical.damage = 0
                Critical.source.unit = nil
                Critical.target.unit = nil
            end
        end
    end

    function Critical.onInit()
        if Damage and USE_DAMAGE then
            RegisterAttackDamagingEvent(Critical.onDamage)
        end
    end

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function RegisterCriticalStrikeEvent(code)
        Critical.register(code)
    end

    function GetCriticalSource()
        return Critical.source.unit
    end

    function GetCriticalTarget()
        return Critical.target.unit
    end

    function GetCriticalDamage()
        return Critical.damage
    end

    function GetUnitCriticalChance(unit)
        return Critical.getChance(unit)
    end

    function GetUnitCriticalMultiplier(unit)
        return Critical.getMultiplier(unit)
    end

    function SetUnitCriticalChance(unit, value)
        return Critical.setChance(unit, value)
    end

    function SetUnitCriticalMultiplier(unit, value)
        return Critical.setMultiplier(unit, value)
    end

    function SetCriticalEventDamage(value)
        Critical.damage = value
    end

    function UnitAddCriticalStrike(unit, chance, multiplier)
        Critical.add(unit, chance, multiplier)
    end
end)