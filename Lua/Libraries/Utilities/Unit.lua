OnInit("Unit", function(requires)
    requires "Class"

    Unit = Class()

    local location = Location(0, 0)

    Unit:property("x", { get = function(self) return GetUnitX(self.unit) end })

    Unit:property("y", { get = function(self) return GetUnitY(self.unit) end })

    Unit:property("z", { get = function(self) 
        MoveLocation(location, GetUnitX(self.unit), GetUnitY(self.unit))
        return GetUnitFlyHeight(self.unit) + GetLocationZ(location)
    end })

    Unit:property("id", { get = function(self) return GetUnitUserData(self.unit) end })

    Unit:property("type", { get = function(self) return GetUnitTypeId(self.unit) end })

    Unit:property("handle", { get = function(self) return GetHandleId(self.unit) end })

    Unit:property("player", { get = function(self) return GetOwningPlayer(self.unit) end })

    Unit:property("armor", { get = function(self) return BlzGetUnitArmor(self.unit) end })

    Unit:property("mana", { get = function(self) return GetUnitState(self.unit, UNIT_STATE_MANA) end })

    Unit:property("health", { get = function(self) return GetWidgetLife(self.unit) end })

    Unit:property("agility", { get = function(self) return GetHeroAgi(self.unit, true) end })

    Unit:property("strength", { get = function(self) return GetHeroStr(self.unit, true) end })

    Unit:property("intelligence", { get = function(self) return GetHeroInt(self.unit, true) end })

    Unit:property("armortype", { get = function(self) return ConvertArmorType(BlzGetUnitIntegerField(self.unit, UNIT_IF_ARMOR_TYPE)) end })

    Unit:property("defensetype", { get = function(self) return ConvertDefenseType(BlzGetUnitIntegerField(self.unit, UNIT_IF_DEFENSE_TYPE)) end })

    Unit:property("isHero", { get = function(self) return IsUnitType(self.unit, UNIT_TYPE_HERO) end })

    Unit:property("isMelee", { get = function(self) return IsUnitType(self.unit, UNIT_TYPE_MELEE_ATTACKER) end })

    Unit:property("isRanged", { get = function(self) return IsUnitType(self.unit, UNIT_TYPE_RANGED_ATTACKER) end })

    Unit:property("isSummoned", { get = function(self) return IsUnitType(self.unit, UNIT_TYPE_SUMMONED) end })

    Unit:property("isStructure", { get = function(self) return IsUnitType(self.unit, UNIT_TYPE_STRUCTURE) end })

    Unit:property("isMagicImmune", { get = function(self) return IsUnitType(self.unit, UNIT_TYPE_MAGIC_IMMUNE) end })

    function Unit:destroy()
        self.unit = nil
    end

    function Unit.create(unit)
        local this = Unit.allocate()

        this.unit = unit

        return this
    end
end)