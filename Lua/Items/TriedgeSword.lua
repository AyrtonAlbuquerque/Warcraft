OnInit(function(requires)
    requires "Class"
    requires "Item"
    requires "Utilities"

    TriedgeSword = Class(Item)
    TriedgeSword.code = S2A('I076')

    TriedgeSword:property("damage", { get = function (self) return 100 end })
    TriedgeSword:property("criticalDamage", { get = function (self) return 1 end })
    TriedgeSword:property("criticalChance", { get = function (self) return 0.1 end })

    function TriedgeSword.onInit()
        RegisterItem(TriedgeSword.allocate(TriedgeSword.code), OrcishAxe.code, KnightBlade.code, 0, 0, 0)
    end
end)