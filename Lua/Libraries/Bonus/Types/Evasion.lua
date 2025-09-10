OnInit("Evasion", function(requires)
    requires "Unit"
    requires "Class"
    requires "Bonus"
    requires.optional "Damage"
    requires.optional "ArcingFloatingText"

    local TEXT_SIZE = 0.016
    local USE_DAMAGE = true
    local ability = FourCC('Z00D')
    local field = ABILITY_RLF_CHANCE_TO_EVADE_EEV1

    local Miss = Class(Bonus)

    function Miss:get(unit)
        return GetUnitMissChance(unit)
    end

    function Miss:set(unit, value)
        return SetUnitMissChance(unit, value)
    end

    function Miss:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    BONUS_MISS_CHANCE = RegisterBonus(Miss.allocate())

    local Pierce = Class(Bonus)

    function Pierce:get(unit)
        return GetUnitPierceChance(unit)
    end

    function Pierce:set(unit, value)
        return SetUnitPierceChance(unit, value)
    end

    function Pierce:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    BONUS_PIERCE_CHANCE = RegisterBonus(Pierce.allocate())

    Evasion = Class(Bonus)

    Evasion.damage = 0
    Evasion.source = Unit.create(nil)
    Evasion.target = Unit.create(nil)

    local miss = {}
    local event = {}
    local pierce = {}
    local evasion = {}

    function Evasion:get(unit)
        if Damage and USE_DAMAGE then
            return Evasion.getEvasion(unit)
        else
            return BlzGetAbilityRealLevelField(BlzGetUnitAbility(unit, ability), field, 0)
        end
    end

    function Evasion:set(unit, value)
        if Damage and USE_DAMAGE then
            return Evasion.setEvasion(unit, value)
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

    function Evasion:add(unit, value)
        self:set(unit, self:get(unit) + value)

        return value
    end

    function Evasion.getEvasion(unit)
        return evasion[unit] or 0
    end

    function Evasion.getPierce(unit)
        return pierce[unit] or 0
    end

    function Evasion.getMiss(unit)
        return miss[unit] or 0
    end

    function Evasion.setEvasion(unit, value)
        evasion[unit] = value

        return value
    end

    function Evasion.setPierce(unit, value)
        pierce[unit] = value

        return value
    end

    function Evasion.setMiss(unit, value)
        miss[unit] = value

        return value
    end

    function Evasion.register(code)
        if type(code) == "function" then
            table.insert(event, code)
        end
    end

    function Evasion.onDamage()
        if Damage and USE_DAMAGE then
            if Damage.isAttack and Damage.amount > 0 then
                if (GetRandomReal(0, 1) <= (evasion[Damage.target.unit] or 0) or GetRandomReal(0, 1) <= (miss[Damage.source.unit] or 0)) and GetRandomReal(0, 1) > (pierce[Damage.source.unit] or 0) then
                    Evasion.source.unit = Damage.source.unit
                    Evasion.target.unit = Damage.target.unit
                    Evasion.damage = Damage.amount
                    Damage.amount = 0
                    Damage.process = false
                    Damage.weapontype = WEAPON_TYPE_WHOKNOWS

                    for i = 1, #event do
                        event[i]()
                    end

                    ArcingTextTag.create("|cffff0000miss|r", Evasion.source.unit, TEXT_SIZE)

                    Evasion.damage = 0
                    Evasion.source.unit = nil
                    Evasion.target.unit = nil
                end
            end
        end
    end

    function Evasion.onInit()
        if Damage and USE_DAMAGE then
            RegisterDamageConfigurationEvent(Evasion.onDamage)
        end
    end

    BONUS_EVASION_CHANCE = RegisterBonus(Evasion.allocate())

    -- ----------------------------------------------------------------------------------------- --
    --                                          Lua API                                          --
    -- ----------------------------------------------------------------------------------------- --
    function RegisterEvasionEvent(code)
        Evasion.register(code)
    end

    function GetMissingUnit()
        return Evasion.source.unit
    end

    function GetEvadingUnit()
        return Evasion.target.unit
    end

    function GetEvadedDamage()
        return Evasion.damage
    end

    function GetUnitEvasionChance(unit)
        return Evasion.getEvasion(unit)
    end

    function GetUnitMissChance(unit)
        return Evasion.getMiss(unit)
    end

    function GetUnitPierceChance(unit)
        return Evasion.getPierce(unit)
    end

    function SetUnitEvasionChance(unit, chance)
        return Evasion.setEvasion(unit, chance)
    end

    function SetUnitMissChance(unit, chance)
        return Evasion.setMiss(unit, chance)
    end

    function SetUnitPierceChance(unit, chance)
        return Evasion.setPierce(unit, chance)
    end

    function UnitAddEvasionChance(unit, chance)
        return Evasion.setEvasion(unit, Evasion.getEvasion(unit) + chance)
    end

    function UnitAddMissChance(unit, chance)
        return Evasion.setMiss(unit, Evasion.getMiss(unit) + chance)
    end

    function UnitAddPierceChance(unit, chance)
        return Evasion.setPierce(unit, Evasion.getPierce(unit) + chance)
    end
end)