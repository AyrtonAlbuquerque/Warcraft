OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    OrcishAxe = Class(Item)
    OrcishAxe.code = S2A('I02S')

    OrcishAxe:property("damage", { get = function (self) return 28 end })
    OrcishAxe:property("criticalChance", { get = function (self) return 0.12 end })
    OrcishAxe:property("criticalDamage", { get = function (self) return 0.3 end })

    function OrcishAxe.onInit()
        RegisterItem(OrcishAxe.allocate(OrcishAxe.code), IronAxe.code, GoldenSword.code, 0, 0, 0)
    end
end)