OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    RedemptionSword = Class(Item)
    RedemptionSword.code = S2A('I090')

    RedemptionSword:property("damage", { get = function (self) return 1500 end })
    RedemptionSword:property("criticalChance", { get = function (self) return 0.3 end })
    RedemptionSword:property("criticalDamage", { get = function (self) return 3 end })
    RedemptionSword:property("spellPower", { get = function (self) return 300 end })

    function RedemptionSword.onInit()
        RegisterItem(RedemptionSword.allocate(RedemptionSword.code), SphereOfDivinity.code, Doombringer.code, 0, 0, 0)
    end
end)